//

//  QIMChatVC.m

//  qunarChatIphone

//

//  Created by wangshihai on 14/12/2.

//  Copyright (c) 2014年 ping.xue. All rights reserved.

#import "QIMTapGestureRecognizer.h"
#import "QIMChatVC.h"
#import "QIMIconInfo.h"
#import "QIMEmotionManager.h"
#import "QIMDataController.h"
#import "QIMJSONSerializer.h"
#import "QIMUUIDTools.h"
#import "QIMSingleChatCell.h"
#import "QIMSingleChatVoiceCell.h"
#import "QIMNavTitleView.h"
#import "QIMMenuImageView.h"
#import "QIMGroupCreateVC.h"
#import "QIMCollectionFaceManager.h"
#import "QIMVoiceRecordingView.h"
#import "MBProgressHUD.h"
#import "QIMVoiceTimeRemindView.h"
#import "QIMOriginMessageParser.h"
//#import "TextCellCaChe.h"
#import "QIMCommonUIFramework.h"
#import <AVFoundation/AVFoundation.h>
#import "NSBundle+QIMLibrary.h"
#import "QIMRemoteAudioPlayer.h"
#import "SDImageCache.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMRedPackageView.h"

#define kPageCount 20
#define kReSendMsgAlertViewTag 10000
#define kForwardMsgAlertViewTag 10001

#import "QIMDisplayImage.h"
#import "QIMPhotoBrowserNavController.h"
#import "QIMContactSelectionViewController.h"

#import "QIMChatBGImageSelectController.h"

#import "QIMMessageBrowserVC.h"

#import "QIMVideoPlayerVC.h"

#import "QIMInputPopView.h"

#import "QIMFileManagerViewController.h"
#import "QIMPreviewMsgVC.h"

#import "QIMEmotionSpirits.h"

#import "QIMUserListVC.h"

#import "QIMWebView.h"


#import "QIMCollectionEmotionEditorVC.h"
#import "QIMPushProductViewController.h"

#import "ShareLocationViewController.h"

#import "UserLocationViewController.h"

#import "QIMOpenPlatformCell.h"

#import "QIMNewMessageTagCell.h"
#import "QIMRobotQuestionCell.h"

#import "QIMNotReadMsgTipViews.h"
#import "QIMTextBar.h"
#import "QIMPNRichTextCell.h"
#import "QIMPNActionRichTextCell.h"
#import "QIMPublicNumberNoticeCell.h"
#import "QIMVoiceNoReadStateManager.h"
#import "QIMPlayVoiceManager.h"
#import "QIMMyFavoitesManager.h"
#import "QIMMessageParser.h"
#import "QIMAttributedLabel.h"
#import "QIMExtensibleProductCell.h"
#import "QIMMessageCellCache.h"
#import "QIMNavBackBtn.h"
#import "QIMNotifyView.h"
#import "QIMRedMindView.h"

#if defined (QIMNotifyEnable) && QIMNotifyEnable == 1

    #import "QIMNotifyManager.h"

#endif

#import "YLGIFImage.h"
#import "QIMExportMsgManager.h"
#import "QIMContactManager.h"

#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
    #import "QIMWebRTCClient.h"
#endif

#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    #import "QIMNoteManager.h"
    #import "QIMEncryptChat.h"
    #import "QIMNoteModel.h"
#endif

#import "QIMProgressHUD.h"
#import "QIMAuthorizationManager.h"
#import "QIMMessageTableViewManager.h"
#import "QIMMessageRefreshHeader.h"
#import "MJRefreshNormalHeader.h"
#import "QIMRobotAnswerCell.h"
#import "QIMSearchRemindView.h"

#if defined (QIMNotifyEnable) && QIMNotifyEnable == 1

@interface QIMChatVC () <QIMNotifyManagerDelegate>

@end

#endif

#if defined (QIMNoteEnable) && QIMNoteEnable == 1

@interface QIMChatVC () <QIMEncryptChatReloadViewDelegate>

@end

#endif

@interface QIMChatVC () <UIGestureRecognizerDelegate, QIMSingleChatCellDelegate, QIMSingleChatVoiceCellDelegate, QIMMWPhotoBrowserDelegate, QIMRemoteAudioPlayerDelegate, QIMMsgBaloonBaseCellDelegate, QIMChatBGImageSelectControllerDelegate, QIMContactSelectionViewControllerDelegate, QIMInputPopViewDelegate, QIMUserListVCDelegate, QIMPushProductViewControllerDelegate, UIActionSheetDelegate, UserLocationViewControllerDelegate, QIMNotReadMsgTipViewsDelegate, QIMTextBarDelegate, QIMPNActionRichTextCellDelegate, QIMPNRichTextCellDelegate, PNNoticeCellDelegate, PlayVoiceManagerDelegate, QIMAttributedLabelDelegate, UIViewControllerPreviewingDelegate, QTalkMessageTableScrollViewDelegate, QIMRobotQuestionCellDelegate, QIMRobotAnswerCellLoadDelegate> {
    
    bool _isReloading;
    
    float _currentDownloadProcess;
    
    CGRect _rootViewFrame;
    CGRect _tableViewFrame;
    
    BOOL _notIsFirstChangeTableViewFrame;
    BOOL _playStop;
    
    NSMutableArray *_imagesArr;
    
    
    
    Message *_resendMsg;
    NSData *_willSendImageData;
    
    NSString *_transferReason;
    BOOL _inputPopViewIsShow;
    QIMTextBarExpandViewItemType _expandViewItemType;
    
    NSString *_shareLctId;
    NSString *_shareFromId;
    
    
    UIView *_maskRightTitleView;
    NSString *_jsonFilePath;
    
    
    BOOL _hasServerTransferFeedback;
    BOOL _hasUserTransferFeedback;
    
}
@property(nonatomic, strong) QIMTextBar *textBar;

@property(nonatomic, strong) UIButton *encryptBtn;

@property(nonatomic, strong) QIMVoiceRecordingView *voiceRecordingView;

@property(nonatomic, strong) QIMVoiceTimeRemindView *voiceTimeRemindView;

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSDate *dataNow;

@property(nonatomic, assign) NSInteger currentPlayVoiceIndex;

@property(nonatomic, copy) NSString *currentPlayVoiceMsgId;

@property(nonatomic, assign) BOOL isNoReadVoice;

#if defined (QIMNoteEnable) && QIMNoteEnable == 1

@property(nonatomic, assign) QIMEncryptChatState encryptChatState;   //加密状态
#endif

@property(nonatomic, assign) BOOL isEncryptChat;    //是否正在加密

@property(nonatomic, copy) NSString *pwd;           //加密会话内存密码

@property(nonatomic, strong) NSMutableDictionary *photos;   //图片

@property(nonatomic, strong) NSMutableDictionary *cellSizeDic;  //Cell缓存

@property(nonatomic, strong) MBProgressHUD *progressHUD;

@property(nonatomic, strong) UIButton *forwardBtn;

@property(nonatomic, strong) QIMMessageTableViewManager *messageManager;

@property(nonatomic, strong) QIMPlayVoiceManager *playVoiceManager;

@property(nonatomic, strong) UIView *notificationView;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) QIMNotReadMsgTipViews *readMsgTipView;

@property(nonatomic, strong) UIWindow *referMsgwindow;

@property(nonatomic, strong) UIView *joinShareLctView;

@property(nonatomic, strong) ShareLocationViewController *shareLctVC;

@property(nonatomic, strong) UIImageView *chatBGImageView;

@property(nonatomic, strong) UIView *forwardNavTitleView;

@property(nonatomic, strong) QIMRemoteAudioPlayer *remoteAudioPlayer;

@property(nonatomic, assign) NSInteger currentMsgIndexs;

@property(nonatomic, assign) NSInteger loadCount;
@property(nonatomic, assign) NSInteger reloadSearchRemindView;
@property(nonatomic, strong) QIMSearchRemindView *searchRemindView;

@property(nonatomic, strong) NSMutableArray *fixedImageArray;

@end

@implementation QIMChatVC


#pragma mark - setter and getter

