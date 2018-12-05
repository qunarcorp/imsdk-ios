//
//  QIMVoiceChatView.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/13.
//
//

#define kVoiceBtnWidth 107
#define kAuditionBtnMaxWidth 80
#define kAuditionBtnMinWidth 50
#define kDelBtnMaxWidth 80
#define kDelBtnMinWidth 50
#define kAuditionBtnCenter CGPointMake(50, 50)
#define kDelBtnCenter CGPointMake(self.width - 50, 50)

#import "QIMVoiceChatView.h"
#import "QIMRemoteAudioPlayer.h"
#import "QIMVoiceGoalBar.h"
#import "QIMTextBar.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMVoiceChatView ()
{
    UIButton            * _voiceBtn;//录音按钮
    UIButton            * _auditionBtn;//试听按钮
    UIButton            * _delBtn;//删除按钮
    UIButton            * _cancelBtn;//取消按钮
    UIButton            * _sendBtn;//发送按钮
    UILabel             * _timeLabel;//显示时间
    
    VoiceBtnStatus        _voiceBtnStatus;
    QIMRemoteAudioPlayer   * _remoteAudioPlayer;
    BOOL                  _canPlaying;
    BOOL                  _canRecording;
    
    QIMVoiceGoalBar        * _voiceGoalBar;
    
    float                 _recordingSeconds;
    BOOL                  _timeLabelDisplayTime;
    BOOL                  _idleTimerDisabled;
}

@end

