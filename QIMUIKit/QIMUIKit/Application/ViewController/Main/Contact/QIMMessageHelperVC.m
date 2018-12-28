//
//  QIMMessageHelperVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/6/29.
//
//

#import "QIMMessageHelperVC.h"

#import "QTalkSessionCell.h"

#import "QIMChatVC.h"

#import "QIMGroupChatVC.h"

#import "QIMSystemVC.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMMessageHelperVC ()<UITableViewDataSource,UITableViewDelegate,QIMSessionScrollDelegate >{
    UITableView *_tableView;
    NSMutableArray *_recentContactArray;
    BOOL _willRefreshTableview;
    NSIndexPath *_swIndexPath;
    QTalkSessionCell *_currentCell;
}

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation QIMMessageHelperVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNSNotifications];
    [self initWithNav];

    _willRefreshTableview = YES;
    [self updateNotReadMsgList];
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

#pragma mark - notify

- (void)updateNotReadMsgList
{
    [_recentContactArray removeAllObjects];
    _recentContactArray = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getNotReaderMsgList]];
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
    NSMutableDictionary * dict =  [_recentContactArray objectAtIndex:indexPath.row];
    ChatType chatType = [[dict objectForKey:@"ChatType"] intValue];
//    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell ChatType(%d)",chatType];
    NSString *chatId = [dict objectForKey:@"XmppId"];
    NSString *realJid = [dict objectForKey:@"RealJid"];
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell ChatId(%@) RealJid(%@) %d", chatId, realJid, indexPath.row];
    QTalkSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QTalkSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setContainingTableView:tableView];
    }
    cell.sessionScrollDelegate = self;
    [cell setInfoDic:dict];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _swIndexPath = nil;
    _currentCell = nil;
    
    NSDictionary *infoDic = [_recentContactArray objectAtIndex:indexPath.row];
    NSString *jid = [infoDic objectForKey:@"XmppId"];
    NSString *name = [infoDic objectForKey:@"Name"];
    ChatType chatType = [[infoDic objectForKey:@"ChatType"] intValue];
    int notReadCount = [[QIMKit sharedInstance] getNotReadMsgCountByJid:jid];
    
    
    QTalkSessionCell *cell = (QTalkSessionCell *)[tableView cellForRowAtIndexPath:indexPath];
    switch (chatType) {
        case ChatType_GroupChat:
        {
            [[QIMKit sharedInstance] clearNotReadMsgByGroupId:jid];
            [QIMFastEntrance openGroupChatVCByGroupId:jid];
            /*
            QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
            [chatGroupVC setTitle:name];
            [chatGroupVC setChatId:jid];
            [self.navigationController pushViewController:chatGroupVC animated:YES];
             */
        }
            break;
        case ChatType_SingleChat:
        {
            [[QIMKit sharedInstance] clearNotReadMsgByJid:jid];
            [QIMFastEntrance openSingleChatVCByUserId:jid];
            /*
            QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
            [chatVC setStype:kSessionType_Chat];
            [chatVC setChatId:jid];
            [chatVC setName:name];
            [chatVC setTitle:name];
            [chatVC setChatType:ChatType_SingleChat];
            [self.navigationController pushViewController:chatVC animated:YES];
             */
        }
            break;
        case ChatType_ConsultServer:
        case ChatType_Consult:
        {
            NSString *xmppId = [infoDic objectForKey:@"XmppId"];
            NSString *realJid = [infoDic objectForKey:@"RealJid"];
            if (chatType == ChatType_Consult) {
                [[QIMKit sharedInstance] clearNotReadMsgByJid:xmppId ByRealJid:xmppId];
            } else if (chatType == ChatType_ConsultServer) {
                [[QIMKit sharedInstance] clearNotReadMsgByJid:xmppId ByRealJid:realJid];
            }
            [QIMFastEntrance openGroupChatVCByGroupId:nil];
            QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
            [chatVC setStype:kSessionType_Chat];
            [chatVC setChatId:realJid];
            [chatVC setVirtualJid:xmppId];
            [chatVC setName:name];
            [chatVC setTitle:name];
            [chatVC setChatType:chatType];
            [self.navigationController pushViewController:chatVC animated:YES];
        }
            break;
        case ChatType_System:
        {
            [[QIMKit sharedInstance] clearNotReadMsgByJid:jid];
            [QIMFastEntrance openHeaderLineVCByJid:jid];
            /*
            QIMSystemVC * chatVC  = [[QIMSystemVC alloc] init];
            [chatVC setChatId:jid];
            [chatVC setName:@"系统消息"];
            [chatVC setTitle:@"系统消息"];
            [self.navigationController pushViewController:chatVC animated:YES];
             */
        }
            break;
        case ChatType_PublicNumber:
        {
            
        }
            break;
        default:
            break;
    }
    [self updateNotReadMsgList];
    [tableView reloadData];
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
