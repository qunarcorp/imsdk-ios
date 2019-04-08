//
//  QIMPublicNumberCardVC.m
//  qunarChatIphone
//
//  Created by admin on 15/8/27.
//
//

#import "QIMPublicNumberCardVC.h"

#import "QIMPublicNumberCardCommonCell.h"

#import "QIMPublicNumberRobotVC.h"

#import "QIMQRCodeCell.h"

@interface QIMPublicNumberCardVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    NSDictionary *_publicNumberCardDic;
    NSString *_descStr;
    NSString *_telStr;
    NSString *_fromSource;
    
    NSArray *_resultList;
    
}

@end

@implementation QIMPublicNumberCardVC

- (void)initUI{
    [self initWithNav];
    [self initWithTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    
    _dataSource = [NSMutableArray array];
    
    if (self.publicRobotDic) {
        _resultList = @[self.publicRobotDic];
        NSDictionary *publicNumberInfo = [[_resultList firstObject] objectForKey:@"rbt_body"];
        _descStr = [publicNumberInfo objectForKey:@"robotDesc"];
        _telStr = [publicNumberInfo objectForKey:@"tel"];
        _fromSource = [publicNumberInfo objectForKey:@"fromsource"];
        NSString *name = [publicNumberInfo objectForKey:@"robotCnName"];
        NSString *headerSrc = [[[publicNumberInfo objectForKey:@"headerurl"] pathComponents] lastObject];
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        [tempDic setQIMSafeObject:[NSString stringWithFormat:@"%@@%@",self.publicNumberId,[[QIMKit sharedInstance] getDomain]] forKey:@"XmppId"];
        [tempDic setQIMSafeObject:self.publicNumberId forKey:@"PublicNumberId"];
        [tempDic setQIMSafeObject:name forKey:@"Name"];
        [tempDic setQIMSafeObject:headerSrc forKey:@"HeaderSrc"];
        [tempDic setQIMSafeObject:publicNumberInfo forKey:@"PublicNumberInfo"];
        _publicNumberCardDic = tempDic;
        [self initUI];
    } else if (self.notConcern) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _resultList = [[QIMKit sharedInstance] updatePublicNumberCardByIds:@[@{@"robot_name":self.publicNumberId,@"version":@(-1)}] WithNeedUpdate:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_resultList.count > 0) {
                    NSDictionary *publicNumberInfo = [[_resultList firstObject] objectForKey:@"rbt_body"];
                    _descStr = [publicNumberInfo objectForKey:@"robotDesc"];
                    _telStr = [publicNumberInfo objectForKey:@"tel"];
                    _fromSource = [publicNumberInfo objectForKey:@"fromsource"];
                    NSString *name = [publicNumberInfo objectForKey:@"robotCnName"];
                    NSString *headerSrc = [[[publicNumberInfo objectForKey:@"headerurl"] pathComponents] lastObject];
                    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                    [tempDic setQIMSafeObject:[NSString stringWithFormat:@"%@@%@",self.publicNumberId,[[QIMKit sharedInstance] getDomain]] forKey:@"XmppId"];
                    [tempDic setQIMSafeObject:self.publicNumberId forKey:@"PublicNumberId"];
                    [tempDic setQIMSafeObject:name forKey:@"Name"];
                        [tempDic setQIMSafeObject:headerSrc forKey:@"HeaderSrc"];
                    [tempDic setQIMSafeObject:publicNumberInfo forKey:@"PublicNumberInfo"];
                    _publicNumberCardDic = tempDic;
                    [self initUI];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该公众号不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                }
            });
        });
    } else {
        _publicNumberCardDic = [[QIMKit sharedInstance] getPublicNumberCardByJid:self.jid];
        NSDictionary *publicNumberInfo = [_publicNumberCardDic objectForKey:@"PublicNumberInfo"];
        _descStr = [publicNumberInfo objectForKey:@"robotDesc"];
        _telStr = [publicNumberInfo objectForKey:@"tel"];
        _fromSource = [publicNumberInfo objectForKey:@"fromsource"];
        [self initUI];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init UI
- (void)initWithNav{
    [self.navigationItem setTitle:[_publicNumberCardDic objectForKey:@"Name"]];
    
    if (!self.notConcern) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonicon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(onMoreClick:)];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
}

