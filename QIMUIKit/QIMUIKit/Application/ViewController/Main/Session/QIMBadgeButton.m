//
//  QIMBadgeButton.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/16.
//
//

#import "QIMBadgeButton.h"
///默认badge宽度
#define KDefaultWidth 20
///默认颜色
#define KDefaultColor [UIColor colorWithRed:0.937 green:0.247 blue:0.227 alpha:1.00]
///默认拉伸长度比率
#define KDefaultRatio 0.15
///默认最小半径
#define KDefaultLimite 3
///默认幅度
#define KdefaultSpringRange 5
@interface QIMBadgeButton ()
///父视图
@property(nonatomic, weak) UIView *containerView;
///前BadgeView视图
@property(nonatomic, strong) UIView *frontView;
///后BadgeView视图
@property(nonatomic, strong) UIView *backView;
/// badgeLabel
@property(nonatomic, strong) UILabel *badgeLabel;

@end

@implementation QIMBadgeButton{
    CGFloat r1;
    CGFloat r2;
    CGPoint orgialPoint;
    CGPoint pointA;
    CGPoint pointB;
    CGPoint pointC;
    CGPoint pointD;
    CGPoint pointO;
    CGPoint pointP;
    CGFloat x1;
    CGFloat x2;
    CGFloat y1;
    CGFloat y2;
    CGFloat sin;
    CGFloat cos;
    CAShapeLayer *shapeLayer;
    UIColor *fillColor;
    CGFloat miniRad;
    CGFloat ratio;
    CGPoint pointG;
    CGFloat cornerRadi;
    UIView *_overView;
}
- (instancetype)initWithFrame:(CGRect)frame
                 diClickBadge:(BadgeDidClickBlock)didClickBlock
                 didDisappear:(BadgeDidDisappearBlock)didDisappearBlock{
    self = [self initWithFrame:frame];
    self.didClickBlock = didClickBlock;
    self.didDisappearBlock = didDisappearBlock;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    //    self.badgeWidth = frame.size.width;
    orgialPoint = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    [self setUpWithFrame:frame];
    
    return  self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.badgeLabel.center = CGPointMake(self.frontView.frame.size.width * 0.5, self.frontView.frame.size.height * 0.5);
    self.frontView.bounds = self.bounds;
}

#pragma mark - 初始化方法
- (void)setUpWithFrame:(CGRect)frame {
    self.isShowBomAnimation = YES;
    self.isShowSpringAnimation = YES;
    self.badgeFont = [UIFont systemFontOfSize:10];
    cornerRadi = 0.5;
    ratio = KDefaultRatio;
    miniRad = KDefaultLimite;
    self.springRange = KdefaultSpringRange;
    shapeLayer = [CAShapeLayer layer];
    //  CGFloat width = self.badgeWidth ? self.badgeWidth : KDefaultWidth;
    self.frontView = [[UIView alloc] init];
    self.frontView.clipsToBounds = YES;
    self.frontView.bounds =CGRectMake(0, 0, frame.size.width,  frame.size.height);
    self.frontView.center = orgialPoint;
    self.frontView.layer.cornerRadius = self.frontView.frame.size.height * cornerRadi;
    self.frontView.backgroundColor = KDefaultColor;
    [self addSubview:self.frontView];
    
    self.backView = [UIView new];
    self.backView.hidden = YES;
    self.backView.clipsToBounds = YES;
    self.backView.frame = CGRectMake(0, 0, frame.size.width,  frame.size.height);
    self.backView.center = orgialPoint;
    self.backView.layer.cornerRadius = self.backView.frame.size.height * 0.5;
    self.backView.backgroundColor = KDefaultColor;
    [self addSubview:self.backView];
    
    self.badgeLabel = [UILabel new];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.frame = self.frontView.bounds;
    self.badgeLabel.font = [UIFont systemFontOfSize:10];
    [self.frontView addSubview:self.badgeLabel];
    
    [self bringSubviewToFront:self.frontView];
    
    self.backgroundColor = [UIColor clearColor];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    [self.frontView addGestureRecognizer:pan];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.frontView addGestureRecognizer:tap];
}
#pragma mark -点击手势
- (void)handleTapGesture:(UIGestureRecognizer *)sender{
    
    if (self.didClickBlock) {
        self.didClickBlock(self);
    }
}



