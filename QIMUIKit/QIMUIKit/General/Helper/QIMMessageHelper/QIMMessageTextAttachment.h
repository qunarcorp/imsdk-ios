//
//  QIMMessageTextAttachment.h
//  qunarChatIphone
//
//  Created by QIM on 2018/4/4.
//

#import "QIMCommonUIFramework.h"

@interface QIMMessageTextAttachment : NSObject

+ (instancetype)sharedInstance;

- (NSString *)getStringFromAttributedString:(NSAttributedString *)attributedString WithOutAtInfo:(NSMutableArray **)outAtInfo;

@end
