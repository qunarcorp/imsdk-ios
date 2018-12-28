//
//  QIMBaseChatVc.m
//  QIMUIKit
//
//  Created by 李露 on 10/15/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMBaseChatVc.h"
#import "QIMTextBar.h"
#import "QIMEmotionManager.h"
#import "QIMMessageRefreshHeader.h"
#import "QIMMessageTableViewManager.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMNavBackBtn.h"
#import "QIMContactSelectionViewController.h"
#import "QIMExportMsgManager.h"
#import "QIMMessageParser.h"
#import "QIMEmotionSpirits.h"
#import "QIMDataController.h"
#import "QIMCollectionFaceManager.h"
#import "QIMFileManagerViewController.h"
#import "QIMPushProductViewController.h"
#import "QIMUserListVC.h"
#import "QIMAuthorizationManager.h"
#import "UserLocationViewController.h"
#import "QIMTextContainer.h"
#import "QIMImageStorage.h"

#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
    #import "QIMWebRTCClient.h"
#endif

#define kReSendMsgAlertViewTag 10000
#define kForwardMsgAlertViewTag 10001

@interface QIMBaseChatVc () <QIMTextBarDelegate> {
    NSDate *_shockDateNow;
}

@end

@implementation QIMBaseChatVc

#pragma mark - setter and getter

- (QIMTextBar *)textBar {
    if (!_textBar) {
        
        QIMTextBarExpandViewType textBarType = QIMTextBarExpandViewTypeSingle;
        if (self.chatType == ChatType_Consult) {
            textBarType = QIMTextBarExpandViewTypeConsult;
        } else if (self.chatType == ChatType_ConsultServer) {
            textBarType = QIMTextBarExpandViewTypeConsultServer;
        } else if (self.chatType == ChatType_SingleChat) {
            textBarType = QIMTextBarExpandViewTypeSingle;
        } else if (self.chatType == ChatType_GroupChat) {
            textBarType = QIMTextBarExpandViewTypeGroup;
        } else if (self.chatType == ChatType_PublicNumber) {
            textBarType = QIMTextBarExpandViewTypePublicNumber;
        } else {
            
        }
        
        _textBar = [QIMTextBar sharedIMTextBarWithBounds:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) WithExpandViewType:textBarType];
        _textBar.associateTableView = self.tableView;
        [_textBar setDelegate:self];
        [_textBar setAllowSwitchBar:NO];
        [_textBar setAllowVoice:YES];
        [_textBar setAllowFace:YES];
        [_textBar setAllowMore:YES];
        [_textBar setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
        [_textBar setPlaceHolder:@"文本信息"];
        __weak QIMTextBar *weakTextBar = _textBar;
        
        [_textBar setSelectedEmotion:^(NSString *faceStr) {
            if ([faceStr length] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *text = [[QIMEmotionManager sharedInstance] getEmotionTipNameForShortCut:faceStr withPackageId:weakTextBar.currentPKId];
                    text = [NSString stringWithFormat:@"[%@]", text];
                    [weakTextBar insertEmojiTextWithTipsName:text shortCut:faceStr];
                });
            }
        }];
        
        [_textBar.layer setBorderColor:[UIColor qim_colorWithHex:0xadadad alpha:1].CGColor];
        [_textBar setIsRefer:NO];
        NSDictionary *notSendDic = [[QIMKit sharedInstance] getNotSendTextByJid:self.chatId];
        [_textBar setQIMAttributedTextWithItems:notSendDic[@"inputItems"]];
    }
    return _textBar;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        if (self.chatType == ChatType_CollectionChat) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        } else if (self.chatType == ChatType_System) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        } else {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 49 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        }
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        _tableView.delegate = self.messageManager;
        _tableView.dataSource = self.messageManager;
        [_tableView setBackgroundColor:[UIColor qtalkChatBgColor]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
#endif
        _tableViewFrame = _tableView.frame;
        [self.view addSubview:_tableView];
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        [_tableView setAccessibilityIdentifier:@"MessageTableView"];
        _tableView.mj_header = [QIMMessageRefreshHeader messsageHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewMsgList)];
    }
    return _tableView;
}

