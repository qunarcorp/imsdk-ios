//
//  QIMKit+QIMMessageManager.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMMessageManager)

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
- (void)addMsgTextBarWithImage:(NSString *)imageName WithTitle:(NSString *)title ForItemId:(NSString *)itemId;

- (void)addMsgTextBarWithTrdInfo:(NSDictionary *)trdExtendInfo;
- (NSArray *)getMsgTextBarButtonInfoList;

- (NSDictionary *)getExpandItemsForTrdextendId:(NSString *)trdextendId;

- (void)removeExpandItemsForType:(QIMTextBarExpandViewItemType)itemType;
- (NSDictionary *)getExpandItemsForType:(QIMTextBarExpandViewItemType)itemType;

- (BOOL)hasExpandItemForType:(QIMTextBarExpandViewItemType)itemType;
- (void)removeAllExpandItems;


@end
