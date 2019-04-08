//
//  QTalkSessionView.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 16/7/20.
//
//

#import "QTalkSessionView.h"
#import "QIMChatVC.h"
#import "QIMMainVC.h"
#import "UIApplication+QIMApplication.h"
#import "QIMJSONSerializer.h"
#import "QIMGroupChatVC.h"
#import "QIMIconInfo.h"
#import "QIMSystemVC.h"
#import "QIMPublicNumberVC.h"
#import "QIMFriendNotifyViewController.h"
#import "QTalkSessionCell.h"
#import "QIMWebView.h"
#import <CoreText/CoreText.h>
#import "QIMCollectionChatViewController.h"
#import "QIMContactSelectionViewController.h"
#import "QIMArrowTableView.h"
#import "QIMContactSelectVC.h"
#import "QIMZBarViewController.h"
#import "QIMJumpURLHandle.h"
#import "MBProgressHUD.h"
#import "QIMCustomPopViewController.h"
#import "QIMCustomPresentationController.h"
#import "QIMCustomPopManager.h"

#if defined (QIMNotifyEnable) && QIMNotifyEnable == 1

#import "QIMNotifyManager.h"
#endif

#define kClearAllNotReadMsg 1002

#if defined (QIMNotifyEnable) && QIMNotifyEnable == 1

@interface QTalkSessionView () <QIMNotifyManagerDelegate>

@end
#endif

@interface QTalkSessionView () <UITableViewDelegate, UITableViewDataSource, QIMSessionScrollDelegate, UIViewControllerPreviewingDelegate, SelectIndexPathDelegate> {
    MBProgressHUD *_tipHUD;
    BOOL _canWrite;
    CABasicAnimation *_writingAnimation;
    CAShapeLayer *_writingLayer;
    CAGradientLayer *_gradLayer;
}

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, assign) BOOL willRefreshTableView;

@property(nonatomic, assign) BOOL willForceTableView;

@property(nonatomic, strong) NSMutableArray *recentContactArray;

@property(nonatomic, strong) QTalkSessionCell *currentCell;

@property(atomic, strong) NSMutableArray *notReaderIndexPathList;

@property(nonatomic, assign) NSInteger currentNotReaderIndex;

@property(nonatomic, strong) dispatch_queue_t update_reader_list_queue;

@property(nonatomic, strong) dispatch_queue_t reloadListViewQueue;

@property(nonatomic, strong) UIButton *moreBtn;

@property(nonatomic, assign) BOOL isSelected;

@property(nonatomic, assign) BOOL netWorkConnection;

@property(nonatomic, strong) UIView *connectionAlertView;

@property(nonatomic, strong) UIView *otherPlatformView;

@property(nonatomic, weak) NSTimer *timer;

@property(nonatomic, assign) BOOL scrollTop;

@property(nonatomic, assign) NSInteger insertCount;

@property(nonatomic, strong) QIMArrowTableView *arrowPopView;

//@property (nonatomic, strong) SCLAlertView *swicthAccountAlert;
//@property (nonatomic, strong) SCLAlertView *waitingAlert;
//@property (nonatomic, strong) QIMSwitchAccountView *accountCollectionView;

@property (nonatomic, strong) NSMutableArray *appendHeaderViews;

@property (nonatomic, strong) QIMMainVC *rootViewController;

@property (nonatomic, strong) UIViewController *tempRootVc;

@property (nonatomic, strong) NSArray *moreActionArray;

@end

@implementation QTalkSessionView

#pragma mark - setter and getter

- (NSMutableArray *)appendHeaderViews {
    if (!_appendHeaderViews) {
        _appendHeaderViews = [NSMutableArray arrayWithCapacity:2];
    }
    return _appendHeaderViews;
}

- (UIView *)connectionAlertView {
    if (!_connectionAlertView) {
        _connectionAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 45)];
        _connectionAlertView.backgroundColor = [UIColor colorWithRed:253 green:228 blue:229 alpha:1.0];
        
        UIImageView *alertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connect_alert_error"]];
        alertView.frame = CGRectMake(20, (CGRectGetHeight(_connectionAlertView.frame) - 28)/2, 28, 28);
        [_connectionAlertView addSubview:alertView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(alertView.frame) + 12, 0, 300, 45)];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"当前网络不可用，请检查你的网络设置";
        [_connectionAlertView addSubview:label];
        [_connectionAlertView setAccessibilityIdentifier:@"connectionAlertView"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotConnectWebView:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_connectionAlertView addGestureRecognizer:tap];
    }
    return _connectionAlertView;
}

- (UIView *)otherPlatformView {
    if (!_otherPlatformView) {
        _otherPlatformView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
        _otherPlatformView.backgroundColor = [UIColor qim_colorWithHex:0xEEEEEE alpha:1.0];
        UIImageView *pcIconView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 8, 24, 24)];
        pcIconView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f491" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]];
        [_otherPlatformView addSubview:pcIconView];
        UILabel *pcTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(pcIconView.right + 24, 10, 108, 20)];
        pcTipLabel.text = @"桌面QTalk已登录";
        pcTipLabel.textColor = [UIColor qim_colorWithHex:0x616161];
        pcTipLabel.font = [UIFont systemFontOfSize:14];
        [_otherPlatformView addSubview:pcTipLabel];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(self.right - 11 - 14, 12, 14, 14)];
        arrowView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3c8" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]];
        [_otherPlatformView addSubview:arrowView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFileTrans)];
        [_otherPlatformView addGestureRecognizer:tap];
    }
    return _otherPlatformView;
}

