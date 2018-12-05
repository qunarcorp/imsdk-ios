//
//  QIMRemoteAudioPlayer.m
//  QunarUGC
//
//  Created by 赵岩 on 12-10-25.
//
//

#import "QIMRemoteAudioPlayer.h"
#import "IMAmrFileCodec.h"
#import "QIMPathManage.h"

@interface QIMRemoteAudioPlayer ()<ASIProgressDelegate>
{
    BOOL _ready;
    BOOL _playAfterReady;
}

@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) NSString *fileName;

@end

@implementation QIMRemoteAudioPlayer

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize player = _player;
@synthesize fileName = _fileName;

- (void)dealloc
{
    [self.request clearDelegatesAndCancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.player = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        //get your app's audioSession singleton object
        AVAudioSession* session = [AVAudioSession sharedInstance];
        //error handling
        BOOL success;
        NSError* error;
        //set the audioSession category.
        //Needs to be Record or PlayAndRecord to use audioRouteOverride:
        success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (!success) {
            QIMVerboseLog(@"AVAudioSession error setting category:%@", error);
        }
        //set the audioSession override
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if (!success) {
            QIMVerboseLog(@"AVAudioSession error overrideOutputAudioPort:%@", error);
        }
        //activate the audio session
        success = [session setActive:NO error:&error];
        if (!success)  {
            QIMVerboseLog(@"AVAudioSession error activating: %@",error);
        } else {
            QIMVerboseLog(@"audioSession active");
        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:kAutoPlayAllVoiceMsgFinishHandleNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAllVoiceMsgFinishHandle:) name:kPlayAllVoiceMsgFinishHandleNotification object:nil];
    }
    return self;
}

- (void)prepareForURL:(NSString *)url playAfterReady:(BOOL)playAfterReady
{
    _playAfterReady = playAfterReady;
}

- (void)prepareForWavFilePath:(NSString *)filePath playAfterReady:(BOOL)playAfterReady{
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    _playAfterReady = playAfterReady;
    [self preparefromWaveData:data playAfterReady:YES];
}

- (void)prepareForFilePath:(NSString *)filePath playAfterReady:(BOOL)playAfterReady{
    NSData *armData = [[NSData alloc] initWithContentsOfFile:filePath];
    _playAfterReady = playAfterReady;
    [self prepareAmrData:armData playAfterReady:YES];
}

//用于QTalk的语音播放。因为使用QIMPathManage类来管理音频文件的存放路径，所以播放音频时将文件名和网络url传输过来。
//判断文件名所对应的文件是否已经存在。若存在，则直接播放；否则从网络上下载再播放，并将下载下来的文件保存下来。
- (void)prepareForFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl playAfterReady:(BOOL)playAfterReady
{
    _fileName = [fileName copy];
    NSString *voicePath = [QIMPathManage getPathByFileName:_fileName ofType:@"amr"];
    if ([QIMPathManage fileExistsAtPath:voicePath]) {
        [self prepareForFilePath:voicePath playAfterReady:playAfterReady];
    } else {
        [self prepareForVoiceURL:voiceUrl playAfterReady:playAfterReady];
    }
}

