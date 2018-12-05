//
//  QIMChatBubbleView.m
//  qunarChatIphone
//
//  Created by chenjie on 16/2/16.
//
//

#import "QIMChatBubbleView.h"

@interface QIMChatBubbleView ()
{
    CALayer	  *_contentLayer;
    CAShapeLayer *_maskLayer;
    CAShapeLayer     * _borderLayer;
}

@end

@implementation QIMChatBubbleView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initMask];
}

- (void)initMask {
    //创建一个CGMutablePathRef的可变路径，并返回其句柄
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat trigleSide = 10;
    CGFloat triglePaddingToTop = 15;
    CGPoint origin = self.bounds.origin;
    CGSize size =  CGSizeMake(self.bounds.size.width - trigleSide, self.bounds.size.height);
    if (self.direction == QIMChatBubbleViewDirectionRight) {
        CGFloat boderRadius = 12.0f;
        CGFloat sharpCorner = 12.0f;
        if (origin.y + size.height - boderRadius < origin.y + 7.0f + 4 * boderRadius) {
            sharpCorner = 3.0f;
        }
        CGPathMoveToPoint(path, NULL, origin.x + sharpCorner, origin.y);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - sharpCorner, origin.y);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, origin.y + sharpCorner, sharpCorner, -M_PI_2, 0, NO);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 7.0f);
        CGPathAddArc(path, NULL, origin.x + size.width + boderRadius, 7.0f, boderRadius, M_PI, M_PI_2, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, 7.0f +  boderRadius);
        
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, size.height - sharpCorner);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, size.height - sharpCorner, sharpCorner, 0, M_PI_2, NO);
        
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, size.height);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height - sharpCorner, sharpCorner, M_PI_2, M_PI, NO);
        CGPathAddLineToPoint(path, NULL, origin.x, origin.y + sharpCorner);
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + sharpCorner, sharpCorner, M_PI_2, 0, NO);
    } else {
        origin = CGPointMake(10, 0);
        CGFloat boderRadius = 12.0f;
        CGFloat sharpCorner = 12.0f;
        if (origin.y + size.height - boderRadius < origin.y + 5 + 4 * boderRadius) {
            sharpCorner = 3.0f;
        }
        
        CGPathMoveToPoint(path, NULL, origin.x + size.width - sharpCorner, origin.y);
        CGPathAddLineToPoint(path, NULL, origin.x + sharpCorner, origin.y);
        CGPathAddArc(path, NULL, origin.x + sharpCorner, origin.y + sharpCorner, sharpCorner, M_PI_2, M_PI, YES);
        
        CGPathAddLineToPoint(path, NULL, origin.x, 5);
        if (origin.y + size.height - boderRadius > origin.y + 5 + 4 * boderRadius) {
            CGPathAddArc(path, NULL, origin.x - 4 * boderRadius, 5, 4 * boderRadius, 2 * M_PI, M_PI_4, NO);
            
            CGPathAddLineToPoint(path, NULL, origin.x, 5 + 4 * boderRadius / sqrt(2));
        } else {
            CGPathAddArc(path, NULL, origin.x - 2 * boderRadius, 5, 2 * boderRadius, 2 * M_PI, M_PI_4, NO);
            
            CGPathAddLineToPoint(path, NULL, origin.x, 5 + 2 * boderRadius / sqrt(2));
        }
        CGPathAddLineToPoint(path, NULL, origin.x, size.height - sharpCorner);
        
        CGPathAddArc(path, NULL, origin.x + sharpCorner, size.height - sharpCorner, sharpCorner, M_PI, M_PI_2, YES);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width - sharpCorner, size.height);
        
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, size.height - sharpCorner, sharpCorner, M_PI_2, 0, YES);
        CGPathAddLineToPoint(path, NULL, origin.x + size.width, origin.y + sharpCorner);
        CGPathAddArc(path, NULL, origin.x + size.width - sharpCorner, origin.y + sharpCorner, sharpCorner, 3 * M_PI_2, 0, NO);
        CGPathCloseSubpath(path);
    }
    
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor blackColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.frame = self.bounds;
        _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
        _maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
    }
    _maskLayer.path = path;
    
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.strokeColor    = [UIColor clearColor].CGColor;
        _borderLayer.lineWidth      = 0.5;
        _borderLayer.frame = self.bounds;
    }

    if (self.direction == QIMChatBubbleViewDirectionLeft) {
        _borderLayer.fillColor  = [UIColor qim_leftBallocColor].CGColor;
    }else{
        _borderLayer.fillColor  = [UIColor qim_rightBallocColor].CGColor;
    }
    _borderLayer.path = path;
    
    self.layer.mask = _maskLayer;
    [self.layer addSublayer:_borderLayer];
    CGPathRelease(path);
}

-(void)setBgColor:(UIColor *)color {
    _borderLayer.fillColor = color.CGColor;
}

- (void)removeMask {
    self.layer.mask = nil;
    [_borderLayer removeFromSuperlayer];
}

@end
