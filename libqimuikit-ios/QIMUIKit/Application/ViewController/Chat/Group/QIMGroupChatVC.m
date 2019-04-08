//
//  QIMGroupChatVC.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/13.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMGroupChatVC.h"
#import "QIMUUIDTools.h"
#import "QIMIconInfo.h"
#import "QIMCommonFont.h"
#import "QIMEmotionManager.h"
#import "QIMDataController.h"
#import "QIMJSONSerializer.h"
#import "QIMSingleChatVoiceCell.h"
#import "QIMNavTitleView.h"
#import "QIMMessageTextAttachment.h"
#import "QIMContactSelectionViewController.h"
#import "QIMCollectionFaceManager.h"
#import "MBProgressHUD.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMRedMindView.h"
#import "QIMTapGestureRecognizer.h"
#import "QIMOriginMessageParser.h"

#import "QIMMenuImageView.h"

#import "QIMVoiceRecordingView.h"

#import "QIMVoiceTimeRemindView.h"

#import <AVFoundation/AVFoundation.h>

#import "QIMMessageRefreshHeader.h"

#import "QIMRemoteAudioPlayer.h"

#import "QIMGroupChatCell.h"

#import "QIMGroupCardVC.h"

#import "QIMDisplayImage.h"

#import "QIMPhotoBrowserNavController.h"

#import "QIMMessageBrowserVC.h"

//#import "NSAttributedString+Attributes.h"

#import "QIMChatBGImageSelectController.h"

#import "QIMVideoPlayerVC.h"

#import "QIMFileManagerViewController.h"

#import "QIMPreviewMsgVC.h"

#import "QIMEmotionSpirits.h"

#import "QIMFriendsSpaceViewController.h"

#import "QIMUserListVC.h"
#import "QIMWebView.h"

#import "QIMMsgBaloonBaseCell.h"
#import "QIMChatNotifyInfoCell.h"
#import "QIMCollectionEmotionEditorVC.h"
#import "QIMNewMessageTagCell.h"
#import "QIMNotReadMsgTipViews.h"
#import "QIMPushProductViewController.h"
#import "QIMRedPackageView.h"
#import "ShareLocationViewController.h"
#import "UserLocationViewController.h"
#import "QIMTextBar.h"
#import "QIMMyFavoitesManager.h"
#import "QIMPlayVoiceManager.h"
#import "QIMPNActionRichTextCell.h"
#import "QIMPNRichTextCell.h"
#import "QIMPublicNumberNoticeCell.h"
#import "QIMVoiceNoReadStateManager.h"
#import "QIMMessageParser.h"
#import "QIMAttributedLabel.h"
#import "QIMExtensibleProductCell.h"
#import "QIMMessageCellCache.h"
#import "YLGIFImage.h"
#import "QIMExportMsgManager.h"
#import "QIMContactSelectVC.h"
#import "QIMContactManager.h"
#import "QIMGroupCardVC.h"
#import "QIMNavBackBtn.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMMessageTableViewManager.h"
#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
    #import "QIMWebRTCMeetingClient.h"
#endif
#import "QIMAuthorizationManager.h"
#import "QIMSearchRemindView.h"
#define kPageCount 20

#define kReSendMsgAlertViewTag 10000
#define kForwardMsgAlertViewTag 10001

static NSMutableDictionary *__checkGroupMembersCardDic = nil;

@interface QIMGroupChatVC () <UIGestureRecognizerDelegate, QIMGroupChatCellDelegate, QIMSingleChatVoiceCellDelegate, QIMMWPhotoBrowserDelegate, QIMRemoteAudioPlayerDelegate, QIMMsgBaloonBaseCellDelegate, QIMChatBGImageSelectControllerDelegate, QIMUserListVCDelegate, QIMContactSelectionViewControllerDelegate, QIMPushProductViewControllerDelegate, UIActionSheetDelegate, UserLocationViewControllerDelegate, PNNoticeCellDelegate, QIMPNRichTextCellDelegate, QIMPNActionRichTextCellDelegate, QIMChatNotifyInfoCellDelegate, QIMTextBarDelegate, QIMNotReadMsgTipViewsDelegate, QIMPNRichTextCellDelegate, PlayVoiceManagerDelegate, UIViewControllerPreviewingDelegate, QTalkMessageTableScrollViewDelegate> {
    
    bool _isReloading;
    
    BOOL _isOnline;
    
    NSMutableDictionary *_cellSizeDic;
    
    float _currentDownloadProcess;
    
    UIButton *_AddToGroupBtn;
    
    CGRect _rootViewFrame;
    
    CGRect _tableViewFrame;
    
    BOOL _notIsFirstChangeTableViewFrame;
    
    BOOL _playStop;
    
    UIView *notificationView;
    
    UILabel *commentCountLabel;
    
    UIImageView *backImageView;
    
    QIMTapGestureRecognizer *_tap;
    
    NSMutableDictionary *_photos;
    NSMutableArray *_imagesArr;
    
    UIImageView *_chatBGImageView;
    
    NSMutableDictionary *_gUserNameColorDic;
    Message *_resendMsg;
    
    NSString *_replyMsgId;
    NSString *_replyUser;
    QIMTextBarExpandViewItemType _expandViewItemType;
    
    ShareLocationViewController *_shareLctVC;
    UIView *_joinShareLctView;
    NSString *_shareLctId;
    NSString *_shareFromId;
    
    QIMNotReadMsgTipViews *_readMsgTipView;
    QIMPlayVoiceManager *_playVoiceManager;
    
    dispatch_queue_t _update_members_headimg;
    NSMutableArray *_hasGetHeadImgUsers;
    
    UIView *_forwardNavTitleView;
    UIView *_maskRightTitleView;
    NSString *_jsonFilePath;
    
    UIWindow * _referMsgwindow;
}

@property(nonatomic, strong) QIMTextBar *textBar;

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) QIMVoiceRecordingView *voiceRecordingView;

@property(nonatomic, strong) UIView *atAllView;

@property(nonatomic, strong) QIMVoiceTimeRemindView *voiceTimeRemindView;

@property(nonatomic, strong) QIMAttributedLabel *atAllLabel;

@property(nonatomic, strong) QIMNavTitleView *titleView;

@property(nonatomic, strong) UILabel *descLabel;

@property(nonatomic, strong) UIButton *friendsterButton;

@property(nonatomic, strong) UIButton *addGroupMember;

@property(nonatomic, assign) NSInteger currentPlayVoiceIndex;

@property(nonatomic, copy) NSString *currentPlayVoiceMsgId;

@property(nonatomic, strong) NSIndexPath *currentPlayVoiceMsgIndexPath;

@property(nonatomic, assign) BOOL isNoReadVoice;

@property(nonatomic, strong) MBProgressHUD *progressHUD;

@property(nonatomic, strong) UIButton *forwardBtn;

@property(nonatomic, strong) QIMMessageTableViewManager *messageManager;

@property(nonatomic, strong) QIMRemoteAudioPlayer *remoteAudioPlayer;

@property(nonatomic, assign) NSInteger currentMsgIndexs;

@property(nonatomic, assign) NSInteger loadCount;

@property(nonatomic, assign) BOOL reloadSearchRemindView;

@property(nonatomic, strong) QIMSearchRemindView *searchRemindView;

@property(nonatomic, strong) NSMutableArray *fixedImageArray;

@end

@implementation QIMGroupChatVC

- (void)updateGroupMemberCards {
    if (__checkGroupMembersCardDic == nil) {
        __checkGroupMembersCardDic = [NSMutableDictionary dictionary];
    }
    double prepCheckTime = [[__checkGroupMembersCardDic objectForKey:self.chatId] longLongValue];
    double currentTime = [[NSDate date] timeIntervalSince1970];
    if (currentTime - prepCheckTime > 10 * 60) {
        
        [__checkGroupMembersCardDic setObject:@(currentTime) forKey:self.chatId];
        dispatch_async(
                       
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           
                           // 频度控制？
                           [[QIMKit sharedInstance] updateQChatGroupMembersCardForGroupId:self.chatId];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               [_tableView reloadData];
                           });
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

- (QIMTextBar *)textBar {
    
    if (!_textBar) {
        _textBar = [QIMTextBar sharedIMTextBarWithBounds:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) WithExpandViewType:QIMTextBarExpandViewTypeGroup];
        _textBar.associateTableView = self.tableView;
        [_textBar setDelegate:self];
        [_textBar setAllowSwitchBar:NO];
        [_textBar setAllowVoice:YES];
        [_textBar setAllowFace:YES];
        [_textBar setAllowMore:YES];
        [_textBar setChatId:self.chatId];
//        [_textBar needFirstResponder:NO];
//        [_textBar setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
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
        _tableView.mj_header = [QIMMessageRefreshHeader messsageHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewGroupMsgList)];
    }
    return _tableView;
}

- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
        _titleLabel.text = self.title;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _titleLabel;
}

- (QIMVoiceRecordingView *)voiceRecordingView {
    
    if (!_voiceRecordingView) {
        
        _voiceRecordingView = [[QIMVoiceRecordingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, 150, 150, 150)];
        [self.view addSubview:_voiceRecordingView];
        _voiceRecordingView.hidden = YES;
        _voiceRecordingView.userInteractionEnabled = NO;
        [self.view addSubview:_voiceRecordingView];
    }
    return _voiceRecordingView;
}

- (QIMVoiceTimeRemindView *)voiceTimeRemindView {
    
    if (!_voiceTimeRemindView) {
        
        _voiceTimeRemindView = [[QIMVoiceTimeRemindView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, 150, 150, 150)];
        _voiceTimeRemindView.hidden = YES;
        _voiceTimeRemindView.userInteractionEnabled = NO;
        [self.view addSubview:_voiceTimeRemindView];
    }
    return _voiceTimeRemindView;
}

- (UIView *)atAllView {
    
    if (!_atAllView) {
        
        _atAllView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
        [_atAllView setBackgroundColor:[UIColor qim_colorWithHex:0xc1c1c1 alpha:1]];
        [_atAllView setHidden:YES];
    }
    return _atAllView;
}

