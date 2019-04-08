//
//  QIMChatNewVc.m
//  QIMUIKit
//
//  Created by 李露 on 10/18/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMChatNewVc.h"
#import "QIMNavTitleView.h"
#import "QIMProgressHUD.h"

#if defined (QIMNotifyEnable) && QIMNotifyEnable == 1
    #import "QIMNotifyManager.h"
#endif

#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
    #import "QIMWebRTCClient.h"
#endif

#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    #import "QIMNoteManager.h"
    #import "QIMEncryptChat.h"
    #import "QIMNoteModel.h"
#endif

@interface QIMChatNewVc ()

@property (nonatomic, strong) UILabel *titleLabel;

#if defined (QIMNoteEnable) && QIMNoteEnable == 1

@property (nonatomic, strong) UIButton *encryptBtn;  //加密/解锁🔓按钮

@property(nonatomic, assign) QIMEncryptChatState encryptChatState;   //加密状态

@property (nonatomic, assign) BOOL isEncryptChat;    //是否正在加密

@property(nonatomic, copy) NSString *pwd;           //加密会话内存密码

#endif

@end

@implementation QIMChatNewVc

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNSNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    
}

- (void)setChatTitle {
    
    QIMNavTitleView *titleView = [[QIMNavTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleView.autoresizesSubviews = YES;
    titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (self.chatType == ChatType_ConsultServer) {
        NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:self.userId];
        NSString *userName = [infoDic objectForKey:@"Name"];
        if (userName.length <= 0) {
            userName = [self.userId componentsSeparatedByString:@"@"].firstObject;
        }
        self.title = userName;
    } else if (self.chatType == ChatType_Consult) {
        NSDictionary *virtualDic = [[QIMKit sharedInstance] getUserInfoByUserId:self.virtualJid];
        NSString *virtualName = [virtualDic objectForKey:@"Name"];
        if (virtualName.length <= 0) {
            virtualName = [self.virtualJid componentsSeparatedByString:@"@"].firstObject;
        }
        if (virtualName) {
            self.title = virtualName;
        }
    } else if (self.chatType == ChatType_CollectionChat) {
        NSDictionary *collectionUserInfo = [[QIMKit sharedInstance] getCollectionUserInfoByUserId:self.userId];
        NSString *userName = [collectionUserInfo objectForKey:@"Name"];
        if (userName) {
            self.title = userName;
        }
    }
    if (self.title.length <= 0 || !self.title) {
        NSString *xmppId = [self.chatInfoDict objectForKey:@"XmppId"];
        NSString *userId = [self.chatInfoDict objectForKey:@"UserId"];
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:xmppId];
        if (userInfo.count) {
            self.title = [userInfo objectForKey:@"Name"];
        }
        if (!self.title) {
            self.title = userId;
        }
    }
    titleLabel.text = self.title;
    if (self.isEncryptChat) {
        titleLabel.text = [titleLabel.text stringByAppendingString:@"【加密中】"];
    }
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _titleLabel = titleLabel;
    [titleView addSubview:titleLabel];
    if (self.chatType != ChatType_Consult) {
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 200, 12)];
        descLabel.textColor = [UIColor blackColor];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.backgroundColor = [UIColor clearColor];
        descLabel.font = [UIFont systemFontOfSize:10];
        descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (self.chatType == ChatType_ConsultServer) {
            NSDictionary *virtualDic = [[QIMKit sharedInstance] getUserInfoByUserId:self.virtualJid];
            NSString *virtualName = [virtualDic objectForKey:@"Name"];
            if (virtualName.length <= 0) {
                virtualName = [self.virtualJid componentsSeparatedByString:@"@"].firstObject;
            }
            descLabel.text = [NSString stringWithFormat:@"来自%@的咨询用户",virtualName];
        } else if (self.chatType == ChatType_CollectionChat) {
            
        } else {
            if (![[QIMKit sharedInstance] moodshow]) {
                NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.userId];
                
                descLabel.text = [userInfo objectForKey:@"DescInfo"];
            } else {
                [[QIMKit sharedInstance] userProfilewithUserId:[self userId]
                                                    needupdate:NO
                                                     withBlock:^(NSDictionary *userinfo) {
                                                         NSString *desc = [userinfo objectForKey:@"M"];
                                                         if (desc && [desc length] > 0) {
                                                             [descLabel setText:desc];
                                                         } else {
                                                             NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.userId];
                                                             
                                                             descLabel.text = [userInfo objectForKey:@"DescInfo"];
                                                         }
                                                     }];
            }
        }
        [titleView addSubview:descLabel];
    }
    self.navigationItem.titleView = titleView;
}

