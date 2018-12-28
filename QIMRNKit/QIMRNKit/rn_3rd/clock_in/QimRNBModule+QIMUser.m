//
//  QimRNBModule+QIMUser.m
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QimRNBModule+QIMUser.h"

@implementation QimRNBModule (QIMUser)

+ (NSDictionary *)qimrn_getUserInfoByUserId:(NSString *)userId {

    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        [[QIMKit sharedInstance] getQChatUserInfoForUser:userId];
    } else {
    }
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    NSString *headerSrc = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:userId];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:userId forKey:@"UserId"];
    [properties setObject:[userInfo objectForKey:@"Name"]?[userInfo objectForKey:@"Name"]:[userId componentsSeparatedByString:@"@"].firstObject forKey:@"Name"];
    [properties setObject:headerSrc?headerSrc:@"" forKey:@"HeaderUri"];
    [properties setObject:remarkName?remarkName:@"" forKey:@"Remarks"];
    [properties setObject:[userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"" forKey:@"Department"];
    return properties;
}

+ (NSString *)qimrn_getUserMoodByUserId:(NSString *)userId {
    if (!userId || userId.length <= 0) {
        return @"这家伙很懒,什么都没留下";
    }
    NSDictionary * usersInfo = [[QIMKit sharedInstance] getLocalProfileForUserId:userId];
    if (!usersInfo) {
        usersInfo = [[[QIMKit sharedInstance] getRemoteUserProfileForUserIds:@[userId]] objectForKey:userId];
    }
    NSString *mood = [usersInfo objectForKey:@"M"];
    return mood?mood:@"这家伙很懒,什么都没留下";
}

+ (NSArray *)qimrn_getUserMedalByUserId:(NSString *)xmppId {
    if (!xmppId || xmppId.length <= 0) {
        return nil;
    }
    NSArray *localUserMedals = [[QIMKit sharedInstance] getLocalUserMedalWithXmppJid:xmppId];
    return localUserMedals;
}

@end
