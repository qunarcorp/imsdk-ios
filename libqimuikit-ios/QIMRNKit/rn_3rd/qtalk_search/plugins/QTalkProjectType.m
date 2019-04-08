//
//  QTalkProjectType.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/9/12.
//
//

#import "QTalkProjectType.h"
//#import "Login.h"

@implementation QTalkProjectType

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getProjectType:(RCTResponseSenderBlock)success:(RCTResponseSenderBlock)error) {
    
    NSDictionary *responseData = nil;
    
    NSString *key = [[QIMKit sharedInstance] thirdpartKeywithValue];
    NSString *lastJid = [[QIMKit sharedInstance] getLastJid];
    NSString *myNickName = [[QIMKit sharedInstance] getMyNickName];
    NSString *realKey = key.length ? key : @"";
    NSString *realLastJid = lastJid.length ? lastJid : @"";
    NSString *realMyNickName = myNickName.length ? myNickName : @"";
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        // qtalk
        NSNumber *WorkFeedEntrance = [[QIMKit sharedInstance] userObjectForKey:@"kUserWorkFeedEntrance"];
        if (WorkFeedEntrance == nil) {
            WorkFeedEntrance = @(NO);
        }
        NSLog(@"WorkFeedEntrance : %@", WorkFeedEntrance);
        responseData = @{@"isQTalk": @YES, @"domain": realLastJid, @"fullname": realMyNickName, @"c_key": realKey, @"checkUserKeyHost":[[QIMKit sharedInstance] qimNav_HttpHost], @"showOA":@([[QIMKit sharedInstance] qimNav_ShowOA]), @"isShowWorkWorld":WorkFeedEntrance};
    } else {
        // qchat
        BOOL is = [[QIMKit sharedInstance] isMerchant];
        NSNumber *isSupplier = is == YES ? @YES : @NO;
        
        responseData = @{@"isQTalk": @NO, @"domain": realLastJid, @"fullname": realMyNickName, @"c_key": realKey, @"isSupplier": isSupplier};
    }
    QIMVerboseLog(@"getProjectType : %@", responseData);
    success(@[responseData]);
}

@end
