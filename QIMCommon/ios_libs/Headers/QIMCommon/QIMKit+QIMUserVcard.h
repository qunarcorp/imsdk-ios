//
//  QIMKit+QIMUserVcard.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/23.
//

#import "QIMKit.h"

@interface QIMKit (QIMUserVcard)

/**
 更新用户备注信息
 
 @param userId 用户Id
 @param markUpName 用户备注
 */
- (void)updateUserMarkupNameWithUserId:(NSString *)userId WithMarkupName:(NSString *)markUpName;

/**
 获取用户备注信息
 
 @param userId 用户Id
 @return 用户备注
 */
- (NSString *)getUserMarkupNameWithUserId:(NSString *)userId;

/**
 更新用户名片

 @param xmppIds 用户Id数组
 */
- (void)updateUserCard:(NSArray *)xmppIds;

/**
 *  通过userId获取用户大头像
 *
 *  @param userId 头像url
 */
- (NSString *)getUserBigHeaderImageUrlWithUserId:(NSString *)userId;

- (void)updateUserBigHeaderImageUrl:(NSString *)url WihtVersion:(NSString *)version ForUserId:(NSString *)userId ;


/**
 更新我的名片信息
 */
- (void)updateMyCard;

/**
 更新QChat群成员
 
 @param groupId 群id
 */
- (void)updateQChatGroupMembersCardForGroupId:(NSString *)groupId;

/**
 更新我的头像

 @param photoData 头像二进制
 */
- (void)updateMyPhoto:(NSData *)photoData;

/**
 *  根据用户Id获取用户信息
 *
 *  @param myId 用户Id
 *
 *  @return 用户信息Info
 */
- (NSDictionary *)getUserInfoByUserId:(NSString *)myId;

/**
 + 根据用户Id获取WorkInfo
 + */
- (NSDictionary *)getUserWorkInfoByUserId:(NSString *)userId;


/**
 获取远端用户职工信息

 @param userId 用户Id
 */
- (NSDictionary *)getRemoteUserWorkInfoWithUserId:(NSString *)userId;


/**
 获取用户手机号

 @param qtalkId qtalkId
 */
- (NSString *)getPhoneNumberWithUserId:(NSString *)qtalkId;

/**
 *  通过nickName获取用户信息
 *
 *  @param nickName 昵称
 *
 *  数据样例： @"李露lucas"
 {
     DescInfo = "/旅游度假事业部/技术/当地人客户端开发";
     HeaderScr = "lilulucas.li@ejabhost1.jpg";
     LastUpdateTime = 5;
     Name = "\U674e\U9732lucas";
     SearchIndex = "liloulucas|liloulucas|lilulucas.li|lllucas|lllucas|";
     UserId = "lilulucas.li";
     XmppId = "lilulucas.li@ejabhost1";
 }
 */
//TODO 先本地获取名片，若无再取数据库
- (NSDictionary *)getUserInfoByName:(NSString *)nickName;

#pragma mark - 用户头像

/**
 *  根据用户Id更新用户头像
 *
 *  @param userId 用户Id
 */
/*
- (void)takeUserHeaderByUserId:(NSString *)userId;
*/

/**
 用户默认头像
 */
+ (NSData *)defaultUserHeaderImage;

+ (NSString *)defaultUserHeaderImagePath;

/**
 第三方Cell默认头像
 
 @return 用户头像
 */
+ (UIImage *)defaultCommonTrdInfoImage ;

+ (NSString *)defaultCommonTrdInfoImagePath;

/**
 根据用户Id获取用户名片信息

 @param rtxId 用户Id
 */
- (NSDictionary *)getUserInfoByRTX:(NSString *)rtxId ;

/**
 更新用户签名

 @param userId 用户Id
 @param signature 个性签名
 */
- (void)updateUserSignatureForUser:(NSString *)userId signature:(NSString *)signature;


/**
 获取用户Profile

 @param userId 用户Id
 @param update 是否需要更新
 @param block 回调
 */
- (void)userProfilewithUserId:(NSString *)userId needupdate:(BOOL)update withBlock:(void (^)(NSDictionary *))block;

/**
 本地获取用户Profile
 
 @param userId 用户Id
 */
- (NSDictionary *)getLocalProfileForUserId:(NSString *)userId;

/**
 *  获取userProfile
 *
 *  @param userIds 用户ID
 *
 *  @return userProfile
 *  数据样例：
 
 "dan.liu@ejabhost1" =     {
 M = "\U8fd9\U592aimba\U4e86!";
 U = "dan.liu";
 V = 19;
 };
 */
- (NSDictionary *)getRemoteUserProfileForUserIds:(NSArray *)userIds;


/**
 根据用户Id获取QChat 用户名片信息

 @param user 用户Id
 */
- (NSDictionary *)getQChatUserInfoForUser:(NSString *)user;

#pragma mark - 跨域

/**
 搜索用户(跨域)
 
 @param searchStr 关键词
 @return 返回用户列表
 */
- (NSArray *)searchQunarUserBySearchStr:(NSString *)searchStr;

/**
 搜索用户
 
 @param searchStr 关键词
 @return 返回用户列表
 */
- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr;

- (NSInteger)searchUserListTotalCountBySearchStr:(NSString *)searchStr;

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

/**
 搜索用户(全平台)
 
 @param searchStr 关键词
 @param searchURL search url
 @param Id id
 @param limitNum 限制条数
 @param offset 偏移量
 @return 返回用户列表
 */
- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr Url:(NSString *)searchURL id:(NSString *)Id limit:(NSInteger)limitNum offset:(NSInteger)offset;

@end
