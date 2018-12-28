//
//  QIMChatNewVc.h
//  QIMUIKit
//
//  Created by 李露 on 10/18/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMBaseChatVc.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMChatNewVc : QIMBaseChatVc

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *bindId; //代收绑定的账号，默认为nil
@property (nonatomic, strong) NSString *stype;
@property (nonatomic, strong) NSDictionary *chatInfoDict;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL needShowNewMsgTagCell;
@property (nonatomic, assign) long long readedMsgTimeStamp;
@property (nonatomic, assign) long long fastMsgTimeStamp;   //搜索时候快速点击跳转的消息时间戳
@property (nonatomic, assign) int notReadCount;

@property (nonatomic, assign) ChatType chatType;
@property (nonatomic, strong) NSString *virtualJid;


@end

NS_ASSUME_NONNULL_END
