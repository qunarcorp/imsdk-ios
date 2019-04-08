//
//  QIMNavConfigManagerVC.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/10/31.
//
//

#import "QIMNavConfigManagerVC.h"
#import "QIMNavConfigSettingVC.h"
#import "MBProgressHUD.h"
#import "QIMZBarViewController.h"
#import "SCLAlertView.h"
#import "MBProgressHUD.h"
#import "NSBundle+QIMLibrary.h"

#define kAlertViewDebugTag              1001

@interface QIMNavConfigManagerVC () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *navConfigs;

@property (nonatomic, strong) UIBarButtonItem *cancelItem;

@property (nonatomic, strong) UIButton *addNavServerBtn;
@property (nonatomic, strong) UIButton *xmppProtocolButton;
@property (nonatomic, strong) UIButton *protobufProtocolButton;
@property (nonatomic, strong) SCLAlertView *vaildPwdAlert;

@end

@implementation QIMNavConfigManagerVC

- (UIButton *)addNavServerBtn {
    
    if (!_addNavServerBtn) {
        _addNavServerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addNavServerBtn.frame = CGRectMake(15, [UIScreen mainScreen].bounds.size.height - 59, self.view.width - 30, 49);
        _addNavServerBtn.backgroundColor = [UIColor qtalkIconSelectColor];
        [_addNavServerBtn setTitle:@"新增配置" forState:UIControlStateNormal];
        [_addNavServerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addNavServerBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _addNavServerBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        _addNavServerBtn.layer.cornerRadius = 5.0f;
        _addNavServerBtn.layer.masksToBounds = YES;
        [_addNavServerBtn addTarget:self action:@selector(onSettingClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNavServerBtn;
}

- (UIBarButtonItem *)cancelItem {
    
    if (!_cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    }
    return _cancelItem;
}

- (SCLAlertView *)vaildPwdAlert {
    _vaildPwdAlert = [[SCLAlertView alloc] init];
    [_vaildPwdAlert setHorizontalButtons:YES];
    
    SCLTextView *vaildPwdBoxTextField = [_vaildPwdAlert addTextField:@"qunar.com"];
    vaildPwdBoxTextField.keyboardType = UIKeyboardTypeASCIICapable;
    vaildPwdBoxTextField.secureTextEntry = NO;
    __weak __typeof(self) weakSelf = self;
    
    [_vaildPwdAlert addButton:@"确定" validationBlock:^BOOL{
        if (vaildPwdBoxTextField.text.length == 0)
        {
            
            [weakSelf promptUserWithShakeTextField:vaildPwdBoxTextField];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"域名不能为空" attributes:
                                              @{NSForegroundColorAttributeName:[UIColor redColor],
                                                }];
            vaildPwdBoxTextField.attributedPlaceholder = attrString;
            vaildPwdBoxTextField.text = @"";
            [vaildPwdBoxTextField becomeFirstResponder];
            return NO;
        } else {
            NSDictionary *currentNav = @{QIMNavNameKey:vaildPwdBoxTextField.text, QIMNavUrlKey:vaildPwdBoxTextField.text};
            [[QIMKit sharedInstance] setUserObject:currentNav forKey:@"QC_CurrentNavDict"];
            [weakSelf onSaveWithNavUrl:vaildPwdBoxTextField.text WithNavDict:currentNav needSaveAllDict:YES];
        }
        return YES;
    } actionBlock:^{
    }];
    
    SCLButton *cancelBtn = [_vaildPwdAlert addButton:@"取消" target:self selector:@selector(dismisssEncryptChatAlert)];
    cancelBtn.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor qtalkIconSelectColor];
        buttonConfig[@"textColor"] = [UIColor whiteColor];
        return buttonConfig;
    };
    
    SCLButton *continuebtn = [_vaildPwdAlert addButton:@"高级" target:self selector:@selector(advanceAddServer)];
    continuebtn.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor qtalkIconSelectColor];
        buttonConfig[@"textColor"] = [UIColor whiteColor];
        return buttonConfig;
    };
    return _vaildPwdAlert;
}

- (void)promptUserWithShakeTextField:(UITextField *)textField {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    //values 数组定义了表单应该到哪些位置。
    animation.values = @[ @0, @15, @-15, @15, @0 ];
    //设置 keyTimes 属性让我们能够指定关键帧动画发生的时间。它们被指定为关键帧动画总持续时间的一个分数。
    animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
    animation.duration = 0.4;
    animation.additive = YES;
    [textField.layer addAnimation:animation forKey:@"shake"];
}