#pragma mark -拖拽手势
- (void)panGestureAction:(UIGestureRecognizer *)sender{
    CGPoint touchPoint = [sender locationInView:self];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self beganDrag];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self dragMovingWitTouchPoint:touchPoint];
            break;
            
        case UIGestureRecognizerStateEnded :
            [self dragFinishWithTouchPoint:touchPoint];
            break;
        case UIGestureRecognizerStateFailed:
            [self dragFinishWithTouchPoint:touchPoint];
            break;
        case UIGestureRecognizerStateCancelled:
            [self dragFinishWithTouchPoint:touchPoint];
            break;
            
        default:
            break;
    }
    
}
#pragma mark -开始拖拽
- (void)beganDrag{
    self.backView.hidden = NO;
    fillColor = self.badgeColor?self.badgeColor:KDefaultColor;
    [self.frontView.layer removeAllAnimations];
    [self convertToOverView];
}
#pragma mark -正在拖拽
- (void)dragMovingWitTouchPoint:(CGPoint)touchPoint{
    if (r1 < miniRad) {
        fillColor = [UIColor clearColor];
        self.backView.hidden = YES;
        [shapeLayer removeFromSuperlayer];
        
    }else{
        self.backView.hidden = NO;
        fillColor = self.badgeColor?self.badgeColor:KDefaultColor;
    }
    
    self.frontView.center = touchPoint;
    x1 = orgialPoint.x;
    y1 = orgialPoint.y;
    x2 = touchPoint.x;
    y2 = touchPoint.y;
    if (y2 > y1) {
        x2 = touchPoint.x - (self.frontView.frame.size.width - self.frontView.frame.size.height) / 4;
    }else{
        x2 = touchPoint.x + (self.frontView.frame.size.width - self.frontView.frame.size.height) / 4;
    }
    CGFloat distance = sqrtf((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2));
    
    if (distance == 0) {
        sin = 0;
        cos = 1;
    }else{
        sin = (x2 - x1)/distance;
        cos = (y2 - y1)/distance;
    }
    r2 = self.frontView.frame.size.height * 0.5;
    r1 = r2 - distance * ratio;
    pointA = CGPointMake(x1 - r1*cos, y1+r1*sin);
    pointB = CGPointMake(x1 + r1*cos , y1 - r1*sin);
    pointC = CGPointMake(x2 + r2*cos, y2 - r2 *sin);
    pointD = CGPointMake(x2 -r2 *cos, y2 + r2*sin);
    pointP = CGPointMake(pointB.x + distance *0.5 *sin, pointB.y + distance *0.5 *cos);
    pointO = CGPointMake(pointA.x + distance *0.5 *sin, pointA.y + distance *0.5 *cos);
    pointG = CGPointMake(x1 + _springRange*sin, y1 + _springRange*cos);
    
    self.backView.bounds = CGRectMake(0, 0, r1 *2, r1 *2);
    self.backView.layer.cornerRadius = r1 ;
    
    [self  drawRect];
}
#pragma mark -完成拖拽
- (void)dragFinishWithTouchPoint:(CGPoint)touchPoint{
    self.frontView.center = orgialPoint;
    
    if (r1 > miniRad) {
        
        if (self.isShowSpringAnimation) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
                
                [self displaySpringAnimation];
            }
        }
    }
    if (r1 < miniRad) {
        self.frontView.hidden = YES;
        self.badgeLabel.text = @"";
        if (self.isShowBomAnimation) {
            [self displayBomAnimationWithPoint:touchPoint];
        }
        
        if (self.didDisappearBlock) {
            self.didDisappearBlock(self);
        }
    }
    self.backView.bounds = CGRectMake(0, 0, self.frontView.frame.size.width, self.frontView.frame.size.width);
    self.backView.layer.cornerRadius = self.frontView.frame.size.height *0.5;
    [shapeLayer removeFromSuperlayer];
    self.backView.hidden = YES;
    [self convertToOrigalContainerView];
    
    
}
#pragma mark -迁移到置顶视图坐标系
- (void)convertToOverView{
    if(!self.overView.superview){
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows){
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self.overView];
                break;
            }
        }
    } else {
        [self.overView.superview bringSubviewToFront:self.overView];
    }
    _containerView = self.superview;
    self.center = [_containerView convertPoint:self.center toView:self.overView];
    
    if ([_containerView isKindOfClass:[UITableViewCell class]]
        && self == ((UITableViewCell* )_containerView).accessoryView) {
        ((UITableViewCell* )_containerView).accessoryView = nil;
    }
    
    [self.overView addSubview:self];
}
#pragma mark -迁移到原来的坐标系
- (void)convertToOrigalContainerView {
    self.center = [_overView convertPoint:self.center toView:_containerView];
    
    [_containerView addSubview:self];
    
    [_overView removeFromSuperview];
    _overView = nil;
}

