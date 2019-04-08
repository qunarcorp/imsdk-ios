//
//  UIScreen+QIMIpad.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/6/16.
//
//

#import "UIScreen+QIMIpad.h"

@implementation UIScreen(QIMIpad)

- (CGFloat)qim_dockWidth{
    if ([UIScreen mainScreen].width * 0.06 < 80) {
        return 80;
    }
    return [UIScreen mainScreen].width * 0.06;
}

- (CGFloat)qim_leftWidth{
    if ([UIScreen mainScreen].width * 0.21 < 300) {
        return 300;
    }
    return [UIScreen mainScreen].width * 0.21;
}

- (CGFloat)qim_rightWidth{
    return [UIApplication sharedApplication].keyWindow.bounds.size.width - [self qim_leftWidth] - [self qim_dockWidth];
}

- (CGFloat)height{
    return self.bounds.size.height;
}

- (CGFloat)width{
    return self.bounds.size.width;
}
@end
