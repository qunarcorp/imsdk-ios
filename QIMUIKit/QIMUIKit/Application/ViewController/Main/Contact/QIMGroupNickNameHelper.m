//
//  QIMGroupNickNameHelper.m
//  Vacation
//
//  Created by admin on 15/12/16.
//  Copyright © 2015年 Qunar.com. All rights reserved.
//

#import "QIMGroupNickNameHelper.h"

static NSMutableDictionary *__global_gndic = nil;

@implementation QIMGroupNickNameHelper

+ (NSString *)getGroupMemberNickNameByQnrId:(NSString *)qnrId{
    qnrId = [qnrId copy];
    if (__global_gndic == nil) {
        __global_gndic = [NSMutableDictionary dictionary];
    }
    NSString *nickName = [__global_gndic objectForKey:qnrId];
    if (nickName == nil) {
        nickName = [[[QIMKit sharedInstance] getUserInfoByName:qnrId] objectForKey:@"Name"];
        if (nickName.length <= 0) {
            nickName = qnrId;
        } else { 
            [__global_gndic setQIMSafeObject:nickName forKey:qnrId];
        }
    }
    return nickName;
}

@end
