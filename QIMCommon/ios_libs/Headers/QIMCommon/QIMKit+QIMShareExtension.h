//
//  QIMKit+QIMShareExtension.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMShareExtension)

+ (BOOL) setUserName:(NSString *) username;

#pragma mark - 联系人列表

/**
 获取登录的用户名
 
 @return 返回用户名
 */
+ (NSString *) loginUserName;

+ (NSData *)getHeadImageForUserId:(NSString *)userId;

+ (BOOL) setHeadImage:(NSData *)headImage forUserId:(NSString *)userId;

/**
 *  设置最近联系人列表
 *
 *  @param sessionList 最近联系人列表
 *
 *  @return YES成功，NO失败
 */
+ (BOOL) setSessionList:(NSData *)sessionList;

/**
 *  设置最近联系人列表
 *
 *  @param sessionList 最近联系人列表
 *
 *  @return YES成功，NO失败
 */
+ (BOOL) setGroupSessionList:(NSData *)sessionList;

/**
 *  设置最近联系人列表
 *
 *  @param sessionList 最近联系人列表
 *
 *  @return YES成功，NO失败
 */
+ (BOOL) setPeopleSessionList:(NSData *)sessionList;


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
+ (NSData *)getGroupSessionList;

/**
 *  获取个人联系人列表
 *
 *  @return 个人联系人列表
 */
+ (NSData *)getPeopleSessionList;


/**
 获取最近分享过的联系人列表
 
 @return 最近分享过的联系人列表
 */
+ (NSData *)getRecentSharedList;

/**
 get string from keychain
 
 @param key key
 @return 返回string
 */
+ (NSString *)stringFromKeyChainForKey:(NSString *)key;

@end
