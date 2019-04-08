//
//  QIMMessageBrowserVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/2.
//
//

#import "QIMMessageBrowserVC.h"

//#import "NSAttributedString+Attributes.h"

#import "QIMSingleChatVoiceCell.h"

#import "QIMRemoteAudioPlayer.h"
#import "QIMTextContainer.h"

#import "QIMAttributedLabel.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMMessageParser.h"

@interface QIMMessageBrowserVC ()<QIMRemoteAudioPlayerDelegate,QIMSingleChatVoiceCellDelegate,QIMMsgBaloonBaseCellDelegate,QIMMWPhotoBrowserDelegate>{
    
    UIScrollView *_scrollView;
    
    QIMAttributedLabel *_msgLabel;
    
    QIMSingleChatVoiceCell * _voiceCell;
    UIImageView         * _voiceFireBGView;
    UIImageView         * _voiceView;
    UIImageView         * _voicePlayView;
    UILabel             * _voicePressBGView;
    UILabel             * _voicePressView;
    NSUInteger            _voiceTime;
    
    float _currentDownloadProcess;
    NSString *_currentPlayVoiceMsgId;
    QIMRemoteAudioPlayer *_remoteAudioPlayer;
    
    BOOL        _isPlaying;
    
    NSTimer * _timer;
    NSUInteger   _timeCount;
    UILabel  * _timeDisplayLabel;
    QIMMWPhotoBrowser *_browser;
}
@property (nonatomic, assign) BOOL isVoice;
@end

@implementation QIMMessageBrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:self.message.messageDirection == MessageDirection_Sent ? [UIColor qim_rightBallocColor] : [UIColor qim_leftBallocColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidLoaded:) name:@"refreshTableView" object:nil];
    
    switch (self.message.messageType) {
        case QIMMessageType_Text:
        {
            _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            [_scrollView setShowsHorizontalScrollIndicator:NO];
            [_scrollView setShowsVerticalScrollIndicator:YES];
            [self.view addSubview:_scrollView];
            [self refreshUI];
        }
            break;
        case QIMMessageType_Image:
        {
            //初始化图片浏览控件
            _browser = [[QIMMWPhotoBrowser alloc] initWithDelegate:self];
            _browser.displayActionButton = YES;
            _browser.zoomPhotosToFill = YES;
            _browser.enableSwipeToDismiss = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            _browser.wantsFullScreenLayout = YES;
#endif
            [self.view addSubview:_browser.view];
        }
            break;
        case QIMMessageType_Voice:
        {
            [self setIsVoice:YES];
            [self setUpVoiceCell];
        }
            break;
        default:
            break;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - QIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser
{
    return 1;
}

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    NSString *urlStr = self.message.message;
    if (![urlStr qim_hasPrefixHttpHeader]) {
        urlStr = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingPathComponent:urlStr];
    }
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return url?[[QIMMWPhoto alloc] initWithURL:url]:nil;
    
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser
{
   
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_remoteAudioPlayer stop];
    if (_timer) {
        [_timer invalidate];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (!self.isVoice) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
        }
        _timeCount = 0;
        [_timer fire];
//    }
}

- (void)timerHandle:(NSTimer *)sender
{
    if (self.isVoice && _isPlaying) {
        _voicePressView.frame = CGRectMake(_voicePlayView.right + 10, _voicePlayView.top + 9, (self.view.width - 40 - _voicePlayView.width) * (_timeCount * 1.0 / _voiceTime), 3);
    }
    int maxTime = 5;
    if (self.message.messageType == QIMMessageType_Image) {
        maxTime = 30;
    }
    if (_timeCount == maxTime) {
        if (self.isVoice && _isPlaying == NO) {
            _timeDisplayLabel.text = nil;
            [self playVoice];
        }else{
            [_timer invalidate];
            
            [self onClose];
        }
    }else{
        if (!_timeDisplayLabel) {
            _timeDisplayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.width, 50)];
            [_timeDisplayLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            _timeDisplayLabel.textColor = [UIColor redColor];
            _timeDisplayLabel.font = [UIFont boldSystemFontOfSize:17];
            _timeDisplayLabel.textAlignment = NSTextAlignmentCenter;
            _timeDisplayLabel.numberOfLines = 2;
            [self.view addSubview:_timeDisplayLabel];
        }
        if (self.isVoice && _isPlaying == NO) {
            _timeDisplayLabel.text = [NSString stringWithFormat:@"点击任何地方开始播放\n将在 %@s 后自动播放...",@(maxTime - _timeCount)];
        }else if(self.isVoice == NO){
            _timeDisplayLabel.text = [NSString stringWithFormat:@"该窗口将在 %@s 后关闭...",@(maxTime - _timeCount)];
        }
    }
    _timeCount ++;
}

