//
//  QimRNBModule+TravelCalendar.m
//  QIMRNKit
//
//  Created by 李露 on 2018/9/7.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QimRNBModule+TravelCalendar.h"
#import "QIMJSONSerializer.h"

@implementation QimRNBModule (TravelCalendar)

- (NSDictionary *)qimrn_grtRNDataByTrip:(NSDictionary *)tripItem {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:tripItem];
    NSString *memberListJson = [tripItem objectForKey:@"memberList"];
    NSArray *memberList = [[QIMJSONSerializer sharedInstance] deserializeObject:memberListJson error:nil];
    NSMutableArray *newMemberList = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *memberItem in memberList) {
        NSMutableDictionary *newMemberDic = [NSMutableDictionary dictionaryWithDictionary:memberItem];
        NSString *memberId = [memberItem objectForKey:@"memberId"];
        
        NSString *userRemarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:memberId];
        NSString *userHeaderUrl = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:memberId];
        [newMemberDic setQIMSafeObject:userRemarkName forKey:@"memberName"];
        [newMemberDic setQIMSafeObject:userHeaderUrl forKey:@"headerUrl"];
        
        [newMemberList addObject:newMemberDic];
    }
    [temp setQIMSafeObject:newMemberList forKey:@"memberList"];
    return temp;
}

- (void)qimrn_selectUserTripByDate:(NSDictionary *)params {
    
}

- (NSArray *)qimrn_getTripArea {
    NSArray *localAreaList = [[QIMKit sharedInstance] getLocalAreaList];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:3];
    for (NSDictionary *areaItem in localAreaList) {
        NSString *areaName = [areaItem objectForKey:@"areaName"];
        NSString *areaId = [areaItem objectForKey:@"areaId"];
        NSString *morningStarts = [areaItem objectForKey:@"morningStarts"];
        NSString *eveningEnds = [areaItem objectForKey:@"eveningEnds"];
        
        NSMutableDictionary *newAreaItem = [NSMutableDictionary dictionaryWithCapacity:3];
        [newAreaItem setQIMSafeObject:areaName forKey:@"AddressName"];
        [newAreaItem setQIMSafeObject:areaId forKey:@"AddressNumber"];
        [newAreaItem setQIMSafeObject:morningStarts forKey:@"rStartTime"];
        [newAreaItem setQIMSafeObject:eveningEnds forKey:@"rEndTime"];
        [list addObject:newAreaItem];
    }
    return list;
}

@end
