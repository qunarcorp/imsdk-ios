//
//  QIMKit+QIMCollection.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/30.
//

#import "QIMKit.h"

@interface QIMKit (QIMCollection)


#pragma mark - 代收账号

- (NSString *)getCollectionUserHeaderUrlWithXmppId:(NSString *)userId;

/**
 获取代收账号名片信息

 @param myId 用户Id
 @return 代收账号名片信息
 */
- (NSDictionary *)getCollectionUserInfoByUserId:(NSString *)myId;

- (void)updateCollectionUserCardByUserIds:(NSArray *)userIds;

/**
 获取已代收账号列表
 
 @return 已代收账号列表
 */
- (NSArray *)getMyCollectionAccountList;

/**
 http接口获取我的绑定账号列表
 */
- (void)getRemoteCollectionAccountList;


#pragma mark - 代收Group

/**
 根据群Id获取群名片信息

 @param groupId 群Id
 @return 群名片信息
 */
- (NSDictionary *)getCollectionGroupCardByGroupId:(NSString *)groupId;

/**
 主动根据群Id更新群名片信息

 @param groupId 群Id
 */
- (void)updateCollectionGroupCardByGroupId:(NSString *)groupId;


- (NSString *)getCollectionGroupHeaderUrlWithCollectionGroupId:(NSString *)groupId;


#pragma mark - 代收Message

/**
 根据绑定账号BindId获取该账号下的消息列表

 @param bindId 绑定账号BindId
 */
- (NSArray *)getCollectionSessionListWithBindId:(NSString *)bindId;

/**
 根据MsgId获取代收消息
 
 @param lastMsgId lastMsgId
 */
- (NSDictionary *)getLastCollectionMsgByMsgId:(NSString *)lastMsgId;


- (NSArray *)getCollectionMsgListWithBindId:(NSString *)bindId;

/**
 保存代收消息到数据库

 @param collectionMsgDic 代收消息Dic
 */
- (void)saveCollectionMessage:(NSDictionary *)collectionMsgDic;

/**
 根据MsgId获取代收消息

 @param msgId msgId
 */
- (Message *)getCollectionMsgListForMsgId:(NSString *)msgId;

/**
 根据绑定用户Id及消息来源Id获取代收消息列表

 @param userId 消息来源人Id
 @param originUserId 绑定用户Id
 */
- (NSArray *)getCollectionMsgListForUserId:(NSString *)userId originUserId:(NSString *)originUserId;


#pragma mark - 代收未读

/**
 根据Jid清空代收未读消息
 
 @param jid Jid
 */
- (void)clearNotReadCollectionMsgByJid:(NSString *)jid;

/**
 根据绑定账号 & 用户Id清空代收 未读消息
 
 @param bindId 绑定账号Id
 @param userId 用户Id
 */
- (void)clearNotReadCollectionMsgByBindId:(NSString *)bindId WithUserId:(NSString *)userId;

/**
 获取代收总未读消息数
 */
- (NSInteger)getNotReadCollectionMsgCount;

/**
 获取某绑定账号下的代收未读消息数
 
 @param bindId 绑定账号Id
 */
- (NSInteger)getNotReadCollectionMsgCountByBindId:(NSString *)bindId;

/**
 获取某绑定账号下 单一账号来的代收 未读消息
 
 @param bindId 绑定账号Id
 @param userId 用户Id
 */
- (NSInteger)getNotReadCollectionMsgCountByBindId:(NSString *)bindId WithUserId:(NSString *)userId;

@end