- (QIMAttributedLabel *)atAllLabel {
    
    if (!_atAllLabel) {
        
        _atAllLabel = [[QIMAttributedLabel alloc] initWithFrame:CGRectMake(10, 5, self.view.width - 10, 20)];
        [_atAllLabel setBackgroundColor:[UIColor clearColor]];
        _atAllLabel.numberOfLines = 1;
        _atAllLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _atAllLabel;
}

- (UILabel *)descLabel {
    
    if (!_descLabel) {
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 200, 12)];
        _descLabel.textColor = [UIColor blackColor];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.font = [UIFont systemFontOfSize:10];
        _descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _descLabel;
}

- (QIMNavTitleView *)titleView {
    
    if (!_titleView) {
        
        _titleView = [[QIMNavTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _titleView.autoresizesSubviews = YES;
        _titleView.backgroundColor = [UIColor clearColor];
    }
    return _titleView;
}

- (UIButton *)friendsterButton {
    
    if (!_friendsterButton) {
        
        _friendsterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 35, 35)];
        [_friendsterButton setImage:[UIImage imageNamed:@"contacts_add_moment"] forState:UIControlStateNormal];
        [_friendsterButton addTarget:self
                              action:@selector(gotoFriendter:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    return _friendsterButton;
}

- (UIButton *)addGroupMember {
    
    if (!_addGroupMember) {
        
        _addGroupMember = [[UIButton alloc] initWithFrame:CGRectMake(40, 2, 37, 37)];
        [_addGroupMember setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0e0" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
        [_addGroupMember setAccessibilityIdentifier:@"QIMGroupCard"];
        [_addGroupMember addTarget:self
                            action:@selector(addPersonToPgrup:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _addGroupMember;
}

- (QIMRemoteAudioPlayer *)remoteAudioPlayer {
    if (!_remoteAudioPlayer) {
        _remoteAudioPlayer = [[QIMRemoteAudioPlayer alloc] init];
        _remoteAudioPlayer.delegate = self;
    }
    return _remoteAudioPlayer;
}

- (void)setupNav {
    [self setBackBtn];
    NSDictionary *groupCardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.chatId];
    NSString *titleName = [groupCardDic objectForKey:@"Name"];
    NSString *topic = [groupCardDic objectForKey:@"Topic"];
    if (self.chatType == ChatType_CollectionChat) {
        NSDictionary *groupCardDic = [[QIMKit sharedInstance] getCollectionGroupCardByGroupId:self.chatId];
        if (groupCardDic) {
            NSString *groupName = [groupCardDic objectForKey:@"Name"];
            if (groupName) {
                titleName = groupName;
            } else {
                titleName = self.chatId;
            }
        }
    }
    if (titleName.length > 0) {
        self.title = titleName;
        self.titleLabel.text = titleName;
        [self.titleView addSubview:self.titleLabel];
    }
    if (topic.length > 0) {
        self.descLabel.text = topic;
        [self.titleView addSubview:self.descLabel];
        self.navigationItem.titleView = self.titleView;
    } else {
        
        [self.titleView addSubview:self.titleLabel];
        self.navigationItem.titleView = self.titleView;
    }
    if (self.chatType == ChatType_GroupChat) {
        UIView *rightBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        [rightBarView addSubview:self.addGroupMember];
        if (![[[QIMKit sharedInstance] userObjectForKey:kRightCardRemindNotification] boolValue]) {
            QIMRedMindView *redMindView = [[QIMRedMindView alloc] initWithBroView:self.addGroupMember withRemindNotificationName:kRightCardRemindNotification];
            [rightBarView addSubview:redMindView];
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarView];
    } else {
        
    }
}

- (void)initUI {
    
    self.view.backgroundColor = [UIColor qtalkChatBgColor];
  
    [[QIMEmotionSpirits sharedInstance] setTableView:_tableView];
    [self loadData];
//    if (self.chatType == ChatType_GroupChat) {
//        [self.view addSubview:self.textBar];
//    }
    [self refreshChatBGImageView];
    
//    添加整个view的点击事件，当点击页面空白地方时，输入框收回
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    gesture.delegate = self;
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:gesture];
    
    [self.view addSubview:self.atAllView];
    [self.atAllView addSubview:self.atAllLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAtAll)];
    [self.atAllView addGestureRecognizer:tap];
    
    [self updateAtAllView];
    _shareLctId = [[QIMKit sharedInstance] getShareLocationIdByJid:self.chatId];
    if (_shareLctId.length > 0 && [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count > 0) {
        
        _shareFromId = [[QIMKit sharedInstance] getShareLocationFromIdByShareLocationId:_shareLctId];
        [self initJoinShareView];
    }
    if (self.needShowNewMsgTagCell) {
        
        //未读消息按钮
        _readMsgTipView = [[QIMNotReadMsgTipViews alloc] initWithNotReadCount:self.notReadCount];
        [_readMsgTipView setFrame:CGRectMake(self.view.width, 10, _readMsgTipView.width, _readMsgTipView.height)];
        [_readMsgTipView setNotReadMsgDelegate:self];
        [self.view addSubview:_readMsgTipView];
        [UIView animateWithDuration:0.3 animations:^{
            [UIView setAnimationDelay:0.1];
            [_readMsgTipView setFrame:CGRectMake(self.view.width - _readMsgTipView.width, _readMsgTipView.top, _readMsgTipView.width, _readMsgTipView.height)];
        }];
    }
    [self.textBar performSelector:@selector(keyBoardDown) withObject:nil afterDelay:0.5];
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    [self.textBar keyBoardDown];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.textBar keyBoardDown];
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
        _maskRightTitleView = [[UIView alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.bounds.size.width - 100, 0, 100, self.navigationController.navigationBar.bounds.size.height)];
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

- (QIMMessageTableViewManager *)messageManager {
    if (!_messageManager) {
        _messageManager = [[QIMMessageTableViewManager alloc] initWithChatId:self.chatId ChatType:self.chatType OwnerVc:self];
        _messageManager.delegate = self;
    }
    return _messageManager;
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
            _jsonFilePath = [QIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@的聊天记录", self.title]];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadCount = 0;
    if (self.bindId) {
        self.chatType = ChatType_CollectionChat;
    } else {
        self.chatType = ChatType_GroupChat;
    }
    [self setupNav];
    [self initNotifications];
    [[QIMKit sharedInstance] setUserObject:@"OFF" forKey:@"burnAfterReadingStatus"];
    _playVoiceManager = [QIMPlayVoiceManager defaultPlayVoiceManager];
    _playVoiceManager.playVoiceManagerDelegate = self;
    _playVoiceManager.chatId = self.chatId;
    _photos = [[NSMutableDictionary alloc] init];
    _rootViewFrame = self.view.frame;
    _cellSizeDic = [NSMutableDictionary dictionary];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) { // 检查群成员名片变更
        
        [self updateGroupMemberCards];
    }
    [self initUI];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self synchronizeChatSession];
    });
}

- (void)synchronizeChatSession {
    [[QIMKit sharedInstance] synchronizeChatSessionWithUserId:self.chatId WithChatType:self.chatType WithRealJid:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[QIMKit sharedInstance] setCurrentSessionUserId:self.chatId];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.chatType == ChatType_GroupChat) {
        [self.view addSubview:self.textBar];
    }
//    [self initUI];
    /*
    if (self.chatType == ChatType_GroupChat) {
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
    
    if (_shareLctId && [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:_shareLctId].count == 0) {
        
        [_joinShareLctView removeFromSuperview];
        _joinShareLctView = nil;
    }
    
    [self.remoteAudioPlayer stop];
    _currentPlayVoiceMsgId = nil;
    
    for (int i = 0; i < (int) self.messageManager.dataSource.count - kPageCount * 2; i++) {
        
        [[QIMMessageCellCache sharedInstance] removeObjectForKey:[(Message *) self.messageManager.dataSource[i] messageId]];
    }
}

- (void)updateGroupUsersHeadImgForMsgs:(NSArray *)msgs {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (_hasGetHeadImgUsers == nil) {
            _hasGetHeadImgUsers = [NSMutableArray arrayWithCapacity:1];
        }
        for (Message *msg in msgs) {
            if (msg.nickName == nil || [_hasGetHeadImgUsers containsObject:msg.nickName] || msg.messageType == QIMMessageType_Time || msg.messageType == QIMMessageType_GroupNotify || msg.messageType == QIMMessageType_Revoke || msg.messageType == QIMMessageType_AAInfo || msg.messageType == QIMMessageType_RedPackInfo) {
                continue;
            } else {
                [_hasGetHeadImgUsers addObject:msg.nickName];
                /*
                if (![[QIMKit sharedInstance] isExistUserHeaderImageByUserId:msg.nickName WithImageSize:CGSizeMake(90, 90)]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        [[QIMKit sharedInstance] updateUserHeaderImageWithXmppId:msg.nickName];
                    });
                }
                 */
                /*
                NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByName:msg.nickName];
                if (infoDic.count > 0) {
                    NSString *xmppId = [infoDic objectForKey:@"XmppId"];
                    if (![[QIMKit sharedInstance] isExistUserHeaderImageByUserId:xmppId WithImageSize:CGSizeMake(90, 90)]) {
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            [[QIMKit sharedInstance] updateUserHeaderImageWithXmppId:xmppId];
                        });
                    }
                } */
            }
        }
    });
    
}

