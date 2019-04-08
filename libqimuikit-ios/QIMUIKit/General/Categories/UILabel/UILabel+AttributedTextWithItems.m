//
//  UILabel+AttributedTextWithItems.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 16/7/19.
//
//

#import "UILabel+AttributedTextWithItems.h"
#import "QIMEmojiTextAttachment.h"
#import "QIMEmotionManager.h"
#import "QIMEmotionManager.h"

@implementation UILabel (AttributedTextWithItems)

- (void)setQIMAttributedTextWithItems:(NSArray *)items {
    
    if (![items isKindOfClass:[NSArray class]]) {
        
        return;
    }
    NSMutableAttributedString * mulAttStr = [[NSMutableAttributedString alloc] init];
    for (NSString * item in items) {
        
        if ([item isKindOfClass:[NSString class]]) {
            
            NSArray * itemInfoArr = [item componentsSeparatedByString:@"____"];
            if (itemInfoArr.count == 3) {
                
                QIMEmojiTextAttachment *emojiTextAttachment = [QIMEmojiTextAttachment new];
                //设置表情图片
                emojiTextAttachment.image = [UIImage imageWithContentsOfFile:[[QIMEmotionManager sharedInstance] getEmotionImagePathForShortCut:itemInfoArr[1] withPackageId:itemInfoArr[0]]];
                emojiTextAttachment.packageId = itemInfoArr[0];
                emojiTextAttachment.shortCut = itemInfoArr[1];
                emojiTextAttachment.tipsName = itemInfoArr[2];
                NSMutableAttributedString *emjoAtr = [[NSMutableAttributedString alloc] init];
                [emjoAtr appendAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment]];
                [mulAttStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment]];
            }else{
                
                [mulAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:item]];
            }
        }
    }
    [self setAttributedText:mulAttStr];
}

@end
