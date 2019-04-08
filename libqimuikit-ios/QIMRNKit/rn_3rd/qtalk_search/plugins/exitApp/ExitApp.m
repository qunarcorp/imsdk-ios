//
//  ExitApp.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/4/5.
//
//


#import "ExitApp.h"

@implementation ExitApp

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {
    return @{@"greeting": @"Welcome to the DevDactic\n React Native Tutorial!"};
}

RCT_EXPORT_METHOD(exitApp:(RCTResponseSenderBlock)success:(RCTResponseSenderBlock)error) {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_ReactVC_GoBack object:nil];
        
        // 触发前端订阅事件
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_RN_QTALK_SUGGEST_VC_WILL_SHOW object:nil];
    });
}

@end
