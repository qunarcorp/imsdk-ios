//
//  QIMVoiceOperator.m
//  AudioTempForQT
//
//  Created by danzheng on 15/4/21.
//  Copyright (c) 2015年 fresh. All rights reserved.
//

#import "QIMVoiceOperator.h"
#import "QIMPathManage.h"
//#define MAX_AUDIO_RECODE_TIME 10.0
#define MIN_TIMEOUT 1.0f            //最短录音时间长度

@interface QIMVoiceOperator ()<AVAudioRecorderDelegate> {
    CGFloat     _timeCount;             //用于记录时长
    NSTimer     *_timer;                //用于更新峰值
    BOOL        _ifSave;                //是否保存
}

@property (nonatomic, retain)   AVAudioRecorder     *recoder;
@property (nonatomic, retain)   NSString            *filePath;
@property (nonatomic, retain)   NSString            *fileName;

@end

@implementation QIMVoiceOperator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fileName = [[NSString alloc] init];
        _filePath = [[NSString alloc] init];
        _ifSave = YES;
    }
    return self;
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

//开始录制音频，存储于filename，录音成功后返回音频存储路径和录音时间
- (void)doVoiceRecordByFilename:(NSString *)filename
{
    if (![self canRecord]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:[NSString stringWithFormat:@"%@需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风", [QIMKit getQIMProjectTitleName]]
                                   delegate:nil
                          cancelButtonTitle:@"好"
                          otherButtonTitles:nil] show];
        return;
    }
    NSError *error=nil;
    _fileName = [NSString stringWithString:filename];
    _filePath = [QIMPathManage getPathByFileName:_fileName ofType:@"wav"];
    _recoder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:_filePath]
                                           settings:[QIMVoiceOperator getAudioRecorderSettingDic]
                                              error:&error];
//    QIMVerboseLog(@"recoder path == %@",_filePath);
    if (error) {
        QIMVerboseLog(@"recoder init error: %@", error);
    }
    _recoder.delegate = self;
    _recoder.meteringEnabled = YES;             //监控声波
    [_recoder prepareToRecord];
    //初始化计时器
    _timeCount = 0;
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [_recoder record];
    
    [self startTimer];
}

//结束音频录制
- (void)finishRecoderWithSave:(BOOL)ifSave
{
    [self stopTimer];
    if (_recoder.isRecording) {
        [_recoder stop];
    }
    _ifSave = ifSave;
}

#pragma mark --codes 不在类外使用
#pragma mark -code 关于timer
- (void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateTheMeters) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}


//定期更新峰值
- (void)updateTheMeters
{
    if (_recoder.isRecording) {
        [_recoder updateMeters];
        //取得第一个通道的音频，音频强度范围是－160到0
        float power = [_recoder averagePowerForChannel:0];
        //在此处应该通知录音界面更新声音强度
        [_voiceOperatorDelegate updateVoiceViewHeightWithPower:power+160.0];
        

//        if (_timeCount >= MAX_AUDIO_RECODE_TIME-10 && _timeCount < MAX_AUDIO_RECODE_TIME) {
//            //在此处通知录音界面要进行剩余时间提醒
//            float remainTime = MAX_AUDIO_RECODE_TIME - _timeCount;
//            [_voiceOperatorDelegate updateViewToAlertUserWithRemainTime:remainTime];
//        } else if (_timeCount >= MAX_AUDIO_RECODE_TIME) {
//            //在此处通知录音界面进行录音时间停止的提醒，同时停止录音
//            [self finishRecoder];
//        }

        _timeCount += 0.1f;
    }
}

#pragma mark -AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    //录音完成，返回音频存储路径和录音时间
    NSURL *audioFileURL = [NSURL fileURLWithPath:_filePath];
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:audioFileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    if (audioDurationSeconds < MIN_TIMEOUT || !_ifSave) {
        //录音时间太短||用户取消录音,删除文件，并通知delegate
        [QIMPathManage deleteFileAtPath:_filePath];
        [_voiceOperatorDelegate voiceOperatorFinishedRecordWithFilepath:nil andFilename:nil andTimeCount:audioDurationSeconds];
    } else {
        [_voiceOperatorDelegate voiceOperatorFinishedRecordWithFilepath:_filePath andFilename:_fileName andTimeCount:audioDurationSeconds];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    QIMVerboseLog(@"error:%@",error);
}

#pragma mark --类方法

+ (NSDictionary *)getAudioRecorderSettingDic
{
    //依次设置采样率、音频格式、采样位数（默认16）、通道的数目
    NSMutableDictionary * recordSettingDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [recordSettingDic setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    [recordSettingDic setObject:[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];
    [recordSettingDic setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSettingDic setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSettingDic setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSettingDic setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    return recordSettingDic;
}

@end
