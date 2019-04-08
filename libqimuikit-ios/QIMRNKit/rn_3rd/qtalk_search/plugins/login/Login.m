//
//  QTalkAuth.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/4/5.
//
//

#import "Login.h"

@implementation Login

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {
    return @{@"greeting": @"Welcome to the DevDactic\n React Native Tutorial!"};
}

RCT_EXPORT_METHOD(getLoginInfo:(RCTResponseSenderBlock)success:(RCTResponseSenderBlock)error) {
 
    NSString *userName = [QIMKit getLastUserName];
    userName = userName.length ? userName : @"";
    NSString *qtalkToken = [[QIMKit sharedInstance] myRemotelogginKey];
    qtalkToken = qtalkToken.length ? qtalkToken : @"";
    
    NSString *key = [[QIMKit sharedInstance] thirdpartKeywithValue];
    key = key.length ? key : @"";

    NSString *httpHost = [[QIMKit sharedInstance] qimNav_HttpHost];
    httpHost = httpHost.length ? httpHost : @"";

    if ([userName.lowercaseString isEqualToString:@"appstore"] == NO) {
        NSDictionary *responseData = @{@"userid" : userName, @"q_auth" : qtalkToken, @"c_key" : key, @"checkUserKeyHost" : httpHost, @"showOA":@([[QIMKit sharedInstance] qimNav_ShowOA])};
        QIMVerboseLog(@"%@ 登录骆驼帮OA : %@", userName.lowercaseString, responseData);
        success(@[responseData]);
    }
}

RCT_EXPORT_METHOD(updateCkey:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSNumber *is_ok = @NO;
    NSString *errorMsg = @"";
    
    @try {
        [[QIMKit sharedInstance] updateRemoteLoginKey];
        is_ok = @YES;
    } @catch (NSException *exception) {
        is_ok = @NO;
        errorMsg = [exception reason];
    }
    
    NSDictionary *responseData = @{@"is_ok": is_ok, @"msg": errorMsg};
    resolve(responseData);
}

@end