- (UIView *)tableViewHeaderView {
    
    CGFloat appendHeight = 0.0f;
    for (UIView *appendView in self.appendHeaderViews) {
        appendHeight += appendView.height;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, ([self.rootViewController isKindOfClass:[QIMMainVC class]] ? self.rootViewController.searchBar.height : 0) + appendHeight)];
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(0, - self.tableView.height, self.tableView.width, self.tableView.height)];
    [logoView setBackgroundColor:[UIColor qim_colorWithHex:0x787878 alpha:1]];
    [headerView addSubview:logoView];
    if ([self.rootViewController isKindOfClass:[QIMMainVC class]]) {
        [headerView addSubview:self.rootViewController.searchBar];
    }
    for (UIView *appendView in self.appendHeaderViews) {
        UIView *lastView = headerView.subviews.lastObject;
        CGRect appendViewFrame = CGRectMake(appendView.origin.x, lastView.bottom, appendView.width, appendView.height);
        [appendView setFrame:appendViewFrame];
        [headerView addSubview:appendView];
    }
    return headerView;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0f];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView setAccessibilityIdentifier:@"SessionView"];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 0.5);           //top left bottom right 左右边距相同
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.tableFooterView = [UIView new];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [_tableView setTableHeaderView:[self tableViewHeaderView]];
    }
    return _tableView;
}

- (QIMArrowTableView *)arrowPopView {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.width - 20 - 28, -30, 28, 28);
    button.backgroundColor = [UIColor clearColor];
    [self addSubview:button];
    CGRect rect1 = [button convertRect:button.frame fromView:self];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    CGRect rect2 = [button convertRect:rect1 toView:window];         //获取button在window的位置
    
    CGRect rect3 = CGRectInset(rect2, -0.5 * 8, -0.5 * 8);
    
    CGPoint point;
    //获取控件相对于window的   中心点坐标
    
    NSString *qCloudHost = [[QIMKit sharedInstance] qimNav_QCloudHost];
    NSString *wikiHost = [[QIMKit sharedInstance] qimNav_WikiUrl];
    self.moreActionArray = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *moreActionImages = nil;
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        if (qCloudHost.length > 0 && wikiHost.length > 0) {
            self.moreActionArray = @[@"扫一扫", @"发起聊天", @"一键已读", @"随记", @"Wiki"];
            moreActionImages = @[[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]],[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f4" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e23f" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f1b7" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e455" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]]];
        } else {
            if (wikiHost.length > 0) {
                self.moreActionArray       = @[ @"扫一扫", @"发起聊天", @"一键已读", @"Wiki"];
                moreActionImages = @[[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]],[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f4" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e23f" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e455" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]]];
            } else {
                self.moreActionArray       = @[ @"扫一扫", @"发起聊天", @"一键已读"];
                moreActionImages = @[[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]],[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f4" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]], [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e23f" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]]];
            }
        }
    } else {
        self.moreActionArray       = @[@"扫一扫", @"发起聊天"];
        moreActionImages = @[[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f5" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]],[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0f4" size:20 color:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0]]]];
    }
    //    e23f
    point = CGPointMake(rect3.origin.x + rect3.size.width / 2 ,rect3.origin.y + rect3.size.height / 2);
    _arrowPopView = [[QIMArrowTableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) Origin:point Width:120 Height:45 * self.moreActionArray.count Type:Type_UpRight Color:[UIColor colorWithRed:0.2737 green:0.2737 blue:0.2737 alpha:1.0] ];
    _arrowPopView.dataArray = self.moreActionArray;
    _arrowPopView.backView.layer.cornerRadius = 5;
    _arrowPopView.images = moreActionImages;
    _arrowPopView.row_height      = 45;
    _arrowPopView.delegate        = self;
    _arrowPopView.titleTextColor  = [UIColor colorWithRed:0.2669 green:0.765 blue:1.0 alpha:1.0];
    return _arrowPopView;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        UIButton *moreActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreActionBtn.frame = CGRectMake(0, 0, 28, 28);
        [moreActionBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3e1" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
        [moreActionBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3e1" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateSelected];
        [moreActionBtn addTarget:self action:@selector(doMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        _moreBtn = moreActionBtn;
    }
    return _moreBtn;
}

- (void)doMoreAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = ~button.selected;
    if (button.selected) {
        [self.arrowPopView popView];
    } else {
        [self.arrowPopView dismiss];
    }
}

- (void)initUI {
    
    [self addSubview:self.tableView];
    [self reloadTableView];
}

- (void)updateOtherPlatFrom:(BOOL)flag {
    if (flag) {
        if (![self.appendHeaderViews containsObject:self.otherPlatformView]) {
            [self.appendHeaderViews addObject:self.otherPlatformView];
        } else {
            //不做改变
        }
    } else {
        [self.appendHeaderViews removeObject:self.otherPlatformView];
    }
    [self.tableView setTableHeaderView:[self tableViewHeaderView]];
}

- (void)updateSessionHeaderViewWithShowNetWorkBar:(BOOL)showNetWorkBar {
    if (showNetWorkBar) {
        if (![self.appendHeaderViews containsObject:self.connectionAlertView]) {
            [self.appendHeaderViews addObject:self.connectionAlertView];
        } else {
            //不做改变
        }
    } else {
        [self.appendHeaderViews removeObject:self.connectionAlertView];
    }
    [self.tableView setTableHeaderView:[self tableViewHeaderView]];
}

- (void)showFileTrans {
    [[QIMFastEntrance sharedInstance] openFileTransMiddleVC];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _canWrite = YES;
        _willForceTableView = YES;
        _willRefreshTableView = YES;
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        _netWorkConnection = YES;
        _recentContactArray = [NSMutableArray arrayWithCapacity:20];
        _update_reader_list_queue = dispatch_queue_create("update reader list queue", 0);
        _reloadListViewQueue = dispatch_queue_create("reloadListViewQueue", 0);
        [self resigisterNSNotifications];
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withRootViewController:(id)rootVc {
    
    self = [super initWithFrame:frame];
    if (self) {
        _canWrite = YES;
        _willForceTableView = YES;
        _willRefreshTableView = YES;
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        _netWorkConnection = YES;
        if ([rootVc isKindOfClass:[QIMMainVC class]]) {
            QIMMainVC *mainVc = (QIMMainVC *)rootVc;
            _rootViewController = mainVc;
        } else if ([rootVc isKindOfClass:[UIViewController class]]) {
            _tempRootVc = rootVc;
        } else {
            
        }
        _recentContactArray = [NSMutableArray arrayWithCapacity:20];
        _update_reader_list_queue = dispatch_queue_create("update reader list queue", 0);
        _reloadListViewQueue = dispatch_queue_create("reloadListViewQueue", 0);
        [self resigisterNSNotifications];
        [self initUI];
    }
    return self;
}

- (void)resigisterNSNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeRefreshTableView:) name:kNotificationSessionListUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeRefreshTableView:) name:kNotificationSessionListRemove object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListFont:) name:kNotificationCurrentFontUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChatRoomDestroy:) name:kChatRoomDestroy object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChatSession:) name:kChatSessionDelete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stickyChatSession:) name:kChatSessionStick object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeNotifyView:) name:@"kNotifyViewCloseNotification" object:nil];
}