- (QIMMessageTableViewManager *)messageManager {
    if (!_messageManager) {
        _messageManager = [[QIMMessageTableViewManager alloc] initWithChatId:self.chatId ChatType:self.chatType OwnerVc:self];
        _messageManager.delegate = self;
    }
    return _messageManager;
}

- (UIButton *)forwardBtn {
    if (!_forwardBtn) {
        _forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forwardBtn.frame = CGRectMake(0, self.view.height - 50 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], self.view.width, 50);
        [_forwardBtn setTitle:@"转发" forState:UIControlStateNormal];
        [_forwardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_forwardBtn addTarget:self action:@selector(forwardBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_forwardBtn setEnabled:NO];
        [self.textBar setUserInteractionEnabled:NO];
    }
    if (_forwardBtn.enabled) {
        [_forwardBtn setBackgroundColor:[UIColor qtalkIconSelectColor]];
    } else {
        [_forwardBtn setBackgroundColor:[UIColor lightGrayColor]];
    }
    return _forwardBtn;
}

- (NSMutableDictionary *)photos {
    if (!_photos) {
        _photos = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _photos;
}

- (UIView *)notificationView {
    if (!_notificationView) {
        _notificationView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 110, self.textBar.frame.origin.y - 50, 100, 40)];
        
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [backImageView setImage:[UIImage imageNamed:@"notificationToast"]];
        [_notificationView addSubview:backImageView];
        
        UIImageView *messageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 7, 20, 20)];
        [messageImageView setImage:[UIImage imageNamed:@"notificationToastCommentIcon"]];
        [_notificationView addSubview:messageImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToBottom_tableView)];
        [_notificationView addGestureRecognizer:tap];
        _notificationView.userInteractionEnabled = YES;
        
        UILabel *commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 70, 20)];
        [commentCountLabel setTextColor:[UIColor whiteColor]];
        [commentCountLabel setText:@"下面有新消息"];
        [commentCountLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [_notificationView addSubview:commentCountLabel];
        [self.view addSubview:_notificationView];
    }
    return _notificationView;
}

- (void)forwardBtnHandle:(id)sender {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *quickForwardAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"One-by-One Forward"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            NSArray *forwardIndexpaths = [self.messageManager.forwardSelectedMsgs.allObjects sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return [(Message *)obj1 messageDate] > [(Message *)obj2 messageDate];
            }];

            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (Message *message in forwardIndexpaths) {
                [msgList addObject:[QIMMessageParser reductionMessageForMessage:message]];
            }
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            [controller setMessageList:msgList];
            [[self navigationController] presentViewController:nav
                                                      animated:YES
                                                    completion:^{
                                                        [self cancelForwardHandle:nil];
                                                    }];
        }];
        UIAlertAction *mergerForwardAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"Combine and Forward"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            if (!self.messageManager.forwardSelectedMsgs) {
                self.messageManager.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
            }
            NSArray *msgList = [self.messageManager.forwardSelectedMsgs.allObjects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [(Message *)obj1 messageDate] > [(Message *)obj2 messageDate];
            }];
            self.forwardExportMsgJsonFilePath = [QIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@的聊天记录", self.title]];
            self.tableView.editing = NO;
            [_forwardNavTitleView removeFromSuperview];
            [_maskRightTitleView removeFromSuperview];
            [_forwardBtn removeFromSuperview];
            [_textBar setUserInteractionEnabled:YES];
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            controller.delegate = self;
            [[self navigationController] presentViewController:nav
                                                      animated:YES
                                                    completion:^{
                                                        [self cancelForwardHandle:nil];
                                                    }];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
            
        }];
        
        [alertController addAction:quickForwardAction];
        [alertController addAction:mergerForwardAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:[NSBundle qim_localizedStringForKey:@"One-by-One Forward"], [NSBundle qim_localizedStringForKey:@"Combine and Forward"], nil];
        alertView.tag = kForwardMsgAlertViewTag;
        [alertView show];
    }
}