- (QIMTextBar *)textBar {
    
    if (!_textBar) {
        
        QIMTextBarExpandViewType textBarType = QIMTextBarExpandViewTypeSingle;
        if (self.chatType == ChatType_Consult) {
            textBarType = QIMTextBarExpandViewTypeConsult;
        } else if (self.chatType == ChatType_ConsultServer) {
            textBarType = QIMTextBarExpandViewTypeConsultServer;
        } else if ([[QIMKit sharedInstance] isMiddleVirtualAccountWithJid:self.chatId]) {
            textBarType = QIMTextBarExpandViewTypeRobot;
        } else if ([self.chatId isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
            textBarType = QIMTextBarExpandViewTypeRobot;
        } else {
            textBarType = QIMTextBarExpandViewTypeSingle;
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
        if (self.chatType == ChatType_Consult) {
//            [self.textBar setChatId:self.virtualJid];
            
        } else if (self.chatType == ChatType_ConsultServer) {
            [self.textBar setChatId:self.chatId];
            
        } else {
            [self.textBar setChatId:self.chatId];
        }
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

- (QIMMessageTableViewManager *)messageManager {
    if (!_messageManager) {
        _messageManager = [[QIMMessageTableViewManager alloc] initWithChatId:self.chatId ChatType:self.chatType OwnerVc:self];
        _messageManager.delegate = self;
    }
    return _messageManager;
}
 
- (NSMutableDictionary *)photos {
    if (!_photos) {
        _photos = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return _photos;
}

- (QIMVoiceRecordingView *)voiceRecordingView {
    
    if (!_voiceRecordingView) {
        
        _voiceRecordingView = [[QIMVoiceRecordingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, self.navigationController.navigationBar.height + 150, 150, 150)];
        _voiceRecordingView.hidden = YES;
        _voiceRecordingView.userInteractionEnabled = NO;
        [self.view addSubview:_voiceRecordingView];
    }
    return _voiceRecordingView;
}

- (QIMVoiceTimeRemindView *)voiceTimeRemindView {
    
    if (!_voiceTimeRemindView) {
        
        _voiceTimeRemindView = [[QIMVoiceTimeRemindView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, self.navigationController.navigationBar.height + 150, 150, 150)];
        _voiceTimeRemindView.hidden = YES;
        _voiceTimeRemindView.userInteractionEnabled = NO;
        [self.view addSubview:_voiceTimeRemindView];
    }
    return _voiceTimeRemindView;
}

- (QIMPlayVoiceManager *)playVoiceManager {
    if (!_playVoiceManager) {
        _playVoiceManager = [QIMPlayVoiceManager defaultPlayVoiceManager];
        _playVoiceManager.playVoiceManagerDelegate = self;
    }
    return _playVoiceManager;
}

- (UIView *)notificationView {
    if (!_notificationView) {
        _notificationView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 110, _textBar.frame.origin.y - 50, 100, 40)];
        
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

- (QIMRemoteAudioPlayer *)remoteAudioPlayer {
    if (!_remoteAudioPlayer) {
        _remoteAudioPlayer = [[QIMRemoteAudioPlayer alloc] init];
        _remoteAudioPlayer.delegate = self;
    }
    return _remoteAudioPlayer;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        
    }
    return _titleLabel;
}

- (QIMNotReadMsgTipViews *)readMsgTipView {
    if (!_readMsgTipView) {
        //未读消息按钮
        _readMsgTipView = [[QIMNotReadMsgTipViews alloc] initWithNotReadCount:self.notReadCount];
        [_readMsgTipView setFrame:CGRectMake(self.view.width, 10, _readMsgTipView.width, _readMsgTipView.height)];
        [_readMsgTipView setNotReadMsgDelegate:self];
    }
    return _readMsgTipView;
}

- (UIWindow *)referMsgwindow {
    if (!_referMsgwindow) {
        
    }
    return _referMsgwindow;
}

- (UIView *)joinShareLctView {
    if (!_joinShareLctView) {
        
    }
    return _joinShareLctView;
}

- (ShareLocationViewController *)shareLctVC {
    if (!_shareLctVC) {
        _shareLctVC = [[ShareLocationViewController alloc] init];
        _shareLctVC.shareLocationId = _shareLctId;
        _shareLctVC.userId = self.chatId;
    }
    return _shareLctVC;
}

- (UIImageView *)chatBGImageView {
    if (!_chatBGImageView) {
        _chatBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
        _chatBGImageView.contentMode = UIViewContentModeScaleAspectFill;
        _chatBGImageView.clipsToBounds = YES;
    }
    return _chatBGImageView;
}

- (UIView *)getForwardNavView {
    if (_forwardNavTitleView == nil) {
        _forwardNavTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, self.navigationController.navigationBar.bounds.size.height)];
        _forwardNavTitleView.backgroundColor = [UIColor qtalkTableDefaultColor];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelForwardHandle:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.frame = CGRectMake(20, 0, 50, _forwardNavTitleView.height);
        [_forwardNavTitleView addSubview:cancelBtn];
    }
    return _forwardNavTitleView;
}

- (UIView *)getMaskRightTitleView {
    if (_maskRightTitleView == nil) {
        _maskRightTitleView = [[UIView alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.bounds.size.width - 130, 0, 130, self.navigationController.navigationBar.bounds.size.height)];
        _maskRightTitleView.backgroundColor = [UIColor qtalkTableDefaultColor];
    }
    return _maskRightTitleView;
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

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        if (self.chatType == ChatType_CollectionChat) {
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
        _tableView.mj_header = [QIMMessageRefreshHeader messsageHeaderWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessageData)];
    }
    return _tableView;
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textBar keyBoardDown];
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
            __weak typeof(self) weakSelf = self;
            [[self navigationController] presentViewController:nav
                                                      animated:YES
                                                    completion:^{
                                                        [weakSelf cancelForwardHandle:nil];
                                                    }];
        }];
        UIAlertAction *mergerForwardAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"Combine and Forward"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            NSArray *forwardIndexpaths = [_tableView.indexPathsForSelectedRows sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return obj1 > obj2;
            }];
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (NSIndexPath *indexPath in forwardIndexpaths) {
                [msgList addObject:[self.messageManager.dataSource objectAtIndex:indexPath.row]];
            }
            
            NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:[[QIMKit sharedInstance] getLastJid]];
            NSString *userName = [userInfoDic objectForKey:@"Name"];
            
            _jsonFilePath = [QIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@和%@的聊天记录", userName ? userName : [QIMKit getLastUserName], self.title]];
            _tableView.editing = NO;
            [_forwardNavTitleView removeFromSuperview];
            [_maskRightTitleView removeFromSuperview];
            [self.forwardBtn removeFromSuperview];
            [self.textBar setUserInteractionEnabled:YES];
            
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            controller.delegate = self;
            __weak typeof(self) weakSelf = self;
            [[self navigationController] presentViewController:nav
                                                      animated:YES
                                                    completion:^{
                                                        [weakSelf cancelForwardHandle:nil];
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
    
    _tableView.editing = NO;
    [_forwardNavTitleView removeFromSuperview];
    [_maskRightTitleView removeFromSuperview];
    [self.forwardBtn removeFromSuperview];
    [self.textBar setUserInteractionEnabled:YES];
    [self.messageManager.forwardSelectedMsgs removeAllObjects];
}


- (void)setupNavBar {
    [self setBackBtn];
    UIView *rightItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    UIButton *cardButton = [[UIButton alloc] initWithFrame:CGRectMake(rightItemView.right - 30, 9, 30, 30)];
    [cardButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [cardButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0eb" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
    [cardButton setAccessibilityIdentifier:@"rightUserCardBtn"];
    [cardButton addTarget:self action:@selector(onCardClick) forControlEvents:UIControlEventTouchUpInside];
    [rightItemView addSubview:cardButton];
    if (![[[QIMKit sharedInstance] userObjectForKey:kRightCardRemindNotification] boolValue]) {
        QIMRedMindView *redMindView = [[QIMRedMindView alloc] initWithBroView:cardButton withRemindNotificationName:kRightCardRemindNotification];
        [rightItemView addSubview:redMindView];
    }
    
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        
        UIButton *encryptBtn = nil;
        NSString *qCloudHost = [[QIMKit sharedInstance] qimNav_QCloudHost];
        if (qCloudHost.length > 0 && ![[QIMKit sharedInstance] isMiddleVirtualAccountWithJid:self.chatId] && self.chatType == ChatType_SingleChat) {
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
        if (self.chatType == ChatType_ConsultServer && [[[QIMKit sharedInstance] getMyhotLinelist] containsObject:self.virtualJid]) {
            UIButton *endChatBtn = [[UIButton alloc] initWithFrame:CGRectMake(cardButton.left - 30 - 5, 9, 30, 30)];
            [endChatBtn setAccessibilityIdentifier:@"endChatBtn"];
            [endChatBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0b5" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
            [endChatBtn addTarget:self action:@selector(endChatSession) forControlEvents:UIControlEventTouchUpInside];
            if (self.chatType == ChatType_ConsultServer) {
                [rightItemView addSubview:endChatBtn];
            }
        }
        UIButton *createGrouButton = [[UIButton alloc] initWithFrame:CGRectMake(cardButton.left - 30 - 5, 9, 30, 30)];
        [createGrouButton setAccessibilityIdentifier:@"rightCreateGroupBtn"];
        [createGrouButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0ca" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
        [createGrouButton addTarget:self action:@selector(onCreateGroupClcik) forControlEvents:UIControlEventTouchUpInside];
        //        [rightItemView addSubview:createGrouButton];
    } else {
 
    }
    if (self.chatType != ChatType_CollectionChat) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemView];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
    
    [self initTitleView];
}

- (void)initUI {
    
    self.view.backgroundColor = [UIColor qtalkChatBgColor];
 
    [[QIMEmotionSpirits sharedInstance] setTableView:_tableView];
    [self loadData];
    [self refreshChatBGImageView];
    
    //添加整个view的点击事件，当点击页面空白地方时，输入框收回
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    gesture.delegate = self;
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:gesture];
    
    _shareLctId = [[QIMKit sharedInstance] getShareLocationIdByJid:self.chatId];
    if (_shareLctId.length > 0 && [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count > 0) {
        _shareFromId = [[QIMKit sharedInstance] getShareLocationFromIdByShareLocationId:_shareLctId];
        [self initJoinShareView];
    }
    
    if (self.needShowNewMsgTagCell) {
        
        [self.view addSubview:self.readMsgTipView];
        [UIView animateWithDuration:0.3 animations:^{
            [UIView setAnimationDelay:0.1];
            [self.readMsgTipView setFrame:CGRectMake(self.view.width - _readMsgTipView.width, _readMsgTipView.top, _readMsgTipView.width, _readMsgTipView.height)];
        }];
    }
    [self.textBar performSelector:@selector(keyBoardDown) withObject:nil afterDelay:0.5];
}

- (void)updateTitleView:(NSNotification *)notify {

    NSDictionary *dic = notify.object;
    if (dic.count) {
        NSString *jid = [dic objectForKey:@"jid"];
        NSString *nickName = [dic objectForKey:@"nickName"];
        if ([jid isEqualToString:self.chatId]) {
            self.title = nickName;
            [self initTitleView];
        }
    }
}

- (void)initTitleView {
    QIMNavTitleView *titleView = [[QIMNavTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleView.autoresizesSubviews = YES;
    titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (self.chatType == ChatType_ConsultServer) {
        NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:self.chatId];
        NSString *userName = [infoDic objectForKey:@"Name"];
        if (userName.length <= 0) {
            userName = [self.chatId componentsSeparatedByString:@"@"].firstObject;
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
        NSDictionary *collectionUserInfo = [[QIMKit sharedInstance] getCollectionUserInfoByUserId:self.chatId];
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
                NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.chatId];
                
                descLabel.text = [userInfo objectForKey:@"DescInfo"];
                
            } else {
                /*
                NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.chatId];
                
                descLabel.text = [userInfo objectForKey:@"DescInfo"];
                */
                [[QIMKit sharedInstance] userProfilewithUserId:self.chatId
                                                    needupdate:NO
                                                     withBlock:^(NSDictionary *userinfo) {
                                                         NSString *desc = [userinfo objectForKey:@"M"];
                                                         if (desc && [desc length] > 0) {
                                                             [descLabel setText:desc];
                                                         } else {
                                                             NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.chatId];
                                                             
                                                             descLabel.text = [userInfo objectForKey:@"DescInfo"];
                                                         }
                                                     }];
            }
        }
        [titleView addSubview:descLabel];
    }
    self.navigationItem.titleView = titleView;
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    [self.textBar keyBoardDown];
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.chatType != ChatType_CollectionChat) {
        [self.view addSubview:self.textBar];
    }
//    [self initUI];
    /*
    if (self.chatType != ChatType_CollectionChat) {
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
    */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_forwardNavTitleView.superview) {
        [_forwardNavTitleView.superview bringSubviewToFront:_forwardNavTitleView];
    }
    if (_maskRightTitleView.superview) {
        [_maskRightTitleView.superview bringSubviewToFront:_maskRightTitleView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.remoteAudioPlayer stop];
    _currentPlayVoiceMsgId = nil;
    if (_shareLctId && [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count == 0) {
        [_joinShareLctView removeFromSuperview];
        _joinShareLctView = nil;
    }
    
    for (int i = 0; i < (int) self.messageManager.dataSource.count - kPageCount * 2; i++) {
        [[QIMMessageCellCache sharedInstance] removeObjectForKey:[(Message *) self.messageManager.dataSource[i] messageId]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNotifications];
    [self setupNavBar];
    self.loadCount = 0;
#warning 通知会话
#if defined (QIMNotifyEnable) && QIMNotifyEnable == 1

    [[QIMNotifyManager shareNotifyManager] setNotifyManagerSpecifiedDelegate:self];
#endif
    if (self.bindId) {
        self.chatType = ChatType_CollectionChat;
    }
#warning 加密会话
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    [QIMEncryptChat sharedInstance].delegate = self;

    self.isEncryptChat = [[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId];
    self.encryptChatState = [[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId];
    NSInteger securitySettingTime = [[[QIMKit sharedInstance] userObjectForKey:@"securityMinute"] integerValue];
    if (securitySettingTime == 0) {
        //15分钟安全时间
        [[QIMKit sharedInstance] setUserObject:@(15 * 60) forKey:@"securityMinute"];
    }
    NSTimeInterval leftTime = [[QIMEncryptChat sharedInstance] getEncryptChatLeaveTimeWithUserId:self.chatId];
    NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
    //超过安全时间 或 密码不正确
    if (nowTime - leftTime > securitySettingTime) {
        
        if (self.encryptChatState == QIMEncryptChatStateDecrypted) {
            [[QIMEncryptChat sharedInstance] cancelDescrpytChat];
        } else if (self.encryptChatState == QIMEncryptChatStateEncrypting) {
            [[QIMEncryptChat sharedInstance] closeEncrypt];
        } else {
            
        }
        self.isEncryptChat = NO;
        self.encryptChatState = [[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId];
    } else {
        self.isEncryptChat = [[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId];
    }
#endif
    _photos = [[NSMutableDictionary alloc] init];
    _currentPlayVoiceIndex = 0;
    [[QIMKit sharedInstance] setUserObject:@"OFF" forKey:@"burnAfterReadingStatus"];
    [[QIMKit sharedInstance] setCurrentSessionUserId:self.chatId];
    _rootViewFrame = self.view.frame;
    self.playVoiceManager.chatId = self.chatId;
    self.messageManager.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
    [self initUI];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self synchronizeChatSession];
    });
    if ([self.chatId containsString:@"dujia_warning"]) {
        [self performSelector:@selector(synchronizeDujiaWarning) withObject:nil afterDelay:1.5];
    }
}

- (void)initNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expandViewItemHandleNotificationHandle:) name:kExpandViewItemHandleNotification object:nil];
    //消息发送成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgDidSendNotificationHandle:) name:kXmppStreamDidSendMessage object:nil];
    //消息发送失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgSendFailedNotificationHandle:) name:kXmppStreamSendMessageFailed object:nil];
    //重发消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgReSendNotificationHandle:) name:kXmppStreamReSendMessage object:nil];
    //阅后即焚消息销毁
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BurnAfterReadMsgDestructionNotificationHandle:) name:kBurnAfterReadMsgDestruction object:nil];
    //消息被撤回
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revokeMsgNotificationHandle:) name:kRevokeMsg object:nil];
    //键盘弹出，消息自动滑动最底
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:kQIMTextBarIsFirstResponder object:nil];
    //发送收藏表情图片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionEmotionNotificationHandle:) name:kCollectionEmotionHandleNotification object:nil];
    //发送失效的收藏表情图片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionEmotionNotFoundNotificationHandle:) name:kCollectionEmotionNotFoundHandleNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillSendRedPackNotificationHandle:) name:WillSendRedPackNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageList:) name:kNotificationMessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionMessageList:) name:kNotificationCollectionMessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHistoryMessageList:) name:kNotificationOfflineMessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFileFinished:) name:KDownloadFileFinishedNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTyping:) name:kTyping object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:@"refreshTableView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginShareLocationMsg:) name:kBeginShareLocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endShareLocationMsg:) name:kEndShareLocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionImageDidLoad:) name:kNotificationEmotionImageDidLoad object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transToUser:) name:kTransToUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFileDidUpload:) name:kNotificationFileDidUpload object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceSuccess:) name:kCollectionEmotionUpdateHandleSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceFailed:) name:kCollectionEmotionUpdateHandleFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeNotifyView:) name:kNotifyViewCloseNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceReloadSingleMessages:) name:kSingleChatMsgReloadNotification object:nil];
    //刷新个人备注
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitleView:) name:kMarkNameUpdate object:nil];
    //发送快捷回复
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendQuickReplyContent:) name:kNotificationSendQuickReplyContent object:nil];
    
    //点击机器人问题列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendRobotQuestionText:) name:kNotificationSendRobotQuestion object:nil];
}

- (void)synchronizeDujiaWarning {
    [[QIMKit sharedInstance] synchronizeDujiaWarningWithJid:self.chatId];
}

- (void)synchronizeChatSession {
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.chatId;
    } else {
        userId = self.chatId;
    }
    [[QIMKit sharedInstance] synchronizeChatSessionWithUserId:userId WithChatType:self.chatType WithRealJid:realJid];
}

- (void)forceReloadSingleMessages:(NSNotification *)notify {
    long long currentMaxSingleMsgTime = [[QIMKit sharedInstance] getMaxMsgTimeStampByXmppId:self.chatId];
    Message *msg = [self.messageManager.dataSource lastObject];
    long long currentSingleTime = msg.messageDate;
    if (currentSingleTime < currentMaxSingleMsgTime) {
        QIMVerboseLog(@"重新Reload 单人聊天会话框");
        [self setProgressHUDDetailsLabelText:@"重新加载消息中..."];
        [self loadData];
        [self closeHUD];
        QIMVerboseLog(@"重新Reload 单人聊天会话框结束");
    }
}

- (void)showChatNotifyWithView:(QIMNotifyView *)view WithMessage:(NSDictionary *)message{
    
    NSString *from = [message objectForKey:@"from"];
    NSString *realFrom = [message objectForKey:@"realFrom"];
    NSString *realTo = [message objectForKey:@"realTo"];
    NSString *to = [message objectForKey:@"to"];
    BOOL isConsult = [[message objectForKey:@"isConsult"] boolValue];
    NSInteger consult = [[message objectForKey:@"consult"] integerValue];
    if (isConsult) {
        //客人端展示条，只判断to
        if (consult == ChatType_Consult) {
            if ([self.virtualJid isEqualToString:to]) {
                [self.view addSubview:view];
            }
        } else {
            //客服端展示条，判断to与realto
            if ([self.virtualJid isEqualToString:to] && [self.chatId isEqualToString:realTo]) {
                [self.view addSubview:view];
            }
        }
    } else {
        if ([from isEqualToString:self.chatId] || [to isEqualToString:self.chatId]) {
            [self.view addSubview:view];
        }
    }
}

- (void)closeNotifyView:(NSNotification *)nofity {
    QIMNotifyView *notifyView = nofity.object;
    [notifyView removeFromSuperview];
}
#if defined (QIMNoteEnable) && QIMNoteEnable == 1

- (void)reloadBaseViewWithUserId:(NSString *)userId WithEncryptChatState:(QIMEncryptChatState)encryptChatState {
    if ([self.chatId isEqualToString:userId]) {
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
                self.pwd = [[QIMNoteManager sharedInstance] getChatPasswordWithUserId:self.chatId WithCid:model.c_id];
                _titleLabel.text = [_titleLabel.text stringByAppendingString:@"【加密中】"];
                [self.encryptBtn setImage:[UIImage imageNamed:@"apt-suokongxin-f"] forState:UIControlStateNormal];
            }
                break;
            case QIMEncryptChatStateDecrypted: {
                self.isEncryptChat = YES;
                QIMNoteModel *model = [[QIMNoteManager sharedInstance] getEncrptPwdBox];
                self.pwd = [[QIMNoteManager sharedInstance] getChatPasswordWithUserId:self.chatId WithCid:model.c_id];
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

- (void)keyBoardWillShow:(NSNotification *)notify {
    
    [self scrollToBottom_tableView];
}

//lilu 9.22 3DTouch
- (NSArray<id <UIPreviewActionItem>> *)previewActionItems {
    BOOL isStick = [[QIMKit sharedInstance] isStickWithCombineJid:self.chatId];
    NSString *title = isStick ? @"取消置顶" : @"置顶";
    
    UIPreviewAction *p1 = [UIPreviewAction actionWithTitle:title style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *_Nonnull action, UIViewController *_Nonnull previewViewController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatSessionStick object:self.chatInfoDict];
    }];
    UIPreviewAction *p3 = [UIPreviewAction actionWithTitle:@"删除" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction *_Nonnull action, UIViewController *_Nonnull previewViewController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatSessionDelete object:self.chatInfoDict];
    }];
    return @[p1, p3];
}