@implementation QIMVoiceChatView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor qim_colorWithHex:0xebecef alpha:1];
        
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceBtn.frame = CGRectMake(frame.size.width / 2 - kVoiceBtnWidth / 2, frame.size.height / 2 - kVoiceBtnWidth / 2 - 15, kVoiceBtnWidth, kVoiceBtnWidth);
        [_voiceBtn setAccessibilityIdentifier:@"recordVoiceBtn"];
        [_voiceBtn setImage:[UIImage imageNamed:@"aio_voice_button_icon"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"aio_voice_button_icon"] forState:UIControlStateHighlighted];
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_button_nor"] forState:UIControlStateNormal];
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_button_press"] forState:UIControlStateHighlighted];
//        [_voiceBtn setBackgroundColor: [UIColor colorWithRed:92/255.0 green:197/255.0 blue:127/255.0 alpha:1/1.0]];
        [_voiceBtn addTarget:self action:@selector(recordBtnHandleForStart:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_voiceBtn addTarget:self action:@selector(recordBtnHandle:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
        [_voiceBtn addTarget:self action:@selector(recordBtnHandleForEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_voiceBtn addTarget:self action:@selector(recordBtnHandleForCancel:withEvent:) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:_voiceBtn];
        _voiceBtnStatus = VoiceBtnStatusNomal;
        
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _voiceBtn.top - 30, self.width, 20)];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"按住说话";
        [self addSubview:_timeLabel];
        _timeLabelDisplayTime = NO;
        
        _auditionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _auditionBtn.hidden = YES;
        [_auditionBtn setImage:[UIImage imageNamed:@"aio_voice_operate_listen_nor"] forState:UIControlStateNormal];
        [_auditionBtn setImage:[UIImage imageNamed:@"aio_voice_operate_listen_press"] forState:UIControlStateSelected];
        [_auditionBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_operate_nor"] forState:UIControlStateNormal];
        [_auditionBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_operate_press"] forState:UIControlStateSelected];
        [self addSubview:_auditionBtn];
        
        _delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _delBtn.hidden = YES;
        [_delBtn setImage:[UIImage imageNamed:@"aio_voice_operate_delete_nor"] forState:UIControlStateNormal];
        [_delBtn setImage:[UIImage imageNamed:@"aio_voice_operate_delete_press"] forState:UIControlStateSelected];
        [_delBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_operate_nor"] forState:UIControlStateNormal];
        [_delBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_operate_press"] forState:UIControlStateSelected];
        [self addSubview:_delBtn];
        
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setBackgroundColor:[UIColor whiteColor]];
        [_cancelBtn setTitleColor:[UIColor qim_colorWithHex:0x1da4e9 alpha:1] forState:UIControlStateNormal];
        _cancelBtn.frame = CGRectMake(- 0.5, self.height - 40, self.width / 2, 40);
        _cancelBtn.hidden = YES;
        [_cancelBtn addTarget:self action:@selector(cancelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelBtn];
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_send"] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor whiteColor]];
        [_sendBtn setTitleColor:[UIColor qim_colorWithHex:0x1da4e9 alpha:1] forState:UIControlStateNormal];
        _sendBtn.frame = CGRectMake(self.width / 2 + 0.5, self.height - 40, self.width / 2, 40);
        _sendBtn.hidden = YES;
        [_sendBtn addTarget:self action:@selector(sendBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendBtn];
    }
    return self;
}


- (void)recordBtnHandle:(UIButton * )btn withEvent:(UIEvent *)ev
{
    if (_voiceBtnStatus == VoiceBtnStatusAuditionStart || _voiceBtnStatus == VoiceBtnStatusAuditionStop) {
        return;
    }
    UITouch *touch = [[ev allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
//    QIMVerboseLog(@"Touch x : %f y : %f", touchPoint.x, touchPoint.y);
    
    float auditionLength = [self lengthBetweenPoint:_voiceBtn.center withPoint:_auditionBtn.center] - kVoiceBtnWidth / 2;
    
    float delLength = [self lengthBetweenPoint:_voiceBtn.center withPoint:_delBtn.center] - kVoiceBtnWidth / 2;
    
    float currentLength = [self lengthBetweenPoint:touchPoint withPoint:_auditionBtn.center];
    
    if (currentLength < auditionLength) {
        _auditionBtn.frame = CGRectMake(0, 0, kAuditionBtnMinWidth + (auditionLength - currentLength) / auditionLength * (kAuditionBtnMaxWidth - kAuditionBtnMinWidth), kAuditionBtnMinWidth + (auditionLength - currentLength) / auditionLength * (kAuditionBtnMaxWidth - kAuditionBtnMinWidth));
        _auditionBtn.center = kAuditionBtnCenter;
    }
    if (currentLength < _auditionBtn.width / 2) {
        _auditionBtn.selected = YES;
        _timeLabel.text = @"松手试听";
        _timeLabelDisplayTime = NO;
    }else{
        _auditionBtn.selected = NO;
        _timeLabelDisplayTime = YES;
    }
    
    currentLength = [self lengthBetweenPoint:touchPoint withPoint:_delBtn.center];
    
    if (currentLength < delLength) {
        _delBtn.frame = CGRectMake(0, 0, kDelBtnMinWidth + (delLength - currentLength) / delLength * (kDelBtnMaxWidth - kDelBtnMinWidth), kDelBtnMinWidth + (delLength - currentLength) / delLength * (kDelBtnMaxWidth - kDelBtnMinWidth));
        _delBtn.center = kDelBtnCenter;
    }
    if (currentLength < _delBtn.width / 2) {
        _delBtn.selected = YES;
        _timeLabel.text = @"松手取消发送";
        _timeLabelDisplayTime = NO;
    }else{
        _delBtn.selected = NO;
    }
    
    [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_button_press"] forState:UIControlStateNormal];
}

- (void)recordBtnHandleForStart:(UIButton * )btn withEvent:(UIEvent *)ev
{
    if (_voiceBtnStatus == VoiceBtnStatusAuditionStart || _voiceBtnStatus == VoiceBtnStatusAuditionStop) {
        return;
    }
    
    _idleTimerDisabled = [[UIApplication sharedApplication] isIdleTimerDisabled];
    if (_idleTimerDisabled == NO) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    
    _auditionBtn.hidden = NO;
    _delBtn.hidden = NO;
    
    _recordingSeconds = 0;
    _timeLabelDisplayTime = YES;
    _canRecording = YES;
    [self recordingRefresh];
    
    _auditionBtn.frame = CGRectMake(0, 0, kAuditionBtnMinWidth, kAuditionBtnMinWidth);
    _auditionBtn.center = kAuditionBtnCenter;
    
    _delBtn.frame = CGRectMake(0, 0, kDelBtnMinWidth, kDelBtnMinWidth);
    _delBtn.center = kDelBtnCenter;
    
    _voiceBtnStatus = VoiceBtnStatusRecording;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceChatView:RecordingAtStatus:)]) {
        [self.delegate voiceChatView:self RecordingAtStatus:VoiceChatRecordingStatusStart];
    }
}

- (void)recordBtnHandleForEnd:(UIButton * )btn withEvent:(UIEvent *)ev
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:_idleTimerDisabled];
    if (_voiceBtnStatus == VoiceBtnStatusAuditionStart || _voiceBtnStatus == VoiceBtnStatusAuditionStop) {
        UITouch *touch = [[ev allTouches] anyObject];
        CGPoint touchPoint = [touch locationInView:_voiceBtn];
//        QIMVerboseLog(@"Touch x : %f y : %f", touchPoint.x, touchPoint.y);
        if (touchPoint.y < 0) {
            return;
        }else{
            //试听 播放
            if (_voiceBtnStatus == VoiceBtnStatusAuditionStart) {
                _voiceBtnStatus = VoiceBtnStatusAuditionStop;
                [_voiceBtn setImage:[UIImage imageNamed:@"aio_record_stop_nor"] forState:UIControlStateNormal];
                [_voiceBtn setImage:[UIImage imageNamed:@"aio_record_stop_press"] forState:UIControlStateHighlighted];
                if (self.delegate && [self.delegate respondsToSelector:@selector(playCurrentVoice)]) {
                     _remoteAudioPlayer = [(QIMTextBar *)self.delegate playCurrentVoice];

                }
                _canPlaying = YES;
                [self playingRefresh];
                [_voiceGoalBar setPercent:0 animated:NO];
            }else if(_voiceBtnStatus == VoiceBtnStatusAuditionStop){
                _voiceBtnStatus = VoiceBtnStatusAuditionStart;
                [_voiceBtn setImage:[UIImage imageNamed:@"aio_record_play_nor"] forState:UIControlStateNormal];
                [_voiceBtn setImage:[UIImage imageNamed:@"aio_record_play_press"] forState:UIControlStateHighlighted];
                if (self.delegate && [self.delegate respondsToSelector:@selector(stopCurrentVoice)]) {
                    [(QIMTextBar *)self.delegate stopCurrentVoice];
                    NSTimeInterval timeout = [(QIMTextBar *)self.delegate getCurrentVoiceTimeout];

                    int minutes = (int)(timeout / 60);
                    int second = fmod(timeout, 60);
                    _timeLabel.text = [NSString stringWithFormat:@"%d:%02d",minutes,second];
                    _timeLabelDisplayTime = YES;
                }
            }
            
            
            return;
        }
    }
    
    UITouch *touch = [[ev allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
//    QIMVerboseLog(@"Touch x : %f y : %f", touchPoint.x, touchPoint.y);
    _auditionBtn.hidden = YES;
    _delBtn.hidden = YES;
    
    _voiceBtnStatus = VoiceBtnStatusNomal;
    
    _canRecording = NO;
    [self recordingRefresh];
    float currentLength = [self lengthBetweenPoint:touchPoint withPoint:_auditionBtn.center];
    //试听
    if (currentLength < _auditionBtn.width / 2) {
        
        _timeLabelDisplayTime = YES;
        [self recordingRefresh];
        
        _voiceBtnStatus = VoiceBtnStatusAuditionStart;
        
        _cancelBtn.hidden = NO;
        _sendBtn.hidden = NO;
        
        [_voiceBtn setImage:[UIImage imageNamed:@"aio_record_play_nor"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"aio_record_play_press"] forState:UIControlStateHighlighted];
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"aio_record_finish_button"] forState:UIControlStateNormal];
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"aio_record_finish_button"] forState:UIControlStateHighlighted];
        if (self.delegate && [self.delegate respondsToSelector:@selector(voiceChatView:RecordingAtStatus:)]) {
            [self.delegate voiceChatView:self RecordingAtStatus:VoiceChatRecordingStatusAudition];
        }
    }else{
        [self resetVoiceBtn];
        currentLength = [self lengthBetweenPoint:touchPoint withPoint:_delBtn.center];
        //删除
        if (currentLength < _delBtn.width / 2) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(voiceChatView:RecordingAtStatus:)]) {
                [self.delegate voiceChatView:self RecordingAtStatus:VoiceChatRecordingStatusCancel];
            }
        }
        //直接发送
        else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(voiceChatView:RecordingAtStatus:)]) {
                [self.delegate voiceChatView:self RecordingAtStatus:VoiceChatRecordingStatusEnd];
            }
        }
    }
    
}

