//
//  QIMMsgBaloonBaseCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QIMMsgBaloonBaseCell.h"
#import "QIMTextStorage.h"
#import "QIMImageStorage.h"
#import "QIMTextContainer.h"
#import "QIMCollectionFaceManager.h"

static UIImage *__leftBallocImage = nil;
static UIImage *__rightBallocImage = nil;

@interface QIMMsgBaloonBaseCell() <QIMMenuImageViewDelegate>

@property (nonatomic, strong) QIMTextContainer *textContainer;

@end

@implementation QIMMsgBaloonBaseCell

+ (UIImage *)leftBallocImage {
    //return nil时，自动用贝塞尔曲线画气泡
    return nil;
    if (__leftBallocImage == nil) {
        NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"leftBalloon"]);
        UIImage *image = [[UIImage alloc] initWithData:data scale:[[UIScreen mainScreen] scale]];
        CGFloat width = image.size.width / 2.0;
        CGFloat height = image.size.height / 2.0;
        __leftBallocImage = [image stretchableImageWithLeftCapWidth:width topCapHeight: height];
    }
    return __leftBallocImage;
}

+ (UIImage *)rightBallcoImage{
    return nil;
    if (__rightBallocImage == nil) {
        NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"rightBalloon"]);
        UIImage *image = [[UIImage alloc] initWithData:data scale:[[UIScreen mainScreen] scale]];
        CGFloat width = image.size.width / 2.0;
        CGFloat height = image.size.height / 2.0;
        __rightBallocImage = [image stretchableImageWithLeftCapWidth:width topCapHeight: height];
    }
    return __rightBallocImage;
}

#pragma mark - setter and getter

- (void)setMessage:(Message *)message {
    Message *tempMsg = _message;
    _message = message;
    [self updateNameLabel];
    [self refreshHeaderView];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        UIView* view = [[UIView alloc]initWithFrame:self.contentView.frame];
        view.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView = view;
        [self setBackgroundColor:[UIColor clearColor]];
        [self initBackViewAndHeaderName];
        [self setupGestureRecognizer];
        //消息发送成功
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgDidSendNotificationHandle:) name:kXmppStreamDidSendMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeaderView) name:kUserHeaderImgUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageStateByNotification:) name:kNotificationMessageStateUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserCard:) name:kUserVCardUpdate object:nil];
    }
    return self;
}

- (void)msgDidSendNotificationHandle:(NSNotification *)notify {
    NSString * msgID = [notify.object objectForKey:@"messageId"];
    
    //消息发送成功，更新消息状态
    if ([[self.message messageId] isEqualToString:msgID]) {
        if (self.message.messageState < MessageState_Success) {
            self.message.messageState = MessageState_Success;
        }
        [self refreshUI];
    }
}

- (void)updateMessageStateByNotification:(NSNotification *)notify {
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
                [self updateMessageState];
                [[QIMKit sharedInstance] updateMsgReadCompensateSetWithMsgId:msgId WithAddFlag:NO WithState:state];
                break;
            } else {
                [[QIMKit sharedInstance] updateMsgReadCompensateSetWithMsgId:msgId WithAddFlag:YES WithState:state];
            }
        }
        
        NSMutableSet *compensateMsgs = [[QIMKit sharedInstance] getLastMsgCompensateReadSet];
//        QIMVerboseLog(@"现有的补偿消息状态set : %@", compensateMsgs);
        for (NSDictionary *msgCompensateDic in compensateMsgs) {
//            QIMVerboseLog(@"补偿消息状态 : %@", msgCompensateDic);
            NSString *MsgId = [msgCompensateDic objectForKey:@"MsgId"];
            MessageState state = (MessageState)[[msgCompensateDic objectForKey:@"State"] unsignedIntegerValue];
            if ([MsgId isEqualToString:self.message.messageId]) {
                if (state > self.message.messageState) {
                    self.message.messageState = state;
                }
                [self updateMessageState];
                [[QIMKit sharedInstance] updateMsgReadCompensateSetWithMsgId:MsgId WithAddFlag:NO WithState:state];
                break;
            }
        }
    });
}

- (void)refreshUserCard:(NSNotification *)notify {
    
    NSArray *updateUserIds = notify.object;
    if ([updateUserIds containsObject:self.message.nickName]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateNameLabel];
            [self refreshHeaderView];
        });
    }
}

