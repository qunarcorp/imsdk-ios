//
//  QTalkMessageManager.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QIMCommonUIFramework.h"

@interface QTalkMessageManager : NSObject

+ (QTalkMessageManager *)sharedInstance;

- (NSArray *)getSupportMsgTypeList;

// 会话Cell上显示的文字
- (void)setMsgShowText:(NSString *)showText ForMessageType:(QIMMessageType)messageType;
- (NSString *)getMsgShowTextForMessageType:(QIMMessageType)messageType;

// 消息气泡
- (void)registerMsgCellClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType;
- (void)registerMsgCellClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType;
- (Class)getRegisterMsgCellClassForMessageType:(QIMMessageType)messageType;
- (id)getRegisterMsgCellForMessageType:(QIMMessageType)messageType;

// 消息定制窗口
- (void)registerMsgVCClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType;
- (void)registerMsgVCClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType;
- (Class)getRegisterMsgVCClassForMessageType:(QIMMessageType)messageType;
- (id)getRegisterMsgVCForMessageType:(QIMMessageType)messageType;
- (void)addMsgTextBarWithImage:(NSString *)imageName WithTitle:(NSString *)title ForItemType:(QIMTextBarExpandViewItemType)itemType pushVC:(id)pushVC;
- (NSArray *)getMsgTextBarButtonInfoList;

- (void)removeExpandItemsForType:(QIMTextBarExpandViewItemType)itemType;
- (NSDictionary *)getExpandItemsForType:(QIMTextBarExpandViewItemType)itemType;

- (BOOL)hasExpandItemForType:(QIMTextBarExpandViewItemType)itemType;
- (void)removeAllExpandItems;

@end
