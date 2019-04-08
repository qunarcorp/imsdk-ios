//
//  QIMUUIDTools.h
//  qunarChatMac
//
//  Created by 平 薛 on 14-11-24.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMUUIDTools : NSObject
+ (NSString *)deviceUUID;
+ (NSString *)UUID;
+ (NSString *)OriginalUUID;
+ (NSString *)loginUserName;
+ (NSString *)getUUIDFromKeyChain;
+ (BOOL) setUUID:(NSString *) deviceUid;
+ (BOOL) setUserName:(NSString *) username;

#pragma mark - cookie

+ (BOOL) setQCookie:(NSString *)qcookie;

+ (BOOL) setVCookie:(NSString *)vcookie;

+ (BOOL) setTCookie:(NSString *)tcookie;

+ (NSString *)qcookie;

+ (NSString *)vcookie;

+ (NSString *)tcookie;

#pragma mark - RequestURL & RequestDomain

/**
 设置请求文件服务头
 
 @param requestFileUrl 请求文件服务地址
 @return YES成功，NO失败
 */
+ (BOOL) setRequestFileURL:(NSData *)requestFileUrl;

/**
 获取文件服务头
 
 @return requestUrl
 */
+ (NSData *)getRequestFileUrl;

/**
 设置请求Url头
 
 @param requestUrl 请求Domain
 @return YES成功，NO失败
 */
+ (BOOL) setRequestURL:(NSData *)requestUrl;

/**
 获取请求URL
 
 @return requestUrl
 */
+ (NSData *)getRequestUrl;

/**
 设置请求URL Domain
 
 @param requestDoamin 请求Domain
 @return YES成功，NO失败
 */
+ (BOOL) setRequestDomain:(NSData *)requestDoamin;

/**
 获取请求Doamin
 
 @return requestDoamin
 */
+ (NSData *)getRequestDoamin;

#pragma mark - 联系人列表

+ (NSData *)getHeadImageForUserId:(NSString *)userId;

+ (BOOL) setHeadImage:(NSData *)headImage forUserId:(NSString *)userId;

/**
 *  设置最近联系人列表
 *
 *  @param sessionList 最近联系人列表
 *
 *  @return YES成功，NO失败
 */
+ (BOOL) setUUIDToolsSessionList:(NSData *)sessionList;

/**
 *  设置群组列表
 *
 *  @param sessionList 群组列表
 *
 *  @return YES成功，NO失败
 */
+ (BOOL) setUUIDToolsMyGroupList:(NSData *)groupList;

/**
 *  设置好友列表
 *
 *  @param friendList 好友列表
 *
 *  @return YES成功，NO失败
 */
+ (BOOL) setUUIDToolsFriendList:(NSData *)friendList;


/**
 设置最近分享过的联系人列表

 @param recentSharedList 最近分享过的联系人列表
 @return YES 成功， NO 失败
 */
+ (BOOL) setRecentSharedList:(NSData *)recentSharedList;

/**
 *  获取最近联系人列表
 *
 *  @return 最近联系人列表数据
 */
+ (NSData *)getSessionList;

/**
 *  获取群组联系人列表
 *
 *  @return 群组联系人列表
 */
+ (NSData *)getMyGroupList;

/**
 *  获取个人联系人列表
 *
 *  @return 个人联系人列表
 */
+ (NSData *)getFriendList;


/**
 获取最近分享过的联系人列表

 @return 最近分享过的联系人列表
 */
+ (NSData *)getRecentSharedList;
@end