- (void)autoScrollTableView {
    
    if (!self.scrollTop) {
        [UIView animateWithDuration:3 animations:^{
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            
        } completion:^(BOOL finished) {
            self.scrollTop = YES;
        }];
    } else {
        [self scrollTableToFoot:YES];
        self.scrollTop = NO;
    }
}

- (void)scrollTableToFoot:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger s = [self.tableView numberOfSections];  //有多少组
        if (s<1) return;  //无数据时不执行 要不会crash
        NSInteger r = [self.tableView numberOfRowsInSection:s-1]; //最后一组有多少行
        if (r<1) return;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];  //取最后一行数据
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated]; //滚动到最后一行
    });
}

- (void)sessionViewWillAppear {
    [self refreshTableView];
#if defined (QIMNotifyEnable) && QIMNotifyEnable == 1

    [[QIMNotifyManager shareNotifyManager] setNotifyManagerGlobalDelegate:self];
#endif
}

- (void)noticeRefreshTableView:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *notifyStr = notify.object;
        QIMVerboseLog(@"收到刷新列表页的通知 : %@", notify);
//        if ([notifyStr isEqualToString:@"ForceRefresh"]) {
//            [self.tableView reloadData];
//        } else {
//            [self refreshTableView];
//        }
        [self refreshTableView];
    });
}

- (void)refreshTableView {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadTableView) object:nil];
    _willRefreshTableView = YES;
    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:DEFAULT_DELAY_TIMES];
}

#pragma mark - notify

