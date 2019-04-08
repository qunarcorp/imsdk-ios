//
//  QIMMessageHelperVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/6/29.
//
//

#import "QIMMessageHelperVC.h"
#import "QIMCollectionChatViewController.h"
#import "QTalkSessionCell.h"
#import "QIMPublicNumberVC.h"
#import "QIMChatVC.h"
#import "QIMWebView.h"
#import "QIMGroupChatVC.h"
#import "QIMFriendNotifyViewController.h"
#import "QIMSystemVC.h"
#import "NSBundle+QIMLibrary.h"
#import "UIApplication+QIMApplication.h"

@interface QIMMessageHelperVC ()<UITableViewDataSource,UITableViewDelegate,QIMSessionScrollDelegate >{
    UITableView *_tableView;
    NSMutableArray *_recentContactArray;
    BOOL _willRefreshTableview;
}

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation QIMMessageHelperVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNSNotifications];
    [self initWithNav];

    _willRefreshTableview = YES;
    [self getNotReadMsgList];
    if (_recentContactArray.count <= 0) {
        [self loadEmptyNotReadMsgList];
    } else {
        [self initWithTableView];
        [_tableView reloadData];
    }
}

- (void)registerNSNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:kNotificationSessionListUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:kNotificationSessionListRemove object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:kGroupNickNameChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - init ui

- (void)initWithNav{
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_not_read"]];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
}

- (void)getNotReadMsgList {
    [_recentContactArray removeAllObjects];
    _recentContactArray = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getNotReadSessionList]];
}

#pragma mark - notify

- (void)updateNotReadMsgList {
    [self getNotReadMsgList];
    [_tableView reloadData];
}

- (void)reloadTableView{
    if (_willRefreshTableview) {
        [self updateNotReadMsgList];
        if (_recentContactArray.count <= 0) {
            [self loadEmptyNotReadMsgList];
            self.emptyView.hidden = NO;
        } else {
            self.emptyView.hidden = YES;
            if (!_tableView) {
                [self initWithTableView];
            }
            [_tableView reloadData];
        }
    }
}

- (void)loadEmptyNotReadMsgList {
    [self.emptyView removeAllSubviews];
    [self.emptyView removeFromSuperview];
    self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 130)];
    self.emptyView.backgroundColor = [UIColor whiteColor];
    self.emptyView.center = self.view.center;
    UIImageView *emptyIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    emptyIconView.backgroundColor = [UIColor whiteColor];
    emptyIconView.image = [UIImage imageNamed:@"EmptyNotReadList"];
    [self.emptyView addSubview:emptyIconView];
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyIconView.bottom + 5, 150, 25)];
    [emptyLabel setText:@"当前无未读消息"];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyView addSubview:emptyLabel];
    [self.view addSubview:self.emptyView];
    [self.view bringSubviewToFront:self.emptyView];
}

-(void)refreshTableView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadTableView) object:nil];
    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:DEFAULT_DELAY_TIMES];
}

- (void)updateUserCell:(NSNotification *)notify{
    NSString *userId = [notify object];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL bNeedDisplay = FALSE;
        NSUInteger rowIndex = 0;
        for (NSDictionary * sessionDict in _recentContactArray) {
            if ([userId isEqualToString:[sessionDict objectForKey:@"id"]]) {
                bNeedDisplay = YES;
                break;
            }
            rowIndex++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(bNeedDisplay == YES) {
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    });
}
#pragma mark - table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _recentContactArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [QTalkSessionCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = nil;
    if (_recentContactArray >= indexPath.row && _recentContactArray.count >= 1) {
        dict = [_recentContactArray objectAtIndex:indexPath.row];
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

- (QTalkViewController *)sessionViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath infoDic:(NSDictionary *)infoDic {
    
    NSString *jid = [infoDic objectForKey:@"XmppId"];
    NSString *name = [infoDic objectForKey:@"Name"];
    ChatType chatType = [[infoDic objectForKey:@"ChatType"] intValue];
    NSInteger notReadCount = [[QIMKit sharedInstance] getNotReadMsgCountByJid:jid];
    if (jid) {
        
        switch (chatType) {
                
            case ChatType_GroupChat: {
                QIMGroupChatVC *chatGroupVC = (QIMGroupChatVC *)[[QIMFastEntrance sharedInstance] getGroupChatVCByGroupId:jid];
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
                QIMChatVC *chatSingleVC = (QIMChatVC *)[[QIMFastEntrance sharedInstance] getSingleChatVCByUserId:jid];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QTalkSessionCell *cell = (QTalkSessionCell *) [_tableView cellForRowAtIndexPath:indexPath];
    QTalkViewController *pushVc = [self sessionViewDidSelectRowAtIndexPath:indexPath infoDic:cell.infoDic];
    
    UINavigationController *rootNav = [[UIApplication sharedApplication] visibleNavigationController];
    if (!rootNav) {
        rootNav = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
    }
    pushVc.hidesBottomBarWhenPushed = YES;
    [rootNav pushViewController:pushVc animated:YES];
    [self updateNotReadMsgList];
}

#pragma mark - 删除

//要求委托方的编辑风格在表视图的ji一个特定的位置。
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;//默认没有编辑风格
    return result;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{//设置是否显示一个可编辑视图的视图控制器。
    [super setEditing:editing animated:animated];
    [_tableView setEditing:editing animated:animated];//切换接收者的进入和退出编辑模式。
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{//请求数据源提交的插入或删除指定行接收者。
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        if (indexPath.row < [_recentContactArray count]) {
            NSDictionary *infoDic = [_recentContactArray objectAtIndex:indexPath.row];
            NSString *sid = [infoDic objectForKey:@"XmppId"];
            if (sid) {
                _willRefreshTableview = NO;
                [[QIMKit sharedInstance] removeSessionById:sid];
                _willRefreshTableview = YES;
                [_recentContactArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
            }
        }
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
