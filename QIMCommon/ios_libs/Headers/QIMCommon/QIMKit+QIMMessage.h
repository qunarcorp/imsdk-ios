//
//  QIMKit+QIMMessage.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"
@class Message;

@interface QIMKit (QIMMessage)

/**
 获取指定类型消息
 
 @param msgType 指定消息类型
 @return 返回消息组
 */
- (NSArray *)getMsgsForMsgType:(QIMMessageType)msgType;

- (NSDictionary *)getMsgDictByMsgId:(NSString *)msgId;

- (Message *)getMsgByMsgId:(NSString *)msgId;

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag;

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag;

#pragma mark - 公共消息

/**
 根据用户Id设置Message附加属性 {'cctext', 'bu'}
 
 @param appendInfoDict 附加字典
 @param userId 用户Id
 */
- (void)setAppendInfo:(NSDictionary *)appendInfoDict ForUserId:(NSString *)userId;

/**
 根据用户Id获取Message附加属性  {'cctext', 'bu'}
 
 @param userId 用户Id
 */
- (NSDictionary *)getAppendInfoForUserId:(NSString *)userId;

/**
 根据用户Id设置ChannelId
 
 @param channelId channelId
 @param userId 用户Id
 */
- (void)setChannelInfo:(NSString *)channelId ForUserId:(NSString *)userId;

/**
 根据用户Id获取ChannelId
 
 @param userId 用户Id
 */
- (NSString *)getChancelInfoForUserId:(NSString *)userId;


/**
 根据用户Id设置 点击聊天内容中的URL务必拼接的参数 （众包需求）
 
 @param param param
 @param jid 用户Id
 */
- (void)setConversationParam:(NSDictionary *)param WithJid:(NSString *)jid;

/**
 根据用户Id获取 点击聊天内容中的URL务必拼接的参数 （众包需求）
 
 @param jid 用户Id
 */
- (NSDictionary *)conversationParamWithJid:(NSString *)jid;

/**
 发送正在输入消息
 
 @param userId to 给谁？
 */
- (void)sendTypingToUserId:(NSString *)userId;

/**
 消息入库
 
 @param msg message
 @param sid 会话ID(单人为to，群为群id)
 */
- (void)saveMsg:(Message *)msg ByJid:(NSString *)sid;

//更新消息
- (void)updateMsg:(Message *)msg ByJid:(NSString *)sid;

- (void)deleteMsg:(Message *)msg ByJid:(NSString *)sid;

/**
 发送操作状态(单人会话专用)
 
 @param messages 消息集
 @param xmppId 跟谁的消息对话 to值
 @return 是否成功
 */
- (BOOL)sendControlStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId;

/**
 发送已读状态(单人会话专用)
 
 @param messages 消息集
 @param xmppId 跟谁的消息对话 to值
 @return 是否成功
 */
- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId;

/**
 发送已读状态(Consult会话专用)
 
 @param messages 消息集
 @param xmppId 跟谁的消息对话 to值
 @param realJid 真实 to值(consult消息用，普通消息此值传nil)
 @return 是否成功
 */
- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid;

/**
 发送已读状态(群消息用)
 
 @param lastTime 已读截止时间，一般为最后一条消息时间
 @param groupId 群ID
 @return 是否成功
 */
- (BOOL)sendReadstateWithGroupLastMessageTime:(long long) lastTime withGroupId:(NSString *) groupId;


#pragma mark - 单人消息

/**
 发送窗口抖动
 
 @param userId 对方用户Id
 */
- (Message *)sendShockToUserId:(NSString *)userId;


/**
 撤销单人消息
 
 @param messageId messageId
 @param message message
 @param jid jid
 */
- (void)revokeMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid;

/**
 发送文件消息
 
 @param fileJson 文件URL
 @param userId 对方UserId
 @param msgId 消息Id
 */
- (void)sendFileJson:(NSString *)fileJson ToUserId:(NSString *)userId WithMsgId:(NSString *)msgId;

/**
 发送语音消息
 
 @param voiceUrl 语音文件地址
 @param voiceName 语音文件名
 @param seconds 语音时长
 @param userId 接收方Id
 */
- (Message *)sendVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToUserId:(NSString *)userId;


/**
 发送消息
 
 @param msg 消息Message对象
 @param userId 接收方Id
 */
- (Message *)sendMessage:(Message *)msg ToUserId:(NSString *)userId;

