//
//  QTalkRNSearchManager.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/12/2.
//
//

#import "QTalkRNSearchManager.h"

@interface QTalkRNSearchManager ()

@end

@implementation QTalkRNSearchManager

+ (NSMutableArray *)localSearch:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset groupId:(NSString *)groupId{
    
    NSDictionary *ejabhost2GroupChatList = [QTalkRNSearchManager rnSearchEjabhost2GroupChatResultWithSearchKey:key limit:limit offset:offset];
    NSDictionary *publicNumberList = [QTalkRNSearchManager rnSearchPublicNumberResultWithSearchKey:key limit:limit offset:offset];
    NSDictionary *localUserList = [QTalkRNSearchManager rnSearchLocalUserChatResultWithSearchKey:key limit:limit offset:offset];
    NSDictionary *localGroupList = [QTalkRNSearchManager rnSearchLocalGroupChatResultWithSearchKey:key limit:limit offset:offset];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if(([groupId isEqualToString:@"Q04"] || [groupId isEqualToString:@""]) && ejabhost2GroupChatList != nil) {
        [data addObject:ejabhost2GroupChatList];
    }
    
    if(([groupId isEqualToString:@"Q03"] || [groupId isEqualToString:@""]) &&publicNumberList != nil) {
        [data addObject:publicNumberList];
    }
    
    if(([groupId isEqualToString:@"Q08"] || [groupId isEqualToString:@""]) &&localUserList != nil) {
        [data addObject:localUserList];
    }
    
    if(([groupId isEqualToString:@"Q09"] || [groupId isEqualToString:@""]) &&localGroupList != nil) {
        [data addObject:localGroupList];
    }

    return data;
}

+ (NSDictionary *)rnSearchLocalUserChatResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset  {
    
    NSArray *localUserList = [[QIMKit sharedInstance] searchUserListBySearchStr:key WithLimit:limit WithOffset:offset];
    NSInteger totalCount = [[QIMKit sharedInstance] searchUserListTotalCountBySearchStr:key];
    NSMutableDictionary *localUserDict = [NSMutableDictionary dictionary];
    if (localUserList.count) {
        [localUserDict setQIMSafeObject:localUserList forKey:@"info"];
    } else {
        return nil;
    }
    [localUserDict setQIMSafeObject:@"本地用户" forKey:@"groupLabel"];
    [localUserDict setQIMSafeObject:@"Q08" forKey:@"groupId"];
    [localUserDict setQIMSafeObject:@(QRNSearchGroupPriorityLocalUserList) forKey:@"groupPriority"];
    [localUserDict setQIMSafeObject:@(0) forKey:@"todoType"];
    [localUserDict setQIMSafeObject:@"https://qt.qunar.com/file/v2/download/perm/ff1a003aa731b0d4e2dd3d39687c8a54.png" forKey:@"defaultportrait"];
    if (limit + offset < totalCount) {
        [localUserDict setQIMSafeObject:@(true) forKey:@"hasMore"];
    } else {
        [localUserDict setQIMSafeObject:@(false) forKey:@"hasMore"];
    }
    [localUserDict setQIMSafeObject:@(true) forKey:@"isLoaclData"];
    return localUserDict;
}

+ (NSDictionary *)rnSearchLocalGroupChatResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset  {
    
    NSArray *localGroupList = [[QIMKit sharedInstance] searchGroupBySearchStr:key WithLimit:limit WithOffset:offset];
    NSInteger totalCount = [[QIMKit sharedInstance] searchGroupTotalCountBySearchStr:key];
    NSMutableDictionary *localGroupChatDict = [NSMutableDictionary dictionary];
    if (localGroupList.count) {
        [localGroupChatDict setQIMSafeObject:localGroupList forKey:@"info"];
    } else {
        return nil;
    }
    [localGroupChatDict setQIMSafeObject:@"本地群组" forKey:@"groupLabel"];
    [localGroupChatDict setQIMSafeObject:@"Q09" forKey:@"groupId"];
    [localGroupChatDict setQIMSafeObject:@(QRNSearchGroupPriorityLocalGroupList) forKey:@"groupPriority"];
    [localGroupChatDict setQIMSafeObject:@(1) forKey:@"todoType"];
    [localGroupChatDict setQIMSafeObject:@"https://qt.qunar.com/file/v2/download/perm/bc0fca9b398a0e4a1f981a21e7425c7a.png" forKey:@"defaultportrait"];
    if (limit + offset < totalCount) {
        [localGroupChatDict setQIMSafeObject:@(true) forKey:@"hasMore"];
    } else {
        [localGroupChatDict setQIMSafeObject:@(false) forKey:@"hasMore"];
    }
    [localGroupChatDict setQIMSafeObject:@(true) forKey:@"isLoaclData"];
    return localGroupChatDict;
}