- (void)onChatRoomDestroy:(NSNotification *)notify {
//    QIMVerboseLog(@"收到通知中心onChatRoomDestroy通知 : %@", notify);
    NSString *groupId = nil;
    id obj = notify.object;
    if ([obj isKindOfClass:[NSString class]]) {
        groupId = obj;
    }
    NSString *reason = [notify.userInfo objectForKey:@"Reason"];
    NSString *groupName = [[notify userInfo] objectForKey:@"GroupName"];
    NSString *fromNickName = [[notify userInfo] objectForKey:@"FromNickName"];
    NSString *message = nil;
    if (fromNickName.length > 0) {
        if (groupName.length > 0) {
            message = [NSString stringWithFormat:@"%@销毁了群组:%@。",fromNickName,groupName];
        } else {
            message = [NSString stringWithFormat:@"%@销毁了群组:%@。",fromNickName,groupId];
        }
    } else {
        if (groupName.length > 0) {
            message = [NSString stringWithFormat:@"[%@]群组被销毁。",groupName];
        } else {
            message = [NSString stringWithFormat:@"[%@]群组被销毁。",groupId];
        }
    }
    [self refreshTableView];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (void)reloadTableView {
    
      if (_willRefreshTableView) {
        
        dispatch_async(self.reloadListViewQueue, ^{
            @autoreleasepool {
                QIMVerboseLog(@"啊啊啊你倒是刷新呀");
                NSDictionary *friendDic = [[QIMKit sharedInstance] getLastFriendNotify];
                NSInteger friendNotifyCount = [[QIMKit sharedInstance] getFriendNotifyCount];
                NSArray *temp = [[QIMKit sharedInstance] getSessionList];
                NSMutableArray *tempStickList = [NSMutableArray array];
                NSMutableArray *normalList = [NSMutableArray array];
                BOOL isAddFN = NO;
                long long fnTime = 0;
                NSString *fnDescInfo = nil;
                if (friendDic && friendNotifyCount) {
                    
                    fnTime = [[friendDic objectForKey:@"LastUpdateTime"] longLongValue] * 1000;
                    NSString *name = [friendDic objectForKey:@"Name"];
                    if (name == nil) {
                        
                        name = @"";
                    }
                    int state = [[friendDic objectForKey:@"State"] intValue];
                    NSString *newName = [NSString stringWithFormat:@"%@为好友", name];
                    switch (state) {
                        case 0: {
                            //xxx请求添加为好友
                            fnDescInfo = [name stringByAppendingString:@"请求添加为好友"];
                        }
                            break;
                        case 1: {
                            fnDescInfo = [@"已同意添加" stringByAppendingString:newName];
                        }
                            break;
                        case 2: {
                            fnDescInfo = [@"已拒绝添加" stringByAppendingString:newName];
                        }
                            break;
                        default:
                            break;
                    }
                }
                
                for (NSDictionary *infoDic in temp) {
                    
                    long long sTime = [[infoDic objectForKey:@"MsgDateTime"] longLongValue];
                    long long msgState = [[infoDic objectForKey:@"MsgState"] longLongValue];
                    
                    if (friendDic && isAddFN == NO && fnTime > sTime) {
                        [normalList addObject:@{@"XmppId": @"FriendNotify", @"ChatType": @(ChatType_System), @"MsgType": @(1), @"MsgState": @(msgState), @"Content": fnDescInfo, @"MsgDateTime": @(fnTime)}];
                        isAddFN = YES;
                    } else {
                        [normalList addObject:infoDic];
                    }
                }
                if (friendDic && friendNotifyCount && isAddFN == NO) {
                    
                    NSDictionary *dict = @{@"XmppId": @"FriendNotify", @"ChatType": @(ChatType_System), @"MsgType": @(1), @"Content": fnDescInfo, @"MsgDateTime": @(fnTime)};
                    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [normalList addObject:mutableDict];
                }
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    weakSelf.recentContactArray = [NSMutableArray array];
//                    [weakSelf.recentContactArray addObjectsFromArray:tempStickList];
                    [weakSelf.recentContactArray addObjectsFromArray:normalList];
                    if (_willForceTableView) {
                        QIMVerboseLog(@"列表页强制刷新了!!!");
                        [self.tableView reloadData];
                        _willForceTableView = NO;
                    } else {
                        [weakSelf lazyReloadTableview];
                    }
                });
            }
        });
    }
}

- (void)showNotConnectWebView:(UITapGestureRecognizer *)tapgesture {
    
    QIMWebView *webView = [[QIMWebView alloc] init];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"NetWorkSetting" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [webView setHtmlString:htmlString];
    [self.rootViewController.navigationController pushViewController:webView animated:YES];
}

- (void)oneKeyRead {
    
    NSUInteger count = [[QIMKit sharedInstance] getAppNotReaderCount];
    if (count) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"接下来会清空所有未读消息状态,以及「@all」消息提醒，是否继续？" delegate:self cancelButtonTitle:@"继续" otherButtonTitles:@"取消", nil];
        alertView.tag = kClearAllNotReadMsg;
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前无未读消息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = kClearAllNotReadMsg;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kClearAllNotReadMsg) {
        if (buttonIndex == 0) {
           [[QIMKit sharedInstance] clearAllNoRead];
        }
    }
}

- (void)setHidden:(BOOL)hidden {
    
    [super setHidden:hidden];
    if (hidden == NO) {
        
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreBtn];
        [self.rootViewController.navigationItem setRightBarButtonItem:rightBarItem];
        if (_recentContactArray.count > 0) {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        }
    } else {
        [self.rootViewController.navigationItem setRightBarButtonItem:nil];
    }
}

#pragma mark - life ctyle

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

- (void)dealloc {
    
    _tableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification Method

- (void)lazyReloadTableview {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self.tableView
                                             selector:@selector(reloadData)
                                               object:nil];
    
    [self.tableView performSelector:@selector(reloadData)
                     withObject:nil
                     afterDelay:0.1];
    QIMVerboseLog(@"列表页终于刷新了！！！");
}

- (MBProgressHUD *)tipHUDWithText:(NSString *)text {
    if (!_tipHUD) {
        _tipHUD = [[MBProgressHUD alloc] initWithView:self];
        _tipHUD.minSize = CGSizeMake(120, 120);
        _tipHUD.minShowTime = 1;
        [_tipHUD setLabelText:@""];
        [self addSubview:_tipHUD];
    }
    [_tipHUD setDetailsLabelText:text];
    return _tipHUD;
}

- (void)closeHUD {
    if (_tipHUD) {
        [_tipHUD hide:YES];
    }
}

- (void)updateListFont:(NSNotification *)notify {
    
    [self lazyReloadTableview];
}

#pragma mark - UITableViewDelegate Method

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {//设置是否显示一个可编辑视图的视图控制器。
    
    [_tableView setEditing:editing animated:animated];//切换接收者的进入和退出编辑模式。
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [QTalkSessionCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isSelected == NO) {
        self.isSelected = YES;
        
        [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5];
        _willRefreshTableView = NO;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        _currentCell = nil;
        QTalkSessionCell *cell = (QTalkSessionCell *) [_tableView cellForRowAtIndexPath:indexPath];
        QTalkViewController *pushVc = [self sessionViewDidSelectRowAtIndexPath:indexPath infoDic:cell.infoDic];
        if ([self.rootViewController isKindOfClass:[QIMMainVC class]]) {
            [self.rootViewController.navigationController pushViewController:pushVc animated:YES];
        } else {
            UINavigationController *rootNav = [[UIApplication sharedApplication] visibleNavigationController];
            NSLog(@"跳转的RootVc1 ：%@ ", rootNav);
            if (!rootNav) {
                rootNav = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
                NSLog(@"跳转的RootVc2 ：%@ ", rootNav);
            }
            NSLog(@"跳转的RootVc3 ：%@ ", rootNav);
            NSLog(@"跳转的PushVc : %@", pushVc);
            pushVc.hidesBottomBarWhenPushed = YES;
            [rootNav pushViewController:pushVc animated:YES];
        }
        _willRefreshTableView = YES;
    }
}