- (void)initBackViewAndHeaderName{
    
    self.backView = [[QIMMenuImageView alloc] initWithFrame:CGRectZero];
    [self.backView setDelegate:self];
    [self.backView setUserInteractionEnabled:YES];
    [self.backView setAccessibilityIdentifier:@"MessageBackView"];
    
    [self.contentView addSubview:self.backView];
    
    [self.contentView addSubview:self.HeadView];
    [self.contentView addSubview:self.nameLabel];
}

- (UIImageView *)HeadView {
    if (!_HeadView) {
        _HeadView = [[UIImageView alloc] initWithFrame:CGRectMake(AVATAR_SUPER_LEFT, 0, AVATAR_WIDTH, AVATAR_HEIGHT)];
        _HeadView.layer.cornerRadius = AVATAR_WIDTH / 2.0f;
        _HeadView.layer.masksToBounds = YES;
        _HeadView.contentMode = UIViewContentModeScaleAspectFit;
        _HeadView.userInteractionEnabled = YES;
        _HeadView.backgroundColor = [UIColor qim_colorWithHex:0x9e9e9e alpha:1.0];
        _HeadView.image = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
    }
    return _HeadView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.HeadView.right + NAME_SUPER_LEFT, 0, NAME_SUPER_WIDTH, NAME_SUPER_HEIGHT)];
        _nameLabel.textColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1/1.0];
    }
    return _nameLabel;
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusButton setImage:[UIImage imageNamed:@"MessageSendFail"] forState:UIControlStateNormal];
        _statusButton.contentMode = UIViewContentModeScaleAspectFit;
        _statusButton.frame = CGRectMake(self.backView.left - 30, 0, 24, 24);
        _statusButton.hidden = YES;
        [_statusButton addTarget:self action:@selector(resendMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _statusButton;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.hidden = NO;
    }
    return _indicatorView;
}

- (UILabel *)messgaeStateLabel {
    if (!_messgaeStateLabel) {
        _messgaeStateLabel = [[UILabel alloc] init];
        _messgaeStateLabel.adjustsFontSizeToFitWidth = YES;
        _messgaeStateLabel.textAlignment = NSTextAlignmentRight;
        _messgaeStateLabel.font = [UIFont systemFontOfSize:10];
        _messgaeStateLabel.text = @"未读";
        _messgaeStateLabel.hidden = YES;
        _messgaeStateLabel.frame = CGRectMake(self.backView.left - 40, self.backView.bottom - 12, 35, 12);
        _messgaeStateLabel.textColor = [UIColor qim_colorWithHex:0x15b0f9 alpha:1.0];
    }
    return _messgaeStateLabel;
}

- (UILabel *)messgaeRealStateLabel {
    if (!_messgaeRealStateLabel) {
        _messgaeRealStateLabel = [[UILabel alloc] init];
        _messgaeRealStateLabel.adjustsFontSizeToFitWidth = YES;
        _messgaeRealStateLabel.textAlignment = NSTextAlignmentRight;
        _messgaeRealStateLabel.frame = CGRectMake(self.backView.left - 80, self.backView.top, 70, 24);
        _messgaeRealStateLabel.numberOfLines = 0;
        _messgaeRealStateLabel.font = [UIFont systemFontOfSize:10];
        _messgaeRealStateLabel.textColor = [UIColor redColor];
    }
    return _messgaeRealStateLabel;
}

- (void)setupGestureRecognizer {
    
    UITapGestureRecognizer *tapHead = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHeaderViewClick:)];
    tapHead.numberOfTapsRequired = 1;
    tapHead.numberOfTouchesRequired = 1;
    [self.HeadView addGestureRecognizer:tapHead];
    
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(atSomeOne:)];
    longGes.minimumPressDuration = 0.6;
    longGes.allowableMovement = 1000;
    [self.HeadView addGestureRecognizer:longGes];
}

+ (CGFloat)getCellHeightWihtMessage:(Message *)message  chatType:(ChatType)chatType{
    @throw  [NSException exceptionWithName:@"QIMMsgBaloonBaseCell Exception" reason:[NSString stringWithFormat:@"Class %@ \"getCellHeightWihtMessage\" method has not realized ",[self class]] userInfo:nil];
}

