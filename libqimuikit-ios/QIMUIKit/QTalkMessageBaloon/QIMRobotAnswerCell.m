//
//  QIMRobotAnswerCell.m
//  QIMUIKit
//
//  Created by 李露 on 11/9/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMRobotAnswerCell.h"
#import "QIMTextContainer.h"
#import "QIMMessageParser.h"
#import "QIMAttributedLabel.h"
#import "QIMButton.h"

#define kHintTextFontSize   16
#define kLikeRobotAnswerTag 10001
#define kDislikeRobotAnswerTag 10002
#define kLineWidth             1.0f

@interface QIMRobotAnswerCell ()

@property (nonatomic, strong) QIMAttributedLabel *msgContentLabel;
@property (nonatomic, strong) QIMAttributedLabel *middleContentLabel;
@property (nonatomic, strong) UIView *panelBgView;
@property (nonatomic, strong) UIView *controllPanelBgView;
@property (nonatomic, strong) QIMTextContainer *msgContentContainer;
@property (nonatomic, strong) QIMTextContainer *middleContentContainer;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *dislikeButton;
@property (nonatomic, strong) UIButton *teachButton;

@end

@implementation QIMRobotAnswerCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType {
    
    NSDictionary *exTrdDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
    NSString *content = [exTrdDic objectForKey:@"content"];
    CGFloat cellHeight = 0.0f;
    if (content.length) {
        Message *contentMsg = [[Message alloc] init];
        contentMsg.message = content;
        contentMsg.messageId = [NSString stringWithFormat:@"%@_content", message.messageId];
        contentMsg.messageDirection = message.messageDirection;
        QIMTextContainer *textContainer = [QIMMessageParser textContainerForMessage:contentMsg];
        textContainer.font = [UIFont systemFontOfSize:kHintTextFontSize];
        cellHeight += [textContainer getHeightWithFramesetter:nil width:textContainer.textWidth];
    }
    MessageState state = [[QIMKit sharedInstance] getMessageStateWithMsgId:message.messageId];
    if (state == MessageState_didControl) {
        return cellHeight + 50;
    } else {
        NSString *middleContent = [exTrdDic objectForKey:@"middleContent"];
        if (middleContent.length) {
            Message *middleContentMsg = [[Message alloc] init];
            middleContentMsg.message = middleContent;
            middleContentMsg.messageId = [NSString stringWithFormat:@"%@_middleContent", message.messageId];
            middleContentMsg.messageDirection = message.messageDirection;
            QIMTextContainer *textContainer = [QIMMessageParser textContainerForMessage:middleContentMsg];
            textContainer.font = [UIFont systemFontOfSize:12];
            cellHeight += [textContainer getHeightWithFramesetter:nil width:textContainer.textWidth];
        }
        return cellHeight + 100;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        self.contentView.backgroundColor = [UIColor qtalkChatBgColor];
        
        self.msgContentLabel = [[QIMAttributedLabel alloc] init];
        self.msgContentLabel.backgroundColor = [UIColor clearColor];
        [self.backView addSubview:self.msgContentLabel];
        
        self.panelBgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.panelBgView.backgroundColor = [UIColor whiteColor];
        [self.backView addSubview:self.panelBgView];
        
        self.controllPanelBgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.controllPanelBgView.backgroundColor = [UIColor whiteColor];
        [self.panelBgView addSubview:self.controllPanelBgView];
        
        self.middleContentLabel = [[QIMAttributedLabel alloc] init];
        self.middleContentLabel.backgroundColor = [UIColor clearColor];
        [self.panelBgView addSubview:self.middleContentLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageControlStateByNotification:) name:kNotificationMessageControlStateUpdate object:nil];
    }
    return self;
}

- (void)updateMessageControlStateByNotification:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notifyDic = notify.object;
        NSArray *msgIds = [notifyDic objectForKey:@"MsgIds"];
        for (NSDictionary *msgDict in msgIds) {
            NSString *msgId = [msgDict objectForKey:@"id"];
            MessageState state = (MessageState)[[notifyDic objectForKey:@"State"] unsignedIntegerValue];
            if ([msgId isEqualToString:self.message.messageId]) {
                if (state > self.message.messageState) {
                    self.message.messageState = state;
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshRobotAnswerMessageCell:)]) {
                    [self.delegate refreshRobotAnswerMessageCell:self];
                }
                break;
            } else {
                
            }
        }
    });
}