- (void)cancelForwardHandle:(id)sender {
    
    self.tableView.editing = NO;
    [_forwardNavTitleView removeFromSuperview];
    [_maskRightTitleView removeFromSuperview];
    [_forwardBtn removeFromSuperview];
    [_textBar setUserInteractionEnabled:YES];
    [self.messageManager.forwardSelectedMsgs removeAllObjects];
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.chatType != ChatType_CollectionChat && self.chatType != ChatType_System) {
        BOOL containTextBar = NO;
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[QIMTextBar class]]) {
                containTextBar = YES;
            }
        }
        if (containTextBar == NO) {
            [self.view addSubview:self.textBar];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[QIMKit sharedInstance] setCurrentSessionUserId:self.chatId];
    [self initNotifications];
    [self initUI];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self synchronizeChatSession];
    });
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)initNotifications {

    //键盘弹出，消息自动滑动最底
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:kQIMTextBarIsFirstResponder object:nil];

    //在线收到消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageList:) name:kNotificationMessageUpdate object:nil];
    
    //重新加载离线历史消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHistoryMessageList:) name:kNotificationOfflineMessageUpdate object:nil];

    //收藏表情成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceSuccess:) name:kCollectionEmotionUpdateHandleSuccessNotification object:nil];
    //收藏表情失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceFailed:) name:kCollectionEmotionUpdateHandleFailedNotification object:nil];
    //扩展键盘点击通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expandViewItemHandleNotificationHandle:) name:kExpandViewItemHandleNotification object:nil];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor qtalkChatBgColor];
    [self setBackBtn];
    [self setChatTitle];
    [self setTitleRight];
    [self loadData];
    [self refreshChatBGImageView];
    
    //添加整个view的点击事件，当点击页面空白地方时，输入框收回
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    gesture.delegate = self;
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:gesture];
    if (self.chatType != ChatType_System || self.chatType != ChatType_CollectionChat) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self synchronizeChatSession];
        });
    }
}

- (void)setBackBtn {
    QIMNavBackBtn *backBtn = [QIMNavBackBtn sharedInstance];
    [backBtn addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarBtn = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //将宽度设为负值
    spaceItem.width = -15;
    //将两个BarButtonItem都返回给N
    self.navigationItem.leftBarButtonItems = @[spaceItem,backBarBtn];
}

- (void)leftBarBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//SwipeBack
- (void)selfPopedViewController {
    [super selfPopedViewController];
    if (self.chatType != ChatType_System && self.chatType != ChatType_CollectionChat) {
        [[QIMKit sharedInstance] setNotSendText:[self.textBar getSendAttributedText] inputItems:[self.textBar getAttributedTextItems] ForJid:self.chatId];
    }
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//初始化Title
- (void)setChatTitle {
    @throw  [NSException exceptionWithName:@"QIMBaseChatVc Exception" reason:[NSString stringWithFormat:@"Class %@ \"setChatTitle\" method has not realized ",[self class]] userInfo:nil];
}

//初始化右边按钮
- (void)setTitleRight {
    @throw  [NSException exceptionWithName:@"QIMBaseChatVc Exception" reason:[NSString stringWithFormat:@"Class %@ \"setTitleRight\" method has not realized ",[self class]] userInfo:nil];
}

//进页面默认加载新消息
- (void)loadData {
    @throw  [NSException exceptionWithName:@"QIMBaseChatVc Exception" reason:[NSString stringWithFormat:@"Class %@ \"loadData\" method has not realized ",[self class]] userInfo:nil];
}

- (void)refreshChatBGImageView {
    if (!_chatBGImageView) {
        
        _chatBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 40)];
        _chatBGImageView.contentMode = UIViewContentModeScaleAspectFill;
        _chatBGImageView.clipsToBounds = YES;
    }
    
    NSMutableDictionary *chatBGImageDic = [[QIMKit sharedInstance] userObjectForKey:@"chatBGImageDic"];
    if (chatBGImageDic) {
        
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        UIImage *image = [UIImage imageWithContentsOfFile:[[QIMDataController getInstance] getSourcePath:[NSString stringWithFormat:@"chatBGImageFor_%@", self.chatId]]];
        if (!image) {
            
            image = [UIImage imageWithContentsOfFile:[[QIMDataController getInstance] getSourcePath:@"chatBGImageFor_Common"]];
        }
        if (image) {
            
            _chatBGImageView.image = image;
            [self.view insertSubview:_chatBGImageView belowSubview:self.tableView];
        } else {
            
            [_chatBGImageView removeFromSuperview];
        }
    } else {
        
        [self.tableView setBackgroundColor:[UIColor qtalkChatBgColor]];
    }
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    [self.textBar keyBoardDown];
}