- (void)initNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(expandViewItemHandleNotificationHandle:)
                                                 name:kExpandViewItemHandleNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popFromFriendsSpaceVC)
                                                 name:FriendsSpacePopVc
                                               object:nil];
    
    //键盘弹出，消息自动滑动最底
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillShow:)
                                                 name:kQIMTextBarIsFirstResponder
                                               object:nil];
    
    //消息发送成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(msgDidSendNotificationHandle:)
                                                 name:kXmppStreamDidSendMessage
                                               object:nil];
    
    //消息发送失败
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(msgSendFailedNotificationHandle:)
                                                 name:kXmppStreamSendMessageFailed
                                               object:nil];
    //重发消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(msgReSendNotificationHandle:)
                                                 name:kXmppStreamReSendMessage
                                               object:nil];
    
    //阅后即焚消息销毁
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(beginShareLocationMsg:)
                                                 name:kBeginShareLocation
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endShareLocationMsg:)
                                                 name:kEndShareLocation
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(BurnAfterReadMsgDestructionNotificationHandle:)
                                                 name:kBurnAfterReadMsgDestruction
                                               object:nil];
    
    //消息被撤回
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(revokeMsgNotificationHandle:)
                                                 name:kRevokeMsg
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFileFinished:)
                                                 name:KDownloadFileFinishedNotificationName
                                               object:nil];
    
    //发送收藏表情图片
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(collectionEmotionNotificationHandle:)
                                                 name:kCollectionEmotionHandleNotification
                                               object:nil];
    
    //发送失效的收藏表情图片
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(collectionEmotionNotFoundNotificationHandle:)
                                                 name:kCollectionEmotionNotFoundHandleNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(WillSendRedPackNotificationHandle:)
                                                 name:WillSendRedPackNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMessageList:)
                                                 name:kNotificationMessageUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionMessageList:) name:kNotificationCollectionMessageUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateHistoryMessageList:)
                                                 name:kNotificationOfflineMessageUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableView)
                                                 name:@"refreshTableView"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGroupNickName:)
                                                 name:kGroupNickNameChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChatRoomDestroy:)
                                                 name:kChatRoomDestroy
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFileDidUpload:)
                                                 name:kNotificationFileDidUpload
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionImageDidLoad:) name:kNotificationEmotionImageDidLoad object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceFailed:) name:kCollectionEmotionUpdateHandleFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectEmojiFaceSuccess:) name:kCollectionEmotionUpdateHandleSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceReloadGroupMessages:) name:kGroupChatMsgReloadNotification object:nil];
    
    //发送快捷回复
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendQuickReplyContent:) name:kNotificationSendQuickReplyContent object:nil];
}

- (void)forceReloadGroupMessages:(NSNotification *)notify {
    long long currentMaxGroupTime = [[QIMKit sharedInstance] getMaxMsgTimeStampByXmppId:self.chatId];
    Message *msg = [self.messageManager.dataSource lastObject];
    long long currentGroupTime = msg.messageDate;
    if (currentGroupTime < currentMaxGroupTime) {
        QIMVerboseLog(@"重新Reload 群组聊天会话框");
        [self setProgressHUDDetailsLabelText:@"重新加载消息中..."];
        [self loadData];
        [self closeHUD];
        QIMVerboseLog(@"重新Reload 群组聊天会话框结束");
    }
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

- (void)collectEmojiFaceSuccess:(NSNotification *)notify {
    
    [self setProgressHUDDetailsLabelText:@"添加成功"];
    [self closeHUD];
}

- (void)collectEmojiFaceFailed:(NSNotification *)notify {
    [self setProgressHUDDetailsLabelText:@"收藏表情失败"];
    [self closeHUD];
}

- (void)keyBoardWillShow:(NSNotification *)notify {
    
    [self scrollToBottom_tableView];
}

- (void)popFromFriendsSpaceVC {
    
    [self initUI];
    self.textBar.hidden = NO;
}

- (void)onChatRoomDestroy:(NSNotification *)notify {
    id obj = [notify object];
    if([obj isKindOfClass:[NSString class]]){
        if ([self.chatId isEqualToString:obj]) {
            [self goBack:nil];
        }
    } else {
        // 目前只有上边两种可能
    }
}

- (void)initJoinShareView {
    
    if (_joinShareLctView == nil) {
        
        _joinShareLctView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _joinShareLctView.backgroundColor = [UIColor qim_colorWithHex:0x808e94 alpha:0.85];
        [self.view addSubview:_joinShareLctView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onJoinShareViewClick)];
        [_joinShareLctView addGestureRecognizer:tap];
        
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:_shareFromId];
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, _joinShareLctView.width - 100, _joinShareLctView.height)];
        [tipsLabel setTextAlignment:NSTextAlignmentCenter];
        [tipsLabel setFont:[UIFont systemFontOfSize:14]];
        tipsLabel.textColor = [UIColor whiteColor];
        [tipsLabel setText:[NSString stringWithFormat:@"%@正在共享位置", [userInfo objectForKey:@"Name"]]];
        [_joinShareLctView addSubview:tipsLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
        [arrowImageView setFrame:CGRectMake(_joinShareLctView.right - 40, (_joinShareLctView.height - arrowImageView.width) / 2.0, arrowImageView.width, arrowImageView.height)];
        [_joinShareLctView addSubview:arrowImageView];
        
        [self.view addSubview:_joinShareLctView];
    }
}

- (void)cancelAtAll {
    
    [[QIMKit sharedInstance] removeAtAllByJid:self.chatId];
    [_atAllView setHidden:YES];
}

- (void)updateAtAllView {
    
    NSDictionary *atAllMsgDic = [[QIMKit sharedInstance] getAtAllInfoByJid:self.chatId];
    if (atAllMsgDic) {
        
        [_atAllView setHidden:NO];
        NSString *nickName = [atAllMsgDic objectForKey:@"NickName"];
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:nickName];
        if (userInfo.count) {
            nickName = [userInfo objectForKey:@"Name"];
        }
        Message *msg = [atAllMsgDic objectForKey:@"Msg"];
        QIMTextContainer *container = [QIMMessageParser textContainerForMessage:msg];
        
        [self.atAllLabel removeFromSuperview];
        self.atAllLabel = nil;
        [self.atAllView addSubview:self.atAllLabel];
        
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        [ps setAlignment:NSTextAlignmentLeft];
        NSDictionary *titleDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor qim_colorWithHex:0xff0000 alpha:1], NSForegroundColorAttributeName, ps, NSParagraphStyleAttributeName, [UIFont systemFontOfSize:17], NSFontAttributeName, nil];
        
        [self.atAllLabel appendTextAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"@全体成员 %@:", nickName] attributes:titleDic]];
        if (msg.messageType == QIMMessageType_Text || msg.messageType == QIMMessageType_Image) {
            for (id <QCAppendTextStorageProtocol> storage in container.textStorages) {
                if ([storage isMemberOfClass:[QIMImageStorage class]]) {
                    if ([(QIMImageStorage *) storage image]) {
                        [self.atAllLabel appendImage:[(QIMImageStorage *) storage image] size:CGSizeMake(self.atAllLabel.height, self.atAllLabel.height)];
                    } else {
                        [self.atAllLabel appendTextAttributedString:[[NSAttributedString alloc] initWithString:@"【图片】" attributes:titleDic]];
                    }
                } else if ([storage isMemberOfClass:[QIMLinkTextStorage class]]) {
                    [self.atAllLabel appendLinkWithText:[(QIMLinkTextStorage *) storage linkData] linkFont:[UIFont fontWithName:@"FZLTHJW--GB1-0" size:([[QIMCommonFont sharedInstance] currentFontSize] - 2)] linkData:[(QIMLinkTextStorage *) storage linkData]];
                } else if ([storage isMemberOfClass:[QIMTextStorage class]]) {
                    [self.atAllLabel appendTextAttributedString:[[NSAttributedString alloc] initWithString:[(QIMTextStorage *) storage text] attributes:titleDic]];
                } else {
                    [self.atAllLabel appendText:@""];
                }
            }
        } else {
            [self.atAllLabel appendText:[[QIMKit sharedInstance] getMsgShowTextForMessageType:msg.messageType]];
        }
    }
}

- (void)updateGroupNickName:(NSNotification *)notify {
    
    NSArray *groupIds = notify.object;
    if ([groupIds isKindOfClass:[NSArray class]] && [groupIds containsObject:self.chatId]) {
        
        NSDictionary *cardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.chatId];
        [self setTitle:[cardDic objectForKey:@"Name"]];
        [self.navigationItem setTitle:self.title];
        [self.titleLabel setText:self.title];
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
        [self updateGroupUsersHeadImgForMsgs:@[msg]];
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
    [[QIMKit sharedInstance] getMsgListByUserId:self.chatId
                                        FromTimeStamp:_readedMsgTimeStamp
                                         WihtComplete:^(NSArray *list) {
                                             [self updateGroupUsersHeadImgForMsgs:list];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 self.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
                                                 [weakSelf checkAddNewMsgTag];
                                                 [self.tableView reloadData];
                                                 [self hiddenNotReadTipView];
                                                 [self addImageToImageList];
                                                 if (self.messageManager.dataSource.count > 0) {
                                                     
                                                     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(0) inSection:0]
                                                                           atScrollPosition:UITableViewScrollPositionBottom
                                                                                   animated:YES];
                                                 }
                                             });
                                         }];
}

- (void)reloadTableData {
    
    if (self.chatType == ChatType_CollectionChat) {
        NSArray *list = [[QIMKit sharedInstance] getCollectionMsgListForUserId:self.bindId originUserId:self.chatId];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
            BOOL editing = self.tableView.editing;
            [self.tableView reloadData];
            self.tableView.editing = editing;
            [self scrollToBottom_tableView];
            [self addImageToImageList];
            [[QIMEmotionSpirits sharedInstance] setDataCount:(int) self.messageManager.dataSource.count];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (self.fastMsgTimeStamp > 0) {
                [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:nil FromTimeStamp:self.fastMsgTimeStamp WihtComplete:^(NSArray *list) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
                        //标记已读
                        [self markReadedForChatRoom];
                        BOOL editing = self.tableView.editing;
                        [self.tableView reloadData];
                        self.tableView.editing = editing;
//                        [self scrollBottom];
                        [self addImageToImageList];
                        [[QIMEmotionSpirits sharedInstance] setDataCount:(int) self.messageManager.dataSource.count];
                    });
                }];
            } else {
                [[QIMKit sharedInstance] getMsgListByUserId:self.chatId
                                                WithRealJid:nil
                                                  WihtLimit:kPageCount
                                                 WithOffset:0
                                               WihtComplete:^(NSArray *list) {
                                                   //                                                     [self updateGroupUsersHeadImgForMsgs:list];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       self.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
                                                       //标记已读
                                                       [self markReadedForChatRoom];
                                                       BOOL editing = self.tableView.editing;
                                                       [self.tableView reloadData];
                                                       self.tableView.editing = editing;
                                                       [self scrollBottom];
                                                       [self addImageToImageList];
                                                       [[QIMEmotionSpirits sharedInstance] setDataCount:(int) self.messageManager.dataSource.count];
                                                   });
                                               }];
            }
        });
    }
}