- (void)refreshUI {
    self.backView.menuActionTypeList = [self showMenuActionTypeList];
    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            self.HeadView.frame = CGRectMake(AVATAR_SUPER_LEFT, AVATAR_SUPER_TOP, AVATAR_WIDTH, AVATAR_HEIGHT);
            
            self.nameLabel.font = [UIFont systemFontOfSize:13];
            if (self.chatType == ChatType_System) {
                self.HeadView.hidden = YES;
                self.nameLabel.hidden = YES;
            } else if (self.chatType == ChatType_SingleChat) {
                self.nameLabel.hidden = YES;
            } else {
            }
        }
            break;
        case MessageDirection_Sent: {
            CGFloat selectOffset = self.editing ? (CELL_EDIT_OFFSET + AVATAR_SUPER_LEFT) : AVATAR_SUPER_LEFT;
            CGRect headViewFrame = {{self.frameWidth - AVATAR_WIDTH - selectOffset, AVATAR_SUPER_TOP},{AVATAR_WIDTH,AVATAR_HEIGHT}};
            self.HeadView.frame = headViewFrame;
        }
            break;
        default:
            break;
    }
    [self updateMessageState];
    float moveSpace = 38;
    CGRect rect = self.backView.frame;
    if (self.editing) {
        if (self.message.messageDirection == MessageDirection_Sent) {
            rect.origin.x = rect.origin.x - moveSpace;
            self.backView.frame = rect;
        }
    }
    [self.backView setAccessibilityIdentifier:self.message.messageId];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (self.editing == editing) {
        return;
    }
    [super setEditing:editing animated:animated];
    
    float moveSpace = 38;
    CGRect rect = self.backView.frame;
    CGRect headerRect = self.HeadView.frame;
    if (self.editing) {
        self.HeadView.userInteractionEnabled = NO;
        if (self.message.messageDirection == MessageDirection_Sent) {
            headerRect.origin.x = headerRect.origin.x - moveSpace;
            rect.origin.x = rect.origin.x - moveSpace;
            self.HeadView.frame = headerRect;
            self.backView.frame = rect;
        }
    } else {
        self.HeadView.userInteractionEnabled = YES;
        if (self.message.messageDirection == MessageDirection_Sent) {
            headerRect.origin.x = headerRect.origin.x + moveSpace;
            rect.origin.x = rect.origin.x + moveSpace;
            self.HeadView.frame = headerRect;
            self.backView.frame = rect;
        }
    }
}

- (void)updateNameLabel {

    if (self.message.messageDirection == MessageDirection_Received) {
        __block NSString *nickName = self.message.nickName;
        if (self.chatType != ChatType_CollectionChat) {
            //备注
            NSString * remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.message.nickName];
            if (remarkName.length > 0) {
                nickName = remarkName;
            }
        } else {
            NSDictionary *userInfo = [[QIMKit sharedInstance] getCollectionUserInfoByUserId:nickName];
            NSString *userName = [[[userInfo objectForKey:@"Name"] componentsSeparatedByString:@"@"] firstObject];
            if (userName.length > 0) {
                nickName = userName;
            } else {
                
            }
        }
        nickName = [[nickName componentsSeparatedByString:@"@"] firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nameLabel.text = nickName;
            if (self.delegate && [self.delegate respondsToSelector:@selector(getColorHex:)]) {
                [self.nameLabel setTextColor:[UIColor qim_colorWithHex:[self.delegate getColorHex:nickName] alpha:1.0]];
            } else {
                self.nameLabel.textColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1/1.0];
            }
        });
    }
}