//lilu 9.19表情收藏成功通知
- (MBProgressHUD *)progressHUD {
    
    if (!_progressHUD) {
        
        _progressHUD = [[MBProgressHUD alloc] initWithFrame:self.view.bounds];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.center = self.view.center;
        _progressHUD.minShowTime = 0.7;
        [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    }
    [_progressHUD show:YES];
    return _progressHUD;
}

- (void)setProgressHUDDetailsLabelText:(NSString *)text {
    
    [self.progressHUD setDetailsLabelText:text];
}

- (void)closeHUD {
    if (self.progressHUD) {
        [self.progressHUD hide:YES];
    }
}

- (void)collectEmojiFaceFailed:(NSNotification *)notify {
    [self setProgressHUDDetailsLabelText:@"收藏表情失败"];
    [self closeHUD];
    [self.tableView.mj_header endRefreshing];
}

- (void)collectEmojiFaceSuccess:(NSNotification *)notify {
    
    [self setProgressHUDDetailsLabelText:@"添加成功"];
    [self closeHUD];
}

- (void)transToUser:(NSNotification *)notify {
    NSString *from = notify.object;
    if ([from isEqualToString:self.chatId]) {
        NSDictionary *transInfo = notify.userInfo;
        //        _transToUserInfo = transInfo;
        NSString *transToJid = [transInfo objectForKey:@"TransJid"];
        NSString *transToName = [transInfo objectForKey:@"TransName"];
        Message *msg = [Message new];
        [msg setMessageType:QIMMessageType_TransToUser];
        [msg setMessage:(id) transInfo];
        [self.messageManager.dataSource addObject:msg];
        [_tableView reloadData];
        
        [[QIMKit sharedInstance] setNotSendText:[self.textBar getSendAttributedText] inputItems:[self.textBar getAttributedTextItems] ForJid:transToJid];
        [[QIMKit sharedInstance] openChatSessionByUserId:transToJid];
        
        QIMChatVC *chatVC = [[QIMChatVC alloc] init];
        [chatVC setStype:kSessionType_Chat];
        [chatVC setChatId:transToJid];
        [chatVC setTitle:transToName];
        [chatVC setChatType:ChatType_SingleChat];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        [self.navigationController popToRootVCThenPush:chatVC animated:YES];
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"客服[%@]已将您的咨询转移给客服[%@]处理，是否要切换到该客户继续进行咨询？",self.name,transToName?transToName:transToJid] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        //        [alertView setTag:kTransToUserAlertViewTag];
        //        [alertView show];
    }
}

- (void)cancelTyping {
    if (self.isEncryptChat == YES) {
        _titleLabel.text = [self.title stringByAppendingString:@"【加密中】"];
    } else {
        [_titleLabel setText:self.title];
    }
}

- (void)onTyping:(NSNotification *)notify {
    if ([notify.object isEqualToString:self.chatId]) {
        [_titleLabel setText:@"对方正在输入..."];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelTyping) object:nil];
        [self performSelector:@selector(cancelTyping) withObject:nil afterDelay:5];
    }
}

- (void)checkAddNewMsgTag {
    Message *firstMsg = [self.messageManager.dataSource firstObject];
    if (firstMsg.messageDate > _readedMsgTimeStamp) {
        return;
    }
    int index = 0;
    BOOL needAdd = NO;
    for (Message *msg in self.messageManager.dataSource) {
        if (msg.messageDate >= _readedMsgTimeStamp) {
            needAdd = YES;
            break;
        }
        index++;
    }
    if (needAdd) {
        Message *msg = [Message new];
        [msg setMessageType:QIMMessageType_NewMsgTag];
        [self.messageManager.dataSource insertObject:msg atIndex:index + 1];
        
        [self setNeedShowNewMsgTagCell:NO];
    }
    
}

- (void)hiddenNotReadTipView {
    if (_readMsgTipView) {
        [UIView animateWithDuration:0.3 animations:^{
            [_readMsgTipView setFrame:CGRectMake(self.view.width, _readMsgTipView.top, _readMsgTipView.width, _readMsgTipView.height)];
        }                completion:^(BOOL finished) {
            _readMsgTipView = nil;
        }];
    }
}

- (void)moveToFirstNotReadMsg {
    __weak id weakSelf = self;
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.chatId;
    } else {
        userId = self.chatId;
    }
    [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:realJid FromTimeStamp:_readedMsgTimeStamp WihtComplete:^(NSArray *list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageManager.dataSource removeAllObjects];
            [self.messageManager.dataSource addObjectsFromArray:list];
            [weakSelf checkAddNewMsgTag];
            [_tableView reloadData];
            [weakSelf hiddenNotReadTipView];
            [weakSelf addImageToImageList];
            if (self.messageManager.dataSource.count > 0) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(0) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });
    }];
}

- (void)loadData {
    __weak QIMChatVC *weakSelf = self;
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_CollectionChat) {
        NSArray *collectionMsgs = [[QIMKit sharedInstance] getCollectionMsgListForUserId:self.bindId originUserId:self.chatId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageManager.dataSource removeAllObjects];
            [self.messageManager.dataSource addObjectsFromArray:collectionMsgs];
            [_tableView reloadData];
            [weakSelf scrollBottom];
            [weakSelf addImageToImageList];
            if (_willSendImageData) {
                [weakSelf sendImageData:_willSendImageData];
                _willSendImageData = nil;
            }
            //标记已读
            [weakSelf markReadFlag];
        });
    } else {
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
        }
        if (self.fastMsgTimeStamp > 0) {
            [[QIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid FromTimeStamp:self.fastMsgTimeStamp WihtComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    CGFloat offsetY = _tableView.contentSize.height - _tableView.contentOffset.y;
                    NSRange range = NSMakeRange(0, [list count]);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    
                    [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                    [_tableView reloadData];
                    //重新获取一次大图展示的数组
                    [weakSelf addImageToImageList];
                    [weakSelf.tableView.mj_header endRefreshing];
                    //标记已读
                    [weakSelf markReadFlag];
                });
            }];
        } else {
            if (self.chatType == ChatType_ConsultServer) {
                [[QIMKit sharedInstance] getConsultServerMsgLisByUserId:realJid WithVirtualId:userId WithLimit:kPageCount WithOffset:0 WithComplete:^(NSArray *list) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messageManager.dataSource removeAllObjects];
                        [self.messageManager.dataSource addObjectsFromArray:list];
                        [_tableView reloadData];
                        
                        [weakSelf scrollBottom];
                        [weakSelf addImageToImageList];
                        if (_willSendImageData) {
                            [weakSelf sendImageData:_willSendImageData];
                            _willSendImageData = nil;
                        }
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                }];
            } else {
                [[QIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WihtLimit:kPageCount WithOffset:0 WihtComplete:^(NSArray *list) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messageManager.dataSource removeAllObjects];
                        [self.messageManager.dataSource addObjectsFromArray:list];
                        [_tableView reloadData];
                        [weakSelf scrollToBottom_tableView];
                        [weakSelf addImageToImageList];
                        if (_willSendImageData) {
                            [weakSelf sendImageData:_willSendImageData];
                            _willSendImageData = nil;
                        }
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                }];
            }
        }
    }
}


- (void)markReadFlag {
    
    static int count = 0;
    NSString *userId = @"";
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.chatId;
    } else {
        userId = self.chatId;
    }
    //取出数据库所有消息，置已读
    count ++;
    QIMVerboseLog(@"markReadFlag : %d", count);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *markReadMsgList = [[QIMKit sharedInstance] getNotReadMsgIdListByUserId:userId WithRealJid:realJid];
        if (markReadMsgList.count > 0) {
            [[QIMKit sharedInstance] sendReadStateWithMessagesIdArray:markReadMsgList WithXmppId:self.chatId];
        }
    });
}

//右上角名片信息
- (void)onCardClick {
    if (![[[QIMKit sharedInstance] userObjectForKey:@"kRightCardRemindNotification"] boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRightCardRemindNotification object:nil];
        [[QIMKit sharedInstance] setUserObject:@(YES) forKey:kRightCardRemindNotification];
    }
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.chatId];
    NSString *userId = [userInfo objectForKey:@"XmppId"];
    if (userId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserChatInfoByUserId:userId];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserChatInfoByUserId:self.chatId];
        });
    }
}

//右上角加密
- (void)encryptChat:(id)sender {
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    [[QIMEncryptChat sharedInstance] doSomeEncryptChatWithUserId:self.chatId];
#endif
}

//右上角创建群聊
- (void)onCreateGroupClcik {
    QIMGroupCreateVC *groupCreateVC = [[QIMGroupCreateVC alloc] init];
    groupCreateVC.userId = self.chatId;
    groupCreateVC.userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.chatId];
    [self.navigationController pushViewController:groupCreateVC animated:YES];
}

//右上角关闭咨询会话
- (void)endChatSession {
    UIAlertController *endChatSessionAlertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确认结束本次服务？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[QIMKit sharedInstance] closeSessionWithShopId:self.virtualJid WithVisitorId:self.chatId withBlock:^(NSString *closeMsg) {
            if (closeMsg.length > 0) {
                [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:closeMsg];
                [[QIMProgressHUD sharedInstance] closeHUD];
                [self leftBarBtnClicked:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"结束本地会话失败" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }];
    [endChatSessionAlertVc addAction:cancelAction];
    [endChatSessionAlertVc addAction:okAction];
    [self.navigationController presentViewController:endChatSessionAlertVc animated:YES completion:nil];
}

//左上角返回按钮
- (void)leftBarBtnClicked:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

//SwipeBack
- (void)selfPopedViewController {
    [super selfPopedViewController];
    [[QIMKit sharedInstance] setNotSendText:[self.textBar getSendAttributedText] inputItems:[self.textBar getAttributedTextItems] ForJid:self.chatId];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)dealloc {
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    [[QIMEncryptChat sharedInstance] setEncryptChatLeaveTimeWithUserId:self.chatId WithTime:[NSDate timeIntervalSinceReferenceDate]];
#endif
    [[QIMNavBackBtn sharedInstance] removeTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if kHasVoice
    _remoteAudioPlayer = nil;
#endif
    _tableView.mj_header = nil;
    _chatId = nil;
    _stype = nil;
    _chatInfoDict = nil;
    _notificationView = nil;
//    _textBar = nil;
    _photos = nil;
    _imagesArr = nil;
    _chatBGImageView = nil;
    _titleLabel = nil;
    _resendMsg = nil;
    _willSendImageData = nil;
    
    _transferReason = nil;
    _shareLctVC = nil;
    _joinShareLctView = nil;
    _shareLctId = nil;
    _shareFromId = nil;
    
    _readMsgTipView = nil;
    _playVoiceManager = nil;
    
    _forwardNavTitleView = nil;
    _maskRightTitleView = nil;
    _forwardBtn = nil;
    _jsonFilePath = nil;
    
    _voiceRecordingView = nil;
    _voiceTimeRemindView = nil;
    _tableView = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _messageManager = nil;
    _dataNow = nil;
    _currentPlayVoiceMsgId = nil;
//    [_textBar removeFromSuperview];
}

- (void)viewDidUnload {
    _tableView = nil;
    [super viewDidUnload];
}


#if kHasVoice

#pragma mark - Audio Method

- (BOOL)playingVoiceWithMsgId:(NSString *)msgId {
    return [msgId isEqualToString:self.currentPlayVoiceMsgId];
}

- (void)playVoiceWithMsgId:(NSString *)msgId WithFilePath:(NSString *)filePath {
    
    self.currentPlayVoiceMsgId = msgId;
    self.isNoReadVoice = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] playVoiceIsNoReadWithMsgId:msgId ChatId:self.chatId];
    if (msgId) {
        self.currentPlayVoiceIndex = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getIndexOfMsgIdWithChatId:self.chatId msgId:msgId];
        // 开始播放
        if ([filePath qim_hasPrefixHttpHeader]) {
            
            [self.remoteAudioPlayer prepareForURL:filePath playAfterReady:YES];
        } else {
            [self.remoteAudioPlayer prepareForFilePath:filePath playAfterReady:YES];
        }
    } else {
        // 结束播放
        [self.remoteAudioPlayer stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    NSString *messageId = [[QIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBeginToPlay
                                                        object:messageId];
}

- (void)playVoiceWithMsgId:(NSString *)msgId WithFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl {
    
    self.currentPlayVoiceMsgId = msgId;
    self.isNoReadVoice = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] playVoiceIsNoReadWithMsgId:msgId ChatId:self.chatId];
    if (msgId) {
        self.currentPlayVoiceIndex = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getIndexOfMsgIdWithChatId:self.chatId msgId:msgId];
        [self.remoteAudioPlayer prepareForFileName:fileName andVoiceUrl:voiceUrl playAfterReady:YES];
    } else {
        [self.remoteAudioPlayer stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    NSString *messageId = [[QIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBeginToPlay
                                                        object:messageId];
}


- (void)remoteAudioPlayerReady:(QIMRemoteAudioPlayer *)player {
    
    NSString *msgId = [[QIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] setVoiceNoReadStateWithMsgId:msgId ChatId:self.chatId withState:YES];
}


- (void)remoteAudioPlayerErrorOccured:(QIMRemoteAudioPlayer *)player withErrorCode:(QIMRemoteAudioPlayerErrorCode)errorCode {
    
}

- (void)remoteAudioPlayerDidStartPlaying:(QIMRemoteAudioPlayer *)player {
    
    [self updateCurrentPlayVoiceTime];
}

- (void)remoteAudioPlayerDidFinishPlaying:(QIMRemoteAudioPlayer *)player {
    // 1. 告诉播放者，我播放完毕了
    NSString *msgId = [[QIMPlayVoiceManager defaultPlayVoiceManager] currentMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyEndPlay
                                                        object:msgId];
    self.currentPlayVoiceMsgId = nil;
    NSInteger count = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getVisibleNoReadSoundsCountWithChatId:self.chatId];
    if (self.isNoReadVoice) {
        if (count) {
            if (self.currentPlayVoiceIndex <= count - 1 && self.currentPlayVoiceIndex >= 0 && self.currentPlayVoiceIndex != NSNotFound) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kAutoPlayNextVoiceMsgHandleNotification object:@(self.currentPlayVoiceIndex)];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPlayAllVoiceMsgFinishHandleNotification object:nil];
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPlayAllVoiceMsgFinishHandleNotification object:nil];
        }
    }
}

- (void)updateCurrentPlayVoiceTime {
    
    if (_currentPlayVoiceMsgId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyPlayVoiceTime object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:self.remoteAudioPlayer.currentTime], kNotifyPlayVoiceTimeTime, _currentPlayVoiceMsgId, kNotifyPlayVoiceTimeMsgId, nil]];
        [self performSelector:@selector(updateCurrentPlayVoiceTime) withObject:nil afterDelay:1];
    }
}

- (int)playCurrentTime {
    return self.remoteAudioPlayer.currentTime;
}

- (void)downloadProgress:(float)newProgress {
    
    if (_currentPlayVoiceMsgId) {
        
        _currentDownloadProcess = newProgress;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDownloadProgress object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:_currentDownloadProcess], kNotifyDownloadProgressProgress, _currentPlayVoiceMsgId, kNotifyDownloadProgressMsgId, nil]];
        
    } else {
        _currentDownloadProcess = 1;
    }
}

- (double)getCurrentDownloadProgress {
    
    return _currentDownloadProcess;
}

#endif


- (void)shareLocationCancelBtnHandle:(id)sender {
    [_joinShareLctView removeAllSubviews];
    [UIView animateWithDuration:0.3 animations:^{
        [_joinShareLctView setFrame:CGRectMake(0, 0, self.view.width, 44)];
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:_shareFromId];
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, _joinShareLctView.width - 100, _joinShareLctView.height)];
        [tipsLabel setTextAlignment:NSTextAlignmentCenter];
        [tipsLabel setFont:[UIFont systemFontOfSize:14]];
        tipsLabel.textColor = [UIColor whiteColor];
        [tipsLabel setText:[NSString stringWithFormat:@"%@正在共享位置", [userInfo objectForKey:@"Name"]]];
        [_joinShareLctView addSubview:tipsLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconfont-arrow"]];
        [arrowImageView setFrame:CGRectMake(_joinShareLctView.right - 40, (_joinShareLctView.height - arrowImageView.width) / 2.0, arrowImageView.width, arrowImageView.height)];
        [_joinShareLctView addSubview:arrowImageView];
    }];
}

