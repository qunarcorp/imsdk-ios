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
    return self.bounds.size.width - [self qim_leftWidth] - [self qim_dockWidth];
    return MAX(self.bounds.size.width, self.bounds.size.height) - [self qim_leftWidth] - [self qim_dockWidth];
}

- (CGFloat)height{
    return self.bounds.size.height;
    return MIN(self.bounds.size.width, self.bounds.size.height);
}

- (CGFloat)width{
    return self.bounds.size.width;
    return MAX(self.bounds.size.width, self.bounds.size.height);
}
@end