- (void)loadData {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(reloadTableData)
                                               object:nil];
    [self performSelector:@selector(reloadTableData) withObject:nil afterDelay:0.05];
}

- (void)markReadedForChatRoom {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        if (self.messageManager.dataSource.count > 0) {
            
            [[QIMKit sharedInstance] sendReadstateWithGroupLastMessageTime:[(Message *) self.messageManager.dataSource.lastObject messageDate] withGroupId:self.chatId];
        }
    });
}

- (void)leftBarBtnClicked:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    QIMVerboseLog(@"didReceiveMemoryWarning");
}

- (void)selfPopedViewController {
    
    [super selfPopedViewController];
    [[QIMKit sharedInstance] setNotSendText:[self.textBar getSendAttributedText]
                                 inputItems:[self.textBar getAttributedTextItems]
                                     ForJid:self.chatId];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
}

- (void)goBack:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)onFileDidUpload:(NSNotification *)notify {
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
                    msg = [[QIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_Text];
                    [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                    
                    [self.messageManager.dataSource addObject:msg];
                    [self updateGroupUsersHeadImgForMsgs:@[msg]];
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                    [self.tableView endUpdates];
                    [self scrollToBottomWithCheck:YES];
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
                                msg = [[QIMKit sharedInstance] createMessageWithMsg:msgText extenddInfo:nil userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_Text];
                                [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
                                
                                [self.messageManager.dataSource addObject:msg];
                                [self updateGroupUsersHeadImgForMsgs:@[msg]];
                                [self.tableView beginUpdates];
                                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                                [self.tableView endUpdates];
                                [self scrollToBottomWithCheck:YES];
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
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_VideoCall]) {
#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
        [[QIMWebRTCMeetingClient sharedInstance] setGroupId:self.chatId];
        NSDictionary *groupCardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.chatId];
        NSString *groupName = [groupCardDic objectForKey:@"Name"];
        [[QIMWebRTCMeetingClient sharedInstance] createRoomById:self.chatId WithRoomName:groupName];
#endif
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_MyFiles]) {
        
        QIMFileManagerViewController *fileManagerVC = [[QIMFileManagerViewController alloc] init];
        fileManagerVC.isSelect = YES;
        fileManagerVC.userId = self.chatId;
        fileManagerVC.messageSaveType = ChatType_GroupChat;
        
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:fileManagerVC];
        
        [self presentViewController:nav animated:YES completion:nil];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_ShareCard]) {
        
        //分享名片
        QIMUserListVC *listVC = [[QIMUserListVC alloc] init];
        [listVC setDelegate:self];
        listVC.isTransfer = YES;
        _expandViewItemType = QIMTextBarExpandViewItemType_ShareCard;
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:listVC];
        [[self navigationController] presentViewController:nav animated:YES completion:^{
        }];
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_RedPack]) {
        
        QIMVerboseLog(@"我是 群红包，点我 干哈？");
        if ([[QIMKit sharedInstance] redPackageUrlHost]) {
            QIMWebView *webView = [[QIMWebView alloc] init];
            webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&group_id=%@&rk=%@&q_d=%@", [[QIMKit sharedInstance] redPackageUrlHost], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey],  [[QIMKit sharedInstance] getDomain]];
            //        webView.navBarHidden = YES;
            [webView setFromRegPackage:YES];
            [self.navigationController pushViewController:webView animated:YES];
        } else {
            QIMVerboseLog(@"当前红包URLHost为空，不支持该功能");
        }
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_AACollection]) {
        
        if ([[QIMKit sharedInstance] aaCollectionUrlHost]) {
            QIMWebView *webView = [[QIMWebView alloc] init];
            webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&group_id=%@&rk=%@&q_d=%@", [[QIMKit sharedInstance] aaCollectionUrlHost], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey],  [[QIMKit sharedInstance] getDomain]];
            webView.navBarHidden = YES;
            [webView setFromRegPackage:YES];
            [self.navigationController pushViewController:webView animated:YES];
        } else {
            QIMVerboseLog(@"当前AA收款URLHost为空，不支持该功能");
        }
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_SendActivity]) {
        if ([[QIMKit sharedInstance] redPackageUrlHost]) {
            //发活动
            QIMWebView *webView = [[QIMWebView alloc] init];
            webView.url = [NSString stringWithFormat:@"%@?username=%@&sign=%@&company=qunar&group_id=%@&rk=%@&action="@"event", [[QIMKit sharedInstance] redPackageUrlHost], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey]];
            [webView setFromRegPackage:YES];
            webView.navBarHidden = YES;
            [self.navigationController pushViewController:webView animated:YES];
        } else {
            QIMVerboseLog(@"当前发活动URLHost为空，不支持该功能");
        }
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
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_TouPiao]) {
        NSDictionary *trdExtendDic = [[QIMKit sharedInstance] getExpandItemsForTrdextendId:trId];
        NSString *linkUrl = [trdExtendDic objectForKey:@"linkurl"];
        if (linkUrl.length > 0) {
            if ([linkUrl rangeOfString:@"qunar.com"].location != NSNotFound) {
                linkUrl = [linkUrl stringByAppendingFormat:@"%@username=%@&company=qunar&group_id=%@&rk=%@", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [QIMKit getLastUserName], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] remoteKey]];
            } else {
                linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&chatType=%lld", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [[QIMKit sharedInstance] getLastJid],  [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.chatType];
            }
            [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
        }
    } else if ([trId isEqualToString:QIMTextBarExpandViewItem_Task_list]) {
        NSDictionary *trdExtendDic = [[QIMKit sharedInstance] getExpandItemsForTrdextendId:trId];
        NSString *linkUrl = [trdExtendDic objectForKey:@"linkurl"];
        if (linkUrl.length > 0) {
            if ([linkUrl rangeOfString:@"qunar.com"].location != NSNotFound) {
                linkUrl = [linkUrl stringByAppendingFormat:@"%@username=%@&company=qunar&group_id=%@&rk=%@", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [QIMKit getLastUserName], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] remoteKey]];
            } else {
                linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&chatType=%lld", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [[QIMKit sharedInstance] getLastJid], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.chatType];
            }
            [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
        }
    } else {
        NSDictionary *trdExtendDic = [[QIMKit sharedInstance] getExpandItemsForTrdextendId:trId];
        int linkType = [[trdExtendDic objectForKey:@"linkType"] intValue];
        BOOL openQIMRN = linkType & 4;
        BOOL openRequeset = linkType & 2;
        BOOL openWebView = linkType & 1;
        NSString *linkUrl = [trdExtendDic objectForKey:@"linkurl"];
        if (openQIMRN) {
            [QIMFastEntrance openQIMRNWithScheme:linkUrl withChatId:self.chatId withRealJid:nil withChatType:self.chatType];
        } else if (openRequeset) {
            [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:linkUrl withChatId:self.chatId withRealJid:nil withChatType:self.chatType];
        } else {
            if (linkUrl.length > 0) {
                if ([linkUrl rangeOfString:@"qunar.com"].location != NSNotFound) {
                    linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&chatType=%lld", [linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?", [[QIMKit sharedInstance] getLastJid], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.chatType];
                } else {
                    linkUrl = [linkUrl stringByAppendingFormat:@"%@from=%@&to=%@&chatType=%lld", ([linkUrl rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?"), [[QIMKit sharedInstance] getLastJid], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.chatType];
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
        //找到对应的msg
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
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [[QIMKit sharedInstance] deleteMsg:message ByJid:self.chatId];
            break;
        }
    }
}

- (void)reSendMsg {
    Message *message = _resendMsg;
    [self removeFailedMsg];
    if (message.messageType == QIMMessageType_LocalShare) {
        [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:message.messageType];
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
            
            message = [[QIMKit sharedInstance] createMessageWithMsg:message.message extenddInfo:message.extendInformation userId:self.chatId userType:ChatType_GroupChat msgType:message.messageType forMsgId:_resendMsg.messageId];
            
            [self.messageManager.dataSource addObject:message];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            message = [[QIMKit sharedInstance] sendMessage:message ToUserId:self.chatId];
            [self scrollToBottomWithCheck:YES];
        }
    } else if (message.messageType == QIMMessageType_CardShare) {
        [self sendMessage:message.message WithInfo:message.extendInformation ForMsgType:message.messageType];
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
    
    for (Message *msg in self.messageManager.dataSource) {
        
        if ([msg.messageId isEqualToString:message.messageId]) {
            
            [self.messageManager.dataSource replaceObjectAtIndex:[self.messageManager.dataSource indexOfObject:msg]
                                                      withObject:message];
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[self.tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [self.tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}

- (void)revokeMsgNotificationHandle:(NSNotification *)notify {
    
    NSString *jid = notify.object;
    NSString *msgID = [notify.userInfo objectForKey:@"MsgId"];
    NSString *content = [notify.userInfo objectForKey:@"Content"];
    for (Message *msg in self.messageManager.dataSource) {
        
        if ([msg.messageId isEqualToString:msgID]) {
            
            NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
            [(Message *) msg setMessageType:QIMMessageType_Revoke];
            [self.messageManager.dataSource replaceObjectAtIndex:index withObject:msg];
            [[QIMKit sharedInstance] updateMsg:msg ByJid:self.chatId];
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[self.tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [self.tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}

- (void)WillSendRedPackNotificationHandle:(NSNotification *)noti {
    NSString *infoStr = [NSString qim_stringWithBase64EncodedString:noti.object];
    Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"【红包】请升级最新版本客户端查看红包~"
                                                           extenddInfo:infoStr
                                                                userId:self.chatId
                                                              userType:ChatType_GroupChat
                                                               msgType:QIMMessageType_RedPack];
    
    [self.messageManager.dataSource addObject:msg];
    [self updateGroupUsersHeadImgForMsgs:@[msg]];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    [self addImageToImageList];
    msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
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

#pragma mark - QIMContactSelectionViewControllerDelegate

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC chatVC:(QIMChatVC *)vc {
    
    Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:[contactVC getSelectInfoDic][@"userId"] userType:[[contactVC getSelectInfoDic][@"isGroup"] boolValue] ? ChatType_GroupChat : ChatType_SingleChat msgType:QIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:[NSString stringWithFormat:@"%@的聊天记录", self.title] forKey:@"title"];
    [infoDic setQIMSafeObject:@"" forKey:@"desc"];
    [infoDic setQIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    
    msg.extendInformation = msgContent;
    
    [[QIMKit sharedInstance] uploadFileForData:[NSData dataWithContentsOfFile:_jsonFilePath] forMessage:msg withJid:[contactVC getSelectInfoDic][@"userId"] isFile:YES];
}

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC groupChatVC:(QIMGroupChatVC *)vc {
    Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"您收到了一个消息记录文件文件，请升级客户端查看。" extenddInfo:nil userId:[contactVC getSelectInfoDic][@"userId"] userType:[[contactVC getSelectInfoDic][@"isGroup"] boolValue] ? ChatType_GroupChat : ChatType_SingleChat msgType:QIMMessageType_CommonTrdInfo];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:[NSString stringWithFormat:@"%@的聊天记录", self.title] forKey:@"title"];
    [infoDic setQIMSafeObject:@"" forKey:@"desc"];
    [infoDic setQIMSafeObject:@"" forKey:@"linkurl"];
    NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    
    msg.extendInformation = msgContent;
    
    [[QIMKit sharedInstance] uploadFileForData:[NSData dataWithContentsOfFile:_jsonFilePath] forMessage:msg withJid:[contactVC getSelectInfoDic][@"userId"] isFile:YES];
}


#pragma mark - QIMUserListVCDelegate

- (void)selectContactWithJid:(NSString *)jid {
    
    NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
    if (_expandViewItemType == QIMTextBarExpandViewItemType_ShareCard) {
        //分享名片 选择的user
        [self sendMessage:[NSString stringWithFormat:@"分享名片：\n昵称：%@\n部门：%@", [infoDic objectForKey:@"Name"], [infoDic objectForKey:@"DescInfo"]] WithInfo:[NSString stringWithFormat:@"{\"userId\":\"%@\"}", [infoDic objectForKey:@"XmppId"]] ForMsgType:QIMMessageType_CardShare];
    }
}

#pragma mark - navbar delegate

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[QIMNavBackBtn sharedInstance] removeTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

#if kHasVoice

#pragma mark - Audio Method

- (BOOL)playingVoiceWithMsgId:(NSString *)msgId {
    
    return [msgId isEqualToString:self.currentPlayVoiceMsgId];
}

- (void)playVoiceWithMsgId:(NSString *)msgId WithFilePath:(NSString *)filePath {
    
    self.currentPlayVoiceMsgId = msgId;
    self.isNoReadVoice = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] playVoiceIsNoReadWithMsgId:msgId ChatId:self.chatId];
    if (msgId && filePath) {
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

- (void)remoteAudioPlayerErrorOccured:(QIMRemoteAudioPlayer *)player
                        withErrorCode:(QIMRemoteAudioPlayerErrorCode)errorCode {
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
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(updateCurrentPlayVoiceTime)
                                                   object:nil];
        [self performSelector:@selector(updateCurrentPlayVoiceTime) withObject:nil afterDelay:0.5];
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

#pragma mark - Cell Delegate

- (void)openWebUrl:(NSString *)url {
    QIMWebView *webVC = [[QIMWebView alloc] init];
    [webVC setUrl:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)refreshTableViewCell:(UITableViewCell *)cell {
    if (cell && [cell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Message *message = [self.messageManager.dataSource objectAtIndex:indexPath.row];
        [_cellSizeDic removeObjectForKey:message.messageId];
        if (indexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (NSUInteger)getColorHex:(NSString *)text {
    if (!_gUserNameColorDic) {
        _gUserNameColorDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    NSNumber *colorNum = [_gUserNameColorDic objectForKey:text];
    NSUInteger colorHex = [colorNum unsignedIntegerValue];
    if (colorNum == nil) {
        NSUInteger idHash = [text hash];
        int red = (idHash & 0xff0000) >> 16;
        int green = (idHash & 0xff00) >> 8;
        int blue = (idHash & 0xff);
        int lv = 0.299 * red + 0.587 * green + 0.114 * blue;
        if (lv > 180) {
            red = red * 0.8;
            green = green * 0.8;
            blue = blue * 0.8;
            idHash = (red << 16) + (green << 8) + blue;
        }
        [_gUserNameColorDic setObject:@(idHash) forKey:text];
        colorHex = (int) idHash;
    }
    return colorHex;
}

- (void)browserMessage:(Message *)message {
    
    UIViewController *vc = nil;
    if (message.messageType == QIMMessageType_BurnAfterRead) {
        NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kBurnAfterReadMsgDestruction object:message];
            QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:vc];
            [nc setNavigationBarHidden:YES];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
        } else {
            if (message.messageType == QIMMessageType_Image) {
                message.message = [infoDic objectForKey:@"descStr"];
            } else {
                message.message = [infoDic objectForKey:@"message"];
            }
            vc = [[QIMMessageBrowserVC alloc] init];
//            [(QIMMessageBrowserVC *) vc setTextCache:cache];
            [(QIMMessageBrowserVC *) vc setMessage:message];
            QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:vc];
            [nc setNavigationBarHidden:YES];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
        }
    } else if (message.messageType == QIMMessageType_Text || message.messageType == QIMMessageType_Image || message.message == QIMMessageType_ImageNew) {
        
        vc = [[QIMPreviewMsgVC alloc] init];
        [(QIMPreviewMsgVC *) vc setMessage:message];
        QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:vc];
        [nc setNavigationBarHidden:YES];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)processEvent:(int)event withMessage:(id)message {
    Message *eventMsg = (Message *)message;
    if (self.tableView.editing) {
        [self cancelForwardHandle:nil];
    }
    
    if (event == MA_Repeater) {
        //QIMContactSelectVC * controller = [[QIMContactSelectVC alloc] init];
        QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
        [controller setMessage:[QIMMessageParser reductionMessageForMessage:eventMsg]];
        [[self navigationController] presentViewController:nav animated:YES completion:nil];
        
    } else if (event == MA_Delete) {
        
        for (Message *msg in self.messageManager.dataSource) {
            
            if ([msg.messageId isEqualToString:[(Message *) eventMsg messageId]]) {
                
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
                        
                        [deleteIndexs addObject:[NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:timeMsg]
                                                                   inSection:0]];
                        [self.messageManager.dataSource removeObject:timeMsg];
                        [[QIMKit sharedInstance] deleteMsg:timeMsg
                                                           ByJid:self.chatId];
                    }
                    
                    [self.messageManager.dataSource removeObject:msg];
                    [self.tableView deleteRowsAtIndexPaths:deleteIndexs withRowAnimation:UITableViewRowAnimationAutomatic];
                    [[QIMKit sharedInstance] deleteMsg:eventMsg ByJid:self.chatId];
                    
                }
                break;
            }
        }
        
    } else if (event == MA_ToWithdraw) {
        
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setQIMSafeObject:[[QIMKit sharedInstance] getLastJid] forKey:@"fromId"];
        [dicInfo setQIMSafeObject:[(Message *) eventMsg messageId] forKey:@"messageId"];
        [dicInfo setQIMSafeObject:[(Message *) eventMsg message] forKey:@"message"];
        NSString *msgInfo = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
        
        [[QIMKit sharedInstance] revokeGroupMessageWithMessageId:[(Message *) eventMsg messageId]
                                                               message:msgInfo
                                                                 ToJid:self.chatId];
    } else if (event == MA_ReplyMsg) {
        
        QIMFriendsSpaceViewController *vc = [[QIMFriendsSpaceViewController alloc] init];
        Message *msg = eventMsg;
        vc.msgId = msg.replyMsgId ? msg.replyMsgId : msg.messageId;
        vc.groupId = self.chatId;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (event == MA_Favorite) {
        
        for (Message *msg in self.messageManager.dataSource) {
            
            if ([msg.messageId isEqualToString:[(Message *) eventMsg messageId]]) {
                
                [[QIMMyFavoitesManager sharedMyFavoritesManager] setMyFavoritesArrayWithMsg:eventMsg];
                
                break;
            }
        }
    } else if (event == MA_Forward) {
        self.tableView.editing = YES;
        [self.navigationController.navigationBar addSubview:[self getForwardNavView]];
        [self.navigationController.navigationBar addSubview:[self getMaskRightTitleView]];
        [self.view addSubview:self.forwardBtn];
    }else if (event == MA_Refer) {
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
        
        QIMImageStorage *storage = (QIMImageStorage *) textStorage;
        //图片
        if (storage.imageURL) {
            
            //纪录当前的浏览位置
            tableOffsetPoint = self.tableView.contentOffset;
            
            //初始化图片浏览控件
            QIMMWPhotoBrowser *browser = [[QIMMWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = YES;
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
            if (index == -1 && storage.imageURL.absoluteString.length > 0) {
                if (!self.fixedImageArray) {
                    self.fixedImageArray = [NSMutableArray arrayWithCapacity:2];
                }
                [self.fixedImageArray addObject:storage.imageURL];
                index = 0;
                //                browser.imageUrl = storage.imageURL;
                return;
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
    
    if (index > _imagesArr.count) {
        return nil;
    }
    
    NSString *imageHttpUrl;
    QIMImageStorage *storage = [_imagesArr objectAtIndex:index];
    imageHttpUrl = storage.imageURL.absoluteString;
    NSData *imageData = [[QIMKit sharedInstance] getFileDataFromUrl:imageHttpUrl forCacheType:QIMFileCacheTypeColoction needUpdate:NO];
    if (imageData.length > 0) {
        
        QIMMWPhoto *photo = [[QIMMWPhoto alloc] initWithImage:[UIImage qim_animatedImageWithAnimatedGIFData:imageData]];
        photo.photoData = imageData;
        return photo;
    } else {
        
        NSURL *url = [NSURL URLWithString:[imageHttpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        return url ? [[QIMMWPhoto alloc] initWithURL:url] : nil;
    }
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        // tableView 回滚到上次浏览的位置
        [_tableView setContentOffset:tableOffsetPoint animated:YES];
        [self.fixedImageArray removeAllObjects];
    }];
}

#pragma mark - notification

- (void)emotionImageDidLoad:(NSNotification *)notify {
    for (Message *msg in self.messageManager.dataSource) {
        if ([msg.messageId isEqualToString:notify.object]) {
            QIMTextContainer *container = [QIMMessageParser textContainerForMessage:msg fromCache:NO];
            if (container) {
                [[QIMMessageCellCache sharedInstance] setObject:container forKey:msg.messageId];
            }
            NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[self.messageManager.dataSource indexOfObject:msg] inSection:0];
            BOOL isVisable = [[self.tableView indexPathsForVisibleRows] containsObject:thisIndexPath];
            if (isVisable) {
                [self.tableView reloadRowsAtIndexPaths:@[thisIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)downloadFileFinished:(NSNotification *)notify {
    
    [self refreshTableView];
}

- (void)shareLocationCancelBtnHandle:(id)sender {
    
    [_joinShareLctView removeFromSuperview];
    _joinShareLctView = nil;
    _shareLctId = nil;
    _shareFromId = nil;
}

- (void)shareLocationJoinBtnHandle:(id)sender {
    
    if (_shareLctVC == nil) {
        _shareLctVC = [[ShareLocationViewController alloc] init];
        _shareLctVC.shareLocationId = _shareLctId;
        _shareLctVC.userId = self.chatId;
    }
    [[self navigationController] presentViewController:_shareLctVC animated:YES completion:nil];
}

- (void)onJoinShareViewClick {
    
    [_joinShareLctView removeAllSubviews];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, self.view.width - 80, 40)];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [contentLabel setFont:[UIFont systemFontOfSize:14]];
    [contentLabel setText:@"加"@"入"@"位"@"置共享，聊天中其他人也能看到你的位置，确定加入"@"？"];
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
    [_joinShareLctView addSubview:cancelBtn];
    
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn setTitle:@"加入" forState:UIControlStateNormal];
    [joinBtn setBackgroundColor:[UIColor qim_colorWithHex:0x9fb7be alpha:1]];
    [joinBtn setClipsToBounds:YES];
    [joinBtn.layer setCornerRadius:2.5];
    [joinBtn addTarget:self
                action:@selector(shareLocationJoinBtnHandle:)
      forControlEvents:UIControlEventTouchUpInside];
    joinBtn.frame = CGRectMake(contentLabel.right - 80, cancelBtn.top, 80, 30);
    [_joinShareLctView addSubview:joinBtn];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [_joinShareLctView setFrame:CGRectMake(0, 0, self.view.width, joinBtn.bottom + 10)];
    }];
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

- (void)updateHistoryMessageList:(NSNotification *)notify {
    
    if ([self.chatId isEqualToString:notify.object]) {
        [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:nil WihtLimit:kPageCount WithOffset:0 WihtComplete:^(NSArray *list) {
            [self updateGroupUsersHeadImgForMsgs:list];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.messageManager.dataSource = [NSMutableArray arrayWithArray:list];
                [self.tableView reloadData];
                [self addImageToImageList];
                [self scrollToBottomWithCheck:YES];
            });
            
        }];
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
                self.messageManager.dataSource = [[NSMutableArray alloc] initWithCapacity:10];
                [self.messageManager.dataSource addObject:msg];
                [self.tableView reloadData];
            } else if ([self.messageManager.dataSource count] != [self.tableView numberOfRowsInSection:0]) {
                [self.messageManager.dataSource addObject:msg];
                [self.tableView reloadData];
            } else {
                [self.messageManager.dataSource addObject:msg];
                [self updateGroupUsersHeadImgForMsgs:@[msg]];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            [self addImageToImageList];
            [self scrollToBottomWithCheck:NO];
            if ([msg isKindOfClass:[Message class]] && msg.messageDirection == MessageDirection_Received) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[QIMKit sharedInstance] sendReadstateWithGroupLastMessageTime:msg.messageDate
                                                                             withGroupId:self.chatId];
                });
            }
        }
    }
}

- (void)updateMessageList:(NSNotification *)notify {
    
    NSIndexPath *indexpath = [[self.tableView indexPathsForVisibleRows] lastObject];
    self.currentMsgIndexs = indexpath.row;
    if ([self.chatId isEqualToString:notify.object]) {
        
        Message *msg = [notify.userInfo objectForKey:@"message"];
        NSInteger numbers = [self.tableView numberOfRowsInSection:0];
        if (msg) {
            if (!self.messageManager.dataSource) {
                self.messageManager.dataSource = [[NSMutableArray alloc] initWithCapacity:20];
                [self.messageManager.dataSource addObject:msg];
                [self.tableView reloadData];
            } else if ([self.messageManager.dataSource count] != [_tableView numberOfRowsInSection:0]) {
                [self.messageManager.dataSource addObject:msg];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            } else {
                [self.messageManager.dataSource addObject:msg];
                [self updateGroupUsersHeadImgForMsgs:@[msg]];
                //                dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                //                });
            }
            [self addImageToImageList];
            [self scrollToBottomWithCheck:NO];
            if ([msg isKindOfClass:[Message class]] && msg.messageDirection == MessageDirection_Received) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[QIMKit sharedInstance] sendReadstateWithGroupLastMessageTime:msg.messageDate
                                                                       withGroupId:self.chatId];
                });
            }
        }
    }
}

- (void)scrollBottom {
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    QIMVerboseLog(@"IMGroupChatVc %@ Offset : %f", self.chatId, offset.y);
    if (offset.y > self.tableView.height / 2.0f) {
        [self.tableView setContentOffset:offset animated:NO];
    }
}

- (void)scrollToBottom:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
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
        } else {
            if([self.tableView numberOfSections] > 0 ){
                NSInteger lastSectionIndex = [self.tableView numberOfSections]-1;
                NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex ]-1;
                if(lastRowIndex > 0){
                    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
                    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
                }
            } else {
                CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
                [self.tableView setContentOffset:offset animated:NO];
            }
        }
    });
}

