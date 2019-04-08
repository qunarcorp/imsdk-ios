//
//  QCIMConsultCell.m
//  IMSDK
//
//  Created by chenjie on 2017/08/08.
//  Copyright © 2017年 qunar. All rights reserved.
//

#import "QIMMsgBaloonBaseCell.h"
#import "QIMRobotQuestionCell.h"
#import "QIMTextContainer.h"
#import "QIMAttributedLabel.h"
#import "QIMMessageParser.h"
#import "QIMJSONSerializer.h"
#import "QIMMessageCellCache.h"
#import "QIMCustomPopManager.h"
#import "QIMCustomPopViewController.h"
#import "UIApplication+QIMApplication.h"

#define kSeplineColor       0xCCCCCC

#define kQCIMMsgCellIconWH 44
#define kQCIMMsgCellBoxMargin 12
#define kQCIMMsgCellCtntMargin 15
#define kQCIMMsgCellCtntFont 10
#define kQCIMMsgCellUsrTitleFont 15

#define kIMChatTimeFont [UIFont systemFontOfSize:11] //时间字体
#define kIMChatHintFont [UIFont systemFontOfSize:13] //提示和系统消息字体
#define kIMChatContentFont [UIFont systemFontOfSize:16]//内容字体

#define kLineHeight1px (1/[[UIScreen mainScreen] scale])

#define kIMChatMargin 12 //间隔
#define kIMChatIconWH 44 //头像宽高height、width
#define kIMChatTimeMarginW 10
#define kIMChatTimeMarginH 5
#define kIMChatContentTop 10
#define kIMChatContentLeft 12
#define kIMChatContentBottom 10
#define kIMChatContentRight 12
#define kIMAudioButtonMinWidth 62 //语音消息按钮宽度
#define kIMRedPointWH 8 //语音消息读取状态视图宽高

#define kActionsBtnTagFrom 1000
#define kHintTextFontSize   16
#define kSpaceToSide    15
#define kHintCelMaxWidth    ([UIScreen mainScreen].bounds.size.width - kSpaceToSide * 2)
#define kMessageIsUnfold  @"kMessageIsUnfold"

@interface QIMRobotQuestionCell()<QIMMenuImageViewDelegate,UIActionSheetDelegate,QIMAttributedLabelDelegate>
{
    UIView               * _bgView;
    QIMAttributedLabel   * _textLabel;
    UIView                * _listBGView;
    QIMAttributedLabel   * _hintLabel;
}

@property (nonatomic, strong) QIMTextContainer *textContainer;
@property (nonatomic, strong) QIMTextContainer *hintContainer;

@end

@implementation QIMRobotQuestionCell
@dynamic delegate;

+ (CGFloat)getCellHeightWihtMessage:(Message *)msg chatType:(ChatType)chatType {
    return [self consultRbtCellHeightForMsg:msg];
}