- (void)repeatDelay {
    self.isSelected = NO;
}

//返回表格视图是否可以编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_recentContactArray];
    if (indexPath.row < tempArray.count && indexPath.row >= 0) {
        QTalkSessionCell *cell = (QTalkSessionCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell refreshUI];
        NSDictionary *infoDic = [tempArray objectAtIndex:indexPath.row];
        ChatType chatType = [[infoDic objectForKey:@"ChatType"] intValue];
        NSString *jid = [infoDic objectForKey:@"XmppId"];
        if (chatType != ChatType_PublicNumber) {
            
            return @[cell.deleteBtn, cell.stickyBtn];
        }
        if ([jid hasPrefix:@"FriendNotify"]) {
            
            return @[cell.deleteBtn];
        }
    }
    return nil;
}

- (UIBezierPath *)transformToBezierPath:(NSString *)string {
    CGMutablePathRef paths = CGPathCreateMutable();
    CFStringRef fontNameRef = CFSTR("Zapfino");
    CTFontRef fontRef = CTFontCreateWithName(fontNameRef, 35, nil);
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:@{(__bridge NSString *) kCTFontAttributeName: (__bridge UIFont *) fontRef}];
    CTLineRef lineRef = CTLineCreateWithAttributedString((CFAttributedStringRef) attrString);
    CFArrayRef runArrRef = CTLineGetGlyphRuns(lineRef);
    
    for (int runIndex = 0; runIndex < CFArrayGetCount(runArrRef); runIndex++) {
        const void *run = CFArrayGetValueAtIndex(runArrRef, runIndex);
        CTRunRef runb = (CTRunRef) run;
        
        const void *CTFontName = kCTFontAttributeName;
        
        const void *runFontC = CFDictionaryGetValue(CTRunGetAttributes(runb), CTFontName);
        CTFontRef runFontS = (CTFontRef) runFontC;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        int temp = 0;
        CGFloat offset = .0;
        
        for (int i = 0; i < CTRunGetGlyphCount(runb); i++) {
            CFRange range = CFRangeMake(i, 1);
            CGGlyph glyph = 0;
            CTRunGetGlyphs(runb, range, &glyph);
            CGPoint position = CGPointZero;
            CTRunGetPositions(runb, range, &position);
            
            CGFloat temp3 = position.x;
            int temp2 = (int) temp3 / width;
            CGFloat temp1 = 0;
            
            if (temp2 > temp1) {
                temp = temp2;
                offset = position.x - (CGFloat) temp;
            }
            
            CGPathRef path = CTFontCreatePathForGlyph(runFontS, glyph, nil);
            CGFloat x = position.x - (CGFloat) temp * width - offset;
            CGFloat y = position.y - (CGFloat) temp * 80;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
            CGPathAddPath(paths, &transform, path);
            
            CGPathRelease(path);
        }
        CFRelease(runb);
        CFRelease(runFontS);
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath appendPath:[UIBezierPath bezierPathWithCGPath:paths]];
    
    CGPathRelease(paths);
    CFRelease(fontNameRef);
    CFRelease(fontRef);
    
    return bezierPath;
}

- (QTalkViewController *)sessionViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *infoDic = [self.recentContactArray objectAtIndex:indexPath.row];
    return [self sessionViewDidSelectRowAtIndexPath:indexPath infoDic:infoDic];
}

