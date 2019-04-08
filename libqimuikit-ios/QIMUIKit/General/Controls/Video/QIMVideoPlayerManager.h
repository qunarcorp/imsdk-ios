//
//  QIMVideoPlayerManager.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <AVFoundation/AVFoundation.h>
#import "QIMCommonUIFramework.h"

typedef NS_ENUM(NSInteger,AVPlayerPlayState) {
    
    AVPlayerPlayStatePreparing = 0x0, // 准备播放
    AVPlayerPlayStateBeigin,       // 开始播放
    AVPlayerPlayStatePlaying,      // 正在播放
    AVPlayerPlayStatePause,        // 播放暂停
    AVPlayerPlayStateEnd,          // 播放结束
    AVPlayerPlayStateBufferEmpty,  // 没有缓存的数据供播放了
    AVPlayerPlayStateBufferToKeepUp,//有缓存的数据可以供播放
    
    AVPlayerPlayStateNotPlay,      // 不能播放
    AVPlayerPlayStateNotKnow       // 未知情况
};

@protocol PlayVideoDelegate <NSObject>

// 更新进度条的值
- (void)playProgressChange;
- (void)initPlayerPlayback;
- (void)playStatusChange:(AVPlayerPlayState)state;

// 视频缓冲数据进度
- (void)videoBufferDataProgress:(double)bufferProgress;

@end

@interface QIMVideoPlayerManager : NSObject

@property (nonatomic, weak) id<PlayVideoDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isPlaying;

@property (nonatomic, copy) NSString *videoFileName;

+ (instancetype)sharedInstance;

- (void)playVideoFromUrl:(NSURL *)url videoFromPath:(NSString *)filePath onView:(UIView *)playView;

- (CMTime)playerCurrentDuration;
- (CMTime)playerItemDuration;

- (void)updateMovieScrubberControl;
- (void)setVideoFillMode:(NSString *)fillMode;

// 开始拖动
- (void)beiginSliderScrubbing;
// 结束拖动
- (void)endSliderScrubbing;
// 拖动值发生改变
- (void)sliderScrubbing:(CGFloat)time;

// 播放控制
- (void)play;
- (void)pause;
- (void)resum;
- (void)stop;
- (void)clear;

@end
