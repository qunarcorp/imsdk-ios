//
//  QimRNBModule+QIMLocalSearch.m
//  QIMUIKit
//
//  Created by lilu on 2018/12/4.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QimRNBModule+QIMLocalSearch.h"

@implementation QimRNBModule (QIMLocalSearch)

+ (NSString *)getTimeStr:(long long)time {
    NSDate *date = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:time];
    if ([date qim_isToday]) {
        return @"今天";
    } else if ([date qim_isThisWeek]) {
        return @"这周";
    } else if ([date qim_isThisMonth]) {
        return @"这个月";
    } else {
        return [date qim_MonthDescription];
    }
    return nil;
}

+ (NSString *)getFileTypeWithFileExtension:(NSString *)fileExtension {
    NSString *fileType = @"file";
    if ([fileExtension isEqualToString:@"docx"] || [fileExtension isEqualToString:@"doc"]) {
        fileType = @"word";
    } else if ([fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"gif"] || [fileExtension isEqualToString:@"png"]) {
        fileType = @"image";
    } else if ([fileExtension isEqualToString:@"xlsx"]) {
        fileType = @"excel";
    } else if ([fileExtension isEqualToString:@"pptx"] || [fileExtension isEqualToString:@"ppt"]) {
        fileType = @"powerPoint";
    } else if ([fileExtension isEqualToString:@"pdf"]) {
        fileType = @"pdf";
    } else if ([fileExtension isEqualToString:@"apk"]) {
        fileType = @"apk";
    } else if ([fileExtension isEqualToString:@"txt"]) {
        fileType = @"txt";
    } else if ([fileExtension isEqualToString:@"zip"]) {
        fileType = @"zip";
    } else {
        
    }
    return fileType;
}

