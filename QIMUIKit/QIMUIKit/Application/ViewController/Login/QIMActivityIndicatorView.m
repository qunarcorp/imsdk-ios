//
//  DGActivityIndicatorView.m
//  DGActivityIndicatorExample
//
//  Created by Danil Gontovnik on 5/23/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "QIMActivityIndicatorView.h"

static const CGFloat kDGActivityIndicatorDefaultSize = 40.0f;

@interface QCLineScalePulseOutRapidAnimation : NSObject

@end

@implementation QCLineScalePulseOutRapidAnimation

- (void)setupAnimationInLayer:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)tintColor {
    CGFloat duration = 0.9f;
    NSArray *beginTimes = @[@0.5f, @0.25f, @0.0f, @0.25f, @0.5f];
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.11f :0.49f :0.38f :0.78f];
    CGFloat lineSize = size.width / 9;
    CGFloat x = (layer.bounds.size.width - size.width) / 2;
    CGFloat y = (layer.bounds.size.height - size.height) / 2;
    
    // Animation
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    
    animation.keyTimes = @[@0.0f, @0.8f, @0.9f];
    animation.values = @[@1.0f, @0.3f, @1.0f];
    animation.timingFunctions = @[timingFunction, timingFunction];
    animation.repeatCount = HUGE_VALF;
    animation.duration = duration;
    
    for (int i = 0; i < 5; i++) {
        CAShapeLayer *line = [CAShapeLayer layer];
        UIBezierPath *linePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, lineSize, size.height) cornerRadius:lineSize / 2];
        
        animation.beginTime = [beginTimes[i] floatValue];
        line.fillColor = tintColor.CGColor;
        line.path = linePath.CGPath;
        [line addAnimation:animation forKey:@"animation"];
        line.frame = CGRectMake(x + lineSize * 2 * i, y, lineSize, size.height);
        [layer addSublayer:line];
    }
}

@end

@implementation QIMActivityIndicatorView

#pragma mark -
#pragma mark Constructors

- (id)init {
    return [self initWithTintColor:[UIColor whiteColor] size:kDGActivityIndicatorDefaultSize];
}

- (id)initWithTintColor:(UIColor *)tintColor {
    return [self initWithTintColor:tintColor size:kDGActivityIndicatorDefaultSize];
}

- (id)initWithTintColor:(UIColor *)tintColor size:(CGFloat)size {
    self = [super init];
    if (self) {
        _size = size;
        _tintColor = tintColor;
        self.userInteractionEnabled = NO;
        self.hidden = YES;
    }
    return self;
}

#pragma mark -
#pragma mark Methods

- (void)setupAnimation {
    self.layer.sublayers = nil;
    
    id animation = [[QCLineScalePulseOutRapidAnimation alloc] init];
    
    if ([animation respondsToSelector:@selector(setupAnimationInLayer:withSize:tintColor:)]) {
        [animation setupAnimationInLayer:self.layer withSize:CGSizeMake(_size, _size) tintColor:_tintColor];
        self.layer.speed = 0.0f;
    }
}

- (void)startAnimating {
    if (!self.layer.sublayers) {
        [self setupAnimation];
    }
    self.hidden = NO;
    self.layer.speed = 1.0f;
    _animating = YES;
}

- (void)stopAnimating {
    self.layer.speed = 0.0f;
    _animating = NO;
    self.hidden = YES;
}

#pragma mark -
#pragma mark Setters

- (void)setSize:(CGFloat)size {
    if (_size != size) {
        _size = size;
        
        [self setupAnimation];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if (![_tintColor isEqual:tintColor]) {
        _tintColor = tintColor;
        
        for (CALayer *sublayer in self.layer.sublayers) {
            sublayer.backgroundColor = tintColor.CGColor;
        }
    }
}


@end
