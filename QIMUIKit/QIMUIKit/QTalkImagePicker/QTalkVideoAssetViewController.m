//
//  QTalkVideoAssetViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/8/19.
//
//

#import "QTalkVideoAssetViewController.h"

#import "QIMMoviePlayer.h"

#import <AVFoundation/AVFoundation.h>

#import "QIMStringTransformTools.h"

#import "QTImagePickerController.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
#import "QTPHImagePickerController.h"
#endif

@interface QTVideoAlertView : UIAlertView
@property (nonatomic, copy) NSString *videoOutPath;
@property (nonatomic, copy) NSString *fileSizeStr;
@property (nonatomic, assign) float  videoDuration;
@property (nonatomic, strong) UIImage *thumbImage;
@end

@implementation QTVideoAlertView

- (void)dealloc{
    [self setVideoOutPath:nil];
    [self setFileSizeStr:nil];
    [self setThumbImage:nil];
}

@end

@interface QTalkVideoAssetViewController()<UIAlertViewDelegate>
@property (nonatomic, strong) AVPlayer *player;//播放器对象
@end

@implementation QTalkVideoAssetViewController{
    
    VideoView *_contentView;
    UIView *_bottomView;
    UIButton *_playButton;
    
}

-(void)dealloc{
    [[self player] pause];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
    [self setPlayer:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self initWithUI];
    [self initBottomView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//    AVPlayerItem *playerItem=self.player.currentItem;e
    //这里设置每秒执行一次
//    UISlider *progress=self.progressSlider;
//    UILabel *progressLabel = _progressLabel;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
//        float total=CMTimeGetSeconds([playerItem duration]);
        QIMVerboseLog(@"当前已经播放%.2fs.",current);
        if (current) {
//            CGFloat progressValue = (current/total);
//            if (progress.value > progressValue) {
//                [progress setValue:(current/total) animated:NO];
//            } else {
//                [progress setValue:(current/total) animated:YES];
//            }
//            NSString *totalStr = [NSString stringWithFormat:@"%02d:%02d",(int)total/60,(int)total%60];
//            NSString *currentStr = [NSString stringWithFormat:@"%02d:%02d",(int)current/60,(int)current%60];
//            [progressLabel setText:[NSString stringWithFormat:@"%@/%@",currentStr,totalStr]];
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
//            float total = CMTimeGetSeconds(playerItem.duration);
//            NSString *totalStr = [NSString stringWithFormat:@"%02d:%02d",(int)total/60,(int)total%60];
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

#pragma mark - init
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
    if (self.videoAsset) {
        if ([self.videoAsset isKindOfClass:[ALAsset class]]) {
//            NSURL *url = [self.videoAsset valueForProperty:ALAssetPropertyAssetURL];
//            AVAsset *avasset = [AVAsset assetWithURL:self.videoAsset.defaultRepresentation];
            ALAsset *alasset = (ALAsset *)self.videoAsset;
            NSURL *url2 = alasset.defaultRepresentation.url;
            AVAsset *avasset = [AVAsset assetWithURL:url2];
            self.videoAsset = avasset;
            AVPlayerItem * item = [AVPlayerItem playerItemWithAsset:avasset];

//            AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
            //切换视频
            return item;
        }else if ([self.videoAsset isKindOfClass:[AVAsset class]]) {
            AVPlayerItem * item = [AVPlayerItem playerItemWithAsset:self.videoAsset];
            return item;
        }
        return nil;
    } else {
        return nil;
    }
}

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

- (void)initWithUI{
    _contentView = [[VideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
    [_contentView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_contentView];
    
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame=_contentView.frame;
    playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;//视频填充模式
    [_contentView.layer addSublayer:playerLayer];
    [_contentView setPlayerLayer:playerLayer];
    
}

- (void)initBottomView{
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 70, self.view.width, 70)];
    [_bottomView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_bottomView setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.9]];
    [self.view addSubview:_bottomView];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width - 30)/2.0, 20, 30, 30)];
    [_playButton setImage:[UIImage imageNamed:@"short_video_preview_play"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(onPlayOrPause) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_playButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 23, 50, 24)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:cancelButton];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 60, 23, 50, 24)];
    [okButton setTitle:@"选择" forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(onOk) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:okButton];
    
}

#pragma mark - actions
- (void)onPlayOrPause{
    if(self.player.rate==0){ //说明时暂停
        [self setPlayButtonImage:NO];
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
        [self setPlayButtonImage:YES];
    }
}

- (void)onCancel{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    if (self.picker.selectedAssets.count) {
        [self.picker.selectedAssets removeObjectAtIndex:self.picker.selectedAssets.count - 1];
    }
#endif
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat) getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size;
    }
    return filesize;
}