+ (NSDictionary *)qimrn_searchLocalMsgWithUserParam:(NSDictionary *)param {
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *realjid = [param objectForKey:@"realjid"];
    ChatType chatType = [[param objectForKey:@"chatType"] integerValue];
    NSString *searchText = [param objectForKey:@"searchText"];
    NSMutableDictionary *msgsMap = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *localMsgs = @[];
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        localMsgs = [[QIMKit sharedInstance] getMsgsByKeyWord:searchText ByXmppId:xmppId ByReadJid:realjid];
        NSLog(@"msgs : %@", localMsgs);
    } else {
        localMsgs = [[QIMKit sharedInstance] getMsgsByKeyWord:searchText ByXmppId:xmppId ByReadJid:nil];
        NSLog(@"msgs : %@", localMsgs);
    }
    NSMutableArray *dateArray = [NSMutableArray arrayWithCapacity:3];
    for (Message * msg in localMsgs) {
        NSString *timeStr = [QimRNBModule getTimeStr:msg.messageDate];
        if (![dateArray containsObject:timeStr]) {
            [dateArray addObject:timeStr];
        }
        NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:3];
        
        NSString *msgSendJid = msg.from;
        NSString *msgContent = msg.message;
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:msgSendJid];
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:msgSendJid];
        NSString *userName = [userInfo objectForKey:@"Name"];
        if (searchText.length > 0) {
            if (![[msgContent lowercaseString] containsString:[searchText lowercaseString]]  && ![[remarkName lowercaseString] containsString:[searchText lowercaseString]] && ![[userName lowercaseString] containsString:[searchText lowercaseString]]) {
                continue;
            }
        }
        NSDate *msgDate = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msg.messageDate];
        NSString *msgDateStr = [msgDate qim_formattedTime];
        
        [msgDic setQIMSafeObject:msgDateStr forKey:@"time"];
        [msgDic setQIMSafeObject:msg.from forKey:@"from"];
        [msgDic setQIMSafeObject:msg.messageId forKey:@"msgId"];
        [msgDic setQIMSafeObject:remarkName forKey:@"nickName"];
        [msgDic setQIMSafeObject:msgContent forKey:@"content"];
        [msgDic setQIMSafeObject:@(msg.messageDate) forKey:@"timeLong"];
        NSString *headerUrl = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:msgSendJid];
        [msgDic setQIMSafeObject:headerUrl ? headerUrl : [QIMKit defaultUserHeaderImagePath] forKey:@"headerUrl"];
        
        
        NSMutableArray *timeStrMsgsGroup = [msgsMap objectForKey:timeStr];
        if (timeStrMsgsGroup) {
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        } else {
            timeStrMsgsGroup = [NSMutableArray arrayWithCapacity:1];
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *cMap = [NSMutableDictionary dictionaryWithCapacity:2];
    for (NSInteger i = 0; i < dateArray.count; i++) {
        NSString *dateStr = [dateArray objectAtIndex:i];
        for (NSString *mapKey in [msgsMap allKeys]) {
            if ([mapKey isEqualToString:dateStr]) {
                NSArray *dateArray = [msgsMap objectForKey:mapKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                [dic setQIMSafeObject:dateArray forKey:@"data"];
                [dic setQIMSafeObject:mapKey forKey:@"key"];
                [array addObject:dic];
            }
        }
    }
    
    [cMap setQIMSafeObject:@(YES) forKey:@"ok"];
    [cMap setQIMSafeObject:array forKey:@"data"];
    QIMVerboseLog(@"msgsMap : %@", cMap);
    return cMap;
}

+ (NSDictionary *)qimrn_searchLocalFileWithUserParam:(NSDictionary *)param {
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *realjid = [param objectForKey:@"realjid"];
    ChatType chatType = [[param objectForKey:@"chatType"] integerValue];
    NSString *searchText = [param objectForKey:@"searchText"];
    NSMutableDictionary *msgsMap = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *localMsgs = @[];
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        localMsgs = [[QIMKit sharedInstance] getMsgsForMsgType:@[@(QIMMessageType_File)] ByXmppId:xmppId ByReadJid:realjid];
        NSLog(@"msgs : %@", localMsgs);
    } else {
        localMsgs = [[QIMKit sharedInstance] getMsgsForMsgType:@[@(QIMMessageType_File)] ByXmppId:xmppId];
        NSLog(@"msgs : %@", localMsgs);
    }
    NSMutableArray *dateArray = [NSMutableArray arrayWithCapacity:3];
    for (Message * msg in localMsgs) {
        NSString *timeStr = [QimRNBModule getTimeStr:msg.messageDate];
        if (![dateArray containsObject:timeStr]) {
            [dateArray addObject:timeStr];
        }
        NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:3];
        NSDictionary *fileExtendInfoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:msg.extendInformation ? msg.extendInformation : msg.message error:nil];
        if (!fileExtendInfoDic) {
            continue;
        }
        NSString *fileName = [[fileExtendInfoDic objectForKey:@"FileName"] lowercaseString];
        NSString *msgSendJid = msg.from;
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:msgSendJid];
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:msgSendJid];
        NSString *userName = [userInfo objectForKey:@"Name"];
        if (searchText.length > 0) {
            if (![[fileName lowercaseString] containsString:[searchText lowercaseString]]  && ![[remarkName lowercaseString] containsString:[searchText lowercaseString]] && ![[userName lowercaseString] containsString:[searchText lowercaseString]]) {
                continue;
            }
        }
        NSString *fileSize = [fileExtendInfoDic objectForKey:@"FileSize"];
        NSString *fileType = [QimRNBModule getFileTypeWithFileExtension:[fileName pathExtension]];
        NSString *fileUrl = [fileExtendInfoDic objectForKey:@"HttpUrl"];
        
        [msgDic setQIMSafeObject:fileName forKey:@"fileName"];
        [msgDic setQIMSafeObject:fileType forKey:@"fileType"];
        [msgDic setQIMSafeObject:fileSize forKey:@"fileSize"];
        [msgDic setQIMSafeObject:fileUrl forKey:@"fileUrl"];
        [msgDic setQIMSafeObject:msg.from forKey:@"from"];
        [msgDic setQIMSafeObject:msg.messageId forKey:@"msgId"];
        [msgDic setQIMSafeObject:remarkName forKey:@"nickName"];
        NSString *headerUrl = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:msgSendJid];
        [msgDic setQIMSafeObject:headerUrl ? headerUrl : [QIMKit defaultUserHeaderImagePath] forKey:@"headerUrl"];
        
        
        NSMutableArray *timeStrMsgsGroup = [msgsMap objectForKey:timeStr];
        if (timeStrMsgsGroup) {
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        } else {
            timeStrMsgsGroup = [NSMutableArray arrayWithCapacity:1];
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *cMap = [NSMutableDictionary dictionaryWithCapacity:2];
    for (NSInteger i = 0; i < dateArray.count; i++) {
        NSString *dateStr = [dateArray objectAtIndex:i];
        for (NSString *mapKey in [msgsMap allKeys]) {
            if ([mapKey isEqualToString:dateStr]) {
                NSArray *dateArray = [msgsMap objectForKey:mapKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                [dic setQIMSafeObject:dateArray forKey:@"data"];
                [dic setQIMSafeObject:mapKey forKey:@"key"];
                [array addObject:dic];
            }
        }
    }

    [cMap setQIMSafeObject:@(YES) forKey:@"ok"];
    [cMap setQIMSafeObject:array forKey:@"data"];
    QIMVerboseLog(@"msgsMap : %@", cMap);
    return cMap;
}

+ (NSDictionary *)qimrn_searchLocalLinkWithUserParam:(NSDictionary *)param {
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *realjid = [param objectForKey:@"realjid"];
    NSString *searchText = [param objectForKey:@"searchText"];
    ChatType chatType = [[param objectForKey:@"chatType"] integerValue];
    NSMutableDictionary *msgsMap = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *localMsgs = @[];
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        localMsgs = [[QIMKit sharedInstance] getMsgsForMsgType:@[@(QIMMessageType_CommonTrdInfo), @(QIMMessageType_CommonTrdInfoPer)] ByXmppId:xmppId ByReadJid:realjid];
        NSLog(@"msgs : %@", localMsgs);
    } else {
        localMsgs = [[QIMKit sharedInstance] getMsgsForMsgType:@[@(QIMMessageType_CommonTrdInfo), @(QIMMessageType_CommonTrdInfoPer)] ByXmppId:xmppId];
        NSLog(@"msgs : %@", localMsgs);
    }
    NSMutableArray *dateArray = [NSMutableArray arrayWithCapacity:3];
    for (Message * msg in localMsgs) {
        NSString *timeStr = [QimRNBModule getTimeStr:msg.messageDate];
        if (![dateArray containsObject:timeStr]) {
            [dateArray addObject:timeStr];
        }
        NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:3];
        NSDictionary *linkExtendInfoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:msg.extendInformation ? msg.extendInformation : msg.message error:nil];
        if (!linkExtendInfoDic) {
            continue;
        }
        NSString *linkDesc = [linkExtendInfoDic objectForKey:@"desc"];
        NSString *linkTitle = [linkExtendInfoDic objectForKey:@"title"];
        linkTitle = (linkDesc.length > 0) ? linkDesc : linkTitle;
        NSString *msgSendJid = msg.from;
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:msgSendJid];
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:msgSendJid];
        NSString *userName = [userInfo objectForKey:@"Name"];
        if (searchText.length > 0) {
            if (![[linkTitle lowercaseString] containsString:[searchText lowercaseString]]  && ![[remarkName lowercaseString] containsString:[searchText lowercaseString]] && ![[userName lowercaseString] containsString:[searchText lowercaseString]]) {
                continue;
            }
        }
        NSString *linkUrl = [linkExtendInfoDic objectForKey:@"linkurl"];
        NSString *reactUrl = [linkExtendInfoDic objectForKey:@"reacturl"];
        NSString *linkIcon = [linkExtendInfoDic objectForKey:@"img"];
        if (linkIcon.length <= 0) {
            linkIcon = [QIMKit defaultCommonTrdInfoImagePath];
        }
        NSDate *msgDate = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msg.messageDate];
        
        NSString *linkDate = [msgDate qim_formattedTime];
        
        [msgDic setQIMSafeObject:(linkTitle.length > 0) ? linkTitle : linkUrl forKey:@"linkTitle"];
        [msgDic setQIMSafeObject:linkUrl forKey:@"linkUrl"];
        [msgDic setQIMSafeObject:reactUrl forKey:@"reacturl"];
        [msgDic setQIMSafeObject:linkIcon forKey:@"linkIcon"];
        [msgDic setQIMSafeObject:@"系统分享" forKey:@"linkType"];
        [msgDic setQIMSafeObject:linkDate forKey:@"linkDate"];
        
        [msgDic setQIMSafeObject:msg.from forKey:@"from"];
        [msgDic setQIMSafeObject:msg.messageId forKey:@"msgId"];
        
        [msgDic setQIMSafeObject:remarkName forKey:@"nickName"];
        NSString *headerUrl = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:msgSendJid];
        [msgDic setQIMSafeObject:headerUrl ? headerUrl : [QIMKit defaultUserHeaderImagePath] forKey:@"headerUrl"];
        
        NSMutableArray *timeStrMsgsGroup = [msgsMap objectForKey:timeStr];
        if (timeStrMsgsGroup) {
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        } else {
            timeStrMsgsGroup = [NSMutableArray arrayWithCapacity:1];
            [timeStrMsgsGroup addObject:msgDic];
            [msgsMap setObject:timeStrMsgsGroup forKey:timeStr];
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *cMap = [NSMutableDictionary dictionaryWithCapacity:2];
    for (NSInteger i = 0; i < dateArray.count; i++) {
        NSString *dateStr = [dateArray objectAtIndex:i];
        for (NSString *mapKey in [msgsMap allKeys]) {
            if ([mapKey isEqualToString:dateStr]) {
                NSArray *dateArray = [msgsMap objectForKey:mapKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
                [dic setQIMSafeObject:dateArray forKey:@"data"];
                [dic setQIMSafeObject:mapKey forKey:@"key"];
                [array addObject:dic];
            }
        }
    }
    [cMap setQIMSafeObject:@(YES) forKey:@"ok"];
    [cMap setQIMSafeObject:array forKey:@"data"];
    QIMVerboseLog(@"msgsMap : %@", cMap);
    return cMap;
}

@end
