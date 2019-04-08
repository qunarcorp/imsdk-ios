//
//  QTalkLoaclSearch.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 2016/12/6.
//
//

#import "QTalkLoaclSearch.h"
#import "QTalkSearchRNView.h"
#import "QTalkRNSearchManager.h"

@implementation QTalkLoaclSearch

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(exportRNLog:(NSString *)message) {
    QIMVerboseLog(@"RN日志 : \n<   %@   > \n", message);
}

RCT_EXPORT_METHOD(search:(NSString *)key
                  limit:(NSInteger)limit
                  offset:(NSInteger)offset
                  groupId:(NSString *)groupId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    NSMutableArray *data = [QTalkRNSearchManager localSearch:key limit:limit offset:offset groupId:groupId];
    NSDictionary *resp1 = @{@"is_ok" : @YES, @"data" : data ? data : @[], @"errorMsg" : @""};
    QIMVerboseLog(@"本地搜索记录结果 : %@", resp1);
    resolve(resp1);
}

RCT_EXPORT_METHOD(searchUrl:(NSString *)MSG
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *searchUrl = [[QIMKit sharedInstance] qimNav_SearchUrl];
    NSDictionary *resp1 = @{@"is_ok" : @YES, @"data" : searchUrl ? searchUrl : @"", @"Msg" : MSG};
    QIMVerboseLog(@"本地搜索获取搜索URL : %@", resp1);
    resolve(resp1);
}

RCT_EXPORT_METHOD(getVersion:(NSString *)MSG
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *appBuildVersion = [[QIMKit sharedInstance] AppBuildVersion];
    NSDictionary *resp1 = @{@"is_ok" : @YES, @"data" : appBuildVersion ? appBuildVersion : @"", @"Msg" : MSG};
    QIMVerboseLog(@"本地搜索获取版本号 : %@", resp1);
    resolve(resp1);
}
@end
