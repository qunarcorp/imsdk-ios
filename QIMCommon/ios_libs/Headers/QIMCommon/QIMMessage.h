//
//  Message.h
//  qunarChatMac
//
//  Created by ping.xue on 14-2-28.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMCommonEnum.h"
@class MessageEntity;

@interface ChatSession : NSObject

@property (nonatomic, copy)   NSString          *sessionId;
@property (nonatomic, copy)   NSString          *userId;
@property (nonatomic, copy)   NSString          *userName;
@property (nonatomic, copy)   NSString          *headerUrl;
@property (nonatomic, copy)   NSString          *lastMsgId;
@property (nonatomic, copy)   NSString          *msgContent;
@property (nonatomic, assign) MessageState      msgState;
@property (nonatomic, assign) QIMMessageType       msgType;
@property (nonatomic, assign) MessageDirection  msgDirection;
@property (nonatomic, assign) long long         lastUpdatetime;
@property (nonatomic, assign) NSInteger         notReadCount;

@end

@interface Message : NSObject 

@property (nonatomic, copy)   NSString          *messageId;                 //消息Id
@property (nonatomic, copy)   NSString          *from;                      //消息发送方
@property (nonatomic, copy)   NSString          *to;                        //消息接收方
@property (nonatomic, copy)   NSString          *realFrom;                  //消息真实发送方
@property (nonatomic, copy)   NSString          *realTo;                    //消息真实接受方
@property (nonatomic, copy)   NSString          *ochatJson;
@property (nonatomic, copy)   NSString          *channelInfo;               //消息channelInfo
@property (nonatomic, copy)   NSString          *message;                   //消息Body体
@property (nonatomic, copy)   NSString          *extendInformation;         //消息的扩展信息
@property (nonatomic, copy)   NSString          *backupInfo;                //群艾特消息，携带BackUpInfo
@property (nonatomic, strong) NSDictionary      *appendInfoDict;            //qchat需求 -> 对方发送过来携带的cctext，bu等字段，发回去消息时务必携带

@property (nonatomic, copy)   NSString          *chatId;                    //Consult消息必须携带

#warning 8.22发送地理位置临时改动
@property (nonatomic, copy)   NSString          *originalMessage;
@property (nonatomic, copy)   NSString          *originalExtendedInfo;

@property (nonatomic, copy)   NSString          *resolveStr;
@property (nonatomic, copy)   NSString          *nickName;

@property (nonatomic, copy)   NSString          *realJid;

@property (nonatomic, assign) IMPlatform        platform;                   //消息发送方的平台
@property (nonatomic, assign) QIMMessageType    messageType;                //消息的Type
@property (nonatomic, assign) MessageState      messageState;               //消息当前状态
@property (nonatomic, assign) MessageDirection  messageDirection;           //消息方向
@property (nonatomic, assign) ChatType          originChatType;             //代收消息 -> 原始消息的ChatType
@property (nonatomic, assign) ChatType          chatType;                   //消息的ChatType
@property (nonatomic, assign) long long         messageDate;                //消息时间戳
@property (nonatomic, assign) long long         version;
@property (nonatomic, strong) NSData            * imageData;
@property (nonatomic, strong) NSString          *MD5;// 保存图片only
@property (nonatomic, assign) int               propress;

@property (nonatomic, copy)   NSString          *xmppId;

@property (nonatomic, copy)   NSString          *replyMsgId;                //回复MsgId
@property (nonatomic, copy)   NSString          *replyUser;                 //回复用户

@property (nonatomic, copy)   NSString          *fromUser;
@property (nonatomic, assign) int               readTag;
@property (nonatomic, copy)   NSString          *msgRaw;                    //原始的消息完整体

- (NSDictionary *)getMsgInfoDic;

- (NSString *)messageId;


@end

