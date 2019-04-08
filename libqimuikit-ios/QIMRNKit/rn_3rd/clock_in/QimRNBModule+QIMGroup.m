//
//  QimRNBModule+QIMGroup.m
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QimRNBModule+QIMGroup.h"

@implementation QimRNBModule (QIMGroup)

+ (NSArray *)qimrn_getGroupMembersByGroupId:(NSString *)groupId {
    NSArray *groupMembers = [[QIMKit sharedInstance] getGroupMembersByGroupId:groupId];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *member in groupMembers) {
        NSString *jid = [member objectForKey:@"xmppjid"];
        if (jid.length <= 0) {
            continue;
        }
        NSString *userJid = [member objectForKey:@"jid"];
        NSString *affiliation = [member objectForKey:@"affiliation"];
        NSString *name = [member objectForKey:@"name"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:member];
        NSString *uri = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:jid];
        [dic setQIMSafeObject:affiliation forKey:@"affiliation"];
        [dic setQIMSafeObject:uri forKey:@"headerUri"];
        [dic setQIMSafeObject:groupId forKey:@"jid"];
        [dic setQIMSafeObject:name forKey:@"name"];
        [dic setQIMSafeObject:(jid.length > 0) ? jid : userJid forKey:@"xmppjid"];
        [list addObject:dic];
    }
    return list;
}

+ (NSDictionary *)qimrn_getGroupInfoByGroupId:(NSString *)groupId {
    if (!groupId || groupId.length <= 0) {
        return nil;
    }
    NSDictionary *groupInfo = [[QIMKit sharedInstance] getGroupCardByGroupId:groupId];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    if (groupInfo.count) {
        NSString *groupId = [groupInfo objectForKey:@"GroupId"];
        NSString *groupName = [groupInfo objectForKey:@"Name"];
        NSString *groupIntroduce = [groupInfo objectForKey:@"Introduce"];
        NSString *groupHeaderSrc = [groupInfo objectForKey:@"HeaderSrc"];
        NSString *groupTopic = [groupInfo objectForKey:@"Topic"];
        
        [properties setQIMSafeObject:groupId forKey:@"GroupId"];
        [properties setQIMSafeObject:groupName forKey:@"Name"];
        [properties setQIMSafeObject:groupHeaderSrc forKey:@"HeaderSrc"];
        [properties setQIMSafeObject:groupTopic forKey:@"Topic"];
        [properties setQIMSafeObject:groupIntroduce forKey:@"Introduce"];
    }
    return properties;
}

@end