/**
 发送单人消息
 
 @param msg 消息Body
 @param info 消息ExtendInfo
 @param userId 接收Id
 @param msgType 消息Type
 */
- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToUserId:(NSString *)userId WihtMsgType:(int)msgType;


// Note消息自动回复消息(您好，我是在线客服xxx，很高兴为您服务)
- (Message *)createNoteReplyMessage:(NSString *)msg ToUserId:(NSString *)user;

#pragma mark - 群消息


/**
 发送群消息
 
 @param msg 消息Body
 @param groupId 群Id
 */
- (Message *)sendMessage:(NSString *)msg ToGroupId:(NSString *)groupId ;


/**
 发送群消息
 
 @param msg 消息Body
 @param info 消息ExtendInfo
 @param groupId 群Id
 @param msgType 消息Type
 */
- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WihtMsgType:(int)msgType;


/**
 发送群消息
 
 @param msg 消息Body
 @param info 消息ExtendInfo
 @param groupId 群Id
 @param msgType 消息Type
 @param msgId 消息Id
 */
- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WihtMsgType:(int)msgType WithMsgId:(NSString *)msgId;

/**
 发送群窗口抖动
 
 @param groupId 群Id
 */
- (Message *)sendGroupShockToGroupId:(NSString *)groupId;

/**
 回复群消息
 
 @param replyMsgId 回复消息id
 @param replyUser 回复userid
 @param msgId 消息id
 @param message 消息
 @param groupId 群id
 @return 是否成功
 */
- (BOOL)sendReplyMessageId:(NSString *)replyMsgId WithReplyUser:(NSString *)replyUser WithMessageId:(NSString *)msgId WithMessage:(NSString *)message ToGroupId:(NSString *)groupId;

/**
 撤销群消息
 
 @param messageId messageId
 @param message message
 @param jid jid
 */
- (void)revokeGroupMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid;

/**
 发送群文件
 
 @param fileJson 文件地址
 @param groupId 群Id
 @param msgId 消息Id
 */
- (void)sendFileJson:(NSString *)fileJson ToGroupId:(NSString *)groupId WihtMsgId:(NSString *)msgId;


/**
 发送群语音消息
 
 @param voiceUrl 语音文件地址
 @param voiceName 语音文件名称
 @param seconds 语音时长
 @param groupId 群Id
 */
- (Message *)sendGroupVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToGroupId:(NSString *)groupId;

// Note消息自动回复消息(您好，我是在线客服xxx，很高兴为您服务)
- (Message *)createNoteReplyMessage:(NSString *)msg ToGroupId:(NSString *)groupId;

// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid;

- (void)sendWlanMessage:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int)msgType completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler;

/**
 创建消息
 
 @param msg 消息文本
 @param extendInfo 扩展消息
 @param userId 用户id(单人id/群id/虚拟id)
 @param userType 会话类型 ChatType
 @param msgType 消息类型 MessageType
 @param mId 消息id，传nil会默认生成
 @param willSave 是否入库
 @return 返回创建的消息
 */
- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave;

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId msgState:(MessageState)msgState willSave:(BOOL)willSave;

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave;