- (void)initWithTableView{
    
    if (_descStr.length > 0) {
        [_dataSource addObject:@"robotDesc"];
    }
    if (_fromSource.length > 0) {
        
        [_dataSource addObject:@"fromsource"];
    }
    if (_telStr.length > 0) {
        [_dataSource addObject:@"tel"];
    }
    [_dataSource addObject:@"cap"];
    [_dataSource addObject:@"qcode"];
    [_dataSource addObject:@"cap"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [self.view addSubview:_tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    [_tableView setTableHeaderView:headerView];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    NSString *headerSrc = [_publicNumberCardDic objectForKey:@"HeaderSrc"];
    [iconImageView setImage:[[QIMKit sharedInstance] getPublicNumberHeaderImageByFileName:headerSrc]];
    [headerView addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right + 10, iconImageView.top+10, headerView.width - iconImageView.right - 10, 20)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:16]];
    [titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
    [titleLabel setText:[_publicNumberCardDic objectForKey:@"Name"]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:titleLabel];
    
    UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom + 4, titleLabel.width, 16)];
    [accountLabel setBackgroundColor:[UIColor clearColor]];
    [accountLabel setFont:[UIFont systemFontOfSize:12]];
    [accountLabel setTextColor:[UIColor qtalkTextLightColor]];
    [accountLabel setText:self.publicNumberId];
    [accountLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:accountLabel];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, 100)];
    [_tableView setTableFooterView:footerView];
    
    if (self.notConcern) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 50, footerView.width-20, 40)];
        [button setBackgroundImage:[[UIImage imageNamed:@"GreenBigBtn"] stretchableImageWithLeftCapWidth:12 topCapHeight:12] forState:UIControlStateNormal];
        [button setTitle:@"关注" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onConcernClick:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button];
    } else {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 50, footerView.width-20, 40)];
        [button setBackgroundImage:[[UIImage imageNamed:@"GreenBigBtn"] stretchableImageWithLeftCapWidth:12 topCapHeight:12] forState:UIControlStateNormal];
        [button setTitle:@"进入公众号" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onOpenPublicNumberClick:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button];
    }
}

- (void)onConcernClick:(UIButton *)sender{
    BOOL isSuccess = [[QIMKit sharedInstance] focusOnPublicNumberId:self.publicNumberId];
    if (isSuccess) {
        [[QIMKit sharedInstance] bulkInsertPublicNumbers:_resultList];
        [self onOpenPublicNumberClick:sender];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"关注失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)onOpenPublicNumberClick:(UIButton *)sender{
    if (self.fromChatVC) {
        [self.navigationController popViewControllerAnimated:YES];
    } else { 
        QIMPublicNumberRobotVC *robotVC = [[QIMPublicNumberRobotVC alloc] init];
        [robotVC setRobotJId:self.jid];
        [robotVC setPublicNumberId:self.publicNumberId];
        [robotVC setName:[_publicNumberCardDic objectForKey:@"Name"]];
        [robotVC setTitle:robotVC.name];
        [self.navigationController popToRootVCThenPush:robotVC animated:YES];
    }
}

- (void)onMoreClick:(UIButton *)sender{
//    @"举报",@"清空内容",@"推荐给朋友",
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"不再关注", nil];
    [sheet setDestructiveButtonIndex:0];
    [sheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        BOOL isSuccess = [[QIMKit sharedInstance] cancelFocusOnPublicNumberId:self.publicNumberId];
        if (isSuccess) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"取消关注失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *value = [_dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"robotDesc"]) {
        return [QIMPublicNumberCardCommonCell getCellHeightByInfo:_descStr];
    } else if ([value isEqualToString:@"fromsource"]) {
        return [QIMPublicNumberCardCommonCell getCellHeightByInfo:_fromSource];
    } else if ([value isEqualToString:@"tel"]) {
        return [QIMPublicNumberCardCommonCell getCellHeightByInfo:_telStr];
    } else if ([value isEqualToString:@"qcode"]) {
        return [QIMQRCodeCell getCellHeight];
    }
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *value = [_dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"robotDesc"]) {
        static NSString *cellIdentifier = @"Cell";
        QIMPublicNumberCardCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMPublicNumberCardCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setInfoTextAlignment:NSTextAlignmentLeft];
        [cell setTitle:@"功能介绍"];
        [cell setInfo:_descStr];
        [cell refreshUI];
        return cell;
    } else if ([value isEqualToString:@"fromsource"]) {
        static NSString *cellIdentifier = @"Cell";
        QIMPublicNumberCardCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMPublicNumberCardCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setInfoTextAlignment:NSTextAlignmentLeft];
        [cell setTitle:@"账号主题"];
        [cell setInfo:_fromSource];
        [cell refreshUI];
        return cell;
    } else if ([value isEqualToString:@"tel"]) {
        static NSString *cellIdentifier = @"Cell";
        QIMPublicNumberCardCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMPublicNumberCardCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setInfoTextAlignment:NSTextAlignmentRight];
        [cell setTitle:@"客服电话"];
        [cell setInfo:_telStr];
        [cell refreshUI];
        return cell;
    } else if ([value isEqualToString:@"qcode"]) {
        static NSString *cellIdentifier = @"Cell QCode";
        QIMQRCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMQRCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setDetail:@"公众号二维码"];
        [cell refreshUI];
        return cell;
    } else {
        static NSString *cellIdentifier = @"Cell Cap";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *value = [_dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"qcode"]) {
        [QIMFastEntrance showQRCodeWithQRId:self.publicNumberId withType:QRCodeType_RobotQR];
    }
}

@end
