//
//  UIView+QIMExtension.h
//
//

#import <UIKit/UIKit.h>

@interface UIView (QIMExtension)

/**  起点x坐标  */
@property (nonatomic, assign) CGFloat x;
/**  起点y坐标  */
@property (nonatomic, assign) CGFloat y;
/**  中心点x坐标  */
@property (nonatomic, assign) CGFloat centerX;
/**  中心点y坐标  */
@property (nonatomic, assign) CGFloat centerY;
/**  宽度  */
@property (nonatomic, assign) CGFloat width;
/**  高度  */
@property (nonatomic, assign) CGFloat height;
/**  顶部  */
@property (nonatomic, assign) CGFloat top;
/**  底部  */
@property (nonatomic, assign) CGFloat bottom;
/**  左边  */
@property (nonatomic, assign) CGFloat left;
/**  右边  */
@property (nonatomic, assign) CGFloat right;
/**  size  */
@property (nonatomic, assign) CGSize size;
/**  origin */
@property (nonatomic, assign) CGPoint origin;

// 设置UIView的X
- (void)setViewX:(CGFloat)newX;

// 设置UIView的Y
- (void)setViewY:(CGFloat)newY;

// 设置UIView的Origin
- (void)setViewOrigin:(CGPoint)newOrigin;

// 设置UIView的width
- (void)setViewWidth:(CGFloat)newWidth;

// 设置UIView的height
- (void)setViewHeight:(CGFloat)newHeight;

// 设置UIView的Size
- (void)setViewSize:(CGSize)newSize;

//放大缩小动画
-(void)scaleAnimation;

-(void)breathAnimation;

-(void)removeAnimation;

/**  设置圆角  */
- (void)rounded:(CGFloat)cornerRadius;

/**  设置圆角和边框  */
- (void)rounded:(CGFloat)cornerRadius width:(CGFloat)borderWidth color:(UIColor *)borderColor;

/**  设置边框  */
- (void)border:(CGFloat)borderWidth color:(UIColor *)borderColor;

/**   给哪几个角设置圆角  */
-(void)round:(CGFloat)cornerRadius RectCorners:(UIRectCorner)rectCorner;

/**  设置阴影  */
-(void)shadow:(UIColor *)shadowColor opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset;

- (UIViewController *)viewController;

+ (CGFloat)getLabelHeightByWidth:(CGFloat)width Title:(NSString *)title font:(UIFont *)font;
    
- (void)removeAllSubviews;
@end