- (void)setTitleRight {
    
    UIView *rightItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    UIButton *cardButton = [[UIButton alloc] initWithFrame:CGRectMake(rightItemView.right - 30, 9, 30, 30)];
    [cardButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [cardButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0eb" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
    [cardButton setAccessibilityIdentifier:@"rightUserCardBtn"];
    [cardButton addTarget:self action:@selector(onCardClick) forControlEvents:UIControlEventTouchUpInside];
    [rightItemView addSubview:cardButton];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        
        UIButton *encryptBtn = nil;
        NSString *qCloudHost = [[QIMKit sharedInstance] qimNav_QCloudHost];
        if (qCloudHost.length > 0) {
            encryptBtn = [[UIButton alloc] initWithFrame:CGRectMake(rightItemView.left, 9, 30, 30)];
            if (self.isEncryptChat) {
                [encryptBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f1ad" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
            } else {
                [encryptBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f1af" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
            }
            [encryptBtn addTarget:self action:@selector(encryptChat:) forControlEvents:UIControlEventTouchUpInside];
            [rightItemView addSubview:encryptBtn];
            self.encryptBtn = encryptBtn;
        }
    } else {
        UIButton *endChatBtn = [[UIButton alloc] initWithFrame:CGRectMake(cardButton.left - 30 - 5, 9, 30, 30)];
        [endChatBtn setAccessibilityIdentifier:@"endChatBtn"];
        [endChatBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0b5" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
        [endChatBtn addTarget:self action:@selector(endChatSession) forControlEvents:UIControlEventTouchUpInside];
        if (self.chatType == ChatType_ConsultServer) {
            [rightItemView addSubview:endChatBtn];
        }
    }
    if (self.chatType != ChatType_CollectionChat) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemView];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
}

- (void)loadData {
    __weak __typeof(self)weakSelf = self;
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_CollectionChat) {
        NSArray *collectionMsgs = [[QIMKit sharedInstance] getCollectionMsgListForUserId:self.bindId originUserId:self.userId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageManager.dataSource removeAllObjects];
            [self.messageManager.dataSource addObjectsFromArray:collectionMsgs];
            [self.tableView reloadData];
            [weakSelf scrollBottom];
            /* Comment by lilulucas.li 10.18
            [weakSelf addImageToImageList];
            if (_willSendImageData) {
                [weakSelf sendImageData:_willSendImageData];
                _willSendImageData = nil;
            }
            */
            //标记已读
            [weakSelf markReadFlag];
        });
    } else {
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.userId;
        } else {
            userId = self.userId;
        }
        
        if (self.chatType == ChatType_ConsultServer) {
            [[QIMKit sharedInstance] getConsultServerMsgLisByUserId:realJid WithVirtualId:userId WithLimit:kPageCount WithOffset:0 WithComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messageManager.dataSource removeAllObjects];
                    [self.messageManager.dataSource addObjectsFromArray:list];
                    [self.tableView reloadData];
                    
                    [weakSelf scrollBottom];
                    [weakSelf addImageToImageList];
                    /* Comment by lilulucas.li 10.18
                    if (_willSendImageData) {
                        [weakSelf sendImageData:_willSendImageData];
                        _willSendImageData = nil;
                    }
                    */
                    //标记已读
                    [weakSelf markReadFlag];
                });
            }];
        } else {
            [[QIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WihtLimit:kPageCount WithOffset:0 WihtComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messageManager.dataSource removeAllObjects];
                    [self.messageManager.dataSource addObjectsFromArray:list];
                    [self.tableView reloadData];
                    [weakSelf scrollToBottom_tableView];
                    /* Comment by lilulucas.li 10.18
                    [weakSelf addImageToImageList];
                    if (_willSendImageData) {
                        [weakSelf sendImageData:_willSendImageData];
                        _willSendImageData = nil;
                    }
                    */
                    //标记已读
                    [weakSelf markReadFlag];
                });
            }];
        }
    }
}

- (void)synchronizeChatSession {
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.userId;
    } else {
        userId = self.userId;
    }
    [[QIMKit sharedInstance] synchronizeChatSessionWithUserId:userId WithChatType:self.chatType WithRealJid:realJid];
}

