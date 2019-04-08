//
//  QIMVideoPlayerManager.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.
//


#import "QIMVideoPlayerManager.h"
#import "QIMVideoCachePathTool.h"
#import "QIMVideoDownloadManager.h"
#import "QIMVideoURLAssetResourceLoader.h"

static void *kRateObservationContext = &kRateObservationContext;
static void *kStatusObservationContext = &kStatusObservationContext;
static void *kCurrentItemObservationContext = &kCurrentItemObservationContext;
static void *kTimeRangesObservationContext = &kTimeRangesObservationContext;

/* 本地是否还有可用缓存视频流监听 */
static void *kPlaybackBufferEmptyObservationContext = &kPlaybackBufferEmptyObservationContext;
static void *kPlaybackLikelyToKeepUpObservationContext = &kPlaybackLikelyToKeepUpObservationContext;

static NSString *kRequestKeyPlayState = @"playable";

@interface QIMVideoPlayerManager () <QIMVideoURLAssetResourceLoaderDelegate>

@property (nonatomic, strong) QIMVideoURLAssetResourceLoader *resourceLoader;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AVURLAsset *videoURLAsset;
@property (nonatomic, strong) AVPlayer *mPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) AVPlayerItem *mPlayerItem;

@property(nonatomic, assign) BOOL isAddObserver;

@property (nonatomic, assign) double fullContext;

@end

@implementation QIMVideoPlayerManager {
    
    AVPlayerItem *_currentPlayItem;
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL _isEnterBackgound;
    
    BOOL _isForcusPause;
    BOOL _isEmptyBufferPause;
    UIView *_currentPlayView;
    
    /**
     播放进程结束，因为loadValuesAsynchronouslyForKeys准备播放是一个异步的操作。
     如果该异步操作还没有完成，即用户已进入播放加载界面马上就点击退出，此时loadValuesAsynchronouslyForKeys
     还在后台异步执行，异步准备完成后就会执行播放
     */
    BOOL _isProcessTerminaed;
    
}
+ (instancetype)sharedInstance{
    static QIMVideoPlayerManager *nativeNamager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nativeNamager = [[QIMVideoPlayerManager alloc] init];
    });
    return nativeNamager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ////设置session，防止播放时没有声音，自动识别当前播放模式，是耳机还是外放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:NULL];
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:audioRouteOverride error:nil];
    }
    return self;
}
- (void)playVideoFromUrl:(NSURL *)url videoFromPath:(NSString *)filePath onView:(UIView *)playView {
    if ([url isKindOfClass:[NSURL class]]) {
        if (url.absoluteString.length == 0) {
            return;
        }
        self.url = url;
    } else if ([url isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)url;
        if (str.length == 0) {
            return;
        }
        self.url = [NSURL URLWithString:str];
    }
    if (!playView) {
        return;
    }
    _isProcessTerminaed = NO;
    _currentPlayView = playView;
    AVURLAsset *videoURLAsset = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        //直接从本地读取数据进行播放
        NSURL *playPathURL = [NSURL fileURLWithPath:filePath];
        videoURLAsset = [AVURLAsset URLAssetWithURL:playPathURL options:nil];
        
    } else {
        //网络读取数据
        QIMVideoURLAssetResourceLoader *resourceLoader = [QIMVideoURLAssetResourceLoader new];
        self.resourceLoader = resourceLoader;
        resourceLoader.delegate = self;
        NSURL *playUrl = [resourceLoader getSchemeVideoURL:self.url];
        videoURLAsset = [AVURLAsset URLAssetWithURL:playUrl options:nil];
        self.videoURLAsset = videoURLAsset;
        [self.videoURLAsset.resourceLoader setDelegate:resourceLoader queue:dispatch_get_main_queue()];
    }
    /* 准备播放 */
    [_delegate playStatusChange:AVPlayerPlayStatePreparing];
    [self prepareToPlayAsset:videoURLAsset withKeys:nil];
    
}

/*
- (void)playVideoFromhUrl:(NSURL *)url onView:(UIView *)playView{
    
    if (_url != url) {
        
        _isProcessTerminaed = NO;
        
        _url = url;
        _currentPlayView = playView;
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
        NSArray *requestedKeys = @[kRequestKeyPlayState];
        
        /* 准备播放
        [_delegate playStatusChange:AVPlayerPlayStatePreparing];
        
        // 使用断言去加载指定额键值
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                /**
                                 *  因为这是异步操作，有可能执行到这儿的时候程序已经退出
                                 * 必须要确保当前播放进程没有退出
 
                                if (!_isProcessTerminaed) {
                                    [self prepareToPlayAsset:asset withKeys:requestedKeys];
                                }
                            });
         }];
    }
}
*/
#pragma mark - 私有方法

