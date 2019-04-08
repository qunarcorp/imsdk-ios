//
//  QIMBadgeButton.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/16.
//
//

#import "QIMCommonUIFramework.h"
@class QIMBadgeButton;

typedef void (^BadgeDidClickBlock)(QIMBadgeButton *badgeButton);

typedef void (^BadgeDidDisappearBlock)(QIMBadgeButton *badgeButton);

@interface QIMBadgeButton : UIView
///badgeButton的宽度
@property (nonatomic, assign) CGFloat badgeWidth;
///badge字符串
@property (nonatomic, copy) NSString *badgeString;
///badge颜色 默认为红色
@property (nonatomic, strong) UIColor *badgeColor;
///badge字体
@property (nonatomic, strong) UIFont *badgeFont;
///badge字体颜色 默认为白色
@property (nonatomic, strong) UIColor *badgeTextColor;
///弹簧效果幅度，值越大，幅度越大，默认为20
@property (nonatomic, assign) CGFloat springRange;
///badgeButton最小的半径,越小拉伸得越尖 默认为4
@property (nonatomic, assign) CGFloat badgeMinRadius;
///badgeButton拉伸长度比率,越小拉伸的距离越长 默认为0.2
@property (nonatomic, assign) CGFloat badgeDistaceRatio;
///bageButton切圆比率,当width == height 时 ：0.5为圆,0为方形
@property (nonatomic, assign) CGFloat cornerRadiusRation;
///是否 爆炸效果
@property (nonatomic, assign) BOOL isShowBomAnimation;
///是否 弹簧效果
@property (nonatomic, assign) BOOL isShowSpringAnimation;
///badgeButton是否隐藏
@property (nonatomic, assign,readonly) BOOL isHidden;
///点击button的回调
@property (nonatomic, copy) BadgeDidClickBlock didClickBlock;
///删除badgeString的回调
@property (nonatomic, copy) BadgeDidDisappearBlock didDisappearBlock;

///隐藏badgeBtton
- (void)hiddenBadgeButton:(BOOL)hidden;
/**
 *  初始化方法
 *
 *  @param frame
 *  @param didClickBlock     点击后的回到block
 *  @param didDisappearBlock bage隐藏后的block
 */
- (instancetype)initWithFrame:(CGRect)frame
                 diClickBadge:(BadgeDidClickBlock)didClickBlock
                 didDisappear:(BadgeDidDisappearBlock)didDisappearBlock;
@end