- (BOOL)shouldScrollToBottomForNewMessage {
    CGFloat _h = self.tableView.contentSize.height - self.tableView.contentOffset.y - (CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.bottom);
    
//    return _h <= 66 * 4;
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
}

- (void)referViewTapHandlel:(UITapGestureRecognizer *)tap {
    _referMsgwindow.hidden = YES;
    _referMsgwindow = nil;
}

#pragma mark - text bar delegate

- (void)sendImageText:(NSString *)text {
    
    if ([text length] > 0) {
        Message *msg = nil;
        
        msg = [[QIMKit sharedInstance] createMessageWithMsg:text extenddInfo:nil userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_Text];
        [self.messageManager.dataSource addObject:msg];
        [self updateGroupUsersHeadImgForMsgs:@[msg]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        msg = [[QIMKit sharedInstance] sendMessage:text ToGroupId:self.chatId];
    }
}

- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType {
    if (msgType == QIMMessageType_LocalShare) {
        NSData *imageData = [[QIMKit sharedInstance] userObjectForKey:@"userLocationScreenshotImage"];
        Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_LocalShare forMsgId:_resendMsg.messageId];
        [msg setOriginalMessage:[msg message]];
        [msg setOriginalExtendedInfo:[msg extendInformation]];
        
        
        [self.messageManager.dataSource addObject:msg];
        [self updateGroupUsersHeadImgForMsgs:@[msg]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        [self addImageToImageList];
        [self scrollToBottomWithCheck:YES];
        [[QIMKit sharedInstance] uploadFileForData:imageData forMessage:msg withJid:self.chatId isFile:NO];
    } else {
        
        Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:message extenddInfo:info userId:self.chatId userType:ChatType_GroupChat msgType:msgType forMsgId:_resendMsg.messageId];
        [self.messageManager.dataSource addObject:msg];
        [self updateGroupUsersHeadImgForMsgs:@[msg]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        [self scrollToBottomWithCheck:YES];
        msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
    }
}

- (void)sendNormalEmotion:(NSString *)faceStr WithPackageId:(NSString *)packageId {
    if (faceStr && packageId) {
        NSString *text = [NSString stringWithFormat:@"[obj type=\"%@\" value=\"%@\" width=%@ height=0 ]", @"emoticon",[NSString stringWithFormat:@"[%@]", faceStr], packageId];
        NSDictionary *normalEmotionExtendInfoDic = @{@"height": @(0), @"pkgid":packageId, @"shortcut":faceStr, @"url":@"", @"width": @(0)};
        NSString *normalEmotionExtendInfoStr = [[QIMJSONSerializer sharedInstance] serializeObject:normalEmotionExtendInfoDic];
        if ([text length] > 0) {
            Message *msg = nil;
            text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
            if (self.textBar.isRefer) {
                NSDictionary *referMsgUserInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.textBar.referMsg.nickName];
                NSString *referMsgNickName = [referMsgUserInfo objectForKey:@"Name"];
                text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n", (referMsgNickName.length > 0) ? referMsgNickName : self.textBar.referMsg.nickName,self.textBar.referMsg.message] stringByAppendingString:text];
                self.textBar.isRefer = NO;
                self.textBar.referMsg = nil;
            }
            NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
            if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
                
                NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                [dicInfo setObject:@(QIMMessageType_ImageNew) forKey:@"msgType"];
                [dicInfo setObject:normalEmotionExtendInfoStr forKey:@"descStr"];
                [dicInfo setObject:text forKey:@"message"];
                NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
                msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~"
                                                              extenddInfo:extendInformation
                                                                   userId:self.chatId
                                                                 userType:ChatType_GroupChat
                                                                  msgType:QIMMessageType_BurnAfterRead];
                
                [self.messageManager.dataSource addObject:msg];
                [self updateGroupUsersHeadImgForMsgs:@[msg]];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                [self.tableView endUpdates];
                [self scrollToBottomWithCheck:YES];
                [self addImageToImageList];
                msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
            } else if (_replyMsgId) {
                
                [[QIMKit sharedInstance] sendReplyMessageId:_replyMsgId
                                                    WithReplyUser:_replyUser
                                              WithMessageId:[QIMUUIDTools UUID]
                                                      WithMessage:text
                                                        ToGroupId:self.chatId];
                _replyMsgId = nil;
            } else {
                
                msg = [[QIMKit sharedInstance] createMessageWithMsg:text
                                                              extenddInfo:normalEmotionExtendInfoStr
                                                                   userId:self.chatId
                                                                 userType:ChatType_GroupChat
                                                                  msgType:QIMMessageType_ImageNew];
                
                [self.messageManager.dataSource addObject:msg];
                [self updateGroupUsersHeadImgForMsgs:@[msg]];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                [self.tableView endUpdates];
                [self scrollToBottomWithCheck:YES];
                [self addImageToImageList];
                msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
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
    
    NSMutableArray *outATInfoArray = [NSMutableArray arrayWithCapacity:3];
    NSString *attributedText = [[QIMMessageTextAttachment sharedInstance] getStringFromAttributedString:[self.textBar getTextBarAttributedText] WithOutAtInfo:&outATInfoArray];
    //    NSString *attributedText = [self.textBar getSendAttributedText];
    if (attributedText.length > 0) {
        text = attributedText;
    }
    
    if ([text length] > 0) {
        Message *msg = nil;
        text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
        if (self.textBar.isRefer) {
            NSDictionary *referMsgUserInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.textBar.referMsg.nickName];
            NSString *referMsgNickName = [referMsgUserInfo objectForKey:@"Name"];
            text = [[NSString stringWithFormat:@"「 %@:%@ 」\n- - - - - - - - - - - - - - -\n",(referMsgNickName.length > 0) ? referMsgNickName : self.textBar.referMsg.nickName,self.textBar.referMsg.message] stringByAppendingString:text];
            self.textBar.isRefer = NO;
            self.textBar.referMsg = nil;
        }
        NSString *backInfo = nil;
        if (outATInfoArray) {
            backInfo = [[QIMJSONSerializer sharedInstance] serializeObject:outATInfoArray];
        }
        NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
        if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
            
            NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
            [dicInfo setObject:@(QIMMessageType_Text) forKey:@"msgType"];
            [dicInfo setObject:text forKey:@"descStr"];
            [dicInfo setObject:text forKey:@"message"];
            NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
            msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~"
                                                          extenddInfo:extendInformation
                                                               userId:self.chatId
                                                             userType:ChatType_GroupChat
                                                              msgType:QIMMessageType_BurnAfterRead
                                                             backinfo:backInfo];
            
            [self.messageManager.dataSource addObject:msg];
            [self updateGroupUsersHeadImgForMsgs:@[msg]];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
            msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
        } else if (_replyMsgId) {
            
            [[QIMKit sharedInstance] sendReplyMessageId:_replyMsgId
                                                WithReplyUser:_replyUser
                                          WithMessageId:[QIMUUIDTools UUID]
                                                  WithMessage:text
                                                    ToGroupId:self.chatId];
            _replyMsgId = nil;
        } else {
            
            msg = [[QIMKit sharedInstance] createMessageWithMsg:text
                                                          extenddInfo:nil
                                                               userId:self.chatId
                                                             userType:ChatType_GroupChat
                                                              msgType:QIMMessageType_Text
                                                             backinfo:backInfo];
            [self.messageManager.dataSource addObject:msg];
            [self updateGroupUsersHeadImgForMsgs:@[msg]];
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
            [self scrollToBottomWithCheck:YES];
            [self addImageToImageList];
            msg = [[QIMKit sharedInstance] sendMessage:msg ToUserId:self.chatId];
        }
    }
}

