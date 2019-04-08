//
//  UIImage+QIMTint.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/11/25.
//
//

#import "UIImage+QIMTint.h"

@implementation UIImage (QIMTint)

- (UIImage *) qim_imageWithTintColor:(UIColor *)tintColor
{
    return [self qim_imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *) qim_imageWithGradientTintColor:(UIColor *)tintColor
{
    return [self qim_imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *) qim_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@end