- (void)updateMessageState {
    if (self.chatType == ChatType_PublicNumber) {
        return;
    }
    if (self.message.messageDirection == MessageDirection_Sent) {
        //这里只有单聊，Consult（单人会话）显示消息状态
        if ((self.chatType == ChatType_SingleChat || self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) && ![[QIMKit sharedInstance] isMiddleVirtualAccountWithJid:self.message.to]) {
            if ([[QIMKit sharedInstance] qimNav_Showmsgstat]) {
                [self.contentView addSubview:self.messgaeStateLabel];
            }
            if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
                self.messgaeRealStateLabel.frame = CGRectMake(self.backView.left - 80, self.backView.top, 70, 24);
                [self.contentView addSubview:self.messgaeRealStateLabel];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (self.message.messageState) {
                case MessageState_Waiting: {
                    self.indicatorView.center = CGPointMake(self.backView.left - 24, self.backView.centerY);
                    [self.contentView addSubview:self.indicatorView];
                    [self.indicatorView startAnimating];
                    self.messgaeRealStateLabel.text = [NSString stringWithFormat:@"发送中 %@", self.message.messageId];
                }
                    break;
                case MessageState_Faild: {
//                    QIMVerboseLog(@"消息发送失败 : %@", self.message);
                    self.messgaeRealStateLabel.text = [NSString stringWithFormat:@"消息发送失败 %@", self.message.messageId];
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                    self.statusButton.center = CGPointMake(self.backView.left - 24, self.backView.centerY);
                    self.statusButton.hidden = NO;
                    [self.contentView addSubview:self.statusButton];
                }
                    break;
                case MessageState_NotRead: {
//                    QIMVerboseLog(@"已发送至对方用户，但未读 : 【%@】", self.message.messageId);
                    self.messgaeRealStateLabel.text = [NSString stringWithFormat:@"%@-%@", @"已发送至对方用户，但未读", self.message.messageId];
                    
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                    self.messgaeStateLabel.hidden = NO;
                    self.statusButton.hidden = YES;
                    self.messgaeStateLabel.text = @"未读";
                    self.messgaeStateLabel.textColor = [UIColor qim_colorWithHex:0x15b0f9 alpha:1.0];
                }
                    break;
                case MessageState_didRead: {
//                    QIMVerboseLog(@"对方已读 : 【%@】", self.message.messageId);
                    self.messgaeRealStateLabel.text = @"对方已读";
                    
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                    self.messgaeStateLabel.hidden = NO;
                    self.messgaeStateLabel.text = @"已读";
                    self.messgaeStateLabel.textColor = [UIColor lightGrayColor];
                    self.statusButton.hidden = YES;
                }
                    break;
                case MessageState_none: {
                    self.messgaeRealStateLabel.text = [NSString stringWithFormat:@"未读None_%@", self.message.messageId];
                    
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                    self.statusButton.hidden = YES;
                    self.messgaeStateLabel.hidden = NO;
                    self.messgaeStateLabel.text = @"未读";
                    self.messgaeStateLabel.textColor = [UIColor qim_colorWithHex:0x15b0f9 alpha:1.0];
                }
                    break;
                case MessageState_Success: {
//                    QIMVerboseLog(@"已送达至服务器，对方用户还没接收 : 【%@】", self.message.messageId);
                    self.messgaeRealStateLabel.text = [NSString stringWithFormat:@"%@-%@", @"已送达至服务器，对方用户还没接收", self.message.messageId];
                    
                    self.statusButton.hidden = YES;
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                    self.messgaeStateLabel.hidden = NO;
                    self.messgaeStateLabel.text = @"未读";
                    self.messgaeStateLabel.textColor = [UIColor qim_colorWithHex:0x15b0f9 alpha:1.0];
                }
                    break;
                default: {
                    self.statusButton.hidden = YES;
                    [self.indicatorView stopAnimating];
                    self.indicatorView.hidden = YES;
                }
                    break;
            }
        });
    } else {
        switch (self.message.messageState) {
            case MessageState_didRead: {
//                QIMVerboseLog(@"接收到的消息【%@】已读", self.message.messageId);
            }
                break;
            default:
                break;
        }
    }
}

- (void)setBackViewWithWidth:(CGFloat)backWidth WihtHeight:(CGFloat)backHeight{
    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            CGRect frame = {{kBackViewCap + AVATAR_WIDTH,kCellHeightCap / 2.0 + _nameLabel.bottom},{backWidth,backHeight}};
            if (self.chatType != ChatType_PublicNumber && self.chatType != ChatType_System) {
                frame = CGRectMake(kBackViewCap + AVATAR_WIDTH, kCellHeightCap / 2.0 + _nameLabel.bottom, backWidth, backHeight);
            } else {
                frame = CGRectMake(kBackViewCap, kCellHeightCap / 2.0, backWidth, backHeight);
            }
            [self.backView setFrame:frame];
            [self.backView setImage:[QIMMsgBaloonBaseCell leftBallocImage]];
        }
            break;
        case MessageDirection_Sent: {
            CGRect frame = {{self.frameWidth - kBackViewCap - backWidth - AVATAR_WIDTH, kCellHeightCap / 2.0 + kBackViewCap},{backWidth,backHeight}};
            [self.backView setFrame:frame];
            [self.backView setImage:[QIMMsgBaloonBaseCell rightBallcoImage]];
            _messgaeStateLabel.frame = CGRectMake(self.backView.left - 40, self.backView.bottom - 12, 35, 12);
            _statusButton.frame = CGRectMake(self.backView.left - 30, 0, 24, 24);
            _statusButton.center = CGPointMake(self.backView.left - 24, self.backView.centerY);
        }
            break;
        default:
            break;
    }
}

- (CGRect)getCellBackViewFrame{
    CGRect backFrame = [self convertRect:_backView.frame fromView:self.contentView];
    return CGRectMake(self.left + backFrame.origin.x, self.top + backFrame.origin.y, backFrame.size.width, backFrame.size.height);
}