- (void)synchronizeChatSession {
    if (self.chatType == ChatType_GroupChat || self.chatType == ChatType_SingleChat) {
        @throw  [NSException exceptionWithName:@"QIMBaseChatVc Exception" reason:[NSString stringWithFormat:@"Class %@ \"synchronizeChatSession\" method has not realized ",[self class]] userInfo:nil];
    }
}

//翻页加载新消息
- (void)loadNewMsgList {
    @throw  [NSException exceptionWithName:@"QIMBaseChatVc Exception" reason:[NSString stringWithFormat:@"Class %@ \"loadNewMsgList\" method has not realized ",[self class]] userInfo:nil];
}

- (void)scrollToBottom_tableView {
    if (self.messageManager.dataSource.count == 0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self scrollToBottom:YES];
    }else {
        [self scrollToBottom:NO];
    }
}

- (BOOL)shouldScrollToBottomForNewMessage {
    CGFloat _h = self.tableView.contentSize.height - self.tableView.contentOffset.y - (CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.bottom);
    
    return _h <= 66 * 4;
}

- (void)scrollBottom {
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    if (offset.y > self.tableView.height / 2.0f) {
        [self.tableView setContentOffset:offset animated:NO];
    }
}

- (void)scrollToBottomWithCheck:(BOOL)flag {
    
    Message *message = self.messageManager.dataSource.lastObject;
    MessageDirection messageDirection = message.messageDirection;
    if (messageDirection == MessageDirection_Sent) {
        [self scrollToBottom:flag];
        [self hidePopView];
    } else {
        if ([self shouldScrollToBottomForNewMessage]) {
            [self scrollToBottom:flag];
        } else {
            [self showPopView];
        }
    }
}

- (void)scrollToBottom:(BOOL)animated {
    if (self.messageManager.dataSource.count == 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        CGFloat offsetY = self.tableView.contentSize.height + self.tableView.contentInset.bottom - CGRectGetHeight(self.tableView.frame);
        if (offsetY < -self.tableView.contentInset.top) {
            offsetY = -self.tableView.contentInset.top;
        }
        [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:animated];
    }else {
        if([self.tableView numberOfSections] > 0 ){
            NSInteger lastSectionIndex = [self.tableView numberOfSections]-1;
            NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex ]-1;
            UITableViewCell *lastRowCell = self.tableView.visibleCells.lastObject;
            if(lastRowIndex > 0 && lastRowCell){
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
                [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            }
        } else {
            CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:offset animated:NO];
        }
    }
}

#pragma mark - NSNotifications

- (void)keyBoardWillShow:(NSNotification *)notify {
    [self scrollToBottom_tableView];
}

//获取大图展示数组

