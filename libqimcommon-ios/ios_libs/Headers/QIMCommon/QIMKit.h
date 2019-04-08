//
//  QIMKit.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QIMCommonEnum.h"

@class Message;
@interface QIMKit : NSObject

+ (QIMKit *)sharedInstance;

- (void)clearQIMManager;

- (NSMutableDictionary *)timeStempDic;

- (dispatch_queue_t)getLastQueue;

- (NSString *)getImagerCache;

/**
 更新remote key
 
 @return 返回remote key
 */
- (NSString *)updateRemoteLoginKey;

@end

@interface QIMKit (Common) <NSXMLParserDelegate>

- (NSData *)updateOrganizationalStructure;

- (NSData *)updateRosterList;

- (void)updateUserSuoXie;

- (void)synchServerTime;

- (void)checkRosterListWithForceUpdate:(BOOL)forceUpdate;

@end


@interface QIMKit (CommonConfig)

//认证


/**
 UK，登录之后服务器下发下来，用作旧接口的验证
 */
- (NSString *)remoteKey;

/**
 get remote key
 
 @return 返回remote key
 */
- (NSString *)myRemotelogginKey;


/**
 第三方认证的key - Ckey/q_ckey
 
 @return 返回Base64后的Key
 */
- (NSString *) thirdpartKeywithValue;


/**
 手动设置客服状态

 @param isMerchant 客服状态
 */
- (void)setIsMerchant:(BOOL)isMerchant;

/**
 客服状态
 */
- (BOOL)isMerchant;

/**
 *  UserName Ex: lilulucas.li
 *
 *  @return UserName
 */
+ (NSString *)getLastUserName;

/**
 *  PWD
 *
 *  @return 无用
 */
- (NSString *)getLastPassword;

/**
 *  JID  Ex: lilulucas.li@ejabhost1
 *
 *  @return JID
 */
- (NSString *)getLastJid;

/**
 *  nickName  Ex: 李露lucas
 *
 *  @return MyNickName
 */
- (NSString *)getMyNickName;

/**
 获取当前登录的公司
 */
- (NSString *)getCompany;

/**
 获取当前登录的domain
 */
- (NSString *)getDomain;

/**
 偷摸获取客户端Ip地址
 */
- (NSString *)getClientIp;


- (long long)getCurrentServerTime;


- (int)getServerTimeDiff;

- (NSHTTPCookie *)cookie;

// 更新导航配置
- (void)updateNavigationConfig;

- (void)checkClientConfig;

/**
 获取trdExtendInfo
 
 @return 返回trdExtendInfo
 */
- (NSArray *)trdExtendInfo;

/**
 获取AA收款URL

 @return 返回aaCollectionUrlHost
 */
- (NSString *)aaCollectionUrlHost;

/**
 获取红包URL

 @return 返回redPackageUrlHost
 */
- (NSString *)redPackageUrlHost;

/**
 获取余额URL

 @return 返回redPackageBalanceUrl
 */
- (NSString *)redPackageBalanceUrl;

/**
 获取我的红包URL

 @return 返回myRedpackageUrl
 */
- (NSString *)myRedpackageUrl;

/**
 新消息通知？
 
 @return bool值
 */
- (BOOL)isNewMsgNotify;

/**
 设置新消息通知？
 
 @param flag bool值
 */
- (void)setNewMsgNotify:(BOOL)flag;
//相册是否发送原图
- (BOOL)pickerPixelOriginal;

- (void)setPickerPixelOriginal:(BOOL)flag;

//是否优先展示对方个性签名
- (BOOL)moodshow;

/**
 设置 mood show
 
 @param flag bool值
 */
- (void)setMoodshow:(BOOL)flag;

/**
 获取At me的
 
 @param jid 会话id
 @return 返回结果
 */
- (NSArray *)getHasAtMeByJid:(NSString *)jid ;

- (void)addAtMeByJid:(NSString *)jid WithNickName:(NSString *)nickName;

- (void)removeAtMeByJid:(NSString *)jid;

- (void)addAtALLByJid:(NSString *)jid WithMsgId:(NSString *)msgId WihtMsg:(Message *)message WithNickName:(NSString *)nickName;

/**
 移除atall
 
 @param jid 用户id
 */
- (void)removeAtAllByJid:(NSString *)jid;

/**
 获取atall
 
 @param jid user id
 @return 返回atall信息
 */
- (NSDictionary *)getAtAllInfoByJid:(NSString *)jid;

- (NSDictionary *)getNotSendTextByJid:(NSString *)jid ;

- (void)setNotSendText:(NSString *)text inputItems:(NSArray *)inputItems ForJid:(NSString *)jid;

/**
 qchat获取token
 
 @return 返回token
 */
- (NSDictionary *)getQChatTokenWithBusinessLineName:(NSString *)businessLineName;

- (NSDictionary *)getQVTForQChat;

- (void)removeQVTForQChat;

- (NSString *)getDownloadFilePath;

/**
 清空缓存
 */
- (void)clearcache;

/**
 置顶/ 移除置顶
 
 @param jid 需要置顶的jid
 */
- (BOOL)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType;

/**
 置顶/ 移除置顶
 
 @param jid 需要置顶的jid
 @param chatType 会话类型
 */
- (BOOL)removeStickWithCombineJid:(NSString *)jid WithChatType:(ChatType)chatType;

/**
 是否已置顶
 
 @param jid session id
 @return 返回判定结果
 */
- (BOOL)isStickWithCombineJid:(NSString *)jid;

/**
 获取置顶列表
 
 @return 置顶的会话列表
 */
- (NSDictionary *)stickList;

- (BOOL)setMsgNotifySettingWithIndex:(QIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn;

- (BOOL)getLocalMsgNotifySettingWithIndex:(QIMMSGSETTING)setting;

- (void)getMsgNotifyRemoteSettings;

/**
 关闭通知
 */
- (void)sendNoPush;


/**
 上传推送Token到服务器

 @param notificationToken 注册的通知Token
 @param username 用户名
 @param paramU 用户ming
 @param paramK 用户验证的key
 @param deleteFlag 是否删除服务器推送Token
 @return 上传是否成功
 */
- (BOOL)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag;

/**
 发送push Token

 @param myToken 注册的通知token
 @param deleteFlag 是否删除
 */
- (BOOL)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag;

- (void)checkClearCache;

/**
 获取用户在线状态
 
 @param sid 用户
 @return 返回状态值
 */
- (NSString *)userOnlineStatus:(NSString *)sid;

/**
 判断用户是否在线
 
 @param userId user di
 @return 返回是否在线
 */
- (BOOL)isUserOnline:(NSString *)userId;

- (UserPrecenseStatus)getUserPrecenseStatus:(NSString *)jid;

/**
 获取用户 precense status
 
 @param jid 用户id
 @param status status指针
 @return 返回status
 */
- (UserPrecenseStatus)getUserPrecenseStatus:(NSString *)jid status:(NSString **)status;

@end