- (void)recordBtnHandleForCancel:(UIButton * )btn withEvent:(UIEvent *)ev
{
    if (_voiceBtnStatus == VoiceBtnStatusAuditionStart || _voiceBtnStatus == VoiceBtnStatusAuditionStop) {
        return;
    }
    _auditionBtn.hidden = YES;
    _delBtn.hidden = YES;
    [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_button_nor"] forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceChatView:RecordingAtStatus:)]) {
        [self.delegate voiceChatView:self RecordingAtStatus:VoiceChatRecordingStatusCancel];
    }
}

- (float)lengthBetweenPoint:(CGPoint) startPoint withPoint:(CGPoint) endPoint
{
    return sqrtf((startPoint.x - endPoint.x) * (startPoint.x - endPoint.x) + (startPoint.y - endPoint.y) * (startPoint.y - endPoint.y));
}

- (void)stopPlayVoice
{
    _voiceBtnStatus = VoiceBtnStatusAuditionStart;
    [_voiceBtn setImage:[UIImage imageNamed:@"aio_record_play_nor"] forState:UIControlStateNormal];
    [_voiceBtn setImage:[UIImage imageNamed:@"aio_record_play_press"] forState:UIControlStateHighlighted];
    [self playingRefresh];
    _canPlaying = NO;
    _voiceGoalBar.hidden = YES;
}