// 播放前准备
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys{
//    /* 确保能够加载成功. */
//    for (NSString *thisKey in requestedKeys){
//        
//        NSError *error = nil;
//        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
//        if (keyStatus == AVKeyValueStatusFailed){
//            [self assetFailedToPrepareForPlayback:error];
//            return;
//        }
//    }
//    
//    /* 使用asset的playable属性去侦测是否能够加载成功. */
//    if (!asset.playable){
//        
//        /* 生成一个错误的描述. */
//        NSString *localizedDescription = NSLocalizedString(@"不能播放", @"未知错误不能播放");
//        NSString *localizedFailureReason = NSLocalizedString(@"未知错误不能播放", @"不能播放原因");
//        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   localizedDescription, NSLocalizedDescriptionKey,
//                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
//                                   nil];
//        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
//        
//        /* 展示一个错误信息给用户. */
//        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
//        
//        return;
//    }
    
    if (self.mPlayerItem){
        
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
    }
    
    /* 从successfully loaded AVAsset中创建一个新的AVPlayerItem instance. */
    _mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self.mPlayerItem  addObserver:self
                        forKeyPath:@"playbackBufferEmpty"
                           options:NSKeyValueObservingOptionNew
                           context:kPlaybackBufferEmptyObservationContext];
    
    [self.mPlayerItem  addObserver:self
                        forKeyPath:@"playbackLikelyToKeepUp"
                           options:NSKeyValueObservingOptionNew
                           context:kPlaybackLikelyToKeepUpObservationContext];
    
    /* Observe the player 的 "status" key 去决定什么什么去播放. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:kStatusObservationContext];
    
    /* 已经缓冲的值 */
    [self.mPlayerItem addObserver:self
                       forKeyPath:@"loadedTimeRanges"
                          options:NSKeyValueObservingOptionNew
                          context:kTimeRangesObservationContext];
    [self addObserverOnce];
    seekToZeroBeforePlay = NO;
    
    if (!self.mPlayer){
        
        _mPlayer = [AVPlayer playerWithPlayerItem:self.mPlayerItem];
        
        /* 监听 AVPlayer currentItem*/
        [self.mPlayer addObserver:self
                       forKeyPath:@"currentItem"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:kCurrentItemObservationContext];
        
        /* 监听 AVPlayer rate*/
        [self.mPlayer addObserver:self
                       forKeyPath:@"rate"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:kRateObservationContext];
        
    }
    
    if (self.mPlayer.currentItem != self.mPlayerItem){
        [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
    }
    
    // 1.创建一个 AVPlayerLayer
    self.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:_mPlayer];
    [self.avPlayerLayer setFrame:_currentPlayView.bounds];
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [_currentPlayView.layer addSublayer:self.avPlayerLayer];
    
    /* 开始播放 */
    [_delegate playStatusChange:AVPlayerPlayStateBeigin];
    [self.mPlayer play];
}

- (void)addObserverOnce {
    
    if (!self.isAddObserver) {
        /* 监听已经播放结束*/
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.mPlayerItem];
        
        /**
         *  监听应用前后台切换
         *
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appEnteredForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appEnteredBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        //注册中断通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        //添加耳机状态监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    }
    self.isAddObserver = YES;
}

- (void)appEnteredForeground{
    QIMVerboseLog(@"---EnteredForeground");
    //    _isEnterBackgound = NO;
    /**
     *  注意：appEnteredForeground 会在 AVPlayerItemStatusReadyToPlay（从后台回到前台会出发ReadyToPlay）
     *  之后被调用，顾设置 _isEnterBackgound = NO 的操作放在了 AVPlayerItemStatusReadyToPlay 之中
     */
}
- (void)appEnteredBackground{
    QIMVerboseLog(@"---EnteredBackground");
    _isEnterBackgound = YES;
    [self pause];
}


/**
 *  中断处理函数
 *
 *  @param notification 通知对象
 */
- (void)handleInterruption:(NSNotification *)notification{
    NSDictionary * info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    //中断开始和中断结束
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //当被电话等中断的时候，调用这个方法，停止播放
        [self updateCurrentPlayStatus:AVPlayerPlayStatePause];
    } else {
        /**
         *  中断结束，userinfo中会有一个InterruptionOption属性，
         *  该属性如果为resume，则可以继续播放功能
         */
        AVAudioSessionInterruptionOptions option = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (option == AVAudioSessionInterruptionOptionShouldResume) {
            [self updateCurrentPlayStatus:AVPlayerPlayStatePreparing];
        }
    }
}

/**
 *  音频输出改变触发事件
 *
 *  @param notification 通知
 */