- (void)refreshUI {
    
    NSDictionary *exTrdDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil];
    NSString *msgContent = [exTrdDic objectForKey:@"content"];
    Message *contentMsg = [[Message alloc] init];
    contentMsg.message = msgContent;
    contentMsg.messageId = [NSString stringWithFormat:@"%@_content", self.message.messageId];
    contentMsg.messageDirection = self.message.messageDirection;
    _msgContentContainer = [QIMMessageParser textContainerForMessage:contentMsg];
    
    self.msgContentLabel.delegate = self.delegate;
    self.msgContentLabel.textContainer = _msgContentContainer;
    if (_msgContentContainer) {
        [self.msgContentLabel setFrameWithOrign:CGPointMake((MessageDirection_Received == self.message.messageDirection) ? 25 :10, 16) Width:[QIMMessageParser getCellWidth]];
    }else {
        [self.msgContentLabel setFrameWithOrign:CGPointMake(0, 0) Width:[QIMMessageParser getCellWidth]];
    }
    float cellWidth = [QIMMessageParser getCellWidth];
    float height = [QIMRobotAnswerCell getCellHeightWihtMessage:self.message chatType:self.message.chatType - 20];
    
    [self.backView setMessage:self.message];
    [self.backView setBubbleBgColor:[UIColor whiteColor]];
    [self setBackViewWithWidth:[QIMMessageParser getCellWidth] + 40 WihtHeight:height - 30];
    MessageState state = [[QIMKit sharedInstance] getMessageStateWithMsgId:self.message.messageId];
    if (state != MessageState_didControl) {
        self.panelBgView.frame = CGRectMake(10, self.msgContentLabel.bottom, [QIMMessageParser getCellWidth] + 40 - 20, self.backView.bottom - self.msgContentLabel.bottom - 35);
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(12, 5, cellWidth + 20 - 24, 1.0f)];
        self.lineView.backgroundColor = [UIColor qim_colorWithHex:0xEEEEEE];
        [self.panelBgView addSubview:self.lineView];
        
        NSString *middleContent = [exTrdDic objectForKey:@"middleContent"];
        Message *middleContentMsg = [[Message alloc] init];
        middleContentMsg.message = middleContent;
        middleContentMsg.messageId = [NSString stringWithFormat:@"%@_middleContent", self.message.messageId];
        middleContentMsg.messageDirection = self.message.messageDirection;
        _middleContentContainer = [QIMMessageParser textContainerForMessage:middleContentMsg];
        
        self.middleContentLabel.delegate = self.delegate;
        self.middleContentLabel.textContainer = _middleContentContainer;
        if (_middleContentContainer) {
            [self.middleContentLabel setFrameWithOrign:CGPointMake((MessageDirection_Received == self.message.messageDirection) ? 20 :5, 16) Width:[QIMMessageParser getCellWidth]];
        } else {
            [self.middleContentLabel setFrameWithOrign:CGPointMake(0,0) Width:[QIMMessageParser getCellWidth]];
        }
        self.middleContentLabel.font = [UIFont systemFontOfSize:12];
        self.middleContentLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [self.panelBgView addSubview:self.middleContentLabel];
        self.controllPanelBgView.frame = CGRectMake(0, self.middleContentLabel.bottom + 10, self.panelBgView.width, 20);
        [self setupControlButton];
    } else {
        [self.lineView removeFromSuperview];
        [self.panelBgView removeAllSubviews];
        [self.panelBgView removeFromSuperview];
    }
    [super refreshUI];
    [self.backView setBubbleBgColor:[UIColor whiteColor]];
}

