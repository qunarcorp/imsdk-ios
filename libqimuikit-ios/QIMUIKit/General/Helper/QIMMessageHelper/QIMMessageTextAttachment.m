//
//  QIMMessageTextAttachment.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/4.
//

#import "QIMMessageTextAttachment.h"
#import "QIMEmojiTextAttachment.h"
#import "QIMATGroupMemberTextAttachment.h"

@implementation QIMMessageTextAttachment

static QIMMessageTextAttachment *_attachmentManager = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _attachmentManager = [[QIMMessageTextAttachment alloc] init];
    });
    return _attachmentManager;
}

- (NSString *)getStringFromAttributedString:(NSAttributedString *)attributedString WithOutAtInfo:(NSMutableArray **)outAtInfo {
    //最终纯文本
    NSMutableString *plainString = [NSMutableString stringWithString:attributedString.string];
    //替换下标的偏移量
    __block NSUInteger base = 0;
    
    *outAtInfo = [NSMutableArray arrayWithCapacity:3];
    NSMutableDictionary *atInfoDic = [NSMutableDictionary dictionaryWithCapacity:3];
    NSMutableArray *atInfoList = [NSMutableArray array];
    [atInfoDic setQIMSafeObject:atInfoList forKey:@"data"];
    [atInfoDic setQIMSafeObject:@(10001) forKey:@"type"];
    [*outAtInfo addObject:atInfoDic];
    //遍历
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value && [value isKindOfClass:[QIMEmojiTextAttachment class]]) {
            //替换
            [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                       withString:[((QIMEmojiTextAttachment *) value) getSendText]];
            
            //增加偏移量
            base += [((QIMEmojiTextAttachment *) value) getSendText].length - 1;
        } else if (value && [value isKindOfClass:[QIMATGroupMemberTextAttachment class]]) {
            NSMutableDictionary *atDic = [NSMutableDictionary dictionary];
            [atDic setQIMSafeObject:[(QIMATGroupMemberTextAttachment *)value groupMemberName] forKey:@"text"];
            [atDic setQIMSafeObject:[(QIMATGroupMemberTextAttachment *)value groupMemberJid] forKey:@"jid"];
            [atInfoList addObject:atDic];
        }
    }];
    if (atInfoList.count <= 0) {
        *outAtInfo = nil;
    }
    plainString = [NSMutableString stringWithString:[plainString stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""]];
    return plainString;
}

@end