+ (CGFloat)consultRbtCellHeightForMsg:(Message *)msg {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat maxWidth = screenW - 2*kIMChatMargin;
    float cellHeight = 0;
    float cellWidth = maxWidth;
    NSString * jsonStr = msg.extendInformation ? msg.extendInformation : msg.message;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonStr error:nil];
    if (infoDic == nil && jsonStr.length) {
        infoDic = @{@"content":jsonStr?jsonStr:@""};
    }
    if (infoDic.count) { 
        //消息标题
        NSString * content = [infoDic objectForKey:@"content"];
        if (content.length) {
            QIMTextContainer *textContainer = [QIMMessageParser textContainerForMessageCtnt:content withId:msg.messageId direction:msg.messageDirection];
            textContainer.font = [UIFont systemFontOfSize:kHintTextFontSize];
            cellHeight += [textContainer getHeightWithFramesetter:nil width:textContainer.textWidth] + 10;
            cellWidth = textContainer.textWidth + (kIMChatContentLeft + kIMChatContentRight);
            cellHeight += 10;
        }
        
        NSString * listTips = infoDic[@"listTips"];
        if (listTips.length > 0) {
            cellHeight += 20;
            [listTips qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(maxWidth- kIMChatContentLeft - kIMChatContentRight, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
            cellHeight += 5;
        }
        
        cellHeight += 15;
        
        NSString * type = [infoDic[@"listArea"] objectForKey:@"type"];
        if ([type.lowercaseString isEqualToString:@"list"]) {
            NSArray * items = [infoDic[@"listArea"] objectForKey:@"items"];
            int initSize = [infoDic[@"listArea"][@"style"][@"defSize"] intValue];
            NSUInteger maxIndex = items.count;
            NSDictionary * isUnfoldDic = [[QIMMessageCellCache sharedInstance] getObjectForKey:kMessageIsUnfold];
            BOOL isUnfold = NO;
            if (isUnfoldDic) {
                isUnfold = [isUnfoldDic[msg.messageId] boolValue];
            }
            if (isUnfold == NO) {
                maxIndex = MIN(maxIndex, initSize);
            }
            
            if (items && items.count > 0) {
                cellHeight += 15;
                if (items.count > initSize) {
                    cellHeight += 35;
                }
                NSUInteger index = 0;
                for (NSDictionary * item in items) {
                    if ([item objectForKey:@"text"]) {
                        cellHeight += [[item objectForKey:@"text"] qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(maxWidth- kIMChatContentLeft - kIMChatContentRight, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
                        if (index >= maxIndex - 1) {
                            break;
                        }
                        index ++;
                    }
                }
                if (maxIndex >= 1) {
                    cellHeight += (10 * (maxIndex - 1));
                }
                cellHeight += 25;
            }
        }
        
        
        //hints
        NSArray * hints = [infoDic objectForKey:@"hints"];
        if (hints && [hints isKindOfClass:[NSArray class]] && hints.count) {
            cellHeight += 10;
            QIMTextContainer * container = [[QIMTextContainer alloc] init];
            container.textAlignment = kCTCenterTextAlignment;
            container.lineBreakMode = kCTLineBreakByCharWrapping;
            container.font = [UIFont systemFontOfSize:kHintTextFontSize];
            container.isWidthToFit = YES;
            for (NSDictionary * hintDic in hints) {
                NSString * type = [hintDic[@"event"][@"type"] lowercaseString];
                BOOL isLink = type && ![type isEqualToString:@"text"];
                NSString * text = hintDic[@"text"];
                if (isLink) {
                    [container appendLinkWithText:text linkFont:[UIFont systemFontOfSize:kHintTextFontSize] linkColor:[UIColor blueColor] underLineStyle:kCTUnderlineStyleNone linkData:hintDic];
                } else{
                    [container appendText:text];
                }
            }
            container = [container createTextContainerWithTextWidth:kHintCelMaxWidth];
            cellHeight += [container getHeightWithFramesetter:nil width:container.textWidth] + 20;
            [[QIMMessageCellCache sharedInstance] setObject:container forKey:[msg.messageId stringByAppendingString:@"_hints"]];
        }
    }
    return cellHeight + kIMChatContentTop + kIMChatContentBottom + 20;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithChatType:(ChatType)chatType{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.chatType = chatType;
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        self.contentView.backgroundColor = [UIColor qtalkChatBgColor];
        
        self.backView = nil;
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor qtalkChatBgColor];
        [self.contentView addSubview:_bgView];
        
        _textLabel = [[QIMAttributedLabel alloc] init];
        _textLabel.backgroundColor = [UIColor whiteColor];
        [_bgView addSubview:_textLabel];
        
        _listBGView = [[UIView alloc] init];
        _listBGView.backgroundColor = [UIColor whiteColor];
        _listBGView.layer.cornerRadius = 8.0;
        _listBGView.layer.masksToBounds = YES;
        [_bgView addSubview:_listBGView];
        
        _hintLabel = [[QIMAttributedLabel alloc] init];
        _hintLabel.backgroundColor = [UIColor qim_colorWithHex:0xc1c1c1];
        [_bgView addSubview:_hintLabel];
        
    }
    return self;
}

- (void)setMessage:(Message *)message {
    [super setMessage:message];
    _hintContainer = [[QIMMessageCellCache sharedInstance] getObjectForKey:[message.messageId stringByAppendingString:@"_hints"]];
    NSString * jsonStr = self.message.extendInformation ? self.message.extendInformation : self.message.message;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonStr error:nil];
    if (infoDic && infoDic[@"content"]) {
        if ([infoDic[@"content"] length]) {
        }else{
            _textContainer = nil;
            return;
        }
    }
    _textContainer = [QIMMessageParser textContainerForMessageCtnt:infoDic[@"content"] withId:message.messageId direction:message.messageDirection];
}

- (void)refreshUI {
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    _textLabel.delegate = self.delegate;
    _textLabel.textContainer = _textContainer;
    if (_textContainer) {
        [_textLabel setFrameWithOrign:CGPointMake((MessageDirection_Received == self.message.messageDirection) ? kQCIMMsgCellCtntMargin :kQCIMMsgCellCtntMargin - 3,kQCIMMsgCellCtntMargin) Width:[QIMMessageParser getCellWidth]];
    } else {
        [_textLabel setFrameWithOrign:CGPointMake(0,0) Width:[QIMMessageParser getCellWidth]];
    }
    NSString *jsonStr = self.message.extendInformation ? self.message.extendInformation : self.message.message;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonStr error:nil];
    CGFloat maxWidth = screenW - 2*kIMChatMargin;
    float backWidth = maxWidth;
    float backHeight = _textLabel.textContainer.textHeight +  20;
    [_listBGView removeAllSubviews];
    _listBGView.hidden = YES;
    float originY = 0;
    float space = 10;
    NSString * listTips = infoDic[@"listTips"];
    if (listTips.length > 0) {
        _listBGView.hidden = NO;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 55)];
        headerView.backgroundColor = [UIColor whiteColor];
        [_listBGView addSubview:headerView];
        float actionBtnHeight = [listTips qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(backWidth - kIMChatContentLeft - kIMChatContentRight, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
        UILabel *listTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        listTipsLabel.text = listTips;
        listTipsLabel.font = [UIFont boldSystemFontOfSize:16];
        [listTipsLabel setTextColor:[UIColor qim_colorWithHex:0x212121]];
        listTipsLabel.frame = CGRectMake(16,space + originY, backWidth - kIMChatContentLeft - kIMChatContentRight, actionBtnHeight);
        [_listBGView addSubview:listTipsLabel];
        listTipsLabel.centerY = headerView.centerY;
        
        NSString *iconUrl = [infoDic[@"listArea"] objectForKey:@"icon_url"];
        if (iconUrl.length > 0) {
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(headerView.frame) - 70, 5, 48, 48)];
            [iconView qim_setImageWithURL:iconUrl];
            iconView.backgroundColor = [UIColor clearColor];
            [headerView addSubview:iconView];
        }
        originY += (headerView.bottom + space);
    }
    
    NSString * type = [infoDic[@"listArea"] objectForKey:@"type"];
    if ([type.lowercaseString isEqualToString:@"list"]) {
        
        NSArray * items = [infoDic[@"listArea"] objectForKey:@"items"];
        int initSize = [infoDic[@"listArea"][@"style"][@"defSize"] intValue];
        
        if (items && items.count > 0) {
            NSUInteger maxIndex = items.count;
            NSDictionary * isUnfoldDic = [[QIMMessageCellCache sharedInstance] getObjectForKey:kMessageIsUnfold];
            BOOL isUnfold = NO;
            if (isUnfoldDic) {
                isUnfold = [isUnfoldDic[self.message.messageId] boolValue];
            }
            if (isUnfold == NO) {
                maxIndex = MIN(maxIndex, initSize+1);
            }
            NSUInteger index = 0;
            _listBGView.hidden = NO;
      
            for (NSDictionary * item in items) {
                if ([item objectForKey:@"text"]) {
                    float actionBtnHeight = [[item objectForKey:@"text"] qim_sizeWithFontCompatible:kIMChatContentFont constrainedToSize:CGSizeMake(backWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height + 5;
                    UILabel *itemAction = [[UILabel alloc] initWithFrame:CGRectZero];
                    [itemAction setTag:kActionsBtnTagFrom + index];
                    itemAction.numberOfLines = 0;
                    [itemAction setText:[item objectForKey:@"text"]];
                    [itemAction setTextColor:[UIColor qim_colorWithHex:0x5CC57F]];
                    [itemAction setFont:[UIFont systemFontOfSize:15]];
                    itemAction.frame = CGRectMake(16, space + originY, backWidth - kIMChatContentLeft - kIMChatContentRight, actionBtnHeight);
                    itemAction.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionsHandle:)];
                    [itemAction addGestureRecognizer:tap];
                    [_listBGView addSubview:itemAction];
                    
                    originY += (itemAction.height + space);
                    CGFloat lineOriginY = space / 2 + itemAction.height - 1;
                    if (index < maxIndex - 1 ) {
                        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, lineOriginY, itemAction.width, 0.5)];
                        line.backgroundColor = [UIColor qim_colorWithHex:0xe7e7e7];
                        [itemAction addSubview:line];
                    }
                }
                if (index >= maxIndex - 1) {
                    break;
                }
                index += 1;
            }
            
            if (items.count > initSize) {
                float actionBtnHeight = 30;
                UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, originY - 5, maxWidth, 50)];
                bottomView.layer.shadowOffset = CGSizeMake(0, -15);
                bottomView.layer.shadowOpacity = 0.9;
                bottomView.backgroundColor = [UIColor whiteColor];
                bottomView.layer.shadowColor = [UIColor whiteColor].CGColor;
                
                [_listBGView addSubview:bottomView];
                
                UILabel *itemAction = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 65, 20)];
                [itemAction setTextColor:[UIColor qim_colorWithHex:0x616161]];
                [itemAction setText:@"查看更多"];
                itemAction.adjustsFontSizeToFitWidth = YES;
                [itemAction setFont:[UIFont systemFontOfSize:16]];
                
                [bottomView addSubview:itemAction];
                
                itemAction.centerX = bottomView.centerX - 10;
                UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake(itemAction.right, 5, 20, 20)];
                [itemIcon setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3c7" size:20 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]]];
                [bottomView addSubview:itemIcon];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionsHandle:)];
                [bottomView addGestureRecognizer:tap];
                originY += (itemAction.height + space);
            }else{
                originY += 5;
            }
        } else {
            backWidth = self.contentView.width - 2 * kQCIMMsgCellBoxMargin;
        }
        originY += 3;
        _listBGView.frame = CGRectMake(kIMChatContentLeft, 10, backWidth, originY - 2.5);
        _listBGView.backgroundColor = [UIColor whiteColor];
        
