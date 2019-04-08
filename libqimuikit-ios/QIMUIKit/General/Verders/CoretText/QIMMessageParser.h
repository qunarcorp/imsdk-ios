//
//  QIMMessageParser.h
//  qunarChatIphone
//
//  Created by chenjie on 16/7/6.
//
//

#import "QIMCommonUIFramework.h"

@class Message;
@class QIMAttributedLabel;
@class QIMTextContainer;
@interface QIMMessageParser : NSObject

+ (instancetype) sharedInstance;
+ (QIMAttributedLabel *)attributedLabelForMessage:(Message *)message;
+ (QIMTextContainer *)textContainerForMessage:(Message *)message;
+ (QIMTextContainer *)textContainerForMessage:(Message *)message fromCache:(BOOL)fromCache;
+ (QIMTextContainer *)textContainerForMessageCtnt:(NSString *)ctnt withId:(NSString *)signId direction:(MessageDirection)direction;

+ (NSArray *)storagesFromMessage:(Message *)message;

+ (float)getCellWidth;

+ (Message *)reductionMessageForMessage:(Message *)message;
             
- (void)parseForXMLString:(NSString *)xmlStr complete:(void (^)(NSDictionary * info))complete;

@end
