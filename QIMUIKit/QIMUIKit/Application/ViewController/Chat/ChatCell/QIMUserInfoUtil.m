//
//  QIMUserInfoUtil.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/5.
//
//
#import "QIMUserInfoUtil.h"
static QIMUserInfoUtil *__global_userInfo_util = nil;

@interface QIMUserInfoUtil (){
    NSMutableDictionary * _userInfoDic;
}

@end

@implementation QIMUserInfoUtil

+ (id)sharedInstance{
    if (__global_userInfo_util == nil) {
        __global_userInfo_util = [[QIMUserInfoUtil alloc] init];
    }
    return __global_userInfo_util;
}

- (NSMutableDictionary *)userInfoDic
{
    if (_userInfoDic == nil) {
        _userInfoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _userInfoDic;
}


@end
