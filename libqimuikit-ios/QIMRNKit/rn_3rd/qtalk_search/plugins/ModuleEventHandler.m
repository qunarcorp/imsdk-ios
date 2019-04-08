//
//  ModuleEventHandler.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/5/9.
//
//

#import "QIMCommonUIFramework.h"
#import "ModuleEventHandler.h"

@implementation ModuleEventHandler

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {
    return @{@"greeting": @"Welcome to the DevDactic\n React Native Tutorial!"};
}

RCT_EXPORT_METHOD(handModuleEvent:(NSString *)module_name
                  :(NSDictionary *)initParam
                  :(RCTResponseSenderBlock)success
                  :(RCTResponseSenderBlock)error) {
    
    NSDictionary *responseData = @{};
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_QtalkSuggest_handle_opsapp_event object:nil userInfo:@{@"module":module_name, @"initParam":initParam}];
    });
    
    success(@[responseData]);
}

@end