- (void)loadNewMsgList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *userId = nil;
        NSString *realJid = nil;
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.userId;
        } else {
            userId = self.userId;
        }
        __weak typeof(self) weakSelf = self;
        if (self.chatType == ChatType_ConsultServer) {
            [[QIMKit sharedInstance] getConsultServerMsgLisByUserId:realJid WithVirtualId:userId WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    CGFloat offsetY = self.tableView.contentSize.height - self.tableView.contentOffset.y;
                    NSRange range = NSMakeRange(0, [list count]);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    
                    [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                    [self.tableView reloadData];
                    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - offsetY);
                    //重新获取一次大图展示的数组
                    [weakSelf addImageToImageList];
                    [weakSelf.tableView.mj_header endRefreshing];
                    //标记已读
                    [weakSelf markReadFlag];
                });
            }];
        } else {
            
            if (self.fastMsgTimeStamp > 0) {
                [[QIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid FromTimeStamp:self.fastMsgTimeStamp WihtComplete:^(NSArray *list) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        CGFloat offsetY = self.tableView.contentSize.height - self.tableView.contentOffset.y;
                        NSRange range = NSMakeRange(0, [list count]);
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                        
                        [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                        [self.tableView reloadData];
                        //                        _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - offsetY);
                        //重新获取一次大图展示的数组
                        [weakSelf addImageToImageList];
                        [weakSelf.tableView.mj_header endRefreshing];
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                }];
            } else {
                [[QIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WihtLimit:kPageCount WithOffset:(int) self.messageManager.dataSource.count WihtComplete:^(NSArray *list) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        CGFloat offsetY = self.tableView.contentSize.height - self.tableView.contentOffset.y;
                        NSRange range = NSMakeRange(0, [list count]);
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                        
                        [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                        [self.tableView reloadData];
                        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - offsetY);
                        //重新获取一次大图展示的数组
                        [weakSelf addImageToImageList];
                        [weakSelf.tableView.mj_header endRefreshing];
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                }];
            }
        }
    });
}

#pragma mark - NSNotifications

- (void)registerNSNotifications {
    //刷新个人备注
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitleView:) name:kMarkNameUpdate object:nil];
    //发送快捷回复
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendQuickReplyContent:) name:kNotificationSendQuickReplyContent object:nil];
}

- (void)updateMessageList:(NSNotification *)notify {
    
}

- (void)updateHistoryMessageList:(NSNotification *)notify {
    
}

#if defined (QIMNoteEnable) && QIMNoteEnable == 1

- (void)reloadBaseViewWithUserId:(NSString *)userId WithEncryptChatState:(QIMEncryptChatState)encryptChatState {
    if ([self.userId isEqualToString:userId]) {
        self.encryptChatState = encryptChatState;
        switch (self.encryptChatState) {
            case QIMEncryptChatStateNone: {
                self.isEncryptChat = NO;
                _titleLabel.text = self.title;
                [self.encryptBtn setImage:[UIImage imageNamed:@"apt-kaisuokongxin-f"] forState:UIControlStateNormal];
            }
                break;
            case QIMEncryptChatStateEncrypting: {
                self.isEncryptChat = YES;
                QIMNoteModel *model = [[QIMNoteManager sharedInstance] getEncrptPwdBox];
                self.pwd = [[QIMNoteManager sharedInstance] getChatPasswordWithUserId:self.userId WithCid:model.c_id];
                _titleLabel.text = [_titleLabel.text stringByAppendingString:@"【加密中】"];
                [self.encryptBtn setImage:[UIImage imageNamed:@"apt-suokongxin-f"] forState:UIControlStateNormal];
            }
                break;
            case QIMEncryptChatStateDecrypted: {
                self.isEncryptChat = YES;
                QIMNoteModel *model = [[QIMNoteManager sharedInstance] getEncrptPwdBox];
                self.pwd = [[QIMNoteManager sharedInstance] getChatPasswordWithUserId:self.userId WithCid:model.c_id];
                _titleLabel.text = [_titleLabel.text stringByAppendingString:@"【解密中】"];
                [self.encryptBtn setImage:[UIImage imageNamed:@"apt-suokongxin-f"] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        [self loadData];
    }
}
#endif

#pragma mark - Private Method

//右上角名片信息
- (void)onCardClick {
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.userId];
    NSString *userId = [userInfo objectForKey:@"XmppId"];
    if (userId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserChatInfoByUserId:userId];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserChatInfoByUserId:self.userId];
        });
    }
}

//右上角加密
- (void)encryptChat:(id)sender {
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    [[QIMEncryptChat sharedInstance] doSomeEncryptChatWithUserId:self.userId];
#endif
}

//右上角关闭咨询会话
- (void)endChatSession {
    UIAlertController *endChatSessionAlertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确认结束本次服务？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        /*
        NSString *promot = [[QIMKit sharedInstance] closeSessionWithShopId:self.virtualJid WithVisitorId:self.userId];
        if (promot) {
            [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:promot];
            [[QIMProgressHUD sharedInstance] closeHUD];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"结束本地会话失败" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
        }
        */
    }];
    [endChatSessionAlertVc addAction:cancelAction];
    [endChatSessionAlertVc addAction:okAction];
    [self.navigationController presentViewController:endChatSessionAlertVc animated:YES completion:nil];
}

- (void)markReadFlag {
    
    NSString *userId = @"";
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.userId;
    } else {
        userId = self.userId;
    }
    //取出数据库所有消息，置已读
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *markReadMsgList = [[QIMKit sharedInstance] getNotReadMsgIdListByUserId:userId WithRealJid:realJid];
        if (markReadMsgList.count > 0) {
            [[QIMKit sharedInstance] sendReadStateWithMessagesIdArray:markReadMsgList WithXmppId:self.userId];
        }
    });
}

@end
