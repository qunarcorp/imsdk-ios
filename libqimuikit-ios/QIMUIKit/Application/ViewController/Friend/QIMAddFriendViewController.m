//
//  QIMAddFriendViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/11/18.
//
//

#import "QIMAddFriendViewController.h"
#import "QIMChatVC.h"
#import "MBProgressHUD.h"

@interface QIMAddFriendViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    MBProgressHUD *_progressHUD;
}

@end

@implementation QIMAddFriendViewController

- (void)onReceiveFriendPresence:(NSNotification *)notify{
    NSString *xmppId = [self.userInfoDic objectForKey:@"XmppId"];
    if ([xmppId isEqualToString:notify.object]) {
        NSDictionary *presenceDic = notify.userInfo;
        NSString *result = [presenceDic objectForKey:@"result"];
        NSString *reason = [presenceDic objectForKey:@"reason"];
        if ([result isEqualToString:@"success"]) {
            [self openChatSession];
        } else {
            [[self progressHUD] hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"添加好友失败,原因:%@。",reason] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveFriendPresence:) name:kFriendPresence object:nil];
    
    [self initWithNav];
    [self initTableView];
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
    [self.navigationItem setTitle:@"好友申请"];
}

- (void)initTableView{ 
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor qim_colorWithHex:0xeaeaea alpha:1]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
}

