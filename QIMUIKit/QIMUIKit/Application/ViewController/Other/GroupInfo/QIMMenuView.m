//
//  MenuCommonLabelCell.m
//  qunarChatIphone
//
//  Created by admin on 16/5/20.
//
//

#import "QIMMenuView.h"

@implementation QIMMenuView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UILongPressGestureRecognizer *idLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongEvent:)];
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:idLongPress];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}



- (void)copyMethod:(id)sender{
    [self resignFirstResponder];
    if (self.coprText.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.coprText;
    }else{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"并没有什么东西可以复制的！" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)showCopyMenu{
    if([self isFirstResponder]) {
    } else if([self becomeFirstResponder]) {
        NSMutableArray * menuItems = [NSMutableArray array];
        UIMenuItem *copyitem = [[UIMenuItem alloc] initWithTitle:@"拷贝"
                                                          action:@selector(copyMethod:)];
        [menuItems addObject:copyitem];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (menu.menuVisible) {
            [menu setMenuVisible:NO animated:YES];
        }
        if (menuItems.count > 0) {
            menu.menuItems = menuItems;
            [menu update];
            [menu setTargetRect:CGRectZero inView:self];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}


- (void)onLongEvent:(UILongPressGestureRecognizer *)tag{
    if ([tag state] == UIGestureRecognizerStateBegan) {
        [self resignFirstResponder];
        [self showCopyMenu];
    }
}

@end

