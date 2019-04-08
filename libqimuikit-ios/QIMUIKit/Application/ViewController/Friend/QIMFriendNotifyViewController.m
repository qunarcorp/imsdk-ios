//
//  QIMFriendNotifyViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMFriendNotifyViewController.h"
#import "QIMFriendNotifyCell.h"
#import "QIMAddFriendViewController.h"
#import "QIMChatVC.h"
#import "MBProgressHUD.h"
@interface QIMFriendNotifyViewController()<UITableViewDelegate,UITableViewDataSource,QIMFriendNotifyCellDelete>{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    
    NSDictionary *_currentAgreeDic;
    MBProgressHUD *_progressHUD;
}

@end

@implementation QIMFriendNotifyViewController

- (void)onReceiveFriendPresence:(NSNotification *)notify{
    NSString *jid = [_currentAgreeDic objectForKey:@"XmppId"];
    if ([jid isEqualToString:notify.object]) {
        NSDictionary *presenceDic = notify.userInfo;
        NSString *result = [presenceDic objectForKey:@"result"];
        NSString *reason = [presenceDic objectForKey:@"reason"];
        if ([result isEqualToString:@"success"]) {
            [self openChatSession];
            [[QIMKit sharedInstance] sendMessage:@"我通过了你的朋友验证请求，现在我们可以开始聊天了" WithInfo:nil ToUserId:jid WihtMsgType:QIMMessageType_Text];
        } else {
            [[self progressHUD] hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"添加好友失败,原因:%@。",reason] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveFriendPresence:) name:kFriendPresence object:nil];
    _dataSource = [[QIMKit sharedInstance] selectFriendNotifys];
    [self initWithNav];
    [self initWithTableView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init UI
- (void)initWithNav{
    [self.navigationItem setTitle:@"新朋友"];
}
- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    if ([[QIMKit sharedInstance] getIsIpad]) {
        _tableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] qim_rightWidth], [[UIScreen mainScreen] height]);
    }
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
}

- (void)openChatSession{
    NSString *xmppid = [_currentAgreeDic objectForKey:@"XmppId"];
//    NSString *name = [_currentAgreeDic objectForKey:@"Name"];
    [[QIMKit sharedInstance] openChatSessionByUserId:xmppid];
    [QIMFastEntrance openSingleChatVCByUserId:xmppid];
    /*
    QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
    [chatVC setStype:kSessionType_Chat];
    [chatVC setChatId:xmppid];
    [chatVC setName:name];
    [chatVC setTitle:name];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
    [self.navigationController popToRootVCThenPush:chatVC animated:YES];
     */
}

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [_progressHUD setLabelText:@""];
        [_progressHUD setDetailsLabelText:@"请稍等..."];
        [self.view addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)agreeAddFriendWihtUserInfoDic:(NSDictionary *)userInfoDic{
    NSString *xmppId = [userInfoDic objectForKey:@"XmppId"];
    if (xmppId.length > 0) {
        _currentAgreeDic = userInfoDic;
        [[self progressHUD] show:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] agreeFriendRequestWithXmppId:xmppId];
        });
    }
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [QIMFriendNotifyCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"Notify Cell";
    QIMFriendNotifyCell *nodeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nodeCell == nil) {
        nodeCell = [[QIMFriendNotifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [nodeCell setDelegate:self];
    }
    [nodeCell setUserDic:[_dataSource objectAtIndex:indexPath.row]];
    [nodeCell refreshUI];
    return nodeCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *userInfoDic = [_dataSource objectAtIndex:indexPath.row];
    if ([[userInfoDic objectForKey:@"XmppId"] length] > 0) { 
        QIMAddFriendViewController *afVC = [[QIMAddFriendViewController alloc] init];
        [afVC setUserInfoDic:[_dataSource objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:afVC animated:YES];
    }
}

@end