- (void)shareLocationJoinBtnHandle:(id)sender {
    
    [[self navigationController] presentViewController:self.shareLctVC animated:YES completion:nil];
}

#pragma mark - notification

- (void)onFileDidUpload:(NSNotification *)notify {
    [self refreshCellForMsg:notify.object];
}

- (void)emotionImageDidLoad:(NSNotification *)notify {
    for (Message *msg in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:notify.object]) {
            QIMTextContainer *container = [QIMMessageParser textContainerForMessage:msg fromCache:NO];
            if (container) {
                [[QIMMessageCellCache sharedInstance] setObject:container forKey:msg.messageId];
            }
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)downloadFileFinished:(NSNotification *)notify {
    [self refreshTableView];
}

- (void)onJoinShareViewClick {
    
    [_joinShareLctView removeAllSubviews];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, self.view.width - 80, 40)];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [contentLabel setFont:[UIFont systemFontOfSize:14]];
    [contentLabel setText:@"加入位置共享，聊天中其他人也能看到你的位置，确定加入？"];
    [contentLabel setNumberOfLines:2];
    [contentLabel setTextColor:[UIColor whiteColor]];
    [_joinShareLctView addSubview:contentLabel];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor qim_colorWithHex:0x53676f alpha:1]];
    [cancelBtn setClipsToBounds:YES];
    [cancelBtn.layer setCornerRadius:2.5];
    [cancelBtn addTarget:self action:@selector(shareLocationCancelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(contentLabel.left, contentLabel.bottom + 10, 80, 30);
    [cancelBtn setHidden:YES];
    [_joinShareLctView addSubview:cancelBtn];
    
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn setTitle:@"加入" forState:UIControlStateNormal];
    [joinBtn setBackgroundColor:[UIColor qim_colorWithHex:0x9fb7be alpha:1]];
    [joinBtn setClipsToBounds:YES];
    [joinBtn.layer setCornerRadius:2.5];
    [joinBtn addTarget:self action:@selector(shareLocationJoinBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    joinBtn.frame = CGRectMake(contentLabel.right - 80, cancelBtn.top, 80, 30);
    [joinBtn setHidden:YES];
    [_joinShareLctView addSubview:joinBtn];
    [UIView animateWithDuration:0.1 animations:^{
        [_joinShareLctView setFrame:CGRectMake(0, 0, self.view.width, joinBtn.bottom + 10)];
    }                completion:^(BOOL finished) {
        [joinBtn setHidden:NO];
        [cancelBtn setHidden:NO];
    }];
    
}

- (void)initJoinShareView {
    if (_joinShareLctView == nil) {
        _joinShareLctView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _joinShareLctView.backgroundColor = [UIColor qim_colorWithHex:0x808e94 alpha:0.85];
        [self.view addSubview:_joinShareLctView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onJoinShareViewClick)];
        [_joinShareLctView addGestureRecognizer:tap];
        
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:_shareFromId];
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, _joinShareLctView.width - 100, _joinShareLctView.height)];
        [tipsLabel setTextAlignment:NSTextAlignmentCenter];
        [tipsLabel setFont:[UIFont systemFontOfSize:14]];
        tipsLabel.textColor = [UIColor whiteColor];
        [tipsLabel setText:[NSString stringWithFormat:@"%@正在共享位置", [userInfo objectForKey:@"Name"]]];
        [_joinShareLctView addSubview:tipsLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconfont-arrow"]];
        [arrowImageView setFrame:CGRectMake(_joinShareLctView.right - 40, (_joinShareLctView.height - arrowImageView.width) / 2.0, arrowImageView.width, arrowImageView.height)];
        [_joinShareLctView addSubview:arrowImageView];
        
        [self.view addSubview:_joinShareLctView];
    }
    
}

- (void)beginShareLocationMsg:(NSNotification *)notify {
    if ([notify.object isEqualToString:self.chatId]) {
        _shareLctId = notify.userInfo[@"shareId"];
        _shareFromId = notify.userInfo[@"fromId"];
        if (_shareLctId == nil) {
            return;
        }
        [self initJoinShareView];
    }
}

- (void)endShareLocationMsg:(NSNotification *)notify {
    if (_shareLctId && [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count == 0) {
        [_joinShareLctView removeFromSuperview];
        _joinShareLctView = nil;
    }
    _shareLctVC = nil;
    _shareLctId = nil;
}

- (void)collectionEmotionNotFoundNotificationHandle:(NSNotification *)notify {
    
    UIAlertController *notFoundEmojiAlertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"该表情已失效" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:nil];
    [notFoundEmojiAlertVc addAction:okAction];
    [self presentViewController:notFoundEmojiAlertVc animated:YES completion:nil];
}

- (void)collectionEmotionNotificationHandle:(NSNotification *)notify {
    
    NSString *httpUrl = notify.object;
    httpUrl = [httpUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    __block CGFloat width = 0;
    __block CGFloat height = 0;
    if ([httpUrl isEqualToString:kImageFacePageViewAddFlagName]) {
        //添加按钮点击
        QIMCollectionEmotionEditorVC *emotionEditor = [[QIMCollectionEmotionEditorVC alloc] init];
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:emotionEditor];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        __block Message *msg = nil;
        if (httpUrl.length) {
            
            BOOL isFileExist = [[QIMKit sharedInstance] isFileExistForUrl:httpUrl width:0 height:0 forCacheType:QIMFileCacheTypeColoction];
            if (isFileExist) {
                NSData *imgData = [[QIMKit sharedInstance] getFileDataFromUrl:httpUrl forCacheType:QIMFileCacheTypeColoction];
                CGSize size = [[QIMKit sharedInstance] getFitSizeForImgSize:[YLGIFImage imageWithData:imgData].size];
                
                [[QIMKit sharedInstance] saveFileData:imgData url:httpUrl width:size.width height:size.height forCacheType:QIMFileCacheTypeColoction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", httpUrl, size.width, size.height];
                    if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
                        msg = [[QIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:self.chatType msgType:QIMMessageType_Text];
                        [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                    }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
                    else if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
                        NSString *content = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_Text WithOriginBody:msgText WithOriginExtendInfo:nil WithUserId:self.chatId];
                        msg = [[QIMKit sharedInstance] sendMessage:@"[加密收藏表情消息iOS]" WithInfo:content ToUserId:self.chatId WihtMsgType:QIMMessageType_Encrypt];
                    }
#endif
                    else {
                        msg = [[QIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:self.chatType msgType:QIMMessageType_Text];
                        [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                    }
                    
                    [self.messageManager.dataSource addObject:msg];
                    [_tableView beginUpdates];
                    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                    [_tableView endUpdates];
                    [self scrollToBottomWithCheck:YES];;
                    [self addImageToImageList];
                });
            } else {
                [[QIMKit sharedInstance] downloadCollectionEmoji:httpUrl width:0 height:0 forCacheType:QIMFileCacheTypeColoction complation:^(NSData *fileData) {
                    
                    if ([fileData length] > 0) {
                        
                        UIImage *image = [YLGIFImage imageWithData:fileData];
                        if (image) {
                            
                            width = CGImageGetWidth(image.CGImage);
                            height = CGImageGetHeight(image.CGImage);
                            NSDictionary *dict = @{@"httpUrl": httpUrl, @"width": @(width), @"height": @(height)};
                            [[QIMCollectionFaceManager sharedInstance] replaceCollectionInfoWithIndex:index NewInfo:dict];
                            
                            CGSize size = [[QIMKit sharedInstance] getFitSizeForImgSize:image.size];
                            
                            [[QIMKit sharedInstance] saveFileData:fileData url:httpUrl width:size.width height:size.height forCacheType:QIMFileCacheTypeColoction];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSString *msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", httpUrl, size.width, size.height];
                                if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
                                    msg = [[QIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:self.chatType msgType:QIMMessageType_Text];
                                    [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                                }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
                                else if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
                                    NSString *content = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_Text WithOriginBody:msgText WithOriginExtendInfo:nil WithUserId:self.chatId];
                                    msg = [[QIMKit sharedInstance] sendMessage:@"[加密收藏表情消息iOS]" WithInfo:content ToUserId:self.chatId WihtMsgType:QIMMessageType_Encrypt];
                                }
#endif
                                else {
                                    msg = [[QIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:self.chatType msgType:QIMMessageType_Text];
                                    [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                                }
                                [self.messageManager.dataSource addObject:msg];
                                [_tableView beginUpdates];
                                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                                [_tableView endUpdates];
                                [self scrollToBottomWithCheck:YES];;
                                [self addImageToImageList];
                            });
                        }
                    }
                }];
            }
        }
    }
}

- (void)expandViewItemHandleNotificationHandle:(NSNotification *)notify {
    
    NSString *trId = notify.object;
    if ([trId isEqualToString:QIMTextBarExpandViewItem_BurnAfterReading]) {
        NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
        BOOL isOn = NO;
        if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
            [[QIMKit sharedInstance] setUserObject:@"OFF" forKey:@"burnAfterReadingStatus"];
        } else {
            [[QIMKit sharedInstance] setUserObject:@"ON" forKey:@"burnAfterReadingStatus"];
            isOn = YES;
        }
        [self.textBar updateFilrStatus:isOn];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_Shock]) {
        
        NSDate *dateAgain = [NSDate date];
        NSTimeInterval timeInterval = [dateAgain timeIntervalSinceDate:self.dataNow];
        NSInteger isnanTimeInterval = isnan(timeInterval);
        //两次有效窗口抖动的时间间隔为10s，第一次timeInterval为nan，用isnan(timeInterval)判断
        if (timeInterval > 10 || isnanTimeInterval) {
            
            Message *msg = [[QIMKit sharedInstance] sendShockToUserId:self.chatId];
            
            [self.messageManager.dataSource addObject:msg];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            [self scrollToBottomWithCheck:YES];;
            self.dataNow = dateAgain;
        }
        
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_MyFiles]) {
        QIMFileManagerViewController *fileManagerVC = [[QIMFileManagerViewController alloc] init];
        fileManagerVC.isSelect = YES;
        fileManagerVC.userId = self.chatId;
        fileManagerVC.messageSaveType = ChatType_SingleChat;
        
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:fileManagerVC];
        
        [self presentViewController:nav animated:YES completion:nil];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_ChatTransfer]) {
        [QIMFastEntrance openTransferConversation:self.virtualJid withVistorId:self.chatId];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_ShareCard]) {
        //        //分享名片
        QIMUserListVC *listVC = [[QIMUserListVC alloc] init];
        [listVC setDelegate:self];
        listVC.isTransfer = YES;
        _expandViewItemType = QIMTextBarExpandViewItemType_ShareCard;
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:listVC];
        [[self navigationController] presentViewController:nav animated:YES completion:^{
            
        }];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_RedPack]) {
        QIMVerboseLog(@"我是 单人红包，点我 干哈？");
        
        QIMWebView *webView = [[QIMWebView alloc] init];
        webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&user_id=%@&rk=%@&q_d=%@", [[QIMKit sharedInstance] redPackageUrlHost], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey],  [[QIMKit sharedInstance] getDomain]];
        //        webView.navBarHidden = YES;
        [webView setFromRegPackage:YES];
        [self.navigationController pushViewController:webView animated:YES];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_AACollection]) {
        QIMWebView *webView = [[QIMWebView alloc] init];
        webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&user_id=%@&rk=%@&q_d=%@", [[QIMKit sharedInstance] aaCollectionUrlHost], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey],  [[QIMKit sharedInstance] getDomain]];
        webView.navBarHidden = YES;
        [webView setFromRegPackage:YES];
        [self.navigationController pushViewController:webView animated:YES];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_SendProduct]) {
        QIMPushProductViewController *pushProVC = [[QIMPushProductViewController alloc] init];
        pushProVC.delegate = self;
        [self.navigationController pushViewController:pushProVC animated:YES];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_Location]) {
        [QIMAuthorizationManager sharedManager].authorizedBlock = ^{
            UserLocationViewController *userLct = [[UserLocationViewController alloc] init];
            userLct.delegate = self;
            [self.navigationController presentViewController:userLct animated:YES completion:nil];
        };
        [[QIMAuthorizationManager sharedManager] requestAuthorizationWithType:ENUM_QAM_AuthorizationTypeLocation];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_VideoCall]) {
#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
        [[QIMWebRTCClient sharedInstance] setRemoteJID:self.chatId];
        [[QIMWebRTCClient sharedInstance] showRTCViewByXmppId:self.chatId isVideo:YES isCaller:YES];
#endif
    } else {
        NSDictionary *trdExtendDic = [[QIMKit sharedInstance] getExpandItemsForTrdextendId:trId];
        int linkType = [[trdExtendDic objectForKey:@"linkType"] intValue];
        BOOL openQIMRN = linkType & 4;
        BOOL openRequeset = linkType & 2;
        BOOL openWebView = linkType & 1;
        NSString *linkUrl = [trdExtendDic objectForKey:@"linkurl"];
        NSString *userId = nil;
        NSString *realJid = nil;
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
        }
        if (openQIMRN) {
            [QIMFastEntrance openQIMRNWithScheme:linkUrl withChatId:userId withRealJid:realJid withChatType:self.chatType];
        } else if (openRequeset) {
            [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:linkUrl withChatId:userId withRealJid:realJid withChatType:self.chatType];
        } else {
            if (linkUrl.length > 0) {
                if ([linkUrl rangeOfString:@"qunar.com"].location != NSNotFound) {
                    linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&realJid=%@&chatType=%lld", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [[QIMKit sharedInstance] getLastJid], userId, realJid, self.chatType];
                } else {
                    linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&realJid=%@&chatType=%lld", ([linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?"), [[QIMKit sharedInstance] getLastJid], userId, realJid, self.chatType];
                }
                [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
            }
        }
    }
}

- (void)msgDidSendNotificationHandle:(NSNotification *)notify {
    NSString *msgID = [notify.object objectForKey:@"messageId"];
    
    //消息发送成功，更新消息状态，刷新tableView
    for (Message *msg in self.messageManager.dataSource) {
        //找到对应的msg，目前还不知道msgID
        if ([[msg messageId] isEqualToString:msgID]) {
            if (msg.messageState < MessageState_Success) {
                msg.messageState = MessageState_Success;
            }
            break;
        }
    }
}

- (void)msgSendFailedNotificationHandle:(NSNotification *)notify {
    NSString *msgID = [notify.object objectForKey:@"messageId"];
    
    //消息发送失败，更新消息状态，刷新tableView
    for (Message *msg in self.messageManager.dataSource) {
        //找到对应的msg，目前还不知道msgID
        if ([[msg messageId] isEqualToString:msgID]) {
            if (msg.messageState < MessageState_Faild) {
                msg.messageState = MessageState_Faild;
            }
            break;
        }
    }
}

- (void)removeFailedMsg {
    Message *message = _resendMsg;
    for (Message *msg in self.messageManager.dataSource) {
        if ([msg isEqual:message]) {
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            
            [self.messageManager.dataSource removeObject:msg];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            [[QIMKit sharedInstance] deleteMsg:message ByJid:self.chatId];
            break;
        }
    }
}