- (void)dismisssEncryptChatAlert {
    _vaildPwdAlert = nil;
    self.addNavServerBtn.enabled = YES;
}

- (void)initUI {
    
    self.title = [[QIMKit sharedInstance] qimNav_Debug] ? [NSBundle qim_localizedStringForKey:@"nav_title_debug_configManager"] : [NSBundle qim_localizedStringForKey:@"nav_title_configManager"];
    self.view.backgroundColor = [UIColor qtalkTableDefaultColor];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIBarButtonItem *feedBackItem = [[UIBarButtonItem alloc] initWithTitle:@"反馈" style:UIBarButtonItemStylePlain target:self action:@selector(onFeedBack)];
    self.navigationItem.rightBarButtonItem = feedBackItem;
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0];
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset=UIEdgeInsetsMake(0,20, 0, 0);           //top left bottom right 左右边距相同
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNavDicts) name:NavConfigSettingChanged object:nil];
    UITapGestureRecognizer *debugTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismisssEncryptChatAlert)];
    debugTap.delegate = self;
    debugTap.numberOfTouchesRequired = 1; //手指数
    debugTap.numberOfTapsRequired = 1; //tap次数
    [self.view addGestureRecognizer:debugTap];
    
    self.navConfigs = [self navServerConfigs];
    [self initUI];
    if (![[QIMKit sharedInstance] userObjectForKey:@"QC_CurrentNavDict"]) {
        
        [[QIMKit sharedInstance] setUserObject:self.navConfigs[0] forKey:@"QC_CurrentNavDict"];
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication].keyWindow addSubview:self.addNavServerBtn];
    self.addNavServerBtn.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.addNavServerBtn removeFromSuperview];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _vaildPwdAlert = nil;
}

- (NSMutableArray *)navServerConfigs {
    
    NSMutableArray *clientNavServerConfigs = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] userObjectForKey:@"QC_NavAllDicts"]];
    if (!clientNavServerConfigs.count) {
        
        clientNavServerConfigs = [NSMutableArray arrayWithCapacity:5];
        NSString *tempNavName = [NSString stringWithFormat:@"%@导航", [QIMKit getQIMProjectTitleName]];
        NSDictionary *qtalkNav = @{QIMNavNameKey:tempNavName, QIMNavUrlKey:@"https://qt.qunar.com/package/static/qtalk/nav"};
        NSDictionary *publicQTalkNav = @{QIMNavNameKey:@"Qunar公共域导航", QIMNavUrlKey:@"https://qt.qunar.com/package/static/qtalk/publicnav?c=qunar.com"};
        NSDictionary *qchatNav = @{QIMNavNameKey:@"QChat导航", QIMNavUrlKey:@"https://qt.qunar.com/package/static/qchat/nav"};
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
            [clientNavServerConfigs addObject:qtalkNav];
            [clientNavServerConfigs addObject:publicQTalkNav];
        } else {
            [clientNavServerConfigs addObject:qchatNav];
        }
    }
    return clientNavServerConfigs;
}

- (void)reloadNavDicts {
    
    self.navConfigs = [self navServerConfigs];
    [self.tableView reloadData];
}

- (void)debugSetting:(UITapGestureRecognizer *)sender
{
    NSString *message = nil;
    if ([[QIMKit sharedInstance] qimNav_Debug]) {
        message = @"是否要切换到线上环境？";
    } else {
        message = @"是否要切换到测试环境？";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView setTag:kAlertViewDebugTag];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case kAlertViewDebugTag:
        {
            if (buttonIndex == 1) {
                [[QIMKit sharedInstance] setUserObject:@(![QIMKit sharedInstance].qimNav_Debug) forKey:@"QC_Debug"];
                [self onSave];
            }
        }
            break;
        default:
            break;
    }
}

