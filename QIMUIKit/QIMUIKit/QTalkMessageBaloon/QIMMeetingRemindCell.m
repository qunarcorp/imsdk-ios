//
//  QIMMeetingRemindCell.m
//  QIMUIKit
//
//  Created by 李露 on 2018/7/17.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMMeetingRemindCell.h"
#import "QIMJSONSerializer.h"
#import "QIMFastEntrance.h"

#define kCommonMeetingRemindCellWidth       IS_Ipad ? ([UIScreen mainScreen].qim_rightWidth  * 240 / 320) : ([UIScreen mainScreen].bounds.size.width * 5/7)

@interface QIMMeetingRemindCell () <QIMMenuImageViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) NSString *meetingId;

@property (nonatomic, copy) NSString *meetingUrl;

@end

@implementation QIMMeetingRemindCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType{
    
    NSString *infoStr = message.extendInformation.length <= 0 ? message.message : message.extendInformation;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
    NSMutableString *mutableTitle = [[NSMutableString alloc] initWithString:@""];
    
    if ([infoDic isKindOfClass:[NSDictionary class]]) {
        NSString *title = [infoDic objectForKey:@"title"];
        [mutableTitle appendFormat:title];
        [mutableTitle appendString:@"\n\n"];
        NSArray *keyValues = [infoDic objectForKey:@"keyValues"];
        if ([keyValues isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in keyValues) {
                for (NSString *key in [dict allKeys]) {
                    
                    NSString *value = [dict objectForKey:key];
                    if (key.length) {
                        [mutableTitle appendFormat:[NSString stringWithFormat:@"%@:%@", key, (value.length > 0) ? value : @""]];
                        if (![dict isEqual:[keyValues lastObject]]) {
                            [mutableTitle appendFormat:@"\n"];
                        }
                    } else {
                        continue;
                    }
                }
            }
        } else {
            
        }
    } else {
        [mutableTitle appendString:infoStr];
    }
    
    CGSize descSize = [mutableTitle qim_sizeWithFontCompatible:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.60 - 20, MAXFLOAT)];
    return 75 + MAX(descSize.height, 20) + 35;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *view = [[UIView alloc]initWithFrame:self.contentView.frame];
        view.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView = view;
        
        self.frameWidth = [UIScreen mainScreen].bounds.size.width;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor qtalkTextBlackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_titleLabel setNumberOfLines:0];
        [self.backView addSubview:_titleLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
        [self.backView addGestureRecognizer:tap];
    }
    return self;
}

- (void)onClick {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *url = @"";
        if ([self.meetingUrl containsString:@"?"]) {
            url = [NSString stringWithFormat:@"%@username=%@&meeting_id=%@", self.meetingUrl, [QIMKit getLastUserName], self.meetingId];
        } else {
            url = [NSString stringWithFormat:@"%@?username=%@&meeting_id=%@", self.meetingUrl, [QIMKit getLastUserName], self.meetingId];
        }
        [QIMFastEntrance openWebViewForUrl:url showNavBar:YES];
    });
}

- (NSString *)getMeetingRemindContent {
    NSString *infoStr = self.message.extendInformation.length <= 0 ? self.message.message : self.message.extendInformation;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
    NSMutableString *mutableTitle = [[NSMutableString alloc] initWithString:@""];
    
    if ([infoDic isKindOfClass:[NSDictionary class]]) {
        NSString *title = [infoDic objectForKey:@"title"];
        [mutableTitle appendFormat:title];
        [mutableTitle appendString:@"\n\n"];
        NSArray *keyValues = [infoDic objectForKey:@"keyValues"];
        if ([keyValues isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in keyValues) {
                for (NSString *key in [dict allKeys]) {
                    
                    NSString *value = [dict objectForKey:key];
                    if (key.length) {
                        [mutableTitle appendFormat:[NSString stringWithFormat:@"%@:%@ ", key, (value.length > 0) ? value : @""]];
                        if (![dict isEqual:[keyValues lastObject]]) {
                            [mutableTitle appendFormat:@"\n"];
                        }
                    } else {
                        continue;
                    }
                }
            }
        } else {
            
        }
        self.meetingUrl = [infoDic objectForKey:@"url"];
        self.meetingId = [[infoDic objectForKey:@"params"] objectForKey:@"id"];
    } else {
        [mutableTitle appendString:infoStr];
    }
    return mutableTitle;
}

- (void)refreshUI {
    
    self.selectedBackgroundView.frame = self.contentView.frame;
    CGFloat cellHeight = [QIMMeetingRemindCell getCellHeightWihtMessage:self.message chatType:self.chatType];
    CGFloat cellWidth = kCommonMeetingRemindCellWidth;
    [self.backView setMessage:self.message];
    [self setBackViewWithWidth:cellWidth WihtHeight:cellHeight];
    
    CGFloat titleLeft = (self.message.messageDirection == MessageDirection_Sent) ? 15 : 25;
    NSString *content = [self getMeetingRemindContent];
    [_titleLabel setText:content.length > 0 ? content : @""];
    
    CGSize titleSize = [_titleLabel.text qim_sizeWithFontCompatible:_titleLabel.font constrainedToSize:CGSizeMake(cellWidth - titleLeft - 10, cellHeight - 30)];
    [_titleLabel setFrame:CGRectMake(titleLeft, 10, cellWidth - titleLeft - 10, titleSize.height)];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, cellHeight - 30, titleSize.width, 20)];
    NSMutableAttributedString *messageAttriStr = [[NSMutableAttributedString alloc] initWithString:@"点击查看全文"];
    [messageAttriStr addAttribute:NSForegroundColorAttributeName value:[UIColor qim_colorWithHex:0x009ad6 alpha:1.0] range:NSMakeRange(0, 6)];
    [messageAttriStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, 6)];
    text.attributedText = messageAttriStr;
    [self.backView addSubview:text];
    
    [super refreshUI];
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end
