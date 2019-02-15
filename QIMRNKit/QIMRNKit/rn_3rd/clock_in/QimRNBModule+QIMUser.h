//
//  QimRNBModule+QIMUser.h
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QimRNBModule.h"

@interface QimRNBModule (QIMUser)

+ (NSDictionary *)qimrn_getUserInfoByUserId:(NSString *)userId;

+ (NSString *)qimrn_getUserMoodByUserId:(NSString *)userId;

+ (NSArray *)qimrn_getUserMedalByUserId:(NSString *)xmppId;

+ (NSDictionary *)qimrn_getUserLeaderInfoByUserId:(NSString *)userId;

@end
