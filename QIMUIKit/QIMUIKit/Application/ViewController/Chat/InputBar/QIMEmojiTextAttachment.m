
#import "QIMEmojiTextAttachment.h"

@implementation QIMEmojiTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    return CGRectMake(0, -2, 20, 20);
}

- (NSString *)getSendText{
    if (self.shortCut) {
        
        return [NSString stringWithFormat:@"[obj type=\"%@\" value=\"%@\" width=%@ height=0 ]", @"emoticon",[NSString stringWithFormat:@"[%@]",self.shortCut],self.packageId];
    }
    return nil;
}

@end
