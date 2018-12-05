//
//  QIMEmojiTextAttachment.h
//  qunarChatIphone
//
//  Created by chenjie on 16/3/4.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMEmojiTextAttachment : NSTextAttachment

@property (nonatomic,copy) NSString         * packageId;
@property (nonatomic,copy) NSString         * shortCut;
@property (nonatomic,copy) NSString         * tipsName;

- (NSString *)getSendText;

@end