- (void)reSendMsg {
    Message *message = _resendMsg;
    [self removeFailedMsg];
    if (message.messageType == QIMMessageType_LocalShare) {
        if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
            [[QIMKit sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:message.messageType];
        } else {
            [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:message.messageType];
        }
    } else if (message.messageType == QIMMessageType_Voice) {
        NSDictionary *infoDic = [message getMsgInfoDic];
        NSString *fileName = [infoDic objectForKey:@"FileName"];
        NSString *filePath = [infoDic objectForKey:@"filepath"];
        NSNumber *Seconds = [infoDic objectForKey:@"Seconds"];
        NSData *amrData = [NSData dataWithContentsOfFile:filePath];
        //将armData文件上传，获取到相应的url
        NSString *httpUrl = [QIMKit updateLoadVoiceFile:amrData WithFilePath:filePath];
        [self sendVoiceUrl:httpUrl WithDuration:[Seconds intValue] WithSmallData:amrData WithFileName:fileName AndFilePath:filePath];
    } else if (message.messageType == QIMMessageType_BurnAfterRead) {
        //        [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:QIMMessageType_BurnAfterRead];
    } else if (message.messageType == QIMMessageType_Text) {
        if ([self isImageMessage:message.message]) {
            
            QIMTextContainer *textContainer = [QIMMessageParser textContainerForMessage:message];
            QIMImageStorage *imageStorage = textContainer.textStorages.lastObject;
            NSData *data = [[QIMKit sharedInstance] getFileDataFromUrl:[imageStorage.imageURL absoluteString] forCacheType:QIMFileCacheTypeColoction];
            [self sendImageData:data];
            
        } else {
            
            message = [[QIMKit sharedInstance] createMessageWithMsg:message.message extenddInfo:message.extendInformation userId:self.chatId userType:self.chatType msgType:message.messageType forMsgId:_resendMsg.messageId];
            
            [self.messageManager.dataSource addObject:message];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
                message = [[QIMKit sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:message.messageType];
            } else {
                message = [[QIMKit sharedInstance] sendMessage:message ToUserId:self.chatId];
            }
            [self scrollToBottomWithCheck:YES];
        }
    } else if (message.messageType == QIMMessageType_CardShare) {
        if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
            message = [[QIMKit sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:message.messageType];
        } else {
            [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:message.messageType];
        }
    } else if (message.messageType == QIMMessageType_SmallVideo) {
        NSDictionary *infoDic = [message getMsgInfoDic];
        NSString *filePath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:[infoDic objectForKey:@"ThumbName"] ? [infoDic objectForKey:@"ThumbName"] : @""];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        
        NSString *videoPath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingFormat:@"/%@", [infoDic objectForKey:@"FileName"]];
        
        [self sendVideoPath:videoPath WithThumbImage:image WithFileSizeStr:[infoDic objectForKey:@"FileSize"] WithVideoDuration:[[infoDic objectForKey:@"Duration"] floatValue] forMsgId:_resendMsg.messageId];
    }
    _resendMsg = nil;
}

- (void)msgReSendNotificationHandle:(NSNotification *)notify {
    _resendMsg = notify.object;
    UIAlertView *alertView = nil;
    
    if (_resendMsg.messageType == QIMMessageType_BurnAfterRead) {
        alertView = [[UIAlertView alloc] initWithTitle:@"重发该消息？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:@"重发该消息？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", @"重发", nil];
    }
    
    alertView.tag = kReSendMsgAlertViewTag;
    alertView.delegate = self;
    [alertView show];
    return;
}


- (void)BurnAfterReadMsgDestructionNotificationHandle:(NSNotification *)notify {
    Message *message = notify.object;
    message.messageState = MessageState_didDestroyed;
    message.messageType = QIMMessageType_BurnAfterRead;
    [[QIMKit sharedInstance] updateMsg:message ByJid:self.chatId];
    
    for (Message *msg  in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:message.messageId]) {
            [self.messageManager.dataSource replaceObjectAtIndex:[self.messageManager.dataSource indexOfObject:msg] withObject:message];
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}

- (void)revokeMsgNotificationHandle:(NSNotification *)notify {
    //    NSString * jid = notify.object;
    NSString *msgID = [notify.userInfo objectForKey:@"MsgId"];
    //    NSString * content = [notify.userInfo objectForKey:@"Content"];
    for (Message *msg in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:msgID]) {
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            [(Message *) msg setMessageType:QIMMessageType_Revoke];
            [self.messageManager.dataSource replaceObjectAtIndex:index withObject:msg];
            [[QIMKit sharedInstance] updateMsg:msg ByJid:self.chatId];
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}


- (void)WillSendRedPackNotificationHandle:(NSNotification *)noti {
    NSString *infoStr = [NSString qim_stringWithBase64EncodedString:noti.object];
    Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"【红包】请升级最新版本客户端查看红包~" extenddInfo:infoStr userId:self.chatId userType:self.chatType msgType:QIMMessageType_RedPack];
    
    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    [self addImageToImageList];
    if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
        msg = [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
    } else {
        msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
    }
}


- (BOOL)isImageMessage:(NSString *)msg {
    
    NSString *regulaStr = @"\\[obj type=\"(.*?)\" value=\"(.*?)\"(.*?)\\]";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:msg options:0 range:NSMakeRange(0, [msg length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSRange firstRange = [match rangeAtIndex:1];
        NSString *type = [msg substringWithRange:firstRange];
        if ([type isEqualToString:@"image"]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateHistoryMessageList:(NSNotification *)notify {
    
    if ([self.chatId isEqualToString:notify.object]) {
        NSString *userId = nil;
        NSString *realJid = nil;
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
        }
        __weak typeof(self) weakSelf = self;
        if (self.chatType == ChatType_ConsultServer) {
            
            [[QIMKit sharedInstance] getConsultServerMsgLisByUserId:realJid WithVirtualId:userId WithLimit:kPageCount WithOffset:0 WithComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messageManager.dataSource removeAllObjects];
                    [self.messageManager.dataSource addObjectsFromArray:list];
                    [weakSelf.tableView reloadData];
                    [weakSelf addImageToImageList];
                    [weakSelf scrollToBottomWithCheck:YES];
                });
            }];
        } else {
            [[QIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WihtLimit:kPageCount WithOffset:0 WihtComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messageManager.dataSource removeAllObjects];
                    [self.messageManager.dataSource addObjectsFromArray:list];
                    [weakSelf.tableView reloadData];
                    [weakSelf addImageToImageList];
                    [weakSelf scrollToBottomWithCheck:YES];
                });
            }];
        }
    }
}


- (void)updateCollectionMessageList:(NSNotification *)notify {
    NSDictionary *msgDic = notify.object;
    NSString *originFrom = [msgDic objectForKey:@"Originfrom"];
    NSString *originTo = [msgDic objectForKey:@"Originto"];
    if ([originFrom isEqualToString:self.chatId] && [originTo isEqualToString:self.bindId]) {
        NSString *msgId = [msgDic objectForKey:@"MsgId"];
        Message *msg = [[QIMKit sharedInstance] getCollectionMsgListForMsgId:msgId];
        if (msg) {
            if (!self.messageManager.dataSource) {
                self.messageManager.dataSource = [[NSMutableArray alloc] initWithCapacity:20];
                [self.messageManager.dataSource addObject:msg];
                [_tableView reloadData];
            } else if ([self.messageManager.dataSource count] != [_tableView numberOfRowsInSection:0]) {
                [self.messageManager.dataSource addObject:msg];
                [_tableView reloadData];
            } else {
                [self.messageManager.dataSource addObject:msg];
                NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]];
                [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
            [self addImageToImageList];
            [self scrollToBottomWithCheck:NO];
            [self markReadFlag];
        }
    }
}

//
// 二人消息 是在这里收到的

- (void)updateMessageList:(NSNotification *)notify {
    NSString *userId = nil;
    NSIndexPath *indexpath = [[self.tableView indexPathsForVisibleRows] lastObject];
    self.currentMsgIndexs = indexpath.row;
    if (self.chatType == ChatType_Consult) {
        userId = [NSString stringWithFormat:@"%@-%@",self.virtualJid,self.virtualJid];
    } else if (self.chatType == ChatType_ConsultServer) {
        if (_hasServerTransferFeedback && _hasUserTransferFeedback) {
            [[QIMProgressHUD sharedInstance] closeHUD];
        }
        userId = [NSString stringWithFormat:@"%@-%@",self.virtualJid,self.chatId];
    } else {
        userId = self.chatId;
    }
    if ([userId isEqualToString:notify.object]) {
        Message *msg = [notify.userInfo objectForKey:@"message"];
        if (self.chatType == ChatType_ConsultServer) {
            if (msg.messageType == QIMMessageType_TransChatToCustomerService_Feedback) {
                _hasServerTransferFeedback = YES;
            }
            if (msg.messageType == QIMMessageType_TransChatToCustomer_Feedback) {
                _hasUserTransferFeedback = YES;
            }
            if (_hasServerTransferFeedback && _hasUserTransferFeedback) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endTransferChatSession) object:nil];
                [self endTransferChatSession];
            }
        }
        if (msg) {
            if (!self.messageManager.dataSource) {
                self.messageManager.dataSource = [[NSMutableArray alloc] initWithCapacity:20];
                [self.messageManager.dataSource addObject:msg];
                [_tableView reloadData];
            } else if ([self.messageManager.dataSource count] != [_tableView numberOfRowsInSection:0]) {
                [self.messageManager.dataSource addObject:msg];
                [_tableView reloadData];
            } else {
                [self.messageManager.dataSource addObject:msg];
                NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]];
                [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
            [self addImageToImageList];
            [self scrollToBottomWithCheck:NO];
            [self markReadFlag];
        }
    }
}

- (void)scrollBottom {
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    QIMVerboseLog(@"IMChatVc %@ Offset : %f", self.chatId, offset.y);
    if (offset.y > self.tableView.height / 2.0f) {
        [self.tableView setContentOffset:offset animated:NO];
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

- (BOOL)shouldScrollToBottomForNewMessage {
//    CGFloat _h = self.tableView.contentSize.height - self.tableView.contentOffset.y - (CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.bottom);
    
    return (self.messageManager.dataSource.count - self.currentMsgIndexs) <= 3;
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if (_shareLctVC == nil) {
            _shareLctVC = [[ShareLocationViewController alloc] init];
            _shareLctVC.userId = self.chatId;
        }
        [[self navigationController] presentViewController:_shareLctVC animated:YES completion:^{
            
        }];
    } else if (buttonIndex == 1) {
        
        UserLocationViewController *userLct = [[UserLocationViewController alloc] init];
        userLct.delegate = self;
        [self.navigationController presentViewController:userLct animated:YES completion:nil];
    } else if (buttonIndex == 2) {
    }
}


#pragma mark - QIMContactSelectionViewControllerDelegate

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC chatVC:(QIMChatVC *)vc {
    
    NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:[[QIMKit sharedInstance] getLastJid]];
    NSString *userName = [userInfoDic objectForKey:@"Name"];
    
    Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:[contactVC getSelectInfoDic][@"userId"] userType:[[contactVC getSelectInfoDic][@"isGroup"] boolValue] ? ChatType_GroupChat : ChatType_SingleChat msgType:QIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:[NSString stringWithFormat:@"%@和%@的聊天记录", userName ? userName : [QIMKit getLastUserName], self.title] forKey:@"title"];
    [infoDic setQIMSafeObject:@"" forKey:@"desc"];
    [infoDic setQIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    
    msg.extendInformation = msgContent;
    
    [[QIMKit sharedInstance] uploadFileForData:[NSData dataWithContentsOfFile:_jsonFilePath] forMessage:msg withJid:[contactVC getSelectInfoDic][@"userId"] isFile:YES];
}

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC groupChatVC:(QIMGroupChatVC *)vc {
    NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:[[QIMKit sharedInstance] getLastJid]];
    NSString *userName = [userInfoDic objectForKey:@"Name"];
    
    Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:[contactVC getSelectInfoDic][@"userId"] userType:[[contactVC getSelectInfoDic][@"isGroup"] boolValue] ? ChatType_GroupChat : ChatType_SingleChat msgType:QIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:[NSString stringWithFormat:@"%@和%@的聊天记录", userName ? userName : [QIMKit getLastUserName], self.title] forKey:@"title"];
    [infoDic setQIMSafeObject:@"" forKey:@"desc"];
    [infoDic setQIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    
    msg.extendInformation = msgContent;
    
    [[QIMKit sharedInstance] uploadFileForData:[NSData dataWithContentsOfFile:_jsonFilePath] forMessage:msg withJid:[contactVC getSelectInfoDic][@"userId"] isFile:YES];
}

#pragma mark -

#pragma mark - QIMUserListVCDelegate

- (void)endTransferChatSession{
    [[QIMProgressHUD sharedInstance] closeHUD];
    _hasUserTransferFeedback = NO;
    _hasServerTransferFeedback = NO;
}

- (void)selectContactWithJid:(NSString *)jid {
    if (_expandViewItemType == QIMTextBarExpandViewItemType_ChatTransfer) {
        [[QIMProgressHUD sharedInstance] closeHUD];
        [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:@"正在转接会话"];
        _hasUserTransferFeedback = NO;
        _hasServerTransferFeedback = NO;
        [self performSelector:@selector(endTransferChatSession) withObject:nil afterDelay:3];
        if (self.chatType == ChatType_ConsultServer) {
            { //QIMMessageType_TransChatToCustomerService
                //                {
                //                    "d": "ejabhost2",
                //                    "f": "gunjern9357",
                //                    "r": "test转移",
                //                    "u": "uurpoby2438@ejabhost2"
                //                }
                NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
                [infoDic setObject:_transferReason forKey:@"r"];
                [infoDic setObject:[QIMKit getLastUserName] forKey:@"f"];
                [infoDic setObject:[[QIMKit sharedInstance] getDomain] forKey:@"d"];
                [infoDic setObject:self.chatId forKey:@"u"];
                NSString *msgId = [QIMUUIDTools UUID];
                [infoDic setObject:msgId forKey:@"retId"];
                [infoDic setObject:[jid componentsSeparatedByString:@"@"].firstObject forKey:@"rt"];
                [infoDic setObject:self.virtualJid forKey:@"toId"];
                NSString *content = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
                [[QIMKit sharedInstance] sendConsultMessageId:msgId WithMessage:content WithInfo:content toJid:self.virtualJid realToJid:jid WithChatType:self.chatType WithMsgType:QIMMessageType_TransChatToCustomerService];
            }
            { //QIMMessageType_TransChatToCustomer
                NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
                [infoDic setObject:_transferReason forKey:@"TransReson"];
                [infoDic setObject:[[QIMKit sharedInstance] getMyNickName] forKey:@"realfromIdNickName"];
                [infoDic setObject:[jid componentsSeparatedByString:@"@"].firstObject forKey:@"realtoId"];
                [infoDic setObject:[jid componentsSeparatedByString:@"@"].lastObject forKey:@"realtoDomain"];
                [infoDic setObject:self.virtualJid forKey:@"toId"];
//                [infoDic setObject:[self.virtualJid componentsSeparatedByString:@"@"].firstObject forKey:@"toId"];
                NSString *content = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
                Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:content extenddInfo:nil userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:QIMMessageType_TransChatToCustomer forMsgId:[QIMUUIDTools UUID] willSave:YES];
                [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                [self.messageManager.dataSource addObject:msg];
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                [_tableView endUpdates];
                [self scrollToBottomWithCheck:YES];
            }
        } else if (self.chatType == ChatType_SingleChat) {
            [[QIMKit sharedInstance] chatTransferFrom:[[QIMKit sharedInstance] getLastJid] To:jid User:self.chatId Reson:_transferReason chatId:@"0" WithMsgId:[QIMUUIDTools UUID]];
        }
        //        NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:[[QIMKit sharedInstance] getLastJid]];
        //        NSString *name = [infoDic objectForKey:@"Name"];
        //        NSString * infoStr = [[CJSONSerializer serializer] serializeDictionary:@{@"TransId":[jid componentsSeparatedByString:@"@"].firstObject,@"TransReson":[NSString stringWithFormat:@"转移From：%@ \n 转移原因：%@",name,_transferReason]}];
        //        [[QIMKit sharedInstance] chatTransferTo:self.chatId message:infoStr chatId:self.chatId];
        //        [[QIMKit sharedInstance] chatTransferFrom:[[QIMKit sharedInstance] getLastJid] To:jid User:self.chatId Reson:_transferReason chatId:@"0" WithMsgId:[UUIDTools UUID]];
        //    if (!self.isTransfer) {
        //        QIMNavController *nav = (QIMNavController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        //        [nav popToRootVCThenPush:chatVC animated:YES];
        //    }
    } else if (_expandViewItemType == QIMTextBarExpandViewItemType_ShareCard) {
        //分享名片 选择的user
        NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
        if (self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult) {
            [[QIMKit sharedInstance] sendConsultMessageId:[QIMUUIDTools UUID] WithMessage:[NSString stringWithFormat:@"分享名片：\n昵称：%@\n部门：%@", [infoDic objectForKey:@"Name"], [infoDic objectForKey:@"DescInfo"]] WithInfo:[NSString stringWithFormat:@"{\"userId\":\"%@\"}", [infoDic objectForKey:@"UserId"]] toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:QIMMessageType_CardShare];
        } else {
            [self sendMessage:[NSString stringWithFormat:@"分享名片：\n昵称：%@\n部门：%@", [infoDic objectForKey:@"Name"], [infoDic objectForKey:@"DescInfo"]] WithInfo:[NSString stringWithFormat:@"{\"userId\":\"%@\"}", [infoDic objectForKey:@"UserId"]] ForMsgType:QIMMessageType_CardShare];
        }
    }
}

