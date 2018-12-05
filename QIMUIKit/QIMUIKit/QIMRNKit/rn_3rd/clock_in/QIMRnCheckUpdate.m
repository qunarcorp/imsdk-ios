//
//  QIMRnCheckUpdate.m
//  qunarChatIphone
//
//  Created by QIM on 2018/2/1.
//

#import "QIMRnCheckUpdate.h"
#import "QimRNBModule.h"

@implementation QIMRnCheckUpdate

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(update:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    QIMVerboseLog(@"更新QIM RN Param : %@", param);
    NSDictionary *resp = @{@"is_ok": @YES, @"errorMsg": @""};
    callback(@[resp]);
}

@end