- (QTalkViewController *)sessionViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath infoDic:(NSDictionary *)infoDic {
    
    NSString *jid = [infoDic objectForKey:@"XmppId"];
    NSString *name = [infoDic objectForKey:@"Name"];
    ChatType chatType = [[infoDic objectForKey:@"ChatType"] intValue];
    NSInteger notReadCount = [[QIMKit sharedInstance] getNotReadMsgCountByJid:jid];
    if (jid) {
        
        switch (chatType) {
                
            case ChatType_GroupChat: {
                QIMGroupChatVC *chatGroupVC = (QIMGroupChatVC *)[[QIMFastEntrance sharedInstance] getGroupChatVCByGroupId:jid];
                /*
                QIMGroupChatVC *chatGroupVC = [[QIMGroupChatVC alloc] init];
                [chatGroupVC setTitle:name];
                [chatGroupVC setChatId:jid];
                 */
                [chatGroupVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatGroupVC setNotReadCount:notReadCount];
                [chatGroupVC setReadedMsgTimeStamp:-1];
                
                if (chatGroupVC.needShowNewMsgTagCell) {
                    
                    chatGroupVC.readedMsgTimeStamp = [[QIMKit sharedInstance] getReadedTimeStampForUserId:chatGroupVC.chatId WihtMsgDirection:MessageDirection_Received WithReadedState:MessageState_didRead];
                }
                return chatGroupVC;
            }
                break;
            case ChatType_System: {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [[QIMKit sharedInstance] clearNotReadMsgByJid:jid];
                });
                if ([jid hasPrefix:@"FriendNotify"]) {
                    
                    QIMFriendNotifyViewController *friendVC = [[QIMFriendNotifyViewController alloc] init];
                    return friendVC;
                }  else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                    QIMWebView *webView = [[QIMWebView alloc] init];
                    webView.needAuth = YES;
                    webView.fromOrderManager = YES;
                    webView.navBarHidden = YES;
                    webView.url = [[QIMKit sharedInstance] qimNav_QcGrabOrder];
                    return webView;
                } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                    QIMWebView *webView = [[QIMWebView alloc] init];
                    webView.needAuth = YES;
                    webView.navBarHidden = YES;
                    [[QIMKit sharedInstance] clearNotReadMsgByJid:jid];
                    webView.url = [[QIMKit sharedInstance] qimNav_QcOrderManager];
                    return webView;
                } else {
                    
                    QIMSystemVC *chatSystemVC = [[QIMSystemVC alloc] init];
                    [chatSystemVC setChatType:ChatType_System];
                    [chatSystemVC setChatId:jid];
                    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
                        
                        if ([jid hasPrefix:@"rbt-notice"]) {
                            [chatSystemVC setTitle:@"公告通知"];
                        } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                            [chatSystemVC setTitle:@"抢单通知"];
                        } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                            [chatSystemVC setTitle:@"抢单"];
                        } else {
                            [chatSystemVC setTitle:@"系统消息"];
                        }
                    } else {
                        
                        [chatSystemVC setTitle:@"系统消息"];
                    }
                    return chatSystemVC;
                }
            }
                break;
            case ChatType_SingleChat: {
                QIMChatVC *chatSingleVC = (QIMChatVC *)[[QIMFastEntrance sharedInstance] getSingleChatVCByUserId:jid];
                /*
                QIMChatVC *chatSingleVC = [[QIMChatVC alloc] init];
                [chatSingleVC setStype:kSessionType_Chat];
                [chatSingleVC setChatId:jid];
                [chatSingleVC setName:name];
                [chatSingleVC setChatInfoDict:infoDic];
                [chatSingleVC setChatType:chatType];
                */
                NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
                [chatSingleVC setTitle:remarkName ? remarkName : name];
                [chatSingleVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatSingleVC setReadedMsgTimeStamp:-1];
                [chatSingleVC setNotReadCount:notReadCount];
                if (chatSingleVC.needShowNewMsgTagCell) {
                    
                    chatSingleVC.readedMsgTimeStamp = [[QIMKit sharedInstance] getReadedTimeStampForUserId:jid WihtMsgDirection:MessageDirection_Received WithReadedState:MessageState_didRead];
                }
                return chatSingleVC;
            }
                break;
            case ChatType_Consult:
            {
                NSString *xmppId = [infoDic objectForKey:@"XmppId"];
                /*
                NSString *uId = [xmppId componentsSeparatedByString:@"@"].firstObject;
                NSString *realJid = [infoDic objectForKey:@"RealJid"];
                if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
                    NSString *getRealJid = [[QIMKit sharedInstance] getRealJidForVirtual:xmppId];
                    if (getRealJid.length) {
                        realJid = getRealJid;
                    }
                } else {
                    if ([[[QIMKit sharedInstance] getVirtualList] containsObject:uId]) {
                        realJid = [[QIMKit sharedInstance] getRealJidForVirtual:uId];
                        realJid = [NSString stringWithFormat:@"%@@%@",realJid,[[QIMKit sharedInstance] getDomain]];
                    }
                    if (realJid == nil) {
                        realJid = [infoDic objectForKey:@"RealJid"];
                    }
                    if (realJid == nil) {
                        realJid = xmppId;
                    }
                }
                */
                QIMChatVC *chatSingleVC = (QIMChatVC *)[[QIMFastEntrance sharedInstance] getSingleChatVCByUserId:jid];
                /*
                QIMChatVC *chatSingleVC = [[QIMChatVC alloc] init];
                [chatSingleVC setStype:kSessionType_Chat];
                [chatSingleVC setChatId:xmppId];
                [chatSingleVC setVirtualJid:xmppId];
                [chatSingleVC setName:name];
                [chatSingleVC setChatInfoDict:infoDic];
                [chatSingleVC setChatType:chatType];
                */
                //备注
                NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
                [chatSingleVC setTitle:remarkName ? remarkName : name];
                [chatSingleVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatSingleVC setReadedMsgTimeStamp:-1];
                [chatSingleVC setNotReadCount:notReadCount];
                if (chatSingleVC.needShowNewMsgTagCell) {
                    
                    chatSingleVC.readedMsgTimeStamp = [[QIMKit sharedInstance] getReadedTimeStampForUserId:jid WihtMsgDirection:MessageDirection_Received WithReadedState:MessageState_didRead];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [[QIMKit sharedInstance] clearNotReadMsgByJid:xmppId ByRealJid:xmppId];
                });
                return chatSingleVC;
            }
                break;
            case ChatType_ConsultServer: {
                NSString *realJid = [infoDic objectForKey:@"RealJid"];
                NSString *xmppId = [infoDic objectForKey:@"XmppId"];
                QIMChatVC *chatSingleVC = [[QIMChatVC alloc] init];
                [chatSingleVC setStype:kSessionType_Chat];
                [chatSingleVC setChatId:realJid];
                [chatSingleVC setVirtualJid:xmppId];
                [chatSingleVC setChatInfoDict:infoDic];
                [chatSingleVC setChatType:chatType];
                //备注
                NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
                [chatSingleVC setTitle:remarkName ? remarkName : name];
                [chatSingleVC setNeedShowNewMsgTagCell:notReadCount > 10];
                [chatSingleVC setReadedMsgTimeStamp:-1];
                [chatSingleVC setNotReadCount:notReadCount];
                if (chatSingleVC.needShowNewMsgTagCell) {
                    
                    chatSingleVC.readedMsgTimeStamp = [[QIMKit sharedInstance] getReadedTimeStampForUserId:jid WihtMsgDirection:MessageDirection_Received WithReadedState:MessageState_didRead];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [[QIMKit sharedInstance] clearNotReadMsgByJid:xmppId ByRealJid:realJid];
                });
                return chatSingleVC;
            }
                break;
            case ChatType_PublicNumber: {
                QIMPublicNumberVC *chatPublicNumVC = [[QIMPublicNumberVC alloc] init];
                return chatPublicNumVC;
            }
                break;
            case ChatType_CollectionChat: {
#warning 代收消息
                QIMCollectionChatViewController *chatPublicNumVC = [[QIMCollectionChatViewController alloc] init];
                return chatPublicNumVC;
            }
                break;
            default:
                break;
        }
    }
    return nil;
}