- (void)addImageToImageList {
    if (!_imagesArr) {
        _imagesArr = [NSMutableArray arrayWithCapacity:1];
    } else {
        [_imagesArr removeAllObjects];
    }
    NSArray *tempDataSource = [NSArray arrayWithArray:self.messageManager.dataSource];
    for (Message *msg in tempDataSource) {
        if (msg.messageType == QIMMessageType_Image || msg.messageType == QIMMessageType_Text || msg.messageType == QIMMessageType_NewAt) {
            QIMTextContainer *textContainer = [QIMMessageParser textContainerForMessage:msg];
            for (id storage in textContainer.textStorages) {
                if ([storage isMemberOfClass:[QIMImageStorage class]] && ([(QIMImageStorage *) storage storageType] == QIMImageStorageTypeImage || [(QIMImageStorage *) storage storageType] == QIMImageStorageTypeGif)) {
                    [_imagesArr addObject:storage];
                }
            }
        }
    }
}
#pragma mark - show pop view

- (void)showPopView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [self.notificationView setHidden:NO];
    [UIView commitAnimations];
}

- (void)hidePopView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.notificationView setHidden:YES];
    [UIView commitAnimations];
}

- (void)expandViewItemHandleNotificationHandle:(NSNotification *)notify {
    
}

#pragma mark - QIMTextBarDelegate

- (void)sendText:(NSString *)text {
    
}

- (void)emptyText:(NSString *)text {
    
}

- (void)sendNormalEmotion:(NSString *)faceStr WithPackageId:(NSString *)packageId {
    if (faceStr.length > 0 && packageId.length > 0) {
        
    }
}

- (void)sendImageUrl:(NSString *)imageUrl {
    
}

- (void)sendImageData:(NSData *)imageData {
    if (imageData) {
//        [self getStringFromAttributedString:imageData];
    }
}

- (void)sendVoiceUrl:(NSString *)voiceUrl WithDuration:(int)duration WithSmallData:(NSData *)amrData WithFileName:(NSString *)filename AndFilePath:(NSString *)filepath {
    
}

- (void)setKeyBoardHeight:(CGFloat)height WithScrollToBottom:(BOOL)flag {
    
    CGFloat animaDuration = 0.2;
    
    CGRect frame = _tableViewFrame;
    frame.origin.y -= height;
    [UIView animateWithDuration:animaDuration animations:^{
        [_tableView setFrame:frame];
        if (_tableView.contentSize.height - _tableView.tableHeaderView.frame.size.height + 10 < _tableView.frame.size.height && height > 0) {
            if (_tableView.contentSize.height - _tableView.tableHeaderView.frame.size.height + 10 < _tableViewFrame.size.height - height) {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height + 10)];
                [_tableView setTableHeaderView:headerView];
            } else {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, _tableView.frame.size.height - (_tableView.contentSize.height - _tableView.tableHeaderView.frame.size.height + 10) + 10)];
                [_tableView setTableHeaderView:headerView];
            }
        } else {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
            [_tableView setTableHeaderView:headerView];
            //            if (flag) {
            //                [self scrollToBottomWithCheck:YES];
            //            }
        }
    }];
}

- (void)textBarReferBtnDidClicked:(QIMTextBar *)textBar {
    
}

- (void)beginDoVoiceRecord {
    
}

- (void)updateVoiceViewHeightInVCWithPower:(float)power {
    
}

- (void)voiceRecordWillFinishedIsTrue:(BOOL)isTrue andCancelByUser:(BOOL)isCancelByUser {
    
}

- (void)voiceMaybeCancelWithState:(BOOL)ifMaybeCancel {
    
}

- (void)sendVideoPath:(NSString *)videoPath WithThumbImage:(UIImage *)thumbImage WithFileSizeStr:(NSString *)fileSizeStr WithVideoDuration:(float)duration {
    
}

//正在输入状态
- (void)sendTyping {
    if (self.chatType == ChatType_SingleChat) {
        [[QIMKit sharedInstance] sendTypingToUserId:self.chatId];
    }
}

- (void)showActionBottomView {
    
}

@end