//        if (_textContainer) {
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kIMChatContentLeft - 4.5, 0, backWidth - kIMChatContentLeft - kIMChatContentRight, 0.5)];
//            line.backgroundColor = [UIColor qim_colorWithHex:0xe7e7e7];
//            [_listBGView addSubview:line];
//        }
//        backHeight = _listBGView.bottom;
    }
    _bgView.frame = CGRectMake(0, 0, screenW, originY + 5);
//    [self setBackViewWithWidth:backWidth WihtHeight:backHeight];
    
    //hints
//    if (_hintContainer) {
//
//        _hintLabel.delegate = self;
//
//        _hintLabel.textContainer = _hintContainer;
//
//        float spaceToSide = ([UIScreen mainScreen].bounds.size.width - kSpaceToSide - _hintLabel.textContainer.textWidth) / 2;
//
//        [_hintLabel setFrameWithOrign:CGPointMake(spaceToSide, _bgView.bottom + 10) Width:_hintLabel.textContainer.textWidth];
//        _hintLabel.hidden = NO;
//    } else{
//        [_hintLabel setHidden:YES];
//    }
//    [self.backView setBubbleBgColor:[UIColor whiteColor]];
//    [super refreshUI];
}

- (void)requestHttpWithRequestUrl:(NSString *)urlStr {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *requestUrl = [[NSURL alloc] initWithString:urlStr];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        [request addRequestHeader:@"content-type" value:@"application/json"];
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:[[QIMKit sharedInstance] thirdpartKeywithValue]  forKey:NSHTTPCookieValue];
        [properties setValue:@"q_ckey" forKey:NSHTTPCookieName];
        [properties setValue:@".qunar.com" forKey:NSHTTPCookieDomain];
        [properties setValue:@"/" forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        [request startSynchronous];
        NSError *error = [request error];
        if (([request responseStatusCode] == 200) && !error) {
            
        }
    });
}