- (NSString *)sessionViewTitleDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *infoDic = [_recentContactArray objectAtIndex:indexPath.row];
    NSString *name = [infoDic objectForKey:@"Name"];
    if (name) {
        return name;
    } else {
        return @"系统消息";
    }
}

#pragma mark - UITableViewDataSource Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    QIMVerboseLog(@"确实刷新了");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_recentContactArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = nil;
    if (self.recentContactArray.count >= indexPath.row && self.recentContactArray.count >= 1) {
        dict = [self.recentContactArray objectAtIndex:indexPath.row];
    }
    if (!dict) {
        return [QTalkSessionCell new];
    }
    NSString *chatId = [dict objectForKey:@"XmppId"];
    NSString *realJid = [dict objectForKey:@"RealJid"];
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell ChatId(%@) RealJid(%@) %d", chatId, realJid, indexPath.row];
    QTalkSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[QTalkSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.firstRefresh = YES;
    } else {
        cell.firstRefresh = NO;
    }
    [cell setIndexPath:indexPath];
    [cell setAccessibilityIdentifier:chatId];
    cell.infoDic = dict;
    cell.sessionScrollDelegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //请求数据源提交的插入或删除指定行接收者。
    if (editingStyle == UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        
        if (indexPath.row < [_recentContactArray count]) {
            
            NSDictionary *infoDic = [_recentContactArray objectAtIndex:indexPath.row];
            NSString *jid = [infoDic objectForKey:@"XmppId"];
            ChatType chatType = [[infoDic objectForKey:@"ChatType"] longValue];
            if (jid && (chatType != ChatType_Consult || chatType != ChatType_ConsultServer)) {
                
                _willRefreshTableView = NO;
                [[QIMKit sharedInstance] removeSessionById:jid];
                _willRefreshTableView = YES;
                [_recentContactArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
            } else {
                NSString *realJid = [infoDic objectForKey:@"RealJid"];
                _willRefreshTableView = NO;
                [[QIMKit sharedInstance] removeConsultSessionById:jid RealId:realJid];
                _willRefreshTableView = YES;
                [_recentContactArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
            }
        }
    }
}

#pragma mark - QIMSessionScrollDelegate

- (void)stickyChatSession:(NSNotification *)notify {
    
    QIMVerboseLog(@"QTalkSessionView：%@", notify.name);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger row = [_recentContactArray indexOfObject:notify.object];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        _willRefreshTableView = NO;
        [self stickySession:indexPath];
        _willRefreshTableView = YES;
    });
}

- (void)deleteChatSession:(NSNotification *)notify {
    
    QIMVerboseLog(@"QTalkSessionView：%@", notify.name);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger row = [_recentContactArray indexOfObject:notify.object];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        _willRefreshTableView = NO;
        [self deleteSession:indexPath];
        _willRefreshTableView = YES;
    });
}

//置顶会话

- (void)stickySession:(NSIndexPath *)indexPath {
    
    QTalkSessionCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    ChatType chatType = cell.chatType;
    NSString *combineJid = cell.combineJid;
    NSDictionary *dict = @{@"topType":@(![[QIMKit sharedInstance] isStickWithCombineJid:combineJid]), @"chatType":@(cell.chatType)};
    NSString *value = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
    [[QIMKit sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:value WithDel:[[QIMKit sharedInstance] isStickWithCombineJid:combineJid]];
}

- (void)deleteStick:(NSIndexPath *)indexPath {
    QTalkSessionCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    ChatType chatType = cell.chatType;
    NSString *combineJid = cell.combineJid;
    NSDictionary *dict = @{@"topType":@(NO), @"chatType":@(cell.chatType)};
    NSString *value = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
    [[QIMKit sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:value WithDel:YES];
}

//删除会话
- (void)deleteSession:(NSIndexPath *)indexPath {
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_recentContactArray];
    if (indexPath.row < [tempArray count]) {
        NSDictionary *infoDic = [tempArray objectAtIndex:indexPath.row];
        NSString *sid = [infoDic objectForKey:@"XmppId"];
        ChatType chatType = [[infoDic objectForKey:@"ChatType"] longValue];
        if (sid && (chatType != ChatType_Consult && chatType != ChatType_ConsultServer)) {
            _willRefreshTableView = NO;
            [self deleteStick:indexPath];
            [[QIMKit sharedInstance] removeSessionById:sid];
            if (![sid isEqualToString:@"FriendNotify"]) {
                _willRefreshTableView = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView beginUpdates];
                [tempArray removeObjectAtIndex:indexPath.row];
                _recentContactArray = tempArray;
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
                [_tableView endUpdates];
            });
        } else {
            NSString *realJid = [infoDic objectForKey:@"RealJid"];
            _willRefreshTableView = NO;
            [[QIMKit sharedInstance] removeConsultSessionById:sid RealId:realJid];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView beginUpdates];
                [tempArray removeObjectAtIndex:indexPath.row];
                _recentContactArray = tempArray;
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
                [_tableView endUpdates];
            });
        }
    }
}

