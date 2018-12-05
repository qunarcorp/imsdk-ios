//
//  QTalkPlayProgressView.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@protocol QIMVideoPlayProgressViewDelegate <NSObject>
// 开始拖动
- (void)beiginSliderScrubbing;
// 结束拖动
- (void)endSliderScrubbing;
// 拖动值发生改变
- (void)sliderScrubbing;
@end

@interface QIMVideoPlayProgressView : UIView

@property (nonatomic, weak) id<QIMVideoPlayProgressViewDelegate> delegate;

@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat trackValue;
/**
 *  背景颜色：
 playProgressBackgoundColor：播放背景颜色
 trackBackgoundColor ： 缓存条背景颜色
 progressBackgoundColor ： 整个bar背景颜色
 */
@property (nonatomic, strong) UIColor *playProgressBackgoundColor;
@property (nonatomic, strong) UIColor *trackBackgoundColor;
@property (nonatomic, strong) UIColor *progressBackgoundColor;

@end