- (void)emptyText:(NSString *)text {
    //    UIAlertController *emptyTextVc = [UIAlertController alertControllerWithTitle:@"不能发送空白消息" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    //        QIMVerboseLog(@"不能发送空白消息");
    //    }];
    //    [emptyTextVc addAction:okAction];
    //    [self presentViewController:emptyTextVc animated:YES completion:nil];
}

- (void)sendImageData:(NSData *)imageData {
    if (imageData) {
        [self getStringFromAttributedString:imageData];
    }
}

- (void)sendVideoPath:(NSString *)videoPath WithThumbImage:(UIImage *)thumbImage WithFileSizeStr:(NSString *)fileSizeStr WithVideoDuration:(float)duration {
    [self sendVideoPath:videoPath WithThumbImage:thumbImage WithFileSizeStr:fileSizeStr WithVideoDuration:duration forMsgId:nil];
}

- (void)sendVideoPath:(NSString *)videoPath WithThumbImage:(UIImage *)thumbImage WithFileSizeStr:(NSString *)fileSizeStr WithVideoDuration:(float)duration forMsgId:(NSString *)mId {
    
    [self.view setFrame:_rootViewFrame];
    NSString *msgId = mId.length ? mId : [QIMUUIDTools UUID];
    CGSize size = thumbImage.size;
    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.8);
    NSString *pathExtension = [[videoPath lastPathComponent] pathExtension];
    NSString *fileName = [[videoPath lastPathComponent] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
    NSString *thumbFilePath = [videoPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
    [thumbData writeToFile:thumbFilePath atomically:YES];
    
    NSString *httpUrl = [QIMKit updateLoadFile:thumbData
                                        WithMsgId:msgId
                                      WithMsgType:QIMMessageType_Image
                                WihtPathExtension:@"jpg"];
    
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
    [msg setChatType:ChatType_GroupChat];
    [msg setMessageType:QIMMessageType_SmallVideo];
    [msg setMessageDate:([[NSDate date] timeIntervalSince1970] - [[QIMKit sharedInstance] getServerTimeDiff]) * 1000];
    [msg setFrom:[[QIMKit sharedInstance] getLastJid]];
    [msg setTo:self.chatId];
    [msg setMessage:msgContent];
    
    NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
    if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
        
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setQIMSafeObject:@(QIMMessageType_SmallVideo) forKey:@"msgType"];
        [dicInfo setQIMSafeObject:msg.message forKey:@"descStr"];
        [dicInfo setQIMSafeObject:msg.message forKey:@"message"];
        NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
        msg.extendInformation = extendInformation;
        msg.message = @"此为阅后即焚消息，该终端不支持阅后即焚~"@"~";
        msg.messageType = QIMMessageType_BurnAfterRead;
    }
    
    [[QIMKit sharedInstance] insertMessageWihtMsgId:msg.messageId
                                         WithXmppId:self.chatId
                                           WithFrom:msg.from
                                             WithTo:msg.to
                                        WithContent:msg.message
                                     WithExtendInfo:msg.extendInformation
                                       WithPlatform:msg.platform
                                        WithMsgType:msg.messageType
                                       WithMsgState:msg.messageState
                                   WithMsgDirection:msg.messageDirection
                                        WihtMsgDate:msg.messageDate
                                      WithReadedTag:0
                                       WithChatType:msg.chatType];
    if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
        
        [[QIMKit sharedInstance] updateMessageWithExtendInfo:msg.extendInformation ForMsgId:msg.messageId];
    }
    
    [self.messageManager.dataSource addObject:msg];
    [self updateGroupUsersHeadImgForMsgs:@[msg]];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    [self scrollToBottomWithCheck:YES];
    
    [[QIMKit sharedInstance] uploadFileForPath:videoPath forMessage:msg withJid:self.chatId isFile:YES];
}