#pragma mark - action

- (void)onHeaderViewClick:(UITapGestureRecognizer *)tapGesture {
    if (self.message.nickName.length > 0 && self.chatType != ChatType_CollectionChat) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:self.message.nickName];
        });
    }
}

- (void)resendMessage:(id)sender {
    if (self.message.messageState == MessageState_Faild) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamReSendMessage object:self.message];
    }
}

- (void)atSomeOne:(UILongPressGestureRecognizer *)logGes {
    if (logGes.state == UIGestureRecognizerStateBegan && self.chatType == ChatType_GroupChat) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ATSomeOneNotifacation object:self.message.nickName];
    }
}

- (void)onMenuActionWithType:(MenuActionType)actionType {
    switch (actionType) {
        case MA_Copy: {
            NSMutableString *str = [[NSMutableString alloc] initWithCapacity:3];
            for (QIMTextStorage *textStorage in self.textContainer.textStorages) {
                if (![textStorage isKindOfClass:[QIMTextStorage class]]) {
                    continue;
                } else {
                    [str appendString:textStorage.text];
                }
            }
            [_backView setClipboardWitxthText:str];
        }
            break;
        case MA_Collection: {
            for (QIMImageStorage * imageStorage in self.textContainer.textStorages) {
                
                if (![imageStorage isKindOfClass:[QIMImageStorage class]]) {
                    
                    return;
                } else {
                    NSURL *imageUrl = imageStorage.imageURL;
                    [[QIMKit sharedInstance] getPermUrlWithTempUrl:[imageUrl absoluteString] PermHttpUrl:^(NSString *httpPermUrl) {
                        QIMVerboseLog(@"收藏表情后的地址为 : %@", httpPermUrl);
                        if (![httpPermUrl containsString:@"null"] && httpPermUrl.length > 0) {
                            [[QIMCollectionFaceManager sharedInstance] insertCollectionEmojiWithEmojiUrl:httpPermUrl];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionUpdateHandleFailedNotification object:nil];
                            });
                        }
                    }];
                }
            }
        }
        default:
            [self.delegate processEvent:actionType withMessage:self.message];
            break;
    }
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            [menuList addObjectsFromArray:@[@(MA_Refer),@(MA_Repeater), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        case MessageDirection_Sent: {
                [menuList addObjectsFromArray:@[@(MA_Refer), @(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
            }
            break;
        default:
            break;
    }
    if (self.chatType == ChatType_System) {
        [menuList removeObject:@(MA_Refer)];
        [menuList removeObject:@(MA_Delete)];
        [menuList removeObject:@(MA_Forward)];
    } else if (self.chatType == ChatType_CollectionChat) {
        menuList = [NSMutableArray array];
    }
    if ([[QIMKit sharedInstance] getIsIpad]) {
        [menuList removeAllObjects];
    }
    return menuList;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.chatType == ChatType_CollectionChat) {
        self.backView.menuActionTypeList = @[];
    }
}

- (void)refreshHeaderView {
    if (self.message.messageType == QIMMessageType_GroupNotify || self.message.messageType == QIMMessageType_Time || self.message.messageType == QIMMessageType_Revoke || self.message.messageType == QIMMessageTypeRobotQuestionList) {
        self.HeadView.hidden = YES;
        self.nameLabel.hidden = YES;
        return;
    }
    if (self.chatType != ChatType_GroupChat) {
        switch (self.message.messageDirection) {
            case MessageDirection_Sent: {
                self.message.nickName = [[QIMKit sharedInstance] getLastJid];
            }
                break;
            case MessageDirection_Received: {
                self.message.nickName = self.message.from;
            }
            default:
                break;
        }
    }
    if (self.chatType == ChatType_CollectionChat) {
        NSString *collectionUserUrl = [[QIMKit sharedInstance] getCollectionUserHeaderUrlWithXmppId:self.message.from];
        if (![collectionUserUrl qim_hasPrefixHttpHeader]) {
            collectionUserUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], collectionUserUrl];
        }
        [self.HeadView qim_setImageWithURL:collectionUserUrl placeholderImage:[UIImage imageWithData:[QIMKit defaultUserHeaderImage]]];
    } else {
        if (self.message.messageDirection == MessageDirection_Sent) {
            [self.HeadView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid] WithChatType:ChatType_SingleChat];
        } else {
            [self.HeadView qim_setImageWithJid:self.message.nickName];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
