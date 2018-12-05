//
//  QIMHistoryMsgManager.h
//  qunarChatIphone
//
//  Created by chenjie on 16/1/7.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMHistoryMsgManager : NSObject

+ (id)sharedInstance;

- (void)saveMsgText:(NSString *)msgText;

- (NSArray *)getMsgHistoryList;

- (void)saveCopyOrCutTextInfoWithText:(NSString *)text inputItems:(NSArray *)inputItems;

- (NSDictionary *)getCopyOrCutTextInfo;

@end