- (void)routeChange:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription = dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription = [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AVAudioSession * session = [AVAudioSession sharedInstance];
            [session setPreferredIOBufferDuration:audioRouteOverride error:nil];
            //如果视频正在播放，会自动暂停，这里用来设置按钮图标
            if (self.mPlayerItem) {
                [self updateCurrentPlayStatus:AVPlayerPlayStatePause];
            }
        }
    }
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error{
    
    [self removePlayerTimeObserver];
    [self syncScrubber];
    
    [self updateCurrentPlayStatus:AVPlayerPlayStateNotPlay];
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"我知道了"
                                              otherButtonTitles:nil];
    [alertView show];
}
/* 当前是否正在播放视频 */
- (BOOL)isPlaying{
    return mRestoreAfterScrubbingRate != 0.f || [self.mPlayer rate] != 0.f;
}
/* 播放结束的时候回调这个方法. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* 视频播放结束，再次播放需要从0位置开始播放 */
    seekToZeroBeforePlay = YES;
    [self updateCurrentPlayStatus:AVPlayerPlayStateEnd];
}

/* 取消先前注册的观察者 */
-(void)removePlayerTimeObserver{
    if (mTimeObserver){
        [self.mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}

- (void)updateCurrentPlayStatus:(AVPlayerPlayState)playState{
    [_delegate playStatusChange:playState];
}

/* 初始化播放状态. */
-(void)initScrubberTimer{
    [_delegate initPlayerPlayback];
}


- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" */
    if (context == kStatusObservationContext){
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            /* 未知播放状态，尝试着去加载一个错误的资源 */
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self updateCurrentPlayStatus:AVPlayerPlayStateNotPlay];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                /* 一旦 AVPlayerItem 准备好了去播放, i.e.
                 duration 值就可以去捕获到 （从后台回到前台也会触发 ReadyToPlay）*/
                if (!_isEnterBackgound) {
                    [self initScrubberTimer];
                    [self updateCurrentPlayStatus:AVPlayerPlayStateBeigin];
                }else{
                    //后台 ---> 前台
                    _isEnterBackgound = NO;
                }
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }else if (context == kPlaybackBufferEmptyObservationContext){
        QIMVerboseLog(@"----EmptyBuffer");
        
    }else if (context == kPlaybackLikelyToKeepUpObservationContext){
        QIMVerboseLog(@"----Have Buffer");
    }
    /* AVPlayer "rate"*/
    else if (context == kRateObservationContext){
        
        /**
         *  暂停分两种：一个强制暂停（以就是点击了暂停按钮）
         *  另一种就是网络不好加载卡住了暂停。
         */
        if (self.mPlayer.rate == 0) {
            
            /* 缓存不够导致的暂停 */
            if (!_isForcusPause) {
                QIMVerboseLog(@"当前缓存数: %f", self.fullContext);
                if (self.fullContext >= 1.00) {
                    [self updateCurrentPlayStatus:AVPlayerPlayStateEnd];
                } else {
                    QIMVerboseLog(@"self.mPlayer.rate == 0 && _isEmptyBuffer---AVPlayerPlayStatePreparing");
                    [self updateCurrentPlayStatus:AVPlayerPlayStatePreparing];
                    _isEmptyBufferPause = YES;
                }
            }
            /* 正常情况下导致的暂停 */
            else{
                [self updateCurrentPlayStatus:AVPlayerPlayStatePause];
            }
            
        }
        /**
         *  播放都一样
         */
        if (self.mPlayer.rate == 1) {
            _isForcusPause = NO;
            _isEmptyBufferPause = NO;
            QIMVerboseLog(@"self.mPlayer.rate == 1----AVPlayerPlayStatePreparing");
            [self updateCurrentPlayStatus:AVPlayerPlayStateBeigin];
        }
        
    }
    /* AVPlayer "currentItem" 属性值观察.
     当replaceCurrentItemWithPlayerItem方法回调发生的时候. */
    else if (context == kCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* 判断是否为空 */
        if (newPlayerItem == (id)[NSNull null]){
            [self updateCurrentPlayStatus:AVPlayerPlayStateNotPlay];
            
        }else
        {
            self.avPlayerLayer.player = self.mPlayer;
            [self setVideoFillMode:AVLayerVideoGravityResizeAspect];
        }
    }
    /* 已经缓冲的视频 */
    else if (context == kTimeRangesObservationContext){
        
        NSArray* times = self.mPlayerItem.loadedTimeRanges;
        
        // 取出数组中的第一个值
        NSValue* value = [times objectAtIndex:0];
        
        CMTimeRange range;
        [value getValue:&range];
        float start = CMTimeGetSeconds(range.start);
        float duration = CMTimeGetSeconds(range.duration);
        
        /* 得出缓存进度 */
        float videoAvailable = start + duration;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateVideoAvailable:videoAvailable];
        });
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