- (void)sendVoiceData:(NSData *)voiceData WithDuration:(int)duration {
    
    //      [[IMXmppManager sharedInstance] sendVoiceData:voiceData
    //      WithDuration:duration ToUserId:self.chatSession.userId];
    //    [[QIMKit sharedInstance] sendGroupVoiceUrl: withVoiceName:
    //    withSeconds: ToGroupId:]
    //
    //    [[QIMKit sharedInstance] sendVoiceUrl: withVoiceName: withSeconds:
    //    ToUserId:]
}

- (void)setKeyBoardHeight:(CGFloat)height WithScrollToBottom:(BOOL)flag {
    
    CGFloat animaDuration = 0.2;
    
    CGRect frame = _tableViewFrame;
    frame.origin.y -= height;
    [UIView animateWithDuration:animaDuration animations:^{
        
        [self.tableView setFrame:frame];
        if (self.tableView.contentSize.height - self.tableView.tableHeaderView.frame.size.height + 10 < self.tableView.frame.size.height && height > 0) {
            
            if (_tableView.contentSize.height - _tableView.tableHeaderView.frame.size.height + 10 < _tableViewFrame.size.height - height) {
                
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height + 10)];
                [self.tableView setTableHeaderView:headerView];
            } else {
                
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.tableView.frame.size.height - (self.tableView.contentSize.height - self.tableView.tableHeaderView.frame.size.height + 10) + 10)];
                [self.tableView setTableHeaderView:headerView];
            }
        } else {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
            [self.tableView setTableHeaderView:headerView];
            //             if (flag) {
            //                 [self scrollToBottomWithCheck:YES];
            //             }
        }
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if (_shareLctVC == nil) {
            _shareLctVC = [[ShareLocationViewController alloc] init];
            _shareLctVC.userId = self.chatId;
        }
        [[self navigationController] presentViewController:_shareLctVC animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        
        UserLocationViewController *userLct = [[UserLocationViewController alloc] init];
        userLct.delegate = self;
        [self.navigationController presentViewController:userLct animated:YES completion:nil];
    } else if (buttonIndex == 2) {
    }
}

#pragma mark - Action Method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([gestureRecognizer isKindOfClass:[QIMTapGestureRecognizer class]]) {
        NSInteger index = gestureRecognizer.view.tag;
        CGPoint location = [touch locationInView:[gestureRecognizer.view viewWithTag:kTextLabelTag]];
        NSInteger imageIndex = [(QIMGroupChatCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] indexForCellImagesAtLocation:location];
        if (imageIndex < 0) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    //当点击table空白处时，输入框自动回收
    CGPoint point = [touch locationInView:self.view];
    if (!CGRectContainsPoint(self.textBar.frame, point)) {
        [self.textBar needFirstResponder:NO];
    }
    
    [QIMMenuImageView cancelHighlighted];
    
    return NO;
}