- (void)prepareForVoiceURL:(NSString *)voiceUrl playAfterReady:(BOOL)playAfterReady
{
    _playAfterReady = playAfterReady;
    [self.request clearDelegatesAndCancel];
    self.request = nil;
    if (![voiceUrl qim_hasPrefixHttpHeader]) {
        voiceUrl =  [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", voiceUrl];
    } 
    if ([voiceUrl rangeOfString:@"?"].location == NSNotFound) {
        voiceUrl = [voiceUrl stringByAppendingFormat:@"?u=%@&k=%@",[[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[QIMKit sharedInstance] myRemotelogginKey]];
    } else {
        voiceUrl = [voiceUrl stringByAppendingFormat:@"&u=%@&k=%@",[[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[QIMKit sharedInstance] myRemotelogginKey]];
    }
    NSURL *requestUrl = [NSURL URLWithString:voiceUrl];
    if (requestUrl == nil) {
        requestUrl = [NSURL URLWithString:[voiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:requestUrl];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];

    self.request = request;
    [request startAsynchronous];
}

- (void)prepareAmrData:(NSData *)amrData playAfterReady:(BOOL)playAfterReady{
    NSData *data = DecodeAMRToWAVE(amrData);
    [self preparefromWaveData:data playAfterReady:playAfterReady];
}

- (void)preparefromWaveData:(NSData *)data playAfterReady:(BOOL)playAfterReady{
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
    player.volume = 1.0;
    player.delegate = self;
    self.player = player;
    BOOL successful = [player prepareToPlay];
    _ready = YES;
    if (successful) {
        //在这里开启红外感应，用于切换听筒和外放语音 //添加近距离事件监听，添加前需先设置为YES，如果设置完后读取还是NO的话，说明当前设备没有近距离传感器
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        //默认开启 外放模式
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        } else {
            QIMVerboseLog(@"The device does not have a proximity sensor");
        }
        if (_playAfterReady) {
            successful = [player play];
            if (successful) {
                [_delegate remoteAudioPlayerDidStartPlaying:self];
            }
            else {
                [_delegate remoteAudioPlayerErrorOccured:self withErrorCode:QIMRemoteAudioPlayerPlayingFailure];
            }
        }
    }
    else {
        [_delegate remoteAudioPlayerErrorOccured:self withErrorCode:QIMRemoteAudioPlayerPlayingFailure];
    }
}

#pragma mark - 处理近距离监听触发事件
- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    //如果手机靠近面部放在耳朵旁，声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) { //黑屏
        //设置为通过听筒输出
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else { //没有黑屏
        //设置为外放输出，并判断是否已播放完成。若已不再播放，则关闭传感器
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!self.player || ![self.player isPlaying]) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
    }
}

    
- (BOOL)ready {
    return _ready;
}
    
- (BOOL)playing {
    return self.player.playing;
}

- (BOOL)play
{
    if (!_ready) {
        return NO;
    }
    else {
        return [self.player play];
    }
}

- (void)stop
{
    if (_ready && self.player.playing) {
        [self.player stop];
    }
    [self setPlayer:nil];
}

- (void)pause
{
    if (!_ready) {
        return;
    }
    if (_ready && self.player.playing) {
        [self.player pause];
    }
}

- (NSTimeInterval)currentTime{
    return self.player.currentTime;
}
    
#pragma mark - ASIHTTPRequestDelegate
    
- (void)setProgress:(float)newProgress{
    if ([self.delegate respondsToSelector:@selector(downloadProgress:)]) {
        [self.delegate downloadProgress:newProgress];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [_delegate remoteAudioPlayerReady:self];
    NSData *amrData = [request responseData];
    //保存数据到本地
    [QIMPathManage getPathToSaveWithSaveData:amrData ToFileName:_fileName ofType:@"amr"];
    [self prepareAmrData:amrData playAfterReady:YES];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_delegate remoteAudioPlayerErrorOccured:self withErrorCode:QIMRemoteAudioPlayerLoadingFailure];
    [self setPlayer:nil];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playVoiceEndSound];
    [_delegate remoteAudioPlayerDidFinishPlaying:self];
//    [self setPlayer:nil];
//    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [_delegate remoteAudioPlayerErrorOccured:self withErrorCode:QIMRemoteAudioPlayerPlayingFailure];
    [self setPlayer:nil];
}

//播放语音消息结束提示音
-(void)playVoiceEndSound {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"end" ofType:@"wav"];
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    if (applicationState == UIApplicationStateActive)
    {
        // 非租车业务才播放声音
        SystemSoundID soundID;
        // 读文件获取SoundID
        if (filePath != nil)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            //声音
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:filePath],
                                             &soundID);
            AudioServicesPlaySystemSound(soundID);
        }
    }
}

- (void)playAllVoiceMsgFinishHandle:(NSNotificationCenter *)notifi {
    
    [self setPlayer:nil];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
