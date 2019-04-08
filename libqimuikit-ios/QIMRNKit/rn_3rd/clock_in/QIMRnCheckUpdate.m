//
//  QIMRnCheckUpdate.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/1.
//

#import "QIMRnCheckUpdate.h"
#import "QimRNBModule.h"

@implementation QIMRnCheckUpdate

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(update:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    QIMVerboseLog(@"更新QIM RN Param : %@", param);
    NSDictionary *resp2 = @{@"is_ok": @NO, @"errorMsg": @""};
    QIMVerboseLog(@"更新QIM RN 失败 结果 : %@", resp2);
    callback(@[resp2]);
}

@end