-(void)updateVideoAvailable:(float)videoAvailable {
    
    CMTime playerDuration = [self playerItemDuration];
    double progress = 0;
    /* 有可能播放器还没有准备好，playerDuration值为kCMTimeInvalid */
    if (playerDuration.value != 0) {
        double duration = CMTimeGetSeconds(playerDuration);
        progress = videoAvailable/duration;
        self.fullContext = progress;
        [_delegate videoBufferDataProgress:progress];
        /**
         *  如果因为缓冲被暂停的，如果缓冲值已经够了，需要重新播放
         */
        float minValue = 0;
        float maxValue = 1;
        double time = CMTimeGetSeconds([self playerCurrentDuration]);
        double sliderProgress = (maxValue - minValue) * time / duration + minValue;
        
        /**
         *  当前处于缓冲不够暂停状态时
         */
        if ((progress - sliderProgress) > 0.01 && self.mPlayer.rate == 0 && _isEmptyBufferPause) {
            
            [self play];
        }
    }
}


#pragma mark - 公共方法

- (CMTime)playerCurrentDuration{
    return [self.mPlayer currentTime];
}

- (CMTime)playerItemDuration{
    
    AVPlayerItem *playerItem = [_mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}

- (void)updateMovieScrubberControl{
    
    __weak QIMVideoPlayerManager *weakSelf = self;
    mTimeObserver = [_mPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                           queue:NULL usingBlock:
                     ^(CMTime time)
                     {
                         [weakSelf syncScrubber];
                     }];
    
}

- (void)setVideoFillMode:(NSString *)fillMode{
    AVPlayerLayer *playerLayer = self.avPlayerLayer;
    playerLayer.videoGravity = fillMode;
}

#pragma mark - 播放状态控制
- (void)play{
    /* 如果视频正处于播发的结束位置，我们需要调回到初始位置
     进行播放. */
    if (YES == seekToZeroBeforePlay){
        seekToZeroBeforePlay = NO;
        [self.mPlayer seekToTime:kCMTimeZero];
    }
    [_mPlayer play];
}
- (void)pause{
    if (!self.mPlayerItem) {
        return;
    }
    _isForcusPause = YES;
    [_mPlayer pause];
}
- (void)resum{
    [_mPlayer play];
}
- (void)stop{
    if (!self.mPlayer) {
        return;
    }
    [self pause];
}

- (void)clear{
    
    [self removePlayerTimeObserver];
    [self.mPlayer removeObserver:self forKeyPath:@"rate"];
    [self.mPlayer removeObserver:self forKeyPath:@"currentItem"];
    
    [self.mPlayerItem  removeObserver:self forKeyPath:@"status"];
    [self.mPlayerItem  removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.mPlayerItem  removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.mPlayerItem  removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.mPlayer pause];
    
    _isProcessTerminaed = YES;
    self.mPlayer = nil;
    self.mPlayerItem = nil;
    self.avPlayerLayer = nil;
    self.url = nil;
}
#pragma mark - 播放进度控制

// 开始拖动
- (void)beiginSliderScrubbing{
    
    /* 记录开始拖动前的状态，拖动的时候必须要暂停 */
    mRestoreAfterScrubbingRate = [_mPlayer rate];
    
    if (_isEmptyBufferPause) {
        /* 如果是当前网络问题，缓存不够导致的暂停 */
        [_mPlayer setRate:0.f];
    }else{
        /* 正常播放的情况下 */
        [self pause];
    }
}

// 拖动值发生改变
- (void)sliderScrubbing:(CGFloat)time{
    [_mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {}];
}
// 结束拖动
- (void)endSliderScrubbing{
    
    if (!mTimeObserver){
        [self updateMovieScrubberControl];
    }
    
    /* 拖动结束了,得恢复拖动前的状态, (如果是非强制暂停的，以就是缓存不够导致的可以恢复播放 ) */
    if (mRestoreAfterScrubbingRate || !_isForcusPause){
        /* 拖动前是播放状态，这时候需要恢复播放 */
        [_mPlayer setRate:1.f];
        mRestoreAfterScrubbingRate = 0.f;
    }
}
- (void)syncScrubber{
    [_delegate playProgressChange];
}

#pragma mark -----------------------------------------
#pragma mark QTalkVideoLoaderURLConnectionDelegate

-(void)didFailLoadingWithManager:(QIMVideoDownloadManager *)manager WithError:(NSError *)errorCode{
    QIMVerboseLog(@"下载失败");
}

-(void)didFinishLoadingWithManager:(QIMVideoDownloadManager *)manager fileSavePath:(NSString *)filePath{
     QIMVerboseLog(@"Download finished, 下载完成");
}


@end