- (void)actionsHandle:(UITapGestureRecognizer *)tap {
    //问题列表点击动作
    NSInteger index = -1;
    index = tap.view.tag - kActionsBtnTagFrom;
    NSArray * items = nil;
    NSString *listTip = nil;
    int initSize = 0;
    NSString * jsonStr = self.message.extendInformation ? self.message.extendInformation : self.message.message;
    if (jsonStr.length) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonStr error:nil];
        NSString * type = [infoDic[@"listArea"] objectForKey:@"type"];
        listTip = [infoDic objectForKey:@"listTips"];
        if ([type.lowercaseString isEqualToString:@"list"]) {
            
            items = [infoDic[@"listArea"] objectForKey:@"items"];
            initSize = [infoDic[@"listArea"][@"style"][@"defSize"] intValue];
//            initSize = [infoDic[@"listArea"][@"stype"][@"defSize"] intValue];
        }
    }
    BOOL isUnfold = NO;
    NSDictionary * isUnfoldDic = [[QIMMessageCellCache sharedInstance] getObjectForKey:kMessageIsUnfold];
    if (isUnfoldDic) {
        isUnfold = [isUnfoldDic[self.message.messageId] boolValue];
    }
    NSUInteger maxIndex = items.count;
    if (isUnfold == NO) {
        maxIndex = MIN(maxIndex, initSize);
    }
    if (index >= 0 && index < maxIndex) {
        NSDictionary * itemDic = [items objectAtIndex:index];
        NSString * itemText = [itemDic objectForKey:@"text"];
        NSDictionary * eventDic = itemDic[@"event"];
        NSString * clickType = [eventDic objectForKey:@"type"];
        NSString * url = [eventDic objectForKey:@"url"];
        NSString * afterClickSendMsg = [eventDic objectForKey:@"msgText"];
        if ([[clickType lowercaseString] isEqualToString:@"interface"]) {
            if (url.length > 0) {
                [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:url withSuccessCallBack:^(NSData *responseData) {
                    
                } withFailedCallBack:^(NSError *error) {
                    
                }];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(sendTextMessageForText:isSendToServer:userType:)]) {
                    if (afterClickSendMsg.length) {
                        [self.delegate sendTextMessageForText:afterClickSendMsg isSendToServer:YES userType:@"cRbt"];
                    } else{
                        [self.delegate sendTextMessageForText:itemText isSendToServer:NO userType:@"cRbt"];
                    }
                }
            }
        } else if ([[clickType lowercaseString] isEqualToString:@"forward"]) {
            if (url.length ) {
                [QIMFastEntrance openWebViewForUrl:url showNavBar:YES];
            }
        }
    } else {
        QIMCustomPopViewController *popVc = [[QIMCustomPopViewController alloc] init];
        popVc.popHeaderTitle = listTip;
        popVc.items = items;
        [QIMCustomPopManager showPopVC:popVc withRootVC:[[UIApplication sharedApplication] visibleViewController]];
    }
    /*
    else if (index == maxIndex){
        //折叠 展开
        NSMutableDictionary * newIsUnfoldDic = [NSMutableDictionary dictionaryWithDictionary:isUnfoldDic];
        [newIsUnfoldDic setObject:@(!isUnfold) forKey:self.message.messageId];
        [[QIMMessageCellCache sharedInstance] setObject:newIsUnfoldDic forKey:kMessageIsUnfold];
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshRobotQuestionMessageCell:)]) {
            [self.delegate refreshRobotQuestionMessageCell:self];
        }
    }
    */
}

- (NSArray *)showMenuActionTypeList {
    return nil;
}

@end