+ (NSDictionary *)rnSearchEjabhost2GroupChatResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset  {
    
    NSArray *ejabhost2GroupChatList = [[QIMKit sharedInstance] rnSearchEjabHost2GroupChatListByKeyStr:key limit:limit offset:offset];
    NSInteger totalCount = [[QIMKit sharedInstance] getRNSearchEjabHost2GroupChatListByKeyStr:key];
    NSMutableDictionary *ejabhost2GroupChatDict = [NSMutableDictionary dictionary];
    if (ejabhost2GroupChatList.count) {
        [ejabhost2GroupChatDict setQIMSafeObject:ejabhost2GroupChatList forKey:@"info"];
    } else {
        return nil;
    }
    [ejabhost2GroupChatDict setQIMSafeObject:@"外域群组" forKey:@"groupLabel"];
    [ejabhost2GroupChatDict setQIMSafeObject:@"Q04" forKey:@"groupId"];
    [ejabhost2GroupChatDict setQIMSafeObject:@(QRNSearchGroupPriorityGroupOutDomainGroupList) forKey:@"groupPriority"];
    [ejabhost2GroupChatDict setQIMSafeObject:@(1) forKey:@"todoType"];
    [ejabhost2GroupChatDict setQIMSafeObject:@"https://qt.qunar.com/file/v2/download/perm/bc0fca9b398a0e4a1f981a21e7425c7a.png" forKey:@"defaultportrait"];
    if (limit + offset < totalCount) {
        [ejabhost2GroupChatDict setQIMSafeObject:@(true) forKey:@"hasMore"];
    } else {
        [ejabhost2GroupChatDict setQIMSafeObject:@(false) forKey:@"hasMore"];
    }
    [ejabhost2GroupChatDict setQIMSafeObject:@(true) forKey:@"isLoaclData"];

    return ejabhost2GroupChatDict;
}

+ (NSDictionary *)rnSearchPublicNumberResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset {
    NSArray *publicNumberList = [[QIMKit sharedInstance] rnSearchPublicNumberListByKeyStr:key limit:limit offset:offset];
    NSInteger totalCount = [[QIMKit sharedInstance] getRnSearchPublicNumberListByKeyStr:key];
    NSMutableDictionary *publicNumberDict = [NSMutableDictionary dictionary];
    if (publicNumberList.count) {
        [publicNumberDict setQIMSafeObject:publicNumberList forKey:@"info"];
    } else {
        return nil;
    }
    [publicNumberDict setQIMSafeObject:@"公众号列表" forKey:@"groupLabel"];
    [publicNumberDict setQIMSafeObject:@"Q03" forKey:@"groupId"];
    [publicNumberDict setQIMSafeObject:@(QRNSearchGroupPriorityGroupLocalPublicNumberList) forKey:@"groupPriority"];
    [publicNumberDict setQIMSafeObject:@(8) forKey:@"todoType"];
    [publicNumberDict setQIMSafeObject:@"https://qt.qunar.com/file/v2/download/perm/612752b6f60c3379077f71493d4e02ae.png" forKey:@"defaultportrait"];
    if (limit + offset < totalCount) {
        [publicNumberDict setQIMSafeObject:@(true) forKey:@"hasMore"];
    } else {
        [publicNumberDict setQIMSafeObject:@(false) forKey:@"hasMore"];
    }
    [publicNumberDict setQIMSafeObject:@(true) forKey:@"isLoaclData"];
 
    return publicNumberDict;
}

+ (NSString *)searchUrl {
    return [[QIMKit sharedInstance] qimNav_SearchUrl];
}

@end