#pragma mark - QIMInputPopViewDelegate

- (void)inputPopView:(QIMInputPopView *)view willBackWithText:(NSString *)text {
    _inputPopViewIsShow = NO;
    _transferReason = text;
    QIMUserListVC *listVC = [[QIMUserListVC alloc] init];
    [listVC setDelegate:self];
    listVC.isTransfer = YES;
    
    _expandViewItemType = QIMTextBarExpandViewItemType_ChatTransfer;
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:listVC];
    [[self navigationController] presentViewController:nav animated:YES completion:nil];
}

- (void)cancelForQIMInputPopView:(QIMInputPopView *)view {
    _inputPopViewIsShow = NO;
}

#pragma mark - text bar delegate

- (void)sendVideoPath:(NSString *)videoPath
       WithThumbImage:(UIImage *)thumbImage
      WithFileSizeStr:(NSString *)fileSizeStr
    WithVideoDuration:(float)duration {
    [self sendVideoPath:videoPath WithThumbImage:thumbImage WithFileSizeStr:fileSizeStr WithVideoDuration:duration forMsgId:nil];
}

- (void)sendVideoPath:(NSString *)videoPath
       WithThumbImage:(UIImage *)thumbImage
      WithFileSizeStr:(NSString *)fileSizeStr
    WithVideoDuration:(float)duration forMsgId:(NSString *)mId {
    [self.view setFrame:_rootViewFrame];
    NSString *msgId = mId.length ? mId : [QIMUUIDTools UUID];
    CGSize size = thumbImage.size;
    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.8);
    NSString *pathExtension = [[videoPath lastPathComponent] pathExtension];
    NSString *fileName = [[videoPath lastPathComponent] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
    NSString *thumbFilePath = [videoPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
    [thumbData writeToFile:thumbFilePath atomically:YES];
    
    NSString *httpUrl = [QIMKit updateLoadFile:thumbData WithMsgId:msgId WithMsgType:QIMMessageType_Image WihtPathExtension:@"jpg"];
    
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setQIMSafeObject:httpUrl forKey:@"ThumbUrl"];
    [dicInfo setQIMSafeObject:fileName forKey:@"ThumbName"];
    [dicInfo setQIMSafeObject:[videoPath lastPathComponent] forKey:@"FileName"];
    [dicInfo setQIMSafeObject:@(size.width) forKey:@"Width"];
    [dicInfo setQIMSafeObject:@(size.height) forKey:@"Height"];
    [dicInfo setQIMSafeObject:fileSizeStr forKey:@"FileSize"];
    [dicInfo setQIMSafeObject:@(duration) forKey:@"Duration"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
    
    Message *msg = [Message new];
    [msg setMessageId:msgId];
    [msg setMessageDirection:MessageDirection_Sent];
    [msg setChatType:self.chatType];
    [msg setMessageType:QIMMessageType_SmallVideo];
    [msg setMessageDate:([[NSDate date] timeIntervalSince1970] - [[QIMKit sharedInstance] getServerTimeDiff]) * 1000];
    [msg setFrom:[[QIMKit sharedInstance] getLastJid]];
    [msg setMessage:msgContent];
    
    NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
    if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setQIMSafeObject:@(QIMMessageType_SmallVideo) forKey:@"msgType"];
        [dicInfo setQIMSafeObject:msg.message forKey:@"descStr"];
        [dicInfo setQIMSafeObject:msg.message forKey:@"message"];
        NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
        msg.extendInformation = extendInformation;
        msg.message = @"此为阅后即焚消息，该终端不支持阅后即焚~~";
        msg.messageType = QIMMessageType_BurnAfterRead;
    }
    if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
        [msg setTo:self.virtualJid];
        [msg setRealJid:self.chatId];
    }
    else {
        [msg setTo:self.chatId];
        [[QIMKit sharedInstance] insertMessageWihtMsgId:msg.messageId WithXmppId:self.chatId WithFrom:msg.from WithTo:msg.to WithContent:msg.message WithExtendInfo:msg.extendInformation WithPlatform:msg.platform WithMsgType:msg.messageType WithMsgState:msg.messageState WithMsgDirection:msg.messageDirection WihtMsgDate:msg.messageDate WithReadedTag:0 WithMsgRaw:msg.msgRaw WithRealJid:msg.realJid WithChatType:msg.chatType];
    }
    if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
        [[QIMKit sharedInstance] updateMessageWithExtendInfo:msg.extendInformation ForMsgId:msg.messageId];
    }
    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    [[QIMKit sharedInstance] uploadFileForPath:videoPath forMessage:msg withJid:self.chatId isFile:YES];
}

- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType {
    if (msgType == QIMMessageType_LocalShare) {
        NSData *imageData = [[QIMKit sharedInstance] userObjectForKey:@"userLocationScreenshotImage"];
        Message *msg = nil;
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[QIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:QIMMessageType_LocalShare forMsgId:[QIMUUIDTools UUID] willSave:YES];
        } else {
            msg = [[QIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.chatId userType:self.chatType msgType:QIMMessageType_LocalShare forMsgId:_resendMsg.messageId];
        }
        [msg setOriginalMessage:[msg message]];
        [msg setOriginalExtendedInfo:[msg extendInformation]];
        
        [self.messageManager.dataSource addObject:msg];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [self addImageToImageList];
        [[QIMKit sharedInstance] uploadFileForData:imageData forMessage:msg withJid:self.chatId isFile:NO];
    } else {
        Message *msg = nil;
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[QIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:msgType forMsgId:_resendMsg.messageId willSave:YES];
        }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
        else if (self.encryptChatState == QIMEncryptChatStateEncrypting) {
            msg = [[QIMKit sharedInstance] sendMessage:message WithInfo:info ToUserId:self.chatId WihtMsgType:QIMMessageType_Encrypt];
        }
#endif
        else {
            msg = [[QIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.chatId userType:self.chatType msgType:msgType forMsgId:_resendMsg.messageId];
        }
        [self.messageManager.dataSource addObject:msg];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [self addImageToImageList];
        if (self.chatId) {
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
            }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
            else if (self.encryptChatState == QIMEncryptChatStateEncrypting) {
                
            }
#endif
            else {
                msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
            }
        }
    }
}

- (void)sendTyping {
    [[QIMKit sharedInstance] sendTypingToUserId:self.chatId];
}

- (void)sendNormalEmotion:(NSString *)faceStr WithPackageId:(NSString *)packageId {
    if (faceStr && packageId) {
        NSString *text = [NSString stringWithFormat:@"[obj type=\"%@\" value=\"%@\" width=%@ height=0 ]", @"emoticon",[NSString stringWithFormat:@"[%@]", faceStr], packageId];
        NSDictionary *normalEmotionExtendInfoDic = @{@"height": @(0), @"pkgid":packageId, @"shortcut":faceStr, @"url":@"", @"width": @(0)};
        NSString *normalEmotionExtendInfoStr = [[QIMJSONSerializer sharedInstance] serializeObject:normalEmotionExtendInfoDic];
        if ([text length] > 0) {
            Message *msg = nil;
            if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
                NSDictionary *dict = [[QIMKit sharedInstance] conversationParamWithJid:self.chatId];
                NSString *param = [dict objectForKey:@"urlappend"];
                NSMutableArray *paramDict = [[QIMJSONSerializer sharedInstance] deserializeObject:param error:nil];
                text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text WithFilterAppendArray:paramDict];
            } else {
                text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
            }
            if (self.textBar.isRefer) {
                text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n",self.title,self.textBar.referMsg.message] stringByAppendingString:text];
                self.textBar.isRefer = NO;
                self.textBar.referMsg = nil;
            }
            
            NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
            if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
                NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                [dicInfo setObject:@(QIMMessageType_Text) forKey:@"msgType"];
                [dicInfo setObject:text forKey:@"descStr"];
                [dicInfo setObject:text forKey:@"message"];
                NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
                if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                    msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:extendInformation userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:QIMMessageType_BurnAfterRead forMsgId:[QIMUUIDTools UUID] willSave:YES];
                }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
                else if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
                    NSString *content = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_Text WithOriginBody:@"此为阅后即焚消息，该终端不支持阅后即焚~~" WithOriginExtendInfo:extendInformation WithUserId:self.chatId];
                    msg = [[QIMKit sharedInstance] sendMessage:@"[加密文本消息阅后即焚iOS]" WithInfo:content ToUserId:self.chatId WihtMsgType:QIMMessageType_Encrypt];
                }
#endif
                else {
                    msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:extendInformation userId:self.chatId userType:self.chatType msgType:QIMMessageType_BurnAfterRead];
                }
                [self.messageManager.dataSource addObject:msg];
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                [_tableView endUpdates];
                [self scrollToBottomWithCheck:YES];
                [self addImageToImageList];
                if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                    msg = [[QIMKit sharedInstance] createMessageWithMsg:msg.message extenddInfo:msg.extendInformation userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:msg.messageType forMsgId:msg.messageId willSave:YES];
                }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
                else if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
                    
                }
#endif
                else {
                    msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                }
            } else {
                if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                    msg = [[QIMKit sharedInstance] createMessageWithMsg:text extenddInfo:normalEmotionExtendInfoStr userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:QIMMessageType_ImageNew forMsgId:[QIMUUIDTools UUID] willSave:YES];
                }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
                else if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
                    NSString *content = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_ImageNew WithOriginBody:text WithOriginExtendInfo:normalEmotionExtendInfoStr WithUserId:self.chatId];
                    msg = [[QIMKit sharedInstance] sendMessage:@"[加密表情消息iOS]" WithInfo:content ToUserId:self.chatId WihtMsgType:QIMMessageType_Encrypt];
                }
#endif
                else {
                    msg = [[QIMKit sharedInstance] createMessageWithMsg:text extenddInfo:normalEmotionExtendInfoStr userId:self.chatId userType:self.chatType msgType:QIMMessageType_ImageNew];
                }
                
                [self.messageManager.dataSource addObject:msg];
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                [_tableView endUpdates];
                [self scrollToBottomWithCheck:YES];
                [self addImageToImageList];
                if (self.chatId) {
                    if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                        msg = [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                    }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
                    else if (self.encryptChatState == QIMEncryptChatStateEncrypting) {
                        
                        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                            if (self.chatId) {
                                msg = [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                            }
                        } else if (self.encryptChatState == QIMEncryptChatStateEncrypting) {
                            
                        } else {
                            msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                        }
                    }
#endif
                    else {
                        msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                    }
                }
            }
        }
    }
}

- (void)sendQuickReplyContent:(NSNotification *)notify {
    NSString *text = notify.object;
    if (text.length > 0) {
        [self sendText:text];
    }
}

- (void)sendText:(NSString *)text {
    
    NSString *attributedText = [self.textBar getSendAttributedText];
    if (attributedText.length > 0) {
        text = attributedText;
    }
    
    if ([text length] > 0) {
        Message *msg = nil;
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
            NSDictionary *dict = [[QIMKit sharedInstance] conversationParamWithJid:self.chatId];
            NSString *param = [dict objectForKey:@"urlappend"];
            NSMutableArray *paramDict = [[QIMJSONSerializer sharedInstance] deserializeObject:param error:nil];
            text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text WithFilterAppendArray:paramDict];
        } else {
            text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
        }
        if (self.textBar.isRefer) {
            text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n",self.title,self.textBar.referMsg.message] stringByAppendingString:text];
            self.textBar.isRefer = NO;
            self.textBar.referMsg = nil;
        }
        
        NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
        if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
            NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
            [dicInfo setObject:@(QIMMessageType_Text) forKey:@"msgType"];
            [dicInfo setObject:text forKey:@"descStr"];
            [dicInfo setObject:text forKey:@"message"];
            NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:extendInformation userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:QIMMessageType_BurnAfterRead forMsgId:[QIMUUIDTools UUID] willSave:YES];
            }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
            else if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
                NSString *content = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_Text WithOriginBody:@"此为阅后即焚消息，该终端不支持阅后即焚~~" WithOriginExtendInfo:extendInformation WithUserId:self.chatId];
                msg = [[QIMKit sharedInstance] sendMessage:@"[加密文本消息阅后即焚iOS]" WithInfo:content ToUserId:self.chatId WihtMsgType:QIMMessageType_Encrypt];
            }
#endif
            else {
                msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:extendInformation userId:self.chatId userType:self.chatType msgType:QIMMessageType_BurnAfterRead];
            }
            [self.messageManager.dataSource addObject:msg];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                msg = [[QIMKit sharedInstance] createMessageWithMsg:msg.message extenddInfo:msg.extendInformation userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:msg.messageType forMsgId:msg.messageId willSave:YES];
            }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
            else if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
                
            }
#endif
            else {
                msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
            }
        } else {
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                msg = [[QIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:QIMMessageType_Text forMsgId:[QIMUUIDTools UUID] willSave:YES];
            }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
            else if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
                NSString *content = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_Text WithOriginBody:text WithOriginExtendInfo:nil WithUserId:self.chatId];
                msg = [[QIMKit sharedInstance] sendMessage:@"[加密文本消息iOS]" WithInfo:content ToUserId:self.chatId WihtMsgType:QIMMessageType_Encrypt];
            }