#pragma mark - UIScrollView的代理函数

// =======================================================================

// UIScrollView的代理函数

// =======================================================================

- (void)QTalkMessageUpdateForwardBtnState:(BOOL)enable {
    self.forwardBtn.enabled = enable;
    QIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)QTalkMessageScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat h1 = self.tableView.contentOffset.y + self.tableView.frame.size.height;
    CGFloat h2 = self.tableView.contentSize.height - 250;
    CGFloat tempOffY = (self.tableView.contentSize.height - self.tableView.frame.size.height);
    if ((h1 > h2) && tempOffY > 0) {
        [self hidePopView];
    }
}

- (void)QTalkMessageScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

// =======================================================================

// MJRefresh的代理函数

// =======================================================================

- (void)loadNewGroupMsgList {
    __weak typeof(self) weakSelf = self;
    self.loadCount += 1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QIMKit sharedInstance] getMsgListByUserId:weakSelf.chatId
                                        WithRealJid:nil
                                          WihtLimit:kPageCount
                                         WithOffset:(int) weakSelf.messageManager.dataSource.count
                                       WihtComplete:^(NSArray *list) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               CGFloat offsetY = weakSelf.tableView.contentSize.height - weakSelf.tableView.contentOffset.y;
                                               NSRange range = NSMakeRange(0, [list count]);
                                               NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                               
                                               //标记已读
                                               [weakSelf markReadedForChatRoom];
                                               
                                               [weakSelf.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                                               [weakSelf updateGroupUsersHeadImgForMsgs:list];
                                               [weakSelf.tableView reloadData];
                                               weakSelf.tableView.contentOffset = CGPointMake(0, weakSelf.tableView.contentSize.height - offsetY - 30);
                                               //重新获取一次大图展示的数组
                                               [weakSelf addImageToImageList];
                                               [weakSelf.tableView.mj_header endRefreshing];
                                           });
                                       }];
    });
#if defined (QIMRNEnable) && QIMRNEnable == 1
    if (self.loadCount >= 3 && !self.reloadSearchRemindView) {
        self.searchRemindView = [[QIMSearchRemindView alloc] initWithChatId:self.chatId withRealJid:nil withChatType:self.chatType];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToConverstaionSearch)];
        [self.searchRemindView addGestureRecognizer:tap];
        [self.view addSubview:self.searchRemindView];
    }
#endif
}

- (void)jumpToConverstaionSearch {
    self.reloadSearchRemindView = YES;
    [self.searchRemindView removeFromSuperview];
    [[QIMFastEntrance sharedInstance] openLocalSearchWithXmppId:self.chatId withRealJid:nil withChatType:self.chatType];
}

- (void)gotoFriendter:(id)sender {
    
    QIMFriendsSpaceViewController *vc = [[QIMFriendsSpaceViewController alloc] init];
    vc.groupId = self.chatId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addPersonToPgrup:(id)sender {
    if (![[[QIMKit sharedInstance] userObjectForKey:@"kRightCardRemindNotification"] boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRightCardRemindNotification object:nil];
        [[QIMKit sharedInstance] setUserObject:@(YES) forKey:kRightCardRemindNotification];
    }
    [QIMFastEntrance openQIMGroupCardVCByGroupId:self.chatId];
}

- (void)scrollToBottom {
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    [self.tableView setContentOffset:offset animated:NO];
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

- (NSString *)getStringFromAttributedString:(NSData *)imageData {
    UIImage *image = [YLGIFImage imageWithData:imageData];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    __block Message *msg = nil;
    NSString *burnAfterReadingStatus = [[QIMKit sharedInstance] userObjectForKey:@"burnAfterReadingStatus"];
    if (burnAfterReadingStatus && [burnAfterReadingStatus isEqualToString:@"ON"]) {
        
        msg = [[QIMKit sharedInstance] createMessageWithMsg:@"此为阅后即焚消息，该终端不支持阅后即焚~~" extenddInfo:nil userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_BurnAfterRead forMsgId:_resendMsg.messageId];
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
            msgText = [NSString stringWithFormat:@"[obj type=\"image\" value=\"?FileName=%@\" width=%f height=%f]", fileName, width, height];
        }
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:@(QIMMessageType_Text) forKey:@"msgType"];
        [dicInfo setObject:msgText forKey:@"descStr"];
        [dicInfo setObject:msgText forKey:@"message"];
        NSString *extendInformation = [[QIMJSONSerializer sharedInstance] serializeObject:dicInfo];
        msg.extendInformation = extendInformation;
        
    } else {
        msg = [[QIMKit sharedInstance] createMessageWithMsg:@"" extenddInfo:nil userId:self.chatId userType:ChatType_GroupChat msgType:QIMMessageType_Text];
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
    [[QIMKit sharedInstance] updateMsg:msg ByJid:self.chatId];
    
    
    [self.messageManager.dataSource addObject:msg];
    [self updateGroupUsersHeadImgForMsgs:@[msg]];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    [self addImageToImageList];
    [self scrollToBottomWithCheck:YES];
    return nil;
}

- (NSString *)getStringFromAttributedSourceString:(NSString *)sourceStr {
    
    return [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:sourceStr];;
}

- (void)updateForwardBtnState {
    self.forwardBtn.enabled = self.messageManager.forwardSelectedMsgs.count;
    QIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)refreshTableView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self.tableView
                                                 selector:@selector(reloadData)
                                                   object:nil];
        [self.tableView performSelector:@selector(reloadData)
                             withObject:nil
                             afterDelay:DEFAULT_DELAY_TIMES];
    });
}

#pragma mark - show pop view

- (void)showPopView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (notificationView == nil) {
        
        notificationView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 110, self.textBar.frame.origin.y - 50, 100, 40)];
        backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [backImageView setImage:[UIImage imageNamed:@"notificationToast"]];
        [notificationView addSubview:backImageView];
        
        UIImageView *messageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 7, 20, 20)];
        [messageImageView setImage:[UIImage imageNamed:@"notificationToastCommentIcon"]];
        
        [notificationView addSubview:messageImageView];
        if (commentCountLabel == nil) {
            commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 70, 20)];
            [commentCountLabel setTextColor:[UIColor whiteColor]];
            [commentCountLabel setText:@"下面有新消息"];
            [commentCountLabel setFont:[UIFont boldSystemFontOfSize:10]];
            [notificationView addSubview:commentCountLabel];
        }
        
        [self.view addSubview:notificationView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewToFoot)];
        [notificationView addGestureRecognizer:tap];
        notificationView.userInteractionEnabled = YES;
        [notificationView setHidden:NO];
        notificationView.alpha = 1.0;
    }
    [notificationView setHidden:NO];
    notificationView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)hidePopView {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    notificationView.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)moveViewToFoot {
    [self scrollToBottom_tableView];
}

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

#pragma mark -IMTextBarDelegate voice record operator about -add by dan.zheng 15/4/28

- (void)beginDoVoiceRecord {
    self.voiceRecordingView.hidden = NO;
    [self.voiceRecordingView beginDoRecord];
}

- (void)updateVoiceViewHeightInVCWithPower:(float)power {
    [self.voiceRecordingView doImageUpdateWithVoicePower:power];
}

- (void)voiceRecordWillFinishedIsTrue:(BOOL)isTrue
                      andCancelByUser:(BOOL)isCancelByUser {
    
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
    
    [self sendMessage:[NSString stringWithFormat:@"{\"%@\":\"%@\", \"%@\":\"%@\", \"%@\":%@,\"%@\":\"%@\"}", @"HttpUrl", voiceUrl, @"FileName", filename, @"Seconds", [NSNumber numberWithInt:duration], @"filepath", filepath] WithInfo:nil ForMsgType:QIMMessageType_Voice];
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
            NSArray *forwardIndexpaths = [self.tableView.indexPathsForSelectedRows sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return obj1 > obj2;
            }];
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (NSIndexPath *indexPath in forwardIndexpaths) {
                [msgList addObject:[self.messageManager.dataSource objectAtIndex:indexPath.row]];
            }
            NSString *jsonFilePath = [QIMExportMsgManager parseForJsonStrFromMsgList:msgList withTitle:[NSString stringWithFormat:@"%@的聊天记录", self.title]];
            self.tableView.editing = NO;
            [_forwardNavTitleView removeFromSuperview];
            [_maskRightTitleView removeFromSuperview];
            [self.forwardBtn removeFromSuperview];
            [_textBar setUserInteractionEnabled:YES];
            
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            controller.delegate = self;
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                [self cancelForwardHandle:nil];
            }];
        } else if (buttonIndex == 1) {
            NSArray *forwardIndexpaths = [self.tableView.indexPathsForSelectedRows sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                return obj1 > obj2;
            }];
            NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
            for (NSIndexPath *indexPath in forwardIndexpaths) {
                [msgList addObject:[QIMMessageParser reductionMessageForMessage:[self.messageManager.dataSource objectAtIndex:indexPath.row]]];
            }
            QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
            [controller setMessageList:msgList];
            [[self navigationController] presentViewController:nav animated:YES completion:^{
                [self cancelForwardHandle:nil];
            }];
        } else {
            
        }
    } else {
        if (buttonIndex == 1) {
            QIMChatBGImageSelectController *chatBGImageSelectVC = [[QIMChatBGImageSelectController alloc] initWithCurrentBGImage:_chatBGImageView.image];
            chatBGImageSelectVC.userID = self.chatId;
            chatBGImageSelectVC.delegate = self;
            chatBGImageSelectVC.isFromChat = YES;
            [self.navigationController pushViewController:chatBGImageSelectVC
                                                 animated:YES];
        }
    }
}

#pragma mark - QIMChatBGImageSelectControllerDelegate

- (void)ChatBGImageDidSelected:(QIMChatBGImageSelectController *)chatBGImageSelectVC {
    [self refreshChatBGImageView];
}

#pragma mark - QIMPushProductViewControllerDelegate

- (void)sendProductInfoStr:(NSString *)infoStr
          productDetailUrl:(NSString *)detlUrl {
    [self sendMessage:detlUrl WithInfo:infoStr ForMsgType:QIMMessageType_product];
}

@end