- (void)cancelBtnHandle:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceChatView:RecordingAtStatus:)]) {
        [self.delegate voiceChatView:self RecordingAtStatus:VoiceChatRecordingStatusCancel];
    }
    _cancelBtn.hidden = YES;
    _sendBtn.hidden = YES;
    [self resetVoiceBtn];
}


- (void)sendBtnHandle:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceChatView:RecordingAtStatus:)]) {
        [self.delegate voiceChatView:self RecordingAtStatus:VoiceChatRecordingStatusSend];
    }
    _cancelBtn.hidden = YES;
    _sendBtn.hidden = YES;
    [self resetVoiceBtn];
}

- (void)playingRefresh
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playingRefresh) object:nil];
    if (_canPlaying) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(getCurrentVoiceTimeout)]) {
//            NSTimeInterval timeout = [(IMTextBar *)self.delegate getCurrentVoiceTimeout];
            NSTimeInterval timeout = [(QIMTextBar *)self.delegate getCurrentVoiceTimeout];

            if (!_voiceGoalBar) {
                _voiceGoalBar = [[QIMVoiceGoalBar alloc]initWithFrame:CGRectMake(0, 0, kVoiceBtnWidth, kVoiceBtnWidth)];
                [_voiceBtn addSubview:_voiceGoalBar];
                _voiceGoalBar.userInteractionEnabled = NO;
            }else{
                _voiceGoalBar.hidden = NO;
            }
            [_voiceGoalBar setPercent:(int)(_remoteAudioPlayer.currentTime / timeout * 100) animated:NO];
            
            NSInteger minutes = (NSInteger)(_remoteAudioPlayer.currentTime / 60);
//            QIMVerboseLog(@"_remoteAudioPlayer===%lf", _remoteAudioPlayer.currentTime);
            int second = fmod(_remoteAudioPlayer.currentTime, 60);
            _timeLabel.text = [NSString stringWithFormat:@"%ld:%02d",(long)minutes,second];
        }
        [self performSelector:@selector(playingRefresh) withObject:nil afterDelay:0.5];
    }else{
        [_voiceGoalBar setPercent:0 animated:NO];
    }
}

- (void)recordingRefresh
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recordingRefresh) object:nil];
    if (_canRecording) {
        if (_timeLabelDisplayTime) {
            int minutes = (int)(_recordingSeconds / 60);
            int second = fmod(_recordingSeconds, 60);
            _timeLabel.text = [NSString stringWithFormat:@"%d:%02d",minutes,second];
//            QIMVerboseLog(@"_recordingSeconds====%lf", _recordingSeconds);
        }
        _recordingSeconds += 0.1;
        [self performSelector:@selector(recordingRefresh) withObject:nil afterDelay:0.1];
    }
    
}

- (void)resetVoiceBtn
{
    [_voiceBtn setImage:[UIImage imageNamed:@"aio_voice_button_icon"] forState:UIControlStateNormal];
    [_voiceBtn setImage:[UIImage imageNamed:@"aio_voice_button_icon"] forState:UIControlStateHighlighted];
    [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_button_nor"] forState:UIControlStateNormal];
    [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"aio_voice_button_press"] forState:UIControlStateHighlighted];
    _voiceBtnStatus = VoiceBtnStatusNomal;
    
    _timeLabel.text = @"按住说话";
    
    _canPlaying = NO;
    [self playingRefresh];
    _voiceGoalBar.hidden = YES;
    [_remoteAudioPlayer stop];
}

@end