- (UIView *)getContentView{
    
    NSString *jid = [self.userInfoDic objectForKey:@"XmppId"];
    NSString *name = [self.userInfoDic objectForKey:@"Name"];
    NSString *descInfo = [self.userInfoDic objectForKey:@"DescInfo"];
    int state = [[self.userInfoDic objectForKey:@"State"] intValue];
    NSString *addMsg = [self.userInfoDic objectForKey:@"UserInfo"];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, _tableView.height)];
    
    CGFloat startY = 0;
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.width, 60)];
        [headerView setBackgroundColor:[UIColor whiteColor]];
        [contentView addSubview:headerView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHeaderViewClick)];
        [headerView addGestureRecognizer:tap];
        
        UIImageView *headerImageView = [[YLImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [headerImageView setClipsToBounds:YES];
        [headerImageView.layer setCornerRadius:20];
//        [headerImageView setImage:[[QIMKit sharedInstance] getUserHeaderImageByUserId:jid]];
        [headerImageView qim_setImageWithJid:jid];
        [headerView addSubview:headerImageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerImageView.right + 10, 10, contentView.width - headerImageView.right - 10 - 30, 20)];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
        [titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [titleLabel setText:name];
        [headerView addSubview:titleLabel];
        
        UILabel *descInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerImageView.right + 10, 30, titleLabel.width, 20)];
        [descInfoLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [descInfoLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [descInfoLabel setBackgroundColor:[UIColor clearColor]];
        [descInfoLabel setFont:[UIFont systemFontOfSize:12]];
        [descInfoLabel setTextColor:[UIColor qtalkTextLightColor]];
        [descInfoLabel setText:descInfo];
        [headerView addSubview:descInfoLabel];
        
        YLImageView *arrowImageView = [[YLImageView alloc] initWithFrame:CGRectMake(contentView.width - 23, 20, 13, 20)];
        [arrowImageView setImage:[UIImage imageNamed:@"arrow_right"]];
        [headerView addSubview:arrowImageView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.height-0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [headerView addSubview:lineView];
        
        startY += 60;
    }
    
    { // 附加消息 Additional message
        
        UIFont *infoFont = [UIFont systemFontOfSize:16];
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGSize infoSize = [addMsg sizeWithFont:infoFont constrainedToSize:CGSizeMake(contentView.width - 20 - 50 - 10, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
        
        UIView *addMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, startY, contentView.width, infoSize.height + 20)];
        [addMsgView setBackgroundColor:[UIColor whiteColor]];
        [contentView addSubview:addMsgView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (addMsgView.height - 20)/2.0, 50, 20)];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:12]];
        [titleLabel setTextColor:[UIColor qtalkTextLightColor]];
        [titleLabel setText:@"附加信息"];
        [addMsgView addSubview:titleLabel];
        
        UILabel *addMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right + 10, 10, infoSize.width, infoSize.height)];
        [addMsgLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [addMsgLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [addMsgLabel setBackgroundColor:[UIColor clearColor]];
        [addMsgLabel setFont:[UIFont systemFontOfSize:12]];
        [addMsgLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [addMsgLabel setText:addMsg];
        [addMsgLabel setNumberOfLines:0];
        [addMsgView addSubview:addMsgLabel];
        
        if (state == 1) {
            UIButton  *replyButton = [[UIButton alloc] initWithFrame:CGRectMake(contentView.width - 100, addMsgLabel.bottom + 10, 80, 25)];
            [replyButton setBackgroundImage:[UIImage imageNamed:@"AV_Check_start_button_normal"] forState:UIControlStateNormal];
            [replyButton setTitle:@"回复" forState:UIControlStateNormal];
            [replyButton addTarget:self action:@selector(onReplyClick:) forControlEvents:UIControlEventTouchUpInside];
            [addMsgView addSubview:replyButton];
            addMsgView.height += 40;
        }
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, addMsgView.height-0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [addMsgView addSubview:lineView];
        
        startY += addMsgView.height;
    }
    
    switch (state) {
        case 1:
        {
            UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startY + 5, contentView.width - 20, 20)];
            [stateLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [stateLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [stateLabel setBackgroundColor:[UIColor clearColor]];
            [stateLabel setFont:[UIFont systemFontOfSize:12]];
            [stateLabel setTextAlignment:NSTextAlignmentCenter];
            [stateLabel setTextColor:[UIColor qtalkTextLightColor]];
            [stateLabel setText:@"已同意该请求。"];
            [stateLabel setNumberOfLines:0];
            [contentView addSubview:stateLabel];
        }
            break;
        case 2:
        {
            UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startY + 5, contentView.width - 20, 20)];
            [stateLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [stateLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [stateLabel setBackgroundColor:[UIColor clearColor]];
            [stateLabel setFont:[UIFont systemFontOfSize:12]];
            [stateLabel setTextAlignment:NSTextAlignmentCenter];
            [stateLabel setTextColor:[UIColor qtalkTextLightColor]];
            [stateLabel setText:@"已拒绝该请求。"];
            [stateLabel setNumberOfLines:0];
            [contentView addSubview:stateLabel];
        }
            break;
        case 0:
        {
            CGFloat cap = (contentView.width - 240) / 3.0;
            UIButton *refusedButton = [[UIButton alloc] initWithFrame:CGRectMake(cap, startY + 30, 120, 35)];
            [refusedButton setClipsToBounds:YES];
            [refusedButton.layer setCornerRadius:5];
            [refusedButton.layer setBorderColor:[UIColor qtalkTextLightColor].CGColor];
            [refusedButton.layer setBorderWidth:0.5];
            [refusedButton setBackgroundColor:[UIColor whiteColor]];
            [refusedButton setTitleColor:[UIColor qtalkTextBlackColor] forState:UIControlStateNormal];
            [refusedButton setTitle:@"拒绝" forState:UIControlStateNormal];
            [refusedButton addTarget:self action:@selector(onRefuesClick:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:refusedButton];
            
            UIButton *agreeButton = [[UIButton alloc] initWithFrame:CGRectMake(refusedButton.right + cap, startY + 30, 120, 35)];
            [agreeButton setClipsToBounds:YES];
            [agreeButton.layer setCornerRadius:5];
            [agreeButton setBackgroundColor:[UIColor qtalkIconSelectColor]];
            [agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [agreeButton setTitle:@"同意" forState:UIControlStateNormal];
            [agreeButton addTarget:self action:@selector(onAgreeClick:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:agreeButton];
        }
            break;
        default:
            break;
    }
    
    UIButton *reportButton = [[UIButton alloc] initWithFrame:CGRectMake((contentView.width - 100)/2.0, contentView.height - 30, 100, 20)];
    [reportButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [reportButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [reportButton setTitle:@"举报用户" forState:UIControlStateNormal];
    [reportButton addTarget:self action:@selector(onReportClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:reportButton];
    
    return contentView;
}

#pragma mark - init UI

- (void)onHeaderViewClick{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [QIMFastEntrance openUserCardVCByUserId:[weakSelf.userInfoDic objectForKey:@"XmppId"]];
    });
}

- (void)openChatSession{
    NSString *xmppid = [self.userInfoDic objectForKey:@"XmppId"];
    [QIMFastEntrance openSingleChatVCByUserId:xmppid];
    /*
    NSString *name = [self.userInfoDic objectForKey:@"Name"];
    [[QIMKit sharedInstance] openChatSessionByUserId:xmppid];
    
    QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
    [chatVC setStype:kSessionType_Chat];
    [chatVC setChatId:xmppid];
    [chatVC setName:name];
    [chatVC setTitle:name];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
    [self.navigationController popToRootVCThenPush:chatVC animated:YES];
     */
}

- (void)onReplyClick:(UIButton *)sender{
    [self openChatSession];
}

- (void)onReportClick:(UIButton *)sender{
    
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

- (void)onAgreeClick:(UIButton *)sender{
    NSString *xmppId = [self.userInfoDic objectForKey:@"XmppId"];
    if (xmppId.length > 0) {
        [[self progressHUD] show:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] agreeFriendRequestWithXmppId:xmppId];
        });
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self openChatSession];
        NSString *xmppid = [self.userInfoDic objectForKey:@"XmppId"];
//        NSString *name = [self.userInfoDic objectForKey:@"Name"];
//        Message *msg = [[QIMKit sharedInstance] createMessageWithMsg:@"我通过了你的朋友验证请求，现在我们可以开始聊天了" extenddInfo:nil userId:xmppid userType:ChatType_SingleChat msgType:QIMMessageType_Text];
        [[QIMKit sharedInstance] sendMessage:@"我通过了你的朋友验证请求，现在我们可以开始聊天了" WithInfo:nil ToUserId:xmppid WihtMsgType:QIMMessageType_Text];
    }
}

- (void)onRefuesClick:(UIButton *)sender{
    [[QIMKit sharedInstance] refusedFriendRequestWithXmppId:[self.userInfoDic objectForKey:@"XmppId"]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _tableView.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellI = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellI];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellI];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:[self getContentView]];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     
}

@end