- (void)setupControlButton {
    QIMButton *likeButton = [QIMButton buttonWithType:UIButtonTypeCustom];
    likeButton.frame = CGRectMake(15, 0, 50, 20);
    likeButton.imageAlignment = QIMButtonImageAlignmentLeft;
    likeButton.tag = kLikeRobotAnswerTag;
    likeButton.adjustsImageWhenHighlighted = NO;
    [likeButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f04f" size:20 color:[UIColor qim_colorWithHex:0x9E9E9E]]] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f04f" size:20 color:[UIColor redColor]]] forState:UIControlStateSelected];
    [likeButton setTitle:@"有用" forState:UIControlStateNormal];
    [likeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [likeButton setTitleColor:[UIColor qim_colorWithHex:0x5CC57F] forState:UIControlStateNormal];
    [likeButton addTarget:self action:@selector(feedbackAnswer:) forControlEvents:UIControlEventTouchUpInside];
    [self.controllPanelBgView addSubview:likeButton];
    self.likeButton = likeButton;
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(self.controllPanelBgView.width / 3.0, 0, kLineWidth, 20)];
    lineView1.backgroundColor = [UIColor qim_colorWithHex:0xEEEEEE];
    [self.controllPanelBgView addSubview:lineView1];

    QIMButton *dislikeButton = [QIMButton buttonWithType:UIButtonTypeCustom];
    dislikeButton.adjustsImageWhenHighlighted = NO;
    dislikeButton.frame = CGRectMake(lineView1.right + 18, 0, 50, 20);
    dislikeButton.tag = kDislikeRobotAnswerTag;
    dislikeButton.imageAlignment = QIMButtonImageAlignmentLeft;
    [dislikeButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e5eb" size:20 color:[UIColor qim_colorWithHex:0x9E9E9E]]] forState:UIControlStateNormal];
    [dislikeButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e5eb" size:20 color:[UIColor redColor]]] forState:UIControlStateSelected];
    [dislikeButton setTitle:@"没用" forState:UIControlStateNormal];
    [dislikeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [dislikeButton setTitleColor:[UIColor qim_colorWithHex:0x5CC57F] forState:UIControlStateNormal];
    [dislikeButton addTarget:self action:@selector(feedbackAnswer:) forControlEvents:UIControlEventTouchUpInside];
    [self.controllPanelBgView addSubview:dislikeButton];
    self.dislikeButton = dislikeButton;
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(2 * self.controllPanelBgView.width / 3.0, 0, kLineWidth, 20)];
    lineView2.backgroundColor = [UIColor qim_colorWithHex:0xEEEEEE];
    [self.controllPanelBgView addSubview:lineView2];
    
    QIMButton *teachButton = [QIMButton buttonWithType:UIButtonTypeCustom];
    teachButton.adjustsImageWhenHighlighted = NO;
    teachButton.frame = CGRectMake(lineView2.right + 18, 0, 50, 20);
    teachButton.imageAlignment = QIMButtonImageAlignmentLeft;
    [teachButton setTitle:@"教小拿" forState:UIControlStateNormal];
    [teachButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [teachButton setTitleColor:[UIColor qim_colorWithHex:0x5CC57F] forState:UIControlStateNormal];
    [teachButton addTarget:self action:@selector(reTeachRobot:) forControlEvents:UIControlEventTouchUpInside];
    [self.controllPanelBgView addSubview:teachButton];
    self.teachButton = teachButton;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)feedbackAnswer:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSDictionary *exTrdDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil];
    NSString *requestUrl = [exTrdDic objectForKey:@"url"];
    NSDictionary *originPostBody = [exTrdDic objectForKey:@"requestPost"];
    NSMutableDictionary *tempPostBodyDic = [NSMutableDictionary dictionaryWithDictionary:originPostBody];
    if (btn.tag == kLikeRobotAnswerTag) {
        [tempPostBodyDic setObject:@"yes" forKey:@"isOk"];
    } else if (btn.tag == kDislikeRobotAnswerTag) {
        [tempPostBodyDic setObject:@"no" forKey:@"isOk"];
    }
    NSData *bodydata = [[QIMJSONSerializer sharedInstance] serializeObject:tempPostBodyDic error:nil];
    __block NSInteger btnTag = btn.tag;
    __weak __typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:requestUrl withRequestBodyData:bodydata withSuccessCallBack:^(NSData *responseData) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        UIButton *button = (UIButton *)[self.controllPanelBgView viewWithTag:btnTag];
        [button setSelected:YES];
        [button setEnabled:NO];
        [self.likeButton setEnabled:NO];
        [self.dislikeButton setEnabled:NO];
        [self.teachButton setEnabled:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshRobotAnswerMessageCell:)]) {
            [self.delegate refreshRobotAnswerMessageCell:self];
        }
        [[QIMKit sharedInstance] sendControlStateWithMessagesIdArray:@[self.message.messageId] WithXmppId:self.message.from];
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)reTeachRobot:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reTeachRobot)]) {
        [self.delegate reTeachRobot];
    }
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end