#endif
            else {
                msg = [[QIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.chatId userType:self.chatType msgType:QIMMessageType_Text];
            }
            
            [self.messageManager.dataSource addObject:msg];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
            if (self.chatId) {
                if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                    msg = [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
                else if (self.encryptChatState == QIMEncryptChatStateEncrypting) {
                    
                    if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                        if (self.chatId) {
                            msg = [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
                        }
                    } else if (self.encryptChatState == QIMEncryptChatStateEncrypting) {
                        
                    } else {
                        msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                    }
                }
#endif
                else {
                    msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                }
            }
        }
    }
}


- (void)emptyText:(NSString *)text {
    
}

- (void)willSendImageData:(NSData *)imageData {
    _willSendImageData = imageData;
}

- (void)sendFileData:(NSData *)fileData fileName:(NSString *)fileName {
    Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:self.chatId userType:ChatType_SingleChat msgType:QIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:fileName forKey:@"title"];
    [infoDic setQIMSafeObject:@"" forKey:@"desc"];
    [infoDic setQIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    msg.extendInformation = msgContent;
    
    [[QIMKit sharedInstance] uploadFileForData:fileData forMessage:msg withJid:self.chatId isFile:YES];
    
    
    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
}

- (void)sendImageData:(NSData *)imageData {
    if (imageData) {
        [self getStringFromAttributedString:imageData];
    }
}

- (void)sendimageText:(NSString *)text {
    
    if ([text length] > 0) {
        Message *msg = nil;
        if ([self.stype isEqualToString:kSessionType_Group]) {
            msg = [[QIMKit sharedInstance] sendMessage:text ToGroupId:self.chatId];
            [self addImageToImageList];
        } else {
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                msg = [[QIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.virtualJid realJid:self.chatId userType:self.chatId msgType:QIMMessageType_Text forMsgId:[QIMUUIDTools UUID] willSave:YES];
            } else {
                msg = [[QIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.chatId userType:self.chatType msgType:QIMMessageType_Text];
            }
            [self.messageManager.dataSource addObject:msg];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
            if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
                msg = [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
            } else {
                msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
            }
        }
    }
    
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

#pragma mark - Cell Delegate

- (void)openWebUrl:(NSString *)url {
    QIMWebView *webVC = [[QIMWebView alloc] init];
    [webVC setUrl:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)refreshTableViewCell:(UITableViewCell *)cell {
    if (cell && [cell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        if (indexPath) {
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)refreshCellForMsg:(Message *)msg {
    for (Message *message in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:[message messageId]]) {
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            [self.messageManager.dataSource replaceObjectAtIndex:index withObject:msg];
            [self addImageToImageList];
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}

- (void)processEvent:(int)event withMessage:(id)message {
    Message *eventMsg = (Message *)message;
    eventMsg.chatType = self.chatType;
    if (_tableView.editing) {
        [self cancelForwardHandle:nil];
    }
    if (event == MA_Repeater) {
        
        QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
        [controller setMessage:[QIMMessageParser reductionMessageForMessage:eventMsg]];
        [[self navigationController] presentViewController:nav animated:YES completion:^{
            
        }];
    } else if (event == MA_Delete) {
        for (Message *msg in self.messageManager.dataSource) {
            if ([msg.messageId isEqualToString:[(Message *) eventMsg messageId]]) {
                NSMutableArray *deleteIndexs = [NSMutableArray array];
                NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
                [deleteIndexs addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                Message *timeMsg = nil;
                if (index > 0) {
                    Message *tempMsg = [self.messageManager.dataSource objectAtIndex:index - 1];
                    if (tempMsg.messageType == QIMMessageType_Time) {
                        timeMsg = tempMsg;
                        if (index + 1 < self.messageManager.dataSource.count) {
                            Message *nMsg = [self.messageManager.dataSource objectAtIndex:index + 1];
                            if (nMsg.messageType != QIMMessageType_Time) {
                                timeMsg = nil;
                            }
                        }
                    }
                }
                if (timeMsg) {
                    [deleteIndexs addObject:[NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:timeMsg] inSection:0]];
                    [self.messageManager.dataSource removeObject:timeMsg];
                    [[QIMKit sharedInstance] deleteMsg:timeMsg ByJid:self.chatId];
                }
                
                [self.messageManager.dataSource removeObject:msg];
                [_tableView deleteRowsAtIndexPaths:deleteIndexs withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [[QIMKit sharedInstance] deleteMsg:msg ByJid:self.chatId];
                break;
            }
        }
        
    } else if (event == MA_ToWithdraw) {
        for (Message *msg in self.messageManager.dataSource) {
            if ([msg.messageId isEqualToString:[(Message *) eventMsg messageId]]) {
                NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
                [(Message *) eventMsg setMessageType:QIMMessageType_Revoke];
                [self.messageManager.dataSource replaceObjectAtIndex:index withObject:eventMsg];
                [[QIMKit sharedInstance] updateMsg:eventMsg ByJid:self.chatId];
                NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
                BOOL isVisable = [[_tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
                if (isVisable) {
                    [_tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                [dicInfo setObject:[[QIMKit sharedInstance] getLastJid] forKey:@"fromId"];
                [dicInfo setObject:[(Message *) eventMsg messageId] forKey:@"messageId"];
                [dicInfo setObject:[(Message *) eventMsg message] forKey:@"message"];
                NSString *msgInfo = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
                
                [[QIMKit sharedInstance] revokeMessageWithMessageId:[(Message *) eventMsg messageId] message:msgInfo ToJid:self.chatId];
                break;
            }
        }
    } else if (event == MA_Favorite) {
        
        for (Message *msg in self.messageManager.dataSource) {
            
            if ([msg.messageId isEqualToString:[(Message *) eventMsg messageId]]) {
                
                
                [[QIMMyFavoitesManager sharedMyFavoritesManager] setMyFavoritesArrayWithMsg:eventMsg];
                
                break;
            }
        }
    } else if (event == MA_Forward) {
        _tableView.editing = YES;
        [self.navigationController.navigationBar addSubview:[self getForwardNavView]];
        [self.navigationController.navigationBar addSubview:[self getMaskRightTitleView]];
        [self.view addSubview:self.forwardBtn];
    } else if (event == MA_Refer) {
        //引用消息
        self.textBar.isRefer = YES;
        self.textBar.referMsg = eventMsg;
    } else if (event == MA_CopyOriginMsg) {
        for (Message *msg in self.messageManager.dataSource) {
            if ([msg.messageId isEqualToString:[(Message *) eventMsg messageId]]) {
                QIMVerboseLog(@"原始消息为 : %@", msg);
                NSString *originMsg = [[QIMOriginMessageParser shareParserOriginMessage] getOriginPBMessageWithMsgId:msg.messageId];
                if (originMsg.length > 0) {
                    [[UIPasteboard generalPasteboard] setString:originMsg];
                }
                /*
                NSDictionary *originMsgDic = [[QIMOriginMessageParser shareParserOriginMessage] getOriginMessageWithMsgId:msg.messageId];
                NSString *originMsgStr = [[QIMJSONSerializer sharedInstance] serializeObject:originMsgDic];
                if (originMsgStr.length > 0) {
                    [[UIPasteboard generalPasteboard] setString:originMsgStr];
                } */
            }
        }
    }
}

static CGPoint tableOffsetPoint;

#pragma mark - QIMAttributedLabelDelegate

- (void)attributedLabel:(QIMAttributedLabel *)attributedLabel textStorageClicked:(id <QIMTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    //链接link
    if ([textStorage isMemberOfClass:[QIMLinkTextStorage class]]) {
        QIMLinkTextStorage *storage = (QIMLinkTextStorage *) textStorage;
        if (![storage.linkData length]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"页面有问题" message:@"输入的url有问题" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        } else {
            QIMWebView *webView = [[QIMWebView alloc] init];
            [webView setUrl:storage.linkData];
            [[self navigationController] pushViewController:webView animated:YES];
        }
    } else if ([textStorage isMemberOfClass:[QIMPhoneNumberTextStorage class]]) {
        QIMPhoneNumberTextStorage *storage = (QIMPhoneNumberTextStorage *) textStorage;
        if (storage.phoneNumData) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                
                [self presentViewController:[QIMContactManager showAlertViewControllerWithPhoneNum:storage.phoneNumData rootVc:self] animated:YES completion:nil];
            }
        }
    } else if ([textStorage isMemberOfClass:[QIMImageStorage class]]) {
        self.fixedImageArray = [NSMutableArray arrayWithCapacity:3];
        QIMImageStorage *storage = (QIMImageStorage *) textStorage;
        //图片
        if (storage.imageURL) {
            //纪录当前的浏览位置
            tableOffsetPoint = _tableView.contentOffset;
            
            //初始化图片浏览控件
            QIMMWPhotoBrowser *browser = [[QIMMWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = NO;
            browser.zoomPhotosToFill = YES;
            browser.enableSwipeToDismiss = NO;
            NSUInteger index = -1;
            for (NSUInteger i = 0; i < _imagesArr.count; i++) {
                
                if ([(QIMImageStorage *) _imagesArr[i] isEqual:storage]) {
                    index = i;
                    //                    browser.imageUrl = storage.imageURL;
                    break;
                }
            }
            if (index == -1 && storage.imageURL.absoluteString.length <= 0) {
                return;
            } else if (index == -1 && storage.imageURL.absoluteString.length > 0) {
                if (!self.fixedImageArray) {
                    self.fixedImageArray = [NSMutableArray arrayWithCapacity:2];
                }
                [self.fixedImageArray addObject:storage.imageURL];
                index = 0;
            } else {
 
            }
            [browser setCurrentPhotoIndex:index];
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            
            //初始化navigation
            QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
            return;
        } else {
            //表情
        }
    }
}

#pragma mark - QIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser {
    if (self.fixedImageArray.count > 0) {
        return self.fixedImageArray.count;
    }
    return _imagesArr.count;
}

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (self.fixedImageArray.count > 0) {
        NSString *imageUrl = [self.fixedImageArray[0] absoluteString];
        NSURL *url = [NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        return url ? [[QIMMWPhoto alloc] initWithURL:url] : nil;
    }
    NSArray *tempImageArr = _imagesArr;
    if (index > tempImageArr.count)
        return nil;
    
    NSString *imageHttpUrl;
    QIMImageStorage *storage = [tempImageArr objectAtIndex:index];
    imageHttpUrl = storage.imageURL.absoluteString;
    NSData *imageData = [[QIMKit sharedInstance] getFileDataFromUrl:imageHttpUrl forCacheType:QIMFileCacheTypeColoction needUpdate:NO];
    if (imageData.length) {
        QIMMWPhoto *photo = [[QIMMWPhoto alloc] initWithImage:[UIImage qim_animatedImageWithAnimatedGIFData:imageData]];
        photo.photoData = imageData;
        return photo;
//        return [[QIMMWPhoto alloc] initWithImage:[YLGIFImage imageWithData:imageData]];
    } else {
        NSURL *url = [NSURL URLWithString:[imageHttpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        return url ? [[QIMMWPhoto alloc] initWithURL:url] : nil;
    }
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
        [_tableView setContentOffset:tableOffsetPoint animated:YES];
        [self.fixedImageArray removeAllObjects];
    }];
}

#pragma mark - Action Method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[QIMTapGestureRecognizer class]]) {
        NSInteger index = gestureRecognizer.view.tag;
        CGPoint location = [touch locationInView:[gestureRecognizer.view viewWithTag:
                                                  kTextLabelTag]];
        QIMSingleChatCell *cell = (QIMSingleChatCell *) [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if ([cell respondsToSelector:@selector(indexForCellImagesAtLocation:)]) {
            NSInteger imageIndex = [cell indexForCellImagesAtLocation:location];
            if (imageIndex < 0) {
                return NO;
            } else {
                return YES;
            }
        }
    }
    if (_inputPopViewIsShow) {
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    CGPoint point = [touch locationInView:self.view];
    //当点击table空白处时，输入框自动回收
    if (!CGRectContainsPoint(self.textBar.frame, point)) {
        [self.textBar needFirstResponder:NO];
    }
    
    [QIMMenuImageView cancelHighlighted];
    return NO;
}

#pragma mark - UIScrollView的代理函数

- (void)QTalkMessageUpdateForwardBtnState:(BOOL)enable {
    self.forwardBtn.enabled = enable;
    QIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)QTalkMessageScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat h1 = _tableView.contentOffset.y + _tableView.frame.size.height;
    CGFloat h2 = _tableView.contentSize.height - 250;
    CGFloat tempOffY = (_tableView.contentSize.height - _tableView.frame.size.height);
    if ((h1 > h2) && tempOffY > 0) {
        [self hidePopView];
    }
}

- (void)loadMoreMessageData {
    self.loadCount += 1;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *userId = nil;
        NSString *realJid = nil;
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
        }
        if (self.chatType == ChatType_ConsultServer) {
            [[QIMKit sharedInstance] getConsultServerMsgLisByUserId:realJid WithVirtualId:userId WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
                if (list.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        CGFloat offsetY = _tableView.contentSize.height - _tableView.contentOffset.y;
                        NSRange range = NSMakeRange(0, [list count]);
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                        
                        [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                        [_tableView reloadData];
                        _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - offsetY);
                        //重新获取一次大图展示的数组
                        [weakSelf addImageToImageList];
                        [weakSelf.tableView.mj_header endRefreshing];
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                } else {
                    [weakSelf.tableView.mj_header endRefreshing];
                }
            }];
        } else {

            [[QIMKit sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WihtLimit:kPageCount WithOffset:(int) self.messageManager.dataSource.count WihtComplete:^(NSArray *list) {
                if (list.count > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        CGFloat offsetY = _tableView.contentSize.height - _tableView.contentOffset.y;
                        NSRange range = NSMakeRange(0, [list count]);
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                        
                        [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                        [_tableView reloadData];
                        _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - offsetY);
                        //重新获取一次大图展示的数组
                        [weakSelf addImageToImageList];
                        [weakSelf.tableView.mj_header endRefreshing];
                        //标记已读
                        [weakSelf markReadFlag];
                    });
                } else {
                    [weakSelf.tableView.mj_header endRefreshing];
                }
            }];
        }
    });
#if defined (QIMRNEnable) && QIMRNEnable == 1
    if (self.loadCount >= 3 && !self.reloadSearchRemindView) {
        NSString *userId = nil;
        NSString *realJid = nil;
        if (self.chatType == ChatType_Consult) {
            userId = self.virtualJid;
            realJid = self.virtualJid;
        } else if (self.chatType == ChatType_ConsultServer) {
            userId = self.virtualJid;
            realJid = self.chatId;
        } else {
            userId = self.chatId;
        }
        self.searchRemindView = [[QIMSearchRemindView alloc] initWithChatId:userId withRealJid:realJid withChatType:self.chatType];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToConverstaionSearch)];
        [self.searchRemindView addGestureRecognizer:tap];
        [self.view addSubview:self.searchRemindView];
    }
#endif
}

- (void)jumpToConverstaionSearch {
    NSString *userId = nil;
    NSString *realJid = nil;
    if (self.chatType == ChatType_Consult) {
        userId = self.virtualJid;
        realJid = self.virtualJid;
    } else if (self.chatType == ChatType_ConsultServer) {
        userId = self.virtualJid;
        realJid = self.chatId;
    } else {
        userId = self.chatId;
    }
    self.reloadSearchRemindView = YES;
    [self.searchRemindView removeFromSuperview];
    [[QIMFastEntrance sharedInstance] openLocalSearchWithXmppId:userId withRealJid:realJid withChatType:self.chatType];
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

- (void)updateForwardBtnState {
    self.forwardBtn.enabled = self.messageManager.forwardSelectedMsgs.count;
    QIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)refreshTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:_tableView
                                                 selector:@selector(reloadData)
                                                   object:nil];
        
        [_tableView performSelector:@selector(reloadData)
                         withObject:nil
                         afterDelay:DEFAULT_DELAY_TIMES];
    });
}