- (Message *)sendMessage:(Message *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson;

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType;

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType backinfo:(NSString *)backInfo;

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId;

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid;

#pragma mark - 位置共享

/**
 发送共享位置消息
 
 @param msg 消息描述
 @param info 扩展消息
 @param jid 对象id
 @param msgType 消息类型
 @return 返回消息本身
 */
- (Message *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WihtMsgType:(int)msgType;

/**
 共享位置开始
 
 @param userId 用户id
 @param shareLocationId 共享位置标识
 @return 返回消息本身
 */
- (Message *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId;

/**
 共享位置开始(群)
 
 @param GroupId 群id
 @param shareLocationId 共享位置标识
 @return 返回消息本身
 */
- (Message *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId;

/**
 加入消息共享
 
 @param users 共享消息的用户组
 @param shareLocationId 共享消息标识
 @return 是否成功
 */
- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId;

/**
 发送我的位置给其他用户
 
 @param users 共享位置的用户组
 @param locationInfo 位置信息
 @param shareLocationId 共享消息标识
 @return 是否成功
 */
- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId;

/**
 退出位置共享
 
 @param users 共享位置的用户组
 @param shareLocationId 共享消息标识
 @return 是否成功
 */
- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId;

/**
 获取共享标识
 
 @param jid jid
 @return 返回共享消息标识
 */
- (NSString *)getShareLocationIdByJid:(NSString *)jid;

/**
 获取共享位置信息
 
 @param shareLocationId 共享位置标识
 @return 返回共享位置信息
 */
- (NSString *)getShareLocationFromIdByShareLocationId:(NSString *)shareLocationId;

/**
 获取共享位置用户组
 
 @param shareLocationId 共享位置标识
 @return 返回用户组
 */
- (NSArray *)getShareLocationUsersByShareLocationId:(NSString *)shareLocationId;


#pragma mark - 未读数

- (void)updateMsgReadCompensateSetWithMsgId:(NSString *)msgId WithAddFlag:(BOOL)flag WithState:(MessageState)state;

- (NSMutableSet *)getLastMsgCompensateReadSet;

/**
 *  返回未读消息数组
 */
- (NSArray *)getNotReaderMsgList;

/**
 清空所有未读消息
 */
- (void) clearAllNoRead;

/**
 清空HeadLine未读消息
 */
- (void)clearSystemMsgNotReadWithJid:(NSString *)jid;

/**
 根据Jid清空未读消息
 
 @param jid 用户Id
 */
- (void)clearNotReadMsgByJid:(NSString *)jid;

/**
 根据Jid & RealJid清空未读消息
 
 @param jid 用户Id
 @param realJid 真实用户Id
 */
- (void)clearNotReadMsgByJid:(NSString *)jid ByRealJid:(NSString *)realJid;

/**
 根据群Id清空未读消息
 
 @param groupId 群id
 */
- (void)clearNotReadMsgByGroupId:(NSString *)groupId;

/**
 获取Jid下的未读消息数
 
 @param jid Jid
 */
- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid;

/**
 获取Jid & 真实Id下的未读消息数
 
 @param jid 用户Id
 @param realJid 真实用户Id
 */
- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid;

- (void)updateAppNotReadCount;

/**
 获取App总未读数
 */
- (NSInteger)getAppNotReaderCount;

/**
 获取接收但不提醒的未读数
 */
- (NSInteger)getNotRemindNotReaderCount;

/**
 获取骆驼帮未读消息数
 */
- (void)getExploreNotReaderCount;

/**
 获取QChat商家未回复留言数
 */
- (NSInteger)getLeaveMsgNotReaderCount;

- (void)updateNotReadCountCacheByJid:(NSString *)jid WithRealJid:(NSString *)realJid;
- (void)updateMessageStateWithNewState:(MessageState)state ByMsgIdList:(NSArray *)MsgIdList;

- (void)updateNotReadCountCacheByJid:(NSString *)jid;

- (void)saveChatId:(NSString *)chatId ForUserId:(NSString *)userId;

- (void)setMsgSentFaild;

- (NSDictionary *)parseMessageByMsgRaw:(id)msgRaw;

- (NSDictionary *)parseOriginMessageByMsgRaw:(id)msgRaw;

- (NSArray *)getNotReadMsgIdListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid;

/**
 获取消息列表
 
 @param userId   用户名
 @param limit    获取条数
 @param realJid  真实jid
 @param offset   偏移量
 @param complete 回调block
 */
- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WihtLimit:(int)limit WithOffset:(int)offset WihtComplete:(void (^)(NSArray *))complete;

/**
 获取消息列表
 
 @param userId 虚拟id
 @param timeStamp 时间戳
 @param complete 回调block
 */
- (void)getMsgListByUserId:(NSString *)userId FromTimeStamp:(long long)timeStamp WihtComplete:(void (^)(NSArray *))complete;

/**
 获取消息列表
 
 @param userId 虚拟id
 @param realJid 真实id
 
 @param timeStamp 时间戳
 @param complete 回调block
 */
- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp WihtComplete:(void (^)(NSArray *))complete;

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete;

/**
 FS msg
 
 @param xmppId user id
 @return 返回结果
 */
- (NSArray *)getFSMsgByXmppId:(NSString *)xmppId;

/**
 FS msg
 
 @param msgId 消息表示
 @return 返回结果
 */
- (NSDictionary *)getFSMsgByMsgId:(NSString *)msgId;

- (void)checkOfflineMsg;

// ******************** 本地消息搜索 ***************************//

- (NSMutableArray *)searchLocalMessageByKeyword:(NSString *)keyWord
                                         XmppId:(NSString *)xmppid
                                        RealJid:(NSString *)realJid;

@end
