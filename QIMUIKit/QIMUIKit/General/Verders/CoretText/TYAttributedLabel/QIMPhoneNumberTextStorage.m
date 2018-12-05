//
//  QIMPhoneNumberTextStorage.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/11/4.
//
//

#import "QIMPhoneNumberTextStorage.h"
#import "NSMutableAttributedString+QCTY.h"

@implementation QIMPhoneNumberTextStorage

- (instancetype)init
{
    if (self = [super init]) {
        self.underLineStyle = kCTUnderlineStyleSingle;
        self.modifier = kCTUnderlinePatternSolid;
    }
    return self;
}

#pragma mark - protocol

- (void)addTextStorageWithAttributedString:(NSMutableAttributedString *)attributedString
{
    [super addTextStorageWithAttributedString:attributedString];
    if (self.text.length == 0) {
        [attributedString addAttribute:kQCTextRunAttributedName value:self range:self.range];
        self.text = [attributedString.string substringWithRange:self.range];
    }else{
        [attributedString replaceCharactersInRange:self.range withString:self.text];
        [attributedString addAttribute:kQCTextRunAttributedName value:self range:NSMakeRange(self.range.location, self.text.length)];
    }
    
}

@end