- (void)onSaveWithNavUrl:(NSString *)navUrl WithNavDict:(NSDictionary *)navUrlDict needSaveAllDict:(BOOL)needSaveAllDict {
    if (navUrl.length > 0) {
        [[QIMKit sharedInstance] setUserObject:navUrlDict forKey:@"QC_UserWillSaveNavDict"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL success = [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    QIMVerboseLog(@"登录导航Dict :%@", navUrlDict);
                    if (needSaveAllDict) {
                        [self.navConfigs addObject:navUrlDict];
                        [[QIMKit sharedInstance] setUserObject:self.navConfigs forKey:@"QC_NavAllDicts"];
                        [[QIMKit sharedInstance] setUserObject:navUrlDict forKey:@"QC_CurrentNavDict"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:NavConfigSettingChanged object:nil];
                        });
                    } else {
                        [self onCancel];
                    }
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                        message:@"无可用的导航信息"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
            });
        });
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入有效的Nav地址!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)onSave{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
   __block NSDictionary *navUrlDict = [[QIMKit sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
    NSString *navUrl;
    if (navUrlDict) {
        navUrl = [navUrlDict objectForKey:QIMNavUrlKey];;
    }
    [self onSaveWithNavUrl:navUrl WithNavDict:navUrlDict needSaveAllDict:NO];
}

#pragma mark - ButtonItem Action

- (void)onCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onFeedBack {
#if defined (QIMLogEnable) && QIMLogEnable == 1
    [[QIMLocalLog sharedInstance] submitFeedBackWithContent:nil withUserInitiative:NO];
#endif
}

#pragma mark - UITableViewDelegate and DataSource Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.navConfigs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [self.navConfigs objectAtIndex:indexPath.row];
    NSString *title;
    NSString *navHttpURL;
    if (dict) {
        title = dict[QIMNavNameKey];
        navHttpURL = dict[QIMNavUrlKey];
        if ([navHttpURL containsString:@"publicnav?c="]) {
            navHttpURL = [[navHttpURL componentsSeparatedByString:@"publicnav?c="] lastObject];
        }
        NSString *cellIdentifier = @"NavConfigManagerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        if ([dict isEqualToDictionary:[[QIMKit sharedInstance] userObjectForKey:@"QC_CurrentNavDict"]]) {
            
            
            cell.textLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.textColor = [UIColor redColor];
        } else {
            cell.textLabel.textColor = [UIColor qtalkTextLightColor];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
        }
        cell.userInteractionEnabled = YES;
        cell.textLabel.text = title;
        cell.detailTextLabel.text = navHttpURL;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict = [self.navConfigs objectAtIndex:indexPath.row];
    if (dict) {
        cell.selected = YES;
        [[QIMKit sharedInstance] setUserObject:dict forKey:@"QC_CurrentNavDict"];
    }
    [tableView reloadData];
    [self onSave];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *willEditedNavDict = [self.navConfigs objectAtIndex:indexPath.row];
    NSString *navUrl = [willEditedNavDict objectForKey:QIMNavUrlKey];
    NSString *navName = [willEditedNavDict objectForKey:QIMNavNameKey];
    NSString *name = [NSString stringWithFormat:@"%@ : %@", navName, navUrl];
//    [QIMFastEntrance showQRCodeWithUserId:navUrl withName:name withType:QRCodeType_ClientNav];
    [QIMFastEntrance showQRCodeWithQRId:navUrl withType:QRCodeType_ClientNav];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"左滑重新编辑或删除导航配置";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 5, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont systemFontOfSize:14];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    UITapGestureRecognizer *debugTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(debugSetting:)];
    debugTap.delegate = self;
    debugTap.numberOfTouchesRequired = 1; //手指数
    debugTap.numberOfTapsRequired = 10; //tap次数
    [view addGestureRecognizer:debugTap];
    return view;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row <= 1) {

        return NO;
    }
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self) weakself = self;
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"移除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSUInteger row = [indexPath row];
        [weakself.navConfigs removeObjectAtIndex:row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [[QIMKit sharedInstance] setUserObject:weakself.navConfigs forKey:@"QC_NavAllDicts"];
    }];
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
         NSDictionary *willEditedNavDict = [weakself.navConfigs objectAtIndex:indexPath.row];
         QIMNavConfigSettingVC *settingVC = [[QIMNavConfigSettingVC alloc] init];
         [settingVC setEditedNavDict:willEditedNavDict];
         QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:settingVC];
         [weakself presentViewController:nav animated:YES completion:nil];
    }];
    editRowAction.backgroundColor = [UIColor qunarGrayColor];
    return @[deleteRowAction, editRowAction];
}

- (void)advanceAddServer {
    QIMNavConfigSettingVC *settingVC = [[QIMNavConfigSettingVC alloc] init];
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:settingVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onSettingClick:(UIButton *)sender{
    QIMVerboseLog(@"%s", __func__);
    
    [self.vaildPwdAlert showEdit:self title:@"新增配置" subTitle:@"请输入域名，如qunar.com" closeButtonTitle:nil duration:0];
    self.addNavServerBtn.enabled = NO;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMVerboseLog(@"willBeginEditingRowAtIndexPath");
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMVerboseLog(@"didEndEditingRowAtIndexPath");
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSString *touchClass = NSStringFromClass([touch.view class]);
    if ([touchClass isEqualToString:@"UIButton"] || [touchClass isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}
@end
