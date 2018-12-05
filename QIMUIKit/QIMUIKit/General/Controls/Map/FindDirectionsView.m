//
//  FindDirectionsView.m
//  qunarChatIphone
//
//  Created by chenjie on 16/2/4.
//
//

#import "FindDirectionsView.h"

typedef struct TriangleInfo {
    CGPoint firstPoint;
    CGPoint secondPoint;
    CGPoint thirdPoint;
} TriangleInfo;

@interface FindDirectionsView ()
{
    UIView              * _srcView;
    UIView              * _desView;
    UIView              * _driveCarTypeView;
    UIView              * _walkingTypeView;
    UIButton            * _searchBtn;
}

@end

@implementation FindDirectionsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self initSubViews];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapHandle:(id)sender{
    self.hidden = YES;
}

- (void)initSubViews{
    [self setUpSrcView];
    [self setUpDesView];
    [self setUpDriveCarTypeView];
    [self setUpWalkingTypeView];
    [self setUpSearchBtn];
}



- (void)setUpSrcView{
    if (_srcView == nil) {
        _srcView = [[UIView alloc] initWithFrame:CGRectMake(80, 70, self.width - 80 * 2, 50)];
        _srcView.backgroundColor = [UIColor qtalkTextLightColor];
        [self addSubview:_srcView];
    }
}

- (void)setUpDesView{
    if (_desView == nil) {
        _desView = [[UIView alloc] initWithFrame:CGRectMake(80, _srcView.bottom + 10, self.width - 80 * 2, 50)];
        _desView.backgroundColor = [UIColor qtalkTextLightColor];
        [self addSubview:_desView];
    }
}


- (void)setUpDriveCarTypeView{
    if (_driveCarTypeView == nil) {
        _driveCarTypeView = [[UIView alloc] initWithFrame:CGRectMake(self.width - 70, 0, 70, self.height)];
        _driveCarTypeView.backgroundColor = [UIColor redColor];
        [self addSubview:_driveCarTypeView];
    }
}

- (void)setUpWalkingTypeView{
    if (_walkingTypeView == nil) {
        _walkingTypeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, self.height)];
        _walkingTypeView.backgroundColor = [UIColor qtalkIconSelectColor];
        [self addSubview:_walkingTypeView];
    }
}

- (void)setUpSearchBtn{
    
}


- (UIView *)getTriangleWithPointsInfo:(TriangleInfo)triInfo bgColor:(UIColor *)color{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, triInfo.firstPoint.x, triInfo.firstPoint.y);
    CGPathAddLineToPoint(path, NULL, triInfo.secondPoint.x, triInfo.secondPoint.y);
    CGPathAddLineToPoint(path, NULL, triInfo.thirdPoint.x, triInfo.thirdPoint.y);
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = color.CGColor;
    maskLayer.strokeColor = color.CGColor;
    maskLayer.frame = self.bounds;
    maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
    maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
    maskLayer.path = path;//[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:20].CGPath;
    
    CAShapeLayer * borderLayer = [CAShapeLayer layer];
    borderLayer.fillColor  = [UIColor clearColor].CGColor;
    borderLayer.strokeColor    = [UIColor qtalkIconNomalColor].CGColor;
    borderLayer.lineWidth      = 0.5;
    borderLayer.frame = self.bounds;
    borderLayer.path = path;
    CGRect triFrame;
    triFrame.origin.x = MIN(MIN(triInfo.firstPoint.x, triInfo.secondPoint.x), triInfo.thirdPoint.x);
    triFrame.origin.x = MIN(MIN(triInfo.firstPoint.y, triInfo.secondPoint.y), triInfo.thirdPoint.y);
    triFrame.size.width = MAX(MAX(triInfo.firstPoint.x, triInfo.secondPoint.x), triInfo.thirdPoint.x) - triFrame.origin.x;
    triFrame.size.height = MAX(MAX(triInfo.firstPoint.y, triInfo.secondPoint.y), triInfo.thirdPoint.y) - triFrame.origin.y;
    UIView * triView = [[UIView alloc] initWithFrame:triFrame];
    triView.layer.backgroundColor = color.CGColor;
    triView.layer.mask = maskLayer;
    [triView.layer addSublayer:borderLayer];
    return triView;
}

@end
