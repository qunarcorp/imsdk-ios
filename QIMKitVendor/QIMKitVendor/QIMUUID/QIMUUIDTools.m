//
//  QIMUUIDTools.m
//  qunarChatMac
//
//  Created by 平 薛 on 14-11-24.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "QIMUUIDTools.h"
#import "UICKeyChainStore.h"
#import "QIMPublicRedefineHeader.h"

@implementation QIMUUIDTools

+ (NSString *)deviceUUID{
    static NSString *resultKey = nil;
    if (!resultKey) {
        NSString *service = [[NSBundle mainBundle] bundleIdentifier];
        if ([service containsString:@"share"]) {
            service = [[service componentsSeparatedByString:@".shareExtension"] firstObject];
        }
        NSString *key = @"deviceIdentifier";
        NSString *deviceUid = [UICKeyChainStore stringForKey:key
                                                     service:service];
        QIMVerboseLog(@"从KeyChain中取出来的DeviceUid : %@, key : %@, service : %@", deviceUid, key, service);
        if (deviceUid == nil) {
            QIMVerboseLog(@"从KeyChain中未取到DeviceUid，准备重新生成并写入KeyChain");
            deviceUid = [self UUID];
        }
        
        resultKey = [deviceUid copy];
    }
    QIMVerboseLog(@"最终使用的deviceUUID : %@", resultKey);
    return resultKey;
}

//直接从KeyChain中获取UUID，没有或者跟当前登录账号使用的UUID不一致则需要set
+ (NSString *)getUUIDFromKeyChain {
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    NSString *key = @"deviceIdentifier";
    NSString *deviceUid = [UICKeyChainStore stringForKey:key
                                                 service:service];
    return deviceUid;
}

+ (BOOL)setUUID:(NSString *) deviceUid {
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    NSString *key = @"deviceIdentifier";
    BOOL success = [UICKeyChainStore setString:deviceUid forKey:key service:service];
    if (success) {
        QIMVerboseLog(@"向KeyChain中写入DeviceUid 成功 : %@, Key: %@, service : %@", deviceUid, key, service);
    } else {
        QIMVerboseLog(@"向KeyChain中写入DeviceUid 失败 : %@, Key: %@, service : %@", deviceUid, key, service);
    }
    return success;
}

+ (BOOL) setUserName:(NSString *) username {
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    if ([service containsString:@"share"]) {
        service = [[service componentsSeparatedByString:@".shareExtension"] firstObject];
    }
    NSString *key = @"username";
    
    if (username == nil || [username length] <= 0){
        //删除用户的授权cookie
        [self removeUserAuthCookie];
        QIMVerboseLog(@"当前userName为空，清空KeyChain中的userName, Key : %@, service : %@", key, service);
        return [UICKeyChainStore removeItemForKey:key service:service];
    }
    //获取用户的授权cookie
    [self setUserAuthCookie];
    
    BOOL success = [UICKeyChainStore setString:username forKey:key service:service];
    if (success) {
        QIMVerboseLog(@"向KeyChain中写入UserName成功 : %@, key : %@, service : %@", username, key, service);
    } else {
        QIMVerboseLog(@"向KeyChain中写入UserName失败 : %@, key : %@, service : %@", username, key, service);
    }
    return success;
}

+ (NSString *) loginUserName {
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    if ([service containsString:@"share"]) {
        service = [[service componentsSeparatedByString:@".shareExtension"] firstObject];
    }
    NSString *key = @"username";
    NSString *loginUserName = [UICKeyChainStore stringForKey:key service:service];
    QIMVerboseLog(@"从KeyChain中取出的userName : %@, key : %@, service : %@", loginUserName, key, service);
    return loginUserName;
}

+ (NSString *) OriginalUUID {
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    NSString *result = [[NSString alloc] initWithString:(__bridge NSString*)UUIDString];
    if (UUID)
        CFRelease(UUID);
    if (UUIDString)
        CFRelease(UUIDString);
    return result;
}

