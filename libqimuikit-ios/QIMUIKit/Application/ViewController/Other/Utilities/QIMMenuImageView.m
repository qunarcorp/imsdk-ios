//
//  ImageLabel.m
//
//
//  Created by  apple on 08-10-31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QIMMenuImageView.h"
#import "QIMChatBubbleView.h"
@implementation QIMMenuImageView
@synthesize delegate;

+ (void)cancelHighlighted{
    [[NSNotificationCenter defaultCenter] postNotificationName:QIMMenuImageViewCancelHightlighted object:nil];
}

- (void)cancelHighlighted{
    [self resignFirstResponder];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.canShowMenu = YES;
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongEvent:)] ];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelHighlighted) name:QIMMenuImageViewCancelHightlighted object:nil];
        if (_bubbleView == nil) {
            _bubbleView = [[QIMChatBubbleView alloc] initWithFrame:self.bounds];
            [self addSubview:_bubbleView];
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame{

    [super setFrame:frame];
    if (self.image) {
        if (_bubbleView) {
            [_bubbleView removeMask];
            [_bubbleView removeFromSuperview];
        }
    } else {
        if (_bubbleView == nil) {
            _bubbleView = [[QIMChatBubbleView alloc] initWithFrame:self.bounds];
            [self addSubview:_bubbleView];
        }
        _bubbleView.direction = (QIMChatBubbleViewDirection)self.message.messageDirection;
        [_bubbleView setFrame:self.bounds];
    }
}

- (void)setImage:(UIImage *)image{
    [super setImage:image];
    if (self.image) {
        if (_bubbleView) {
            [_bubbleView removeMask];
            [_bubbleView removeFromSuperview];
        }
    } else {
        if (_bubbleView == nil) {
            _bubbleView = [[QIMChatBubbleView alloc] initWithFrame:self.bounds];
            [self addSubview:_bubbleView];
        }
        _bubbleView.direction = (QIMChatBubbleViewDirection)self.message.messageDirection;
        [_bubbleView setFrame:self.bounds];
    }
}

- (void)setBubbleBgColor:(UIColor *)color {
    [_bubbleView setBgColor:color];
}

- (void)onLongEvent:(UILongPressGestureRecognizer *)tag {
    if (!self.canShowMenu) {
        return;
    }
    if ([tag state] == UIGestureRecognizerStateBegan) {
        BOOL needAddForward = NO;
        switch (self.message.messageType) {
            case QIMMessageType_Text:
            case QIMMessageType_Voice:
            case QIMMessageType_File:
            case QIMMessageType_LocalShare:
            case QIMMessageType_SmallVideo:
            case QIMMessageType_CommonTrdInfo:
                needAddForward = YES;
            default:
                break;
        }
        if (needAddForward && ![self.menuActionTypeList containsObject:@(MA_Forward)]) {
            NSMutableArray * newArr = [NSMutableArray arrayWithArray:self.menuActionTypeList];
            if (![[QIMKit sharedInstance] getIsIpad]) {
                [newArr addObject:@(MA_Forward)];
            }
            self.menuActionTypeList = newArr;
        }
        [self showCopyMenu];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QIMMenuImageViewCancelHightlighted object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//默认copy菜单
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    if([super becomeFirstResponder]) {
        self.highlighted = YES;
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder {
    if([super resignFirstResponder]) {
        self.highlighted = NO;
        return YES;
    }
    return NO;
}

- (void)copy:(id)sender {
    //剪贴版
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:self.text];
    self.highlighted = NO;
    [self resignFirstResponder];
}

-(void)setClipboardWitxthText:(NSString *)text {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:text];
    
}

- (void)toWithdrawMsg:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_ToWithdraw];
    }
}

- (void)replyMsg:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_ReplyMsg];
    }
}

- (void)forwardMsgs:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Forward];
    }
}

- (void)referMsgs:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Refer];
    }
}

- (void)copyOriginMsg:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_CopyOriginMsg];
    }
}

-(void)deleteMsg:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Delete];
    }
}