- (void)onOk{
    UIView *loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [loadView setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.5]];
    [loadView.layer setCornerRadius:5];
    [loadView.layer setMasksToBounds:YES];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView setFrame:CGRectMake(10, 0, 40, 40)];
    [activityView startAnimating];
    [loadView addSubview:activityView];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(activityView.right, 10, 150 - activityView.right, 20)];
    [loadingLabel setBackgroundColor:[UIColor clearColor]];
    [loadingLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [loadingLabel setTextAlignment:NSTextAlignmentLeft];
    [loadingLabel setText:@"正在压缩..."];
    [loadingLabel setTextColor:[UIColor whiteColor]];
    [loadView addSubview:loadingLabel];
    
    loadView.center = self.view.center;
    [self.view addSubview:loadView];
    
    AVAssetExportSession *exportSession = nil;
    NSString *resultQuality = AVAssetExportPresetMediumQuality;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    exportSession = [[AVAssetExportSession alloc] initWithAsset:self.videoAsset presetName:resultQuality];
#else
    NSURL *sourceURL = [self.videoAsset valueForProperty:ALAssetPropertyAssetURL];
    float videoLength = [[self.videoAsset valueForProperty:ALAssetPropertyDuration] floatValue];//self.videoAsset.defaultRepresentation.size;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
    exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:resultQuality];
    
#endif
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *videoResultPath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingFormat:@"/video_%@.mp4", [formater stringFromDate:[NSDate date]]];
    exportSession.outputURL = [NSURL fileURLWithPath:videoResultPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [loadView removeFromSuperview];
             switch ((int)exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     QIMVerboseLog(@"AVAssetExportSessionStatusUnknown");
                     break;
                 case AVAssetExportSessionStatusWaiting:
                     QIMVerboseLog(@"AVAssetExportSessionStatusWaiting");
                     break;
                 case AVAssetExportSessionStatusExporting:
                     QIMVerboseLog(@"AVAssetExportSessionStatusExporting");
                     break;
                 case AVAssetExportSessionStatusCompleted:
                 {
                     AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoResultPath] options:nil];
                     AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
                     gen.appliesPreferredTrackTransform = YES;
                     CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                     NSError *error = nil;
                     CMTime actualTime;
                     CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                     UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                     CGImageRelease(image);
                     
                     NSString *fileSizeStr = [QIMStringTransformTools CapacityTransformStrWithSize:[self getFileSize:videoResultPath]];
                     QTVideoAlertView *alertView = [[QTVideoAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"压缩视频后的大小为%@,确定要发送吗？",fileSizeStr] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"直接发送",@"保存相册并发送", nil];
                     [alertView setVideoOutPath:videoResultPath];
                     [alertView setThumbImage:thumb];
                     [alertView setFileSizeStr:fileSizeStr];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
                     [alertView setVideoDuration:self.videoDuration];
                     self.picker.videoPath = videoResultPath;
#else
                     [alertView setVideoDuration:videoLength];
#endif
                     [alertView show];
                 }
                     break;
                 case AVAssetExportSessionStatusFailed:{
                     QTVideoAlertView *alertView = [[QTVideoAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"压缩失败{%@}",exportSession.error] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                     [alertView show];
                 }
                     break;
             }
         });
         
     }];
}

- (void)setPlayButtonImage:(BOOL)flag{
    if (flag) {
        [_playButton setImage:[UIImage imageNamed:@"short_video_preview_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"short_video_preview_play"] forState:UIControlStateHighlighted];
    } else {
        [_playButton setImage:[UIImage imageNamed:@"short_video_preview_pause"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"short_video_preview_pause"] forState:UIControlStateHighlighted];
    }
}

#pragma mark - alert delegate
- (void)alertView:(QTVideoAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    if (buttonIndex) {
        if (buttonIndex == 2) {
            UISaveVideoAtPathToSavedPhotosAlbum(alertView.videoOutPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
        [self.picker finishPickingAssets:nil];
    }
    return;
#endif
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:alertView.videoOutPath forKey:@"VideoOutPath"];
    [dic setObject:alertView.thumbImage forKey:@"ThumbImage"];
    [dic setObject:alertView.fileSizeStr forKey:@"FileSizeStr"];
    [dic setObject:@(floorf(alertView.videoDuration)) forKey:@"VideoDuration"];
    QTImagePickerController *picker = (QTImagePickerController *)self.navigationController;
    if (buttonIndex == 1) {
        if ([picker.imageDelegate respondsToSelector:@selector(qtImagePickerController:didFinishPickingVideo:)]) {
            [picker.imageDelegate qtImagePickerController:picker didFinishPickingVideo:dic];
        }
    } else if (buttonIndex == 2) {
        UISaveVideoAtPathToSavedPhotosAlbum(alertView.videoOutPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        if ([picker.imageDelegate respondsToSelector:@selector(qtImagePickerController:didFinishPickingVideo:)]) {
            [picker.imageDelegate qtImagePickerController:picker didFinishPickingVideo:dic];
        }
    }
    QIMVerboseLog(@"出去了...");
}
// 视频保存回调

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    if (!error) {
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:@"保存成功！" message:@"小视频已经保存到相册..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:@"保存失败！" message:@"请到“设置->隐私->照片”中允许访问相册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
