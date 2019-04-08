//
//  ShapedImageView.m
//  JJTest
//
//  Created by chenjie on 16/1/4.
//  Copyright © 2016年 chenjie. All rights reserved.
//

#import "ShapedImageView.h"

@interface ShapedImageView()
{
    CALayer	  *_contentLayer;
    CAShapeLayer *_maskLayer;
    CAShapeLayer     * _borderLayer;
    UIImageView * _imageView;
}
@end

@implementation ShapedImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setup
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat trigleSide = 10;
    CGFloat triglePaddingToTop = 7;
    CGPoint origin = self.bounds.origin;
    CGSize  size =  CGSizeMake(self.bounds.size.width - trigleSide, self.bounds.size.height);
    if (self.direction == ShapedImageViewDirectionLeft) {
        origin = CGPointMake(10, 0);
        size =  CGSizeMake(self.bounds.size.width - trigleSide, self.bounds.size.height);
    }else{
        size =  CGSizeMake(self.bounds.size.width - trigleSide, self.bounds.size.height);
    }
    CGFloat radius = 5;
    CGPathMoveToPoint(path, NULL, origin.x + radius, origin.y);
    
    CGPathAddLineToPoint(path, NULL, origin.x + size.width - radius, origin.y);
    CGPathAddArc(path, NULL, origin.x + size.width - radius, origin.y + radius, radius, 3 * M_PI_2, 2 * M_PI, NO);
    if (self.direction == ShapedImageViewDirectionRight) {
        //小三角
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width , origin.y + radius + triglePaddingToTop);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width + trigleSide, origin.y + radius + triglePaddingToTop + trigleSide / 2.0f);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, origin.y + radius + triglePaddingToTop + trigleSide);
    }
    
    CGPathAddLineToPoint(path, NULL, origin.x + size.width, origin.y + size.height - radius);
    CGPathAddArc(path, NULL, origin.x + size.width - radius, origin.y + size.height - radius, radius, 0, M_PI_2, NO);
    
    CGPathAddLineToPoint(path, NULL, origin.x + radius, origin.y + size.height);
    CGPathAddArc(path, NULL, origin.x + radius, origin.y + size.height - radius, radius, M_PI_2, M_PI, NO);
    
    if (self.direction == ShapedImageViewDirectionLeft) {
        //小三角
        CGPathAddLineToPoint(path, NULL, origin.x, origin.y + radius + triglePaddingToTop + trigleSide);
        CGPathAddLineToPoint(path, NULL, 0, origin.y + radius + triglePaddingToTop + trigleSide / 2.0f);
        CGPathAddLineToPoint(path, NULL, origin.x, origin.y + radius + triglePaddingToTop);
    }
    
    CGPathAddLineToPoint(path, NULL, origin.x , origin.y + radius);
    CGPathAddArc(path, NULL, origin.x + radius, origin.y + radius, radius, M_PI, 3 * M_PI_2, NO);
    
    if (_maskLayer == nil) { 
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor blackColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.frame = self.bounds;
        _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
        _maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
    }
    _maskLayer.path = path;//[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:20].CGPath;
    
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.fillColor  = [UIColor clearColor].CGColor;
        _borderLayer.strokeColor    = [UIColor qtalkIconNomalColor].CGColor;
        _borderLayer.lineWidth      = 0.5;
        _borderLayer.frame = self.bounds;
    }
    _borderLayer.path = path;
    
    self.layer.mask = _maskLayer;
    [self.layer addSublayer:_borderLayer];
}

- (void)setImage:(UIImage *)image
{
    self.layer.contents = (id)image.CGImage;
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithImage:nil];
        [self addSubview:_imageView];
    }
    _imageView.frame = self.bounds;
    _imageView.image = image;
    
}

@end