#pragma mark -爆炸动画
- (void)displayBomAnimationWithPoint:(CGPoint )point{
    UIImageView *bomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frontView.frame.size.width,self.frontView.frame.size.width)];
    bomView.center = point;
    [self addSubview:bomView];
    NSMutableArray *bomArry = [NSMutableArray array];
    for (int i =0; i < 4; i++) {
        NSString *imgName = [NSString stringWithFormat:@"bomb%d",i];
        UIImage *img  = [UIImage imageNamed:imgName];
        if (img) {
            [bomArry addObject:img];
        }
    }
    bomView.animationImages = bomArry;
    bomView.animationDuration = 0.5;
    bomView.animationRepeatCount = 1;
    [bomView startAnimating];
}
#pragma mark -弹簧动画
- (void)displaySpringAnimation{
    
    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"position"];
    springAnimation.duration = springAnimation.settlingDuration;
    springAnimation.stiffness = 1000;
    springAnimation.damping = 5;
    springAnimation.mass = 0.5;
    springAnimation.initialVelocity = 70;
    springAnimation.fromValue = [NSValue valueWithCGPoint:pointG];
    springAnimation.toValue = [NSValue valueWithCGPoint:orgialPoint];
    springAnimation.repeatCount = 1;
    [self.frontView.layer addAnimation:springAnimation forKey:nil];
    
}
#pragma mark -shapeLayer
- (void)drawRect{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addQuadCurveToPoint:pointD controlPoint:pointO];
    [path addLineToPoint:pointC];
    [path addQuadCurveToPoint:pointB controlPoint:pointP];
    [path moveToPoint:pointA];
    if (self.backView.hidden == NO) {
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = fillColor.CGColor;
        [self.layer insertSublayer:shapeLayer below:self.frontView.layer];
    }
}
#pragma mark -隐藏bageButton
- (void)hiddenBadgeButton:(BOOL)hidden{
    self.frontView.hidden = hidden;
    self.backView.hidden = YES;
}
- (BOOL)isHidden{
    return self.frontView.hidden;
}
#pragma mark -懒加载 置顶视图
- (UIView *)overView {
    if(!_overView) {
        _overView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overView.backgroundColor = [UIColor clearColor];
    }
    return _overView;
}
#pragma mark -setter方法

- (void)setBadgeWidth:(CGFloat)badgeWidth {
    _badgeWidth = badgeWidth;
    CGFloat height = CGRectGetHeight(self.frame);
    self.frame = CGRectMake(0, 0, badgeWidth, height);
    self.frontView.frame = self.frame;
    self.backView.frame = self.frame;
    self.frontView.layer.cornerRadius = height * cornerRadi;
    self.backView.layer.cornerRadius = height * 0.5;
    self.badgeLabel.frame = self.frontView.frame;
    if (badgeWidth <= 10) {
        self.badgeFont = [UIFont systemFontOfSize:5];
    }
}

- (void)setBadgeString:(NSString *)badgeString{
    _badgeString = badgeString;
    self.badgeLabel.text = badgeString;
    self.frontView.hidden = NO;
    self.backView.hidden = YES;
}


- (void)setBadgeColor:(UIColor *)badgeColor {
    _badgeColor = badgeColor;
    self.frontView.backgroundColor = badgeColor;
    self.backView.backgroundColor = badgeColor;
}

- (void)setBadgeFont:(UIFont *)badgeFont{
    _badgeFont = badgeFont;
    self.badgeLabel.font = badgeFont;
}
- (void)setBadgeTextColor:(UIColor *)badgeTextColor{
    _badgeTextColor = badgeTextColor;
    self.badgeLabel.textColor = badgeTextColor;
}
- (void)setBadgeMinRadius:(CGFloat)badgeMinRadius{
    _badgeMinRadius = badgeMinRadius;
    miniRad = badgeMinRadius < self.frontView.frame.size.width * 0.5?badgeMinRadius:KDefaultLimite;
}
- (void)setBadgeDistaceRatio:(CGFloat)badgeDistaceRatio{
    _badgeDistaceRatio = badgeDistaceRatio;
    ratio = badgeDistaceRatio;
}
- (void)setCornerRadiusRation:(CGFloat)cornerRadiusRation{
    _cornerRadiusRation = cornerRadiusRation;
    cornerRadi = cornerRadiusRation;
    self.frontView.layer.cornerRadius = self.frontView.frame.size.width * cornerRadiusRation;
    
}

@end