-(void)dealloc{
    _remoteAudioPlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshUI
{
    QIMTextContainer * container = [QIMMessageParser textContainerForMessage:self.message fromCache:NO];
    _msgLabel = [[QIMAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _msgLabel.textContainer = container;
    [_msgLabel setSize:[container getSuggestedSizeWithFramesetter:nil width:container.textWidth]];
    
    if (_msgLabel.height < _scrollView.height - 20) {
        [_msgLabel setTop:([_scrollView height] - _msgLabel.height)/2.0];
    }
    if (_msgLabel.width < _scrollView.width - 20) {
        [_msgLabel setLeft:([_scrollView width] - _msgLabel.width)/2.0];
    }
    _msgLabel.backgroundColor = [UIColor clearColor];
    //    _msgLabel.delegate = self;
    [_scrollView addSubview:_msgLabel];
    [_scrollView setContentSize:CGSizeMake(_msgLabel.width, _msgLabel.height+20)];
    
}

- (void)setUpVoiceCell
{
//    _voiceCell = [[QIMSingleChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//    [_voiceCell setFrameWidth:self.view.frame.size.width];
//    [_voiceCell setDelegate:self];
//    [_voiceCell setMessage:self.message];
//    _voiceCell.isGroupVoice = NO;
//    [_voiceCell refreshUI];
//    _voiceCell.frame = CGRectMake(0, (self.view.height - [QIMSingleChatVoiceCell getCellHeightWihtMessage:self.message chatType:self.message.messageSaveType]) / 2, self.view.width, 100);
//    [self.view addSubview:_voiceCell];
    
    _voiceFireBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    _voiceFireBGView.center = self.view.center;
    _voiceFireBGView.image = [UIImage imageNamed:@"VoiceFire"];
    _voiceFireBGView.userInteractionEnabled = YES;
    [self.view addSubview:_voiceFireBGView];
    
    _voiceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    _voiceView.center = _voiceFireBGView.center;
    _voiceView.image = [UIImage imageNamed:@"iconfont-icon_voice"];
//    [self.view insertSubview:_voiceView aboveSubview:_voiceFireBGView];
    
    NSArray * receiveImageArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"Chat_VoiceBubble_Friend_Icon1"],[UIImage imageNamed:@"Chat_VoiceBubble_Friend_Icon2"],[UIImage imageNamed:@"Chat_VoiceBubble_Friend_Icon3"],[UIImage imageNamed:@"Chat_VoiceBubble_Friend_Icon4"], nil];
    _voicePlayView = [[UIImageView alloc] initWithFrame:CGRectMake(20, _voiceFireBGView.bottom + 100, 20, 20)];
    [_voicePlayView setImage:[UIImage imageNamed:@"Chat_VoiceBubble_Friend_Icon1"]];
    [_voicePlayView setAnimationImages:receiveImageArray];
    [_voicePlayView setAnimationDuration:1];
    [self.view addSubview:_voicePlayView];
    
    
    _voicePressBGView = [[UILabel alloc] initWithFrame:CGRectMake(_voicePlayView.right + 10, _voicePlayView.top + 9, self.view.width - 40 - _voicePlayView.width, 3)];
    _voicePressBGView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_voicePressBGView];
    
    _voicePressView = [[UILabel alloc] initWithFrame:CGRectZero];
    _voicePressView.backgroundColor = [UIColor spectralColorBlueColor];
    [self.view addSubview:_voicePressView];
    
    _remoteAudioPlayer = [[QIMRemoteAudioPlayer alloc] init];
    
    [_remoteAudioPlayer setDelegate:self];
}