+ (NSString *)UUID{
    return [[self OriginalUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (void)setUserAuthCookie
{
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [myCookie cookies]) {
        if ([cookie.name isEqualToString:@"_q"]) {
            [self setQCookie:cookie.value];
        } else if([cookie.name isEqualToString:@"_v"]) {
            [self setVCookie:cookie.value];
        } else if([cookie.name isEqualToString:@"_t"]) {
            [self setTCookie:cookie.value];
        }
    }
    QIMVerboseLog(@"cookie %@",myCookie.cookies);
}

+ (void)removeUserAuthCookie
{
    [self setQCookie:nil];
    [self setVCookie:nil];
    [self setTCookie:nil];
}

#pragma mark - cookie
+ (BOOL) setQCookie:(NSString *)qcookie
{
    return [self setString:qcookie forKey:@"qcookie"];
}

+ (BOOL) setVCookie:(NSString *)vcookie
{
    return [self setString:vcookie forKey:@"vcookie"];
}

+ (BOOL) setTCookie:(NSString *)tcookie
{
    return [self setString:tcookie forKey:@"tcookie"];
}

+ (NSString *)qcookie
{
    return [self stringForKey:@"qcookie"];
}

+ (NSString *)vcookie
{
    return [self stringForKey:@"vcookie"];
}

+ (NSString *)tcookie
{
    return [self stringForKey:@"tcookie"];
}

#pragma mark - RequestURL & RequestDomain

+ (BOOL) setRequestURL:(NSData *)requestUrl {
    return [self setData:requestUrl forKey:@"requestUrl"];
}

+ (NSData *)getRequestUrl {
    return [QIMUUIDTools dataForKey:@"requestUrl"];
}

+ (BOOL) setRequestDomain:(NSData *)requestDoamin {
    return [self setData:requestDoamin forKey:@"requestDoamin"];
}

+ (NSData *)getRequestDoamin {
    return [QIMUUIDTools dataForKey:@"requestDoamin"];
}

#pragma mark - 联系人列表

+ (BOOL) setHeadImage:(NSData *)headImage forUserId:(NSString *)userId{
    return [self setData:headImage forKey:userId];
}

+ (BOOL) setUUIDToolsSessionList:(NSData *)sessionList{
    return [self setData:sessionList forKey:@"sessionList"];
}

+ (BOOL) setUUIDToolsMyGroupList:(NSData *)sessionList
{
    return [self setData:sessionList forKey:@"MyGroupList"];
}

+ (BOOL) setUUIDToolsFriendList:(NSData *)sessionList
{
    return [self setData:sessionList forKey:@"FriendList"];
}

+ (BOOL) setRecentSharedList:(NSData *)recentSharedList {
    return [self setData:recentSharedList forKey:@"recentSharedList"];
}

+ (NSData *) getHeadImageForUserId:(NSString *)userId{
    return [self dataForKey:userId];
}

+ (NSData *)getSessionList
{
    return [QIMUUIDTools dataForKey:@"sessionList"];
}

+ (NSData *)getMyGroupList
{
    return [QIMUUIDTools dataForKey:@"MyGroupList"];
}

+ (NSData *)getRecentSharedList {
    return [QIMUUIDTools dataForKey:@"recentSharedList"];
}

+ (NSData *)getFriendList
{
    return [QIMUUIDTools dataForKey:@"FriendList"];
}

#pragma mark - private methods

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key
{
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    if ([service containsString:@"share"]) {
        service = [[service componentsSeparatedByString:@".shareExtension"] firstObject];
    }
    if (data == nil || [data length] <= 0) {
        QIMVerboseLog(@"传入的data为空，因此清除之前的数据, Key : %@, service : %@", key, service);
        return [UICKeyChainStore removeItemForKey:key service:service];
    }
    BOOL success = [UICKeyChainStore setData:data forKey:key service:service];
    if (success) {
        QIMVerboseLog(@"向KeyChain中传入data 成功, Key : %@, service : %@", key, service);
    } else {
        QIMVerboseLog(@"向KeyChain中传入data 失败, Key : %@, service : %@", key, service);
    }
    return success;
}

+ (NSData *)dataForKey:(NSString *)key
{
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    if ([service containsString:@"share"]) {
        service = [[service componentsSeparatedByString:@".shareExtension"] firstObject];
    }
    NSData *data = [UICKeyChainStore dataForKey:key service:service];
    QIMVerboseLog(@"从KeyChain中取出数据 , key : %@, service : %@", key, service);
    return data;
}

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key
{
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    if ([service containsString:@"share"]) {
        service = [[service componentsSeparatedByString:@".shareExtension"] firstObject];
    }
    if (string == nil || [string length] <= 0)
        return [UICKeyChainStore removeItemForKey:key service:service];
    
    return [UICKeyChainStore setString:string forKey:key service:service];
}

+ (NSString *)stringForKey:(NSString *)key
{
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    if ([service containsString:@"share"]) {
        service = [[service componentsSeparatedByString:@".shareExtension"] firstObject];
    }
    
    NSString *string =  [UICKeyChainStore stringForKey:key service:service];
    return string == nil ? @"" : string;
}

@end
