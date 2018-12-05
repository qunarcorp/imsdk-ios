//
//  QIMMoviePlayer.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "QIMMoviePlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoView

- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
    [layer setFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.playerLayer setFrame:CGRectMake(0, 0, self.width, self.height)];
}

@end

@interface QIMMoviePlayer(){
    VideoView *_contentView;
    UIView *_playButtonView;
    UIButton *_playOrPause;
    UILabel *_progressLabel;
    UIActivityIndicatorView *_loadingView;
}

@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) AVPlayer *player;//播放器对象

@end

@implementation QIMMoviePlayer

-(void)dealloc{
    [[self player] pause];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
    [self setPlayer:nil];
    [self setProgressSlider:nil];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _contentView = [[VideoView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
        [_contentView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_contentView];
        
        _playButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 40, self.width, 40)];
        [_playButtonView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
        [_playButtonView setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.5]];
        [self addSubview:_playButtonView];
        
        _playOrPause = [[UIButton alloc] initWithFrame:CGRectMake(10, 6, 28, 28)];
        [_playOrPause setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [_playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setPlayButtonImage:YES];
        [_playButtonView addSubview:_playOrPause];
        
        self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(_playOrPause.right + 10, 19, self.width - (_playOrPause.right + 10) - 10, 2)];
        [self.progressSlider setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
        [self.progressSlider setMinimumValue:0];
        [self.progressSlider setMaximumValue:1];
        [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_progressbar_current"] forState:UIControlStateNormal];
        [self.progressSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
        [_playButtonView addSubview:self.progressSlider];
        
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.progressSlider.bottom + 4, self.width - 23, 12)];
        [_progressLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setFont:[UIFont systemFontOfSize:9]];
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_progressLabel setTextAlignment:NSTextAlignmentRight];
        [_playButtonView addSubview:_progressLabel];
        
    }
    return self;
}

- (void)updateValue:(UISlider *)sender{
    float f = sender.value; //读取滑块的值
    int value = (int)(CMTimeGetSeconds([self.player.currentItem duration]) * f);
    CMTime previewCMTime = CMTimeMake(value, 1);
    [self.player seekToTime:previewCMTime];
    if (self.player.rate == 0) {
        [self playClick:nil];
    }
}

- (void)setVideoPath:(NSString *)videoPath{
    _videoPath = videoPath;
    
    //创建播放器层
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame=_contentView.frame;
    playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;//视频填充模式
    [_contentView.layer addSublayer:playerLayer];
    [_contentView setPlayerLayer:playerLayer];
//    [self removeObserverFromPlayerItem:self.player.currentItem];
//    [self.player replaceCurrentItemWithPlayerItem:[self getPlayItem]];
//    [self addProgressObserver];
}

- (void)play{
    [self playClick:nil];
}

- (void) stop {
    [self.player pause];
    [self setPlayButtonImage:YES];
}

- (void)resume {
    if (!self.player.currentItem) {
        return;
    }
    [self.player play];
}

/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */

/**
 *  初始化播放器
 *
 *  @return 播放器对象
 */
-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
        [self addNotification];
    }
    return _player;
}

/**
 *  根据视频索引取得AVPlayerItem对象
 *
 *  @param videoIndex 视频顺序索引
 *
 *  @return AVPlayerItem对象
 */
-(AVPlayerItem *)getPlayItem{
    //    [self removeNotification];
    //    [self removeObserverFromPlayerItem:self.player.currentItem];
    if (self.videoPath) {
//        NSURL *url = [NSURL URLWithString:@"http://avi1.mtvxz.cn/%E7%AD%B7%E5%AD%90%E5%85%84%E5%BC%9F-%E5%B0%8F%E8%8B%B9%E6%9E%9C-%E5%9B%BD%E8%AF%AD%5Bwww.mtvxz.cn%5D.avi"];
        NSURL *url=[NSURL fileURLWithPath:self.videoPath];
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
        //切换视频
        return playerItem;
    } else {
        return nil;
    }
}

#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    [self setPlayButtonImage:YES];
    CMTime previewCMTime = CMTimeMake(0, 1);
    [self.player seekToTime:previewCMTime];
}

#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    //这里设置每秒执行一次
    UISlider *progress=self.progressSlider;
    UILabel *progressLabel = _progressLabel;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        QIMVerboseLog(@"当前已经播放%.2fs.",current);
        if (current) {
            CGFloat progressValue = (current/total);
            if (progress.value > progressValue) {
                [progress setValue:(current/total) animated:NO];
            } else {
                [progress setValue:(current/total) animated:YES];
            }
            NSString *totalStr = [NSString stringWithFormat:@"%02d:%02d",(int)total/60,(int)total%60];
            NSString *currentStr = [NSString stringWithFormat:@"%02d:%02d",(int)current/60,(int)current%60];
            [progressLabel setText:[NSString stringWithFormat:@"%@/%@",currentStr,totalStr]];
        }
    }];
}

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            QIMVerboseLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            float total = CMTimeGetSeconds(playerItem.duration);
            NSString *totalStr = [NSString stringWithFormat:@"%02d:%02d",(int)total/60,(int)total%60];
            [_progressLabel setText:[NSString stringWithFormat:@"%@",totalStr]]; 
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        QIMVerboseLog(@"共缓冲：%.2f",totalBuffer);
        //
    }
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (void)playClick:(UIButton *)sender {
    if(self.player.rate==0){ //说明时暂停
        [self setPlayButtonImage:NO];
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
        [self setPlayButtonImage:YES];
    }
}

- (void)setPlayButtonImage:(BOOL)flag{
    if (flag) {
        [_playOrPause setImage:[UIImage imageNamed:@"video_button_play_normal"] forState:UIControlStateNormal];
        [_playOrPause setImage:[UIImage imageNamed:@"video_button_play_pressed"] forState:UIControlStateHighlighted];
    } else { 
        [_playOrPause setImage:[UIImage imageNamed:@"video_button_stop_normal"] forState:UIControlStateNormal];
        [_playOrPause setImage:[UIImage imageNamed:@"video_button_stop_pressed"] forState:UIControlStateHighlighted];
    }
}

@end