- (void)playVoice
{
    if (!_isPlaying) {
        _isPlaying = YES;
        NSDictionary *infoDic = [self.message getMsgInfoDic];
        NSString *fileName = [infoDic objectForKey:@"FileName"];
        NSString *httpUrl = [infoDic objectForKey:@"HttpUrl"];
        _voiceTime = [[infoDic objectForKey:@"Seconds"] integerValue];
        [self playVoiceWithMsgId:self.message.messageId WithFileName:fileName andVoiceUrl:httpUrl];
        [_voicePlayView startAnimating];
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
        }
        _timeCount = 0;
        [_timer fire];
    }else{
        _isPlaying = NO;
        [self playVoiceWithMsgId:nil WithFileName:nil andVoiceUrl:nil];
        [_voicePlayView stopAnimating];
        [_timer invalidate];
    }
}

- (void)imageDidLoaded:(NSNotification *)noti
{
    
    [self refreshUI];
}

- (void)onClose{
    if (self.isVoice && _isPlaying == NO) {
        _timeDisplayLabel.text = nil;
        [self playVoice];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kBurnAfterReadMsgDestruction object:self.message];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Audio Method

- (BOOL)playingVoiceWithMsgId:(NSString *)msgId{
    
    return [msgId isEqualToString:_currentPlayVoiceMsgId];
    
}



- (void)playVoiceWithMsgId:(NSString *)msgId WithFilePath:(NSString *)filePath{
    
    
    _currentPlayVoiceMsgId = msgId;
    
    
    
    if (_currentPlayVoiceMsgId) {
        
        // 开始播放
        
        if ([filePath qim_hasPrefixHttpHeader]) {
            
            [_remoteAudioPlayer prepareForURL:filePath playAfterReady:YES];
            
        } else {
            
            [_remoteAudioPlayer prepareForFilePath:filePath playAfterReady:YES];
            
        }
        
        
        
    } else {
        
        // 结束播放
        
        [_remoteAudioPlayer stop];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [_voiceCell refreshUI];
        [self onClose];
    }
    
}

//add by dan.zheng 15/4/29
- (void)playVoiceWithMsgId:(NSString *)msgId WithFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl
{
    _currentPlayVoiceMsgId = msgId;
    
    if (_currentPlayVoiceMsgId) {
        [_remoteAudioPlayer prepareForFileName:fileName andVoiceUrl:voiceUrl playAfterReady:YES];
    } else {
        [_remoteAudioPlayer stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [_voiceCell refreshUI];
        [self onClose];
    }
}



- (void)remoteAudioPlayerReady:(QIMRemoteAudioPlayer *)player{
    
    
    
}



- (void)remoteAudioPlayerErrorOccured:(QIMRemoteAudioPlayer *)player withErrorCode:(QIMRemoteAudioPlayerErrorCode)errorCode{
    
    
    
}



- (void)remoteAudioPlayerDidStartPlaying:(QIMRemoteAudioPlayer *)player{
    
    [self updateCurrentPlayVoiceTime];
    
}



- (void)remoteAudioPlayerDidFinishPlaying:(QIMRemoteAudioPlayer *)player{
    
    _currentPlayVoiceMsgId = nil;
    [_voiceCell refreshUI];
    [self onClose];
}



- (void)updateCurrentPlayVoiceTime{
    
    if (_currentPlayVoiceMsgId) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyPlayVoiceTime object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:_remoteAudioPlayer.currentTime],kNotifyPlayVoiceTimeTime,_currentPlayVoiceMsgId,kNotifyPlayVoiceTimeMsgId, nil]];
        
        [self performSelector:@selector(updateCurrentPlayVoiceTime) withObject:nil afterDelay:1];
        
    }
    
}



- (int)playCurrentTime{
    
    return _remoteAudioPlayer.currentTime;
    
}



- (void)downloadProgress:(float)newProgress{
    
    if (_currentPlayVoiceMsgId) {
        
        _currentDownloadProcess = newProgress;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDownloadProgress object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:_currentDownloadProcess],kNotifyDownloadProgressProgress,_currentPlayVoiceMsgId,kNotifyDownloadProgressMsgId, nil]];
        
    } else {
        
        _currentDownloadProcess = 1;
        
    }
    
}



- (double)getCurrentDownloadProgress{
    
    return _currentDownloadProcess;
    
}

@end
