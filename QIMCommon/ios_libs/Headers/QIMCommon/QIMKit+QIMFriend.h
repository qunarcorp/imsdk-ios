//
//  QIMKit+QIMFriend.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMKit.h"

@interface QIMKit (QIMFriend)

- (NSMutableDictionary *)getFriendListDict;

- (void)updateFriendList;

- (void)updateFriendInviteList;

#pragma mark - friend

/**
 获取某人好友验证的类型
 
 @param userId user id
 @return 返回验证类型信息
 */
- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)userId;

/**
 设置我的好友验证类型(带问题答案的)
 
 @param mode 好友验证类型
 @param question 问题
 @param answer 答案
 @return 是否成功
 */
- (BOOL)setVerifyFreindMode:(int)mode WithQuestion:(NSString *)question WithAnswer:(NSString *)answer;

/**
 get friends 信息？
 
 @return 返回friends信息
 */
- (NSString *)getFriendsJson;

/**
 请求添加好友
 
 @param xmppId 请求好友id
 @param answer 答案(如果需要有)
 */
- (void)addFriendPresenceWithXmppId:(NSString *)xmppId WithAnswer:(NSString *)answer;

/**
 回复好友请求
 
 @param xmppId 请求好友id
 @param reason 原因
 */
- (void)validationFriendWihtXmppId:(NSString *)xmppId WithReason:(NSString *)reason;

/**
 同意好友请求
 
 @param xmppId 对方id
 */
- (void)agreeFriendRequestWithXmppId:(NSString *)xmppId;

/**
 拒绝好友请求
 
 @param xmppId 对方id
 */
- (void)refusedFriendRequestWithXmppId:(NSString *)xmppId;

/**
 删除好友
 
 @param xmppId 对方id
 @param mode mode1为单项删除，mode为2为双项删除
 @return 返回处理结果
 */
- (BOOL)deleteFriendWithXmppId:(NSString *)xmppId WithMode:(int)mode;

/**
 获取好友验证类型
 
 @param xmppId 对方id
 @return 返回好友验证type
 */
- (int)getReceiveMsgLimitWithXmppId:(NSString *)xmppId;

/**
 设置好友验证类型
 
 @param mode QIMVerifyMode
 @return 返回处理结果
 */
- (BOOL)setReceiveMsgLimitWithMode:(int)mode;

- (NSDictionary *)getLastFriendNotify;

- (NSInteger)getFriendNotifyCount;

@end
