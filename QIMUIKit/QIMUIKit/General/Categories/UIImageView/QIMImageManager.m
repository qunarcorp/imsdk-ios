//
//  QIMImageManager.m
//  QIMUIKit
//
//  Created by 李露 on 2018/8/27.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMImageManager.h"
#import "NSBundle+QIMLibrary.h"
#import "SDImageCache.h"
#import "QIMKitPublicHeader.h"
#import "QIMCommonCategories.h"

@implementation QIMImageManager

static QIMImageManager *__manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[QIMImageManager alloc] init];
    });
    return __manager;
}

- (void)initWithQIMImageCacheNamespace:(NSString *)ns {
    [[SDImageCache sharedImageCache] initWithNamespace:ns];
}

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid {
    return [self qim_getHeaderCachePathWithJid:jid WithChatType:ChatType_SingleChat];
}

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid WithChatType:(ChatType)chatType {
    return [self qim_getHeaderCachePathWithJid:jid WithRealJid:nil WithChatType:chatType];
}

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(ChatType)chatType {
    NSString *headerUrl = nil;
    switch (chatType) {
        case ChatType_SingleChat: {
            headerUrl = [[QIMKit sharedInstance] getUserHeaderSrcByUserId:jid];
        }
            break;
        case ChatType_GroupChat: {
            headerUrl = [[QIMKit sharedInstance] getGroupHeaderSrc:jid];
        }
            break;
        case ChatType_Consult: {
            headerUrl = [[QIMKit sharedInstance] getUserHeaderSrcByUserId:jid];
        }
            break;
        case ChatType_ConsultServer: {
            headerUrl = [[QIMKit sharedInstance] getUserHeaderSrcByUserId:realJid];
        }
            break;
        default:
            break;
    }
    if (headerUrl.length > 0) {
        if (![headerUrl qim_hasPrefixHttpHeader]) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
        } else {
            
        }
    } else {
        headerUrl = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMRNKit" BundleName:@"QIMRNKit" pathForResource:@"singleHeaderDefault" ofType:@"png"];
    }
    NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:headerUrl];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] && path.length > 0) {
        return path;
    } else {
        return headerUrl;
    }
}

- (NSString *)qim_getHeaderCachePathWithHeaderUrl:(NSString *)headerUrl {
    NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:headerUrl];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] && path.length > 0) {
        return path;
    } else {
        return headerUrl;
    }
}

- (UIImage *)getUserHeaderImageByUserId:(NSString *)jid {
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:[self qim_getHeaderCachePathWithJid:jid]]];
}

@end
