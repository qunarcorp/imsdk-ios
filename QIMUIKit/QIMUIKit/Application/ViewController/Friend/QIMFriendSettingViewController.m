//
//  QIMFriendSettingViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/11/23.
//
//

#import "QIMFriendSettingViewController.h"
#import "QIMFriendSettingCell.h"
#import "QIMFriendQNSettingVC.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMFriendSettingViewController ()<UITableViewDataSource,UITableViewDelegate,QIMFriendQNSettingVCDelegate>
@end

@implementation QIMFriendSettingViewController{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
}

- (void)updateMySetting{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *verifyDic = [[QIMKit sharedInstance] getVerifyFreindModeWithXmppId:[[QIMKit sharedInstance] getLastJid]];
        int mode = [[verifyDic objectForKey:@"mode"] intValue];
        NSString *question = [verifyDic objectForKey:@"question"];
        NSString *answer = [verifyDic objectForKey:@"answer"];
        for (QIMFriendSettingItem * item in _dataSource) {
            if (item.isVerifyMode && item.mode == mode) {
                [item setIsSelected:YES];
                [item setQuestion:question];
                [item setAnswer:answer];
            }
        }
        int receMsgMode = [[QIMKit sharedInstance] getReceiveMsgLimitWithXmppId:[[QIMKit sharedInstance] getLastJid]];
        for (QIMFriendSettingItem * item in _dataSource) {
            if (item.isReceMsgSetting && item.mode == receMsgMode) {
                [item setIsSelected:YES];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataSource = [NSMutableArray array];
     
    QIMFriendSettingItem * item = [[QIMFriendSettingItem alloc] init];
    [item setIsVerifyMode:YES];
    [item setMode:VerifyMode_AllAgree];
    [item setTitle:[NSBundle qim_localizedStringForKey:@"ps_all_allow"]];
    [_dataSource addObject:item];
    item = [[QIMFriendSettingItem alloc] init];
    [item setIsVerifyMode:YES];
    [item setMode:VerifyMode_Validation];
    [item setTitle:[NSBundle qim_localizedStringForKey:@"ps_validation"]];
    [_dataSource addObject:item];
    item = [[QIMFriendSettingItem alloc] init];
    [item setIsVerifyMode:YES];
    [item setMode:VerifyMode_Question_Answer];
    [item setTitle:[NSBundle qim_localizedStringForKey:@"ps_question_answer"]];
    [_dataSource addObject:item];
    item = [[QIMFriendSettingItem alloc] init];
    [item setIsVerifyMode:YES];
    [item setMode:VerifyMode_AllRefused];
    [item setTitle:[NSBundle qim_localizedStringForKey:@"ps_all_refuse"]];
    [_dataSource addObject:item];
    item = [[QIMFriendSettingItem alloc] init];
    [item setIsCap:YES];
    [_dataSource addObject:item];
    item = [[QIMFriendSettingItem alloc] init];
    [item setIsReceMsgSetting:YES];
    [item setMode:ReceMsgSetting_All_Allow];
    [item setTitle:[NSBundle qim_localizedStringForKey:@"pms_all_allow"]];
    [_dataSource addObject:item];
    item = [[QIMFriendSettingItem alloc] init];
    [item setIsReceMsgSetting:YES];
    [item setMode:ReceMsgSetting_Only_Friend];
    [item setTitle:[NSBundle qim_localizedStringForKey:@"pms_only_friend"]];
    [_dataSource addObject:item];
    item = [[QIMFriendSettingItem alloc] init];
    [item setIsReceMsgSetting:YES];
    [item setMode:ReceMsgSetting_All_Refuse];
    [item setTitle:[NSBundle qim_localizedStringForKey:@"pms_all_refuse"]];
    [_dataSource addObject:item];
    
    [self updateMySetting];
    [self initWihtNav];
    [self initWithTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.oldNavHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.oldNavHidden == YES) {
    }
}

#pragma mark - init UI
- (void)initWihtNav{
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"privacy_settings"]];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
    
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMFriendSettingItem *item = [_dataSource objectAtIndex:indexPath.row];
    if (item.isVerifyMode || item.isReceMsgSetting) {
        return [QIMFriendSettingCell getCellHeight];
    } else {
        return 20;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMFriendSettingItem *item = [_dataSource objectAtIndex:indexPath.row];
    if (item.isVerifyMode || item.isReceMsgSetting) {
        NSString *cellIdentifier = @"Setting Cell";
        QIMFriendSettingCell *settingCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (settingCell == nil) {
            settingCell = [[QIMFriendSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [settingCell setItem:item];
        [settingCell refreshUI];
        return settingCell;
    } else {
        NSString *cellIdentifier = @"Cap Cell";
        UITableViewCell *capCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (capCell == nil) {
            capCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [capCell setBackgroundColor:[UIColor clearColor]];
        }
        return capCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMFriendSettingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    QIMFriendSettingItem *item = [_dataSource objectAtIndex:indexPath.row];
    if (item.isVerifyMode && item.mode == VerifyMode_Question_Answer) {
        QIMFriendQNSettingVC *settingVC = [[QIMFriendQNSettingVC alloc] init];
        [settingVC setDelegate:self];
        [settingVC setSettingItem:item];
        [self.navigationController pushViewController:settingVC animated:YES];
    } else {
        if (item.isVerifyMode) {
            BOOL isSuccess = [[QIMKit sharedInstance] setVerifyFreindMode:item.mode WithQuestion:nil WithAnswer:nil];
            if (isSuccess) {
                for (int i = 0; i < _dataSource.count; i++) {
                    QIMFriendSettingItem *item = [_dataSource objectAtIndex:i];
                    if (item.isVerifyMode) {
                        if (indexPath.row == i) {
                            [item setIsSelected:YES];
                        } else {
                            [item setIsSelected:NO];
                        }
                    }
                }
                [_tableView reloadData];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"] message:[NSBundle qim_localizedStringForKey:@"privacy_setting_faild"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_got_it"] otherButtonTitles:nil];
                [alertView show];
            }
        } else if (item.isReceMsgSetting) {
            BOOL isSuccess = [[QIMKit sharedInstance] setReceiveMsgLimitWithMode:item.mode];
            if (isSuccess) {
                for (int i = 0; i < _dataSource.count; i++) {
                    QIMFriendSettingItem *item = [_dataSource objectAtIndex:i];
                    if (item.isReceMsgSetting) {
                        if (indexPath.row == i) {
                            [item setIsSelected:YES];
                        } else {
                            [item setIsSelected:NO];
                        }
                    }
                }
                [_tableView reloadData];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_prompt"] message:[NSBundle qim_localizedStringForKey:@"privacy_setting_faild"] delegate:nil cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_got_it"] otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
}

- (void)setQuestion:(NSString *)question Answer:(NSString *)answer{
    for (int i = 0; i < _dataSource.count; i++) {
        QIMFriendSettingItem *item = [_dataSource objectAtIndex:i];
        if (item.isVerifyMode) {
            if (VerifyMode_Question_Answer == i) {
                [item setIsSelected:YES];
                [item setQuestion:question];
                [item setAnswer:answer];
            } else {
                [item setIsSelected:NO];
            }
        }
    }
    [[QIMKit sharedInstance] setVerifyFreindMode:VerifyMode_Question_Answer WithQuestion:question WithAnswer:answer];
    [_tableView reloadData];
}

@end