- (void)copyMethod:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Copy];
    }
}

- (void)collectionMethod:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Collection];
    }
}

- (void)favoriteMethod:(id)sender {
    
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Favorite];
    }
}

- (void)transmitMsg:(id)sender
{
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Repeater];
    }
}


- (void)transmitSMSMsg:(id)sender{
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_RepeaterToSMS];
    }
}

- (void)saveAddressBook:(id)sender{
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_SaveAddressBook];
    }
}

- (void)callPhone:(id)sender
{
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_CallPhone];
    }
}

- (void)moreItem:(id)sender{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:NO];
    [menu update];
    [menu setTargetRect: CGRectZero inView:self];
    [menu setMenuVisible:YES animated:YES];   //4.0 系统必须要动画，否则不弹出菜单
}

- (NSDictionary *)menuItemDicts {
    return @{@(MA_Copy) : @{@"MenuTitle" : @"复制文字", @"MenuAction" : @"copyMethod:"},
             @(MA_Collection) : @{@"MenuTitle" : @"添加为表情", @"MenuAction" : @"collectionMethod:"},
             @(MA_Favorite) : @{@"MenuTitle" : @"收藏", @"MenuAction" : @"favoriteMethod:"},
             @(MA_Repeater) : @{@"MenuTitle" : @"转发", @"MenuAction" : @"transmitMsg:"},
             @(MA_Delete) : @{@"MenuTitle" : @"删除", @"MenuAction" : @"deleteMsg:"},
             @(MA_ReplyMsg) : @{@"MenuTitle" : @"回复", @"MenuAction" : @"replyMsg:"},
             @(MA_ToWithdraw) : @{@"MenuTitle" : @"撤回", @"MenuAction" : @"toWithdrawMsg:"},
             @(MA_Forward) : @{@"MenuTitle" : @"更多", @"MenuAction" : @"forwardMsgs:"},
             @(MA_Refer) : @{@"MenuTitle" : @"引用", @"MenuAction" : @"referMsgs:"},
             @(MA_CopyOriginMsg) : @{@"MenuTitle" : @"原始消息", @"MenuAction" : @"copyOriginMsg:"},
             };
}

-(void)showCopyMenu {
    if([self becomeFirstResponder]) {
        NSMutableArray * menuItems = [NSMutableArray array];
        for (NSNumber *actionType in self.menuActionTypeList) {
            MenuActionType menuType = actionType.intValue;
            NSDictionary *menuDict = [[self menuItemDicts] objectForKey:@(menuType)];
            NSString *menuTitle = [menuDict objectForKey:@"MenuTitle"];
            NSString *menuSelector = [menuDict objectForKey:@"MenuAction"];
            switch (menuType) {
                case MA_ToWithdraw:
                {
                    BOOL flag = YES;
                    if ([[self message] messageDirection] != MessageDirection_Sent) {
                        flag = NO;
                    }
                    long long date = self.message.messageDate;
                    if (date > 140000000000) {
                        date = date / 1000;
                    }
                    date = date + [[QIMKit sharedInstance] getServerTimeDiff];
                    if ([[NSDate dateWithTimeIntervalSince1970:date] qim_isEarlierThanDate:[NSDate qim_dateWithMinutesBeforeNow:2]]) {
                        flag = NO;
                    }
                    if (flag) {
                        
                        UIMenuItem *toWithdrawItem = [[UIMenuItem alloc] initWithTitle:menuTitle
                                                                                action:NSSelectorFromString(menuSelector)];
                        [menuItems addObject:toWithdrawItem];
                    }
                }
                    break;
                default: {
                    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:menuTitle
                                                                      action:NSSelectorFromString(menuSelector)];
                    [menuItems addObject:menuItem];
                }
                    break;
            }
        }
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (menu.menuVisible)
        {
            [menu setMenuVisible:NO animated:YES];
        }
        if (menuItems.count > 0) {
            menu.menuItems = menuItems;
            [menu update];
            [menu setTargetRect:CGRectMake(self.centerX / 3.0, 0, 0, 0) inView:self];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}


@end
