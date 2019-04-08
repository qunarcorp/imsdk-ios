//
//  QIMWorkMomentLabel.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentLabel.h"

@implementation QIMWorkMomentLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)]];
    }
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer *)tag {
    
    if ([tag state] == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        [self showCopyMenu];
    }
}

- (void)showCopyMenu {
    if([self becomeFirstResponder]) {
        
        NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:1];
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                          action:@selector(copyText:)];
        [menuItems addObject:menuItem];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (menu.menuVisible)
        {
            [menu setMenuVisible:NO animated:YES];
        }
        menu.menuItems = menuItems;
        [menu setTargetRect:self.bounds inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyText:)) {
        return YES;
    }
    return NO;
}

- (void)copyText:(id)sender {
    
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:self.attributedText.string];
//    [self resignFirstResponder];
}

@end
