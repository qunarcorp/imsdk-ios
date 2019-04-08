//
//  QimRNBModule+QIMGroup.h
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QimRNBModule.h"

@interface QimRNBModule (QIMGroup)

+ (NSArray *)qimrn_getGroupMembersByGroupId:(NSString *)groupId;

+ (NSDictionary *)qimrn_getGroupInfoByGroupId:(NSString *)groupId;

@end
