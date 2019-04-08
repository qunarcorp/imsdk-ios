//
//  ImageLabel.h
//
//
//  Created by  apple on 08-10-31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QIMCommonUIFramework.h"

#define QIMMenuImageViewCancelHightlighted @"QIMMenuImageViewCancelHightlighted"
typedef enum{
    MA_Copy,        //拷贝
    MA_Repeater,    //转发
    MA_RepeaterToSMS,
    MA_Delete,      //删除
    MA_ToWithdraw,  //撤回
    MA_SaveAddressBook,
    MA_CallPhone,
    MA_ReplyMsg,    //回复
    MA_Collection,  //添加为表情
    MA_Favorite,    //收藏
    MA_Forward,     //更多
    MA_Refer,     //引用
    MA_CopyOriginMsg,   //拷贝原始消息
}MenuActionType;

typedef enum {
    MenuType_Normal,
    MenuType_SendCard,
    MenuType_ReceiveCard,
}MenuType;

@class Message;
@class QIMChatBubbleView;
@protocol QIMMenuImageViewDelegate;
@interface QIMMenuImageView : UIImageView<UIGestureRecognizerDelegate>
{
    QIMChatBubbleView      * _bubbleView;
}

@property (nonatomic, assign) MenuType menuType;
@property (nonatomic, weak) id <QIMMenuImageViewDelegate> delegate;
//如果是html只有删除按钮
@property (nonatomic, assign) BOOL IsHtml;
@property (nonatomic, copy)   NSString *text;
@property (nonatomic, assign) BOOL canShowMenu;
@property (nonatomic, assign) BOOL hideToWithdraw;//是否隐藏撤回消息
@property (nonatomic, retain) Message * message;

@property (nonatomic, retain) NSArray *menuActionTypeList;

- (void)showCopyMenu;
+ (void)cancelHighlighted;
- (void)setClipboardWitxthText:(NSString *)text;

- (void)setBubbleBgColor:(UIColor *)color;

- (void)onLongEvent:(UILongPressGestureRecognizer *)tag;

@end

@protocol QIMMenuImageViewDelegate <NSObject>
@optional
- (void)onMenuActionWithType:(MenuActionType)type;
@end
