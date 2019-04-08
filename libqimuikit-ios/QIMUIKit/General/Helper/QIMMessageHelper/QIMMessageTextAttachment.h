//
//  QIMMessageTextAttachment.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/4.
//

#import "QIMCommonUIFramework.h"

@interface QIMMessageTextAttachment : NSObject

+ (instancetype)sharedInstance;

- (NSString *)getStringFromAttributedString:(NSAttributedString *)attributedString WithOutAtInfo:(NSMutableArray **)outAtInfo;

@end