- (NSString *)getStringFromAttributedString:(NSData *)imageData {
    
    UIImage *image = [YLGIFImage imageWithData:imageData];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    __block Message *msg = nil;
    NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
    if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
        msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:nil userId:self.chatId userType:ChatType_SingleChat msgType:QIMMessageType_BurnAfterRead forMsgId:_resendMsg.messageId];
        
        NSString *fileName = [[QIMKit sharedInstance] uploadFileForData:imageData forMessage:msg withJid:self.chatId isFile:NO];
        NSString *fileUrl = @"";
        if ([fileName qim_hasPrefixHttpHeader]) {
            fileUrl = fileName;
        } else {
            fileUrl = [NSString stringWithFormat:@"%@/FileName=%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], fileName];
        }
        NSString *sdimageFileKey = [[SDImageCache sharedImageCache] defaultCachePathForKey:fileUrl];
        [imageData writeToFile:sdimageFileKey atomically:YES];
        NSString *msgText = nil;
        if ([fileName qim_hasPrefixHttpHeader]) {
            msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", fileName, width, height];
        } else {
            msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"FileName=%@\" width=%f height=%f]", fileName, width, height];
        }
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:@(QIMMessageType_Text) forKey:@"msgType"];
        [dicInfo setObject:msgText forKey:@"descStr"];
        [dicInfo setObject:msgText forKey:@"message"];
        NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
        
        msg.extendInformation = extendInformation;
        
    } else {
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[QIMKit sharedInstance] createMessageWithMsg:@"" extenddInfo:nil userId:self.virtualJid realJid:self.chatId userType:self.chatType msgType:QIMMessageType_Text forMsgId:nil willSave:YES];
        } else {
            QIMVerboseLog(@"普通图片消息");
            msg = [[QIMKit sharedInstance] createMessageWithMsg:@"" extenddInfo:nil userId:self.chatId userType:ChatType_SingleChat msgType:QIMMessageType_Text];
        }
        NSString *fileName = [[QIMKit sharedInstance] uploadFileForData:imageData forMessage:msg withJid:self.chatId isFile:NO];
        NSString *fileUrl = @"";
        if ([fileName qim_hasPrefixHttpHeader]) {
            fileUrl = fileName;
        } else {
            fileUrl = [NSString stringWithFormat:@"%@/FileName=%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], fileName];
        }
        NSString *sdimageFileKey = [[SDImageCache sharedImageCache] defaultCachePathForKey:fileUrl];
        [imageData writeToFile:sdimageFileKey atomically:YES];
        NSString *msgText = nil;
        if ([fileName qim_hasPrefixHttpHeader]) {
            msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", fileName, width, height];
        } else {
            msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"FileName=%@\" width=%f height=%f]", fileName, width, height];
        }
        
        msg.message = msgText;
    }
    if (!(self.chatType == ChatType_ConsultServer || self.chatType == ChatType_Consult)) {
        [[QIMKit sharedInstance] updateMsg:msg ByJid:self.chatId];
    }
    
    [self.messageManager.dataSource addObject:msg];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [self addImageToImageList];
    [self scrollToBottomWithCheck:YES];
    return nil;
}

- (NSString *)getStringFromAttributedSourceString:(NSString *)sourceStr {
    return [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:sourceStr];
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

#pragma mark -IMTextBarDelegate voice record operator about -add by dan.zheng 15/4/24

- (void)beginDoVoiceRecord {
    self.voiceRecordingView.hidden = NO;
    [self.voiceRecordingView beginDoRecord];
}

- (void)updateVoiceViewHeightInVCWithPower:(float)power {
    [self.voiceRecordingView doImageUpdateWithVoicePower:power];
}

- (void)voiceRecordWillFinishedIsTrue:(BOOL)isTrue andCancelByUser:(BOOL)isCancelByUser {
    [self.voiceRecordingView setHidden:YES];
    if (!isTrue && !isCancelByUser) {
        //录音时间太短，出错提示
        [self.voiceTimeRemindView setHidden:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hiddenQIMVoiceTimeRemindView) userInfo:nil repeats:NO];
        
    }
    [self.voiceRecordingView voiceMaybeCancelWithState:0];
}

- (void)hiddenQIMVoiceTimeRemindView {
    [self.voiceTimeRemindView setHidden:YES];
}

- (void)voiceMaybeCancelWithState:(BOOL)ifMaybeCancel {
    [self.voiceRecordingView voiceMaybeCancelWithState:ifMaybeCancel];
}


//将解压前的数据添加到本地数据源中，再将已提交到网络上的压缩后的数据的信息提交到服务器
- (void)sendVoiceUrl:(NSString *)voiceUrl WithDuration:(int)duration WithSmallData:(NSData *)amrData WithFileName:(NSString *)filename AndFilePath:(NSString *)filepath {
    //    if ([voiceUrl length] > 0) {
    voiceUrl = voiceUrl ? voiceUrl : @"";
    Message *msg = nil;
    NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
    if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:@(QIMMessageType_Voice) forKey:@"msgType"];
        [dicInfo setObject:@"这是一条语音消息" forKey:@"descStr"];
        [dicInfo setObject:[NSString stringWithFormat:@"{\"%@\":\"%@\", \"%@\":\"%@\", \"%@\":%@,\"%@\":\"%@\"}", @"HttpUrl", voiceUrl, @"FileName", filename, @"Seconds", [NSNumber numberWithInt:duration], @"filepath", filepath] forKey:@"message"];
        NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
        //        msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:extendInformation userId:self.chatId userType:self.chatType msgType:QIMMessageType_BurnAfterRead];
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:extendInformation userId:self.virtualJid realJid:self.chatId userType:self.chatId msgType:QIMMessageType_BurnAfterRead forMsgId:[QIMUUIDTools UUID] willSave:YES];
        } else {
            msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:extendInformation userId:self.chatId userType:self.chatType msgType:QIMMessageType_BurnAfterRead];
        }
        [self.messageManager.dataSource addObject:msg];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        [self addImageToImageList];
        if (self.chatType == ChatType_Consult || self.chatType == ChatType_ConsultServer) {
            msg = [[QIMKit sharedInstance] sendConsultMessageId:msg.messageId WithMessage:msg.message WithInfo:msg.extendInformation toJid:self.virtualJid realToJid:self.chatId WithChatType:self.chatType WithMsgType:msg.messageType];
        } else {
            msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
        }
    } else {
        NSString *origintMsg = [NSString stringWithFormat:@"{\"%@\":\"%@\", \"%@\":\"%@\", \"%@\":%@,\"%@\":\"%@\"}", @"HttpUrl", voiceUrl, @"FileName", filename, @"Seconds", [NSNumber numberWithInt:duration], @"filepath", filepath];
        
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
        if(self.encryptChatState == QIMEncryptChatStateEncrypting) {
            NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_Voice WithOriginBody:origintMsg WithOriginExtendInfo:nil WithUserId:self.chatId];
            [self sendMessage:@"iOS加密语音消息" WithInfo:encrypeMsg ForMsgType:QIMMessageType_Encrypt];
        } else {
#endif
            [self sendMessage:origintMsg WithInfo:nil ForMsgType:QIMMessageType_Voice];
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
        }
#endif
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kReSendMsgAlertViewTag) {
        if (buttonIndex == 1) {
            [self processEvent:MA_Delete withMessage:_resendMsg];
        } else if (buttonIndex == 2) {
            [self reSendMsg];
        } else {
        }
    } else if (alertView.tag == kForwardMsgAlertViewTag) {
        if (buttonIndex == 2) {
            if (!self.messageManager.forwardSelectedMsgs) {
                self.messageManager.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
            }
            NSArray *msgList = [self.messageManager.forwardSelectedMsgs.allObjects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [(Message *)obj1 messageDate] > [(Message *)obj2 messageDate];
            }];
            NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:[[QIMKit sharedInstance] getLastJid]];
            NSString *userName = [userInfoDic objectForKey:@"Name"];
            
            _jsonFilePath = [QIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@和%@的聊天记录", userName ? userName : [QIMKit getLastUserName], self.title]];
            _tableView.editing = NO;
            [_forwardNavTitleView removeFromSuperview];
            [_maskRightTitleView removeFromSuperview];
            [self.forwardBtn removeFromSuperview];
            
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            controller.delegate = self;
            __weak typeof(self) weakSelf = self;
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                [weakSelf cancelForwardHandle:nil];
            }];
            
        } else if (buttonIndex == 1) {
            NSArray *forwardIndexpaths = [_tableView.indexPathsForSelectedRows sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return obj1 > obj2;
            }];
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (NSIndexPath *indexPath in forwardIndexpaths) {
                [msgList addObject:[QIMMessageParser reductionMessageForMessage:[self.messageManager.dataSource objectAtIndex:indexPath.row]]];
            }
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            [controller setMessageList:msgList];
            __weak typeof(self) weakSelf = self;
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                [weakSelf cancelForwardHandle:nil];
            }];
        } else {
            
        }
    } else {
        if (buttonIndex == 1) {
            QIMChatBGImageSelectController *chatBGImageSelectVC = [[QIMChatBGImageSelectController alloc] initWithCurrentBGImage:self.chatBGImageView.image];
            chatBGImageSelectVC.userID = self.chatId;
            chatBGImageSelectVC.delegate = self;
            chatBGImageSelectVC.isFromChat = YES;
            [self.navigationController pushViewController:chatBGImageSelectVC animated:YES];
        }
    }
}

#pragma mark - QIMChatBGImageSelectControllerDelegate

- (void)ChatBGImageDidSelected:(QIMChatBGImageSelectController *)chatBGImageSelectVC {
    [self refreshChatBGImageView];
}

#pragma mark - QIMIMTextBarDelegate

- (void)textBarReferBtnDidClicked:(QIMTextBar *)textBar {
    
    if (_referMsgwindow == nil) {
        _referMsgwindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _referMsgwindow.backgroundColor = [UIColor clearColor];
        _referMsgwindow.windowLevel = UIWindowLevelAlert - 1;
        _referMsgwindow.rootViewController = [[UIViewController alloc] init];
    }
    _referMsgwindow.hidden = NO;
    
    UIScrollView * referMsgScrlView = [[UIScrollView alloc] initWithFrame:_referMsgwindow.rootViewController.view.bounds];
    referMsgScrlView.backgroundColor = [UIColor qim_colorWithHex:0x000000 alpha:0.5];
    [_referMsgwindow.rootViewController.view addSubview:referMsgScrlView];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 5;
    bgView.clipsToBounds = YES;
    [referMsgScrlView addSubview:bgView];
    
    QIMAttributedLabel * msgLabel = [[QIMAttributedLabel alloc] init];
    msgLabel.textContainer = [QIMMessageParser textContainerForMessage:textBar.referMsg fromCache:NO];
    msgLabel.textColor = [UIColor blackColor];
    [bgView addSubview:msgLabel];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(referViewTapHandlel:)];
    [referMsgScrlView addGestureRecognizer:tap];
    
    
    float originX = (referMsgScrlView.width - msgLabel.textContainer.textWidth - 40) / 2.0f;
    float originY = (referMsgScrlView.height - msgLabel.textContainer.textHeight - 40) / 2.0f;
    
    [msgLabel setFrameWithOrign:CGPointMake(20,20) Width:msgLabel.textContainer.textWidth];
    bgView.frame = CGRectMake(originX, originY, msgLabel.width + 40, msgLabel.height +  40);
    
    //    referMsgScrlView.contentSize = CGSizeMake(bgView,msgLabel.textContainer.textHeight);
}

- (void)referViewTapHandlel:(UITapGestureRecognizer *)tap {
    _referMsgwindow.hidden = YES;
    _referMsgwindow = nil;
}

- (void)browserMessage:(Message *)message {
    
    UIViewController *vc = nil;
    if (message.messageType == QIMMessageType_BurnAfterRead) {
        
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        message.messageType = (QIMMessageType) [[infoDic objectForKey:@"msgType"] integerValue];
        if (message.messageType == QIMMessageType_SmallVideo) {
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
            NSString *fileName = [infoDic objectForKey:@"FileName"];
            NSString *fileUrl = [infoDic objectForKey:@"FileUrl"];
            fileUrl = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", fileUrl];
            NSString *filePath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:fileName ? fileName : @""];
            vc = [[QIMVideoPlayerVC alloc] init];
            [(QIMVideoPlayerVC *) vc setVideoPath:filePath];
            [(QIMVideoPlayerVC *) vc setVideoUrl:fileUrl];
        } else {
            if (message.messageType == QIMMessageType_Image) {
                message.message = [infoDic objectForKey:@"descStr"];
            } else {
                message.message = [infoDic objectForKey:@"message"];
            }
            vc = [[QIMMessageBrowserVC alloc] init];
//            [(QIMMessageBrowserVC *) vc setTextCache:cache];
            [(QIMMessageBrowserVC *) vc setMessage:message];
            if (message.messageType == QIMMessageType_Voice) {
                [(QIMMessageBrowserVC *) vc setParentVC:self];
            }
        }
        QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:vc];
        [nc setNavigationBarHidden:YES];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    } else if (message.messageType == QIMMessageType_Text || message.messageType == QIMMessageType_Image || message.messageType == QIMMessageType_ImageNew) {
        vc = [[QIMPreviewMsgVC alloc] init];
        [(QIMPreviewMsgVC *) vc setMessage:message];
        QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:vc];
        [nc setNavigationBarHidden:YES];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    }
}

#pragma mark - QIMPushProductViewControllerDelegate

- (void)sendProductInfoStr:(NSString *)infoStr productDetailUrl:(NSString *)detlUrl {
    [self sendMessage:detlUrl WithInfo:infoStr ForMsgType:QIMMessageType_product];
}

#pragma mark - QIMRobotQuestionCellDelegate

- (void)sendRobotQuestionText:(NSNotification *)notify {
    NSDictionary *notifyDic = notify.object;
    NSString *msgText = [notifyDic objectForKey:@"msgText"];
    BOOL isSendToServer = [[notifyDic objectForKey:@"isSendToServer"] boolValue];
    NSString *userType = [notifyDic objectForKey:@"userType"];
    if (msgText.length > 0) {
        [self sendTextMessageForText:msgText isSendToServer:isSendToServer userType:userType];
    }
}

#pragma mark - QIMRobotAnswerCellLoadDelegate

- (void)refreshRobotQuestionMessageCell:(QIMMsgBaloonBaseCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)refreshRobotAnswerMessageCell:(QIMMsgBaloonBaseCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

- (void)reTeachRobot {
    NSString *attributedText = [self.textBar getSendAttributedText];
    if (attributedText.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请清空输入框之后再试" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        });
    } else {
        [self.textBar setText:@"教小拿 "];
    }
}

- (void)sendTextMessageForText:(NSString *)messageContent isSendToServer:(BOOL)isSendToServer userType:(NSString *)userType {
    [self sendText:messageContent];
}

@end
