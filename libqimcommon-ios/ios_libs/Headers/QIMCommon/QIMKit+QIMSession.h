//
//  QIMKit+QIMSession.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit.h"

@interface QIMKit (QIMSession)

/**
 set 当前的会话id
 
 @param userId 当前的会话id
 */
- (void)setCurrentSessionUserId:(NSString *)userId;

/**
 获取当前会话Id
 */
- (NSString *)getCurrentSessionUserId;

/**
 获取最近的单人会话session
 
 @return 返回session信息
 */
- (NSDictionary *)getLastedSingleChatSession;

/**
 获取最近对话列表
 
 @return 最近对话列表
 */
- (NSArray *)getSessionList;

/**
 获取最近有未读消息的会话列表
 */
- (NSArray *)getNotReadSessionList;

/**
 *  清除会话列表
 */
- (void)deleteSessionList;

/**
 根据XmppId移除某一会话

 @param sid xmppId
 */
- (void)removeSessionById:(NSString *)sid;

/**
 根据虚拟账号Id 及 用户RealJid 移除某一Consult会话

 @param sid 虚拟账号Id
 @param realJid 用户真实Id
 */
- (void)removeConsultSessionById:(NSString *)sid RealId:(NSString *)realJid;

- (ChatType)getChatSessionTypeByXmppId:(NSString *)xmppId;

/**
 根据用户Id & 名称打开一个单人会话

 @param userId 用户Id
 @param name 用户名称
 */
- (ChatType)openChatSessionByUserId:(NSString *)userId;

/**
 根据群Id & 群名称打开一个群会话

 @param groupId 群Id
 @param name 群名称
 */
- (void)openGroupSessionByGroupId:(NSString *)groupId ByName:(NSString *)name;


/**
 根据虚拟账号Id & 用户真实Id RealJid 及会话类型打开一个会话

 @param userId 虚拟账号Id
 @param realJid 用户真实Id
 @param chatType 会话类型
 */
- (void)openChatSessionByUserId:(NSString *)userId ByRealJid:(NSString *)realJid WithChatType:(ChatType)chatType;


/**
 新增一个Consult会话

 @param sessionId sessionId
 @param realJid 用户真实Id
 @param userId 虚拟账号Id
 @param msgId msgId
 @param open 是否打开
 @param lastUpdateTime lastUpdateTime
 @param chatType 会话类型
 */
- (void)addConsultSessionById:(NSString *)sessionId ByRealJid:(NSString *)realJid WithUserId:(NSString *)userId ByMsgId:(NSString *)msgId WithOpen:(BOOL)open WithLastUpdateTime:(long long)lastUpdateTime WithChatType:(ChatType)chatType;


/**
 新增一个普通会话

 @param type 会话类型
 @param jid 会话Id
 @param msgId 消息Id
 @param msgTime 消息时间戳
 */
- (void)addSessionByType:(ChatType)type ById:(NSString *)jid ByMsgId:(NSString *)msgId WithMsgTime:(long long)msgTime WithNeedUpdate:(BOOL)needUpdate;

@end