- (void)prepareNotReaderIndexPathList {
    dispatch_async(self.update_reader_list_queue, ^{
        if (!self.notReaderIndexPathList) {
            self.notReaderIndexPathList = [NSMutableArray arrayWithCapacity:3];
        }
        [self.notReaderIndexPathList removeAllObjects];
        int i = 0;
        NSArray *arr = [NSArray arrayWithArray:_recentContactArray];
        NSMutableArray *temoNotReadList = [[NSMutableArray alloc] initWithCapacity:3];
        for (NSDictionary *infoDic in arr) {
            NSString *jid = [[infoDic objectForKey:@"XmppId"] copy];
            NSInteger count = [[QIMKit sharedInstance] getNotReadMsgCountByJid:jid];
            if (count > 0) {
                [temoNotReadList addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            i++;
        }
        self.notReaderIndexPathList = [NSMutableArray arrayWithArray:temoNotReadList];
        self.needUpdateNotReadList = NO;
        [self scrollToNotReadMsg];
    });
}

- (void)scrollToNotReadMsg {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *tempNotReaderIndexPathList = [[NSArray alloc] initWithArray:self.notReaderIndexPathList];
        if ([tempNotReaderIndexPathList count] <= 0) {
            //
            // 如果就木有，那么随便了，你可以在这里增加各种逻辑
        } else {
            
            NSIndexPath *totalBeginPath = nil;
            NSIndexPath *totalEndPath = nil;
            
            NSInteger nSections = [_tableView numberOfSections];
            if (nSections > 0) {
                
                totalBeginPath = [NSIndexPath indexPathForRow:0 inSection:0];
                
                for (int section = 0; section < nSections; section++) {
                    NSInteger rows = [_tableView numberOfRowsInSection:section];
                    totalEndPath = [NSIndexPath indexPathForRow:rows - 1 inSection:section];
                }
            }
            
            NSIndexPath *firstPath = [[_tableView indexPathsForVisibleRows] firstObject];
            NSIndexPath *lastPath = [[_tableView indexPathsForVisibleRows] lastObject];
            
            NSIndexPath *firstUnreadPath = [tempNotReaderIndexPathList firstObject];
            NSIndexPath *lastUnreadPath = [tempNotReaderIndexPathList lastObject];
            if (lastPath == totalEndPath) {
                [_tableView scrollToRowAtIndexPath:firstUnreadPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            } else {
                if (lastUnreadPath.row <= firstPath.row) {
                    //
                    // 如果最后一条未读 在当前可视的上面，那么就轮到最前面一条
                    [_tableView scrollToRowAtIndexPath:firstUnreadPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                } else {
                    
                    NSIndexPath *currentPath = [NSIndexPath indexPathForRow:firstPath.row + 1 inSection:0];
                    
                    while (YES) {
                        if ([tempNotReaderIndexPathList containsObject:currentPath]) {
                            [_tableView scrollToRowAtIndexPath:currentPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            break;
                        }
                        currentPath = [NSIndexPath indexPathForRow:currentPath.row + 1 inSection:0];
                    }
                }
            }
        }
    });
}

- (void)selectIndexPathRow:(NSInteger )index {
    QIMVerboseLog(@"右上角快捷入口%s , %ld", __func__, index);
    NSString *moreActionId = [self.moreActionArray objectAtIndex:index];
    if ([moreActionId isEqualToString:@"扫一扫"]) {
        [QIMFastEntrance openQRCodeVC];
    } else if ([moreActionId isEqualToString:@"发起聊天"]) {
        [QIMFastEntrance openQIMGroupListVC];
    } else if ([moreActionId isEqualToString:@"一键已读"]) {
        [self oneKeyRead];
    } else if ([moreActionId isEqualToString:@"随记"]) {
        [QIMFastEntrance openQTalkNotesVC];
    } else if ([moreActionId isEqualToString:@"Wiki"]) {
        if ([[QIMKit sharedInstance] qimNav_WikiUrl].length > 0) {
            [QIMFastEntrance openWebViewForUrl:[[QIMKit sharedInstance] qimNav_WikiUrl] showNavBar:YES];
        }
    } else {
        
    }
}

#if defined (QIMNotifyEnable) && QIMNotifyEnable == 1

- (void)showGloablNotifyWithView:(QIMNotifyView *)view {
    QIMVerboseLog(@"showGloablNotifyWithViewDelegate :%@", view);
    if ([self.appendHeaderViews containsObject:view]) {
        [self.appendHeaderViews removeObject:view];
    }
    [self.appendHeaderViews addObject:view];
    [self updateTableViewHeaderView];
}

- (void)closeNotifyView:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMNotifyView *notifyView = notify.object;
        [self.appendHeaderViews removeObject:notifyView];
        [self updateTableViewHeaderView];
    });
}

#endif
- (void)updateTableViewHeaderView {
    [self.tableView setTableHeaderView:[self tableViewHeaderView]];
}

@end
