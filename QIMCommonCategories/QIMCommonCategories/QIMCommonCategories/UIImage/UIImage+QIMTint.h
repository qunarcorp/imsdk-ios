//
//  UIImage+QIMTint.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/11/25.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (QIMTint)

- (UIImage *) qim_imageWithTintColor:(UIColor *)tintColor;
- (UIImage *) qim_imageWithGradientTintColor:(UIColor *)tintColor;

@end
