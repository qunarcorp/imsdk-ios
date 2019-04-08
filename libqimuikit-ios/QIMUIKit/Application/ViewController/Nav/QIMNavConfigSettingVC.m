//
//  QIMNavConfigSettingVC.m
//  qunarChatIphone
//
//  Created by admin on 16/3/29.
//
//

#import "QIMNavConfigSettingVC.h"
#import "QIMZBarViewController.h"
#import "MBProgressHUD.h"

@interface QIMNavConfigSettingVC()<UIAlertViewDelegate>{
    UILabel *_navNickNameLable;
    UILabel *_navAddressLabel;
    UITextField *_navNickNameTextField;
    UITextField *_navAddressTextField;
    UIButton *_qrcodeNavBtn;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *navConfigUrls;
@property (nonatomic, strong) NSDictionary *navDict;
@property (nonatomic, copy) NSString *navTitle;
@property (nonatomic, copy) NSString *navUrl;
@property (nonatomic, assign) BOOL edited;
@property (nonatomic, assign) BOOL added;
@end

@implementation QIMNavConfigSettingVC

- (NSMutableArray *)navConfigUrls {
    if (!_navConfigUrls) {
        _navConfigUrls = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] userObjectForKey:@"QC_NavAllDicts"]];
        if (!_navConfigUrls.count) {
            NSString *tempNavName = [NSString stringWithFormat:@"%@导航", [QIMKit getQIMProjectTitleName]];
            NSDictionary *qtalkNav = @{QIMNavNameKey:tempNavName, QIMNavUrlKey:@"https://qt.qunar.com/package/static/qtalk/nav"};
            NSDictionary *publicQTalkNav = @{QIMNavNameKey:@"Qunar公共域导航", QIMNavUrlKey:@"https://qt.qunar.com/package/static/qtalk/publicnav?c=qunar.com"};
            NSDictionary *qchatNav = @{QIMNavNameKey:@"QChat导航", QIMNavUrlKey:@"https://qt.qunar.com/package/static/qchat/nav"};
            if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
                [_navConfigUrls addObject:qtalkNav];
                [_navConfigUrls addObject:publicQTalkNav];
            } else {
                [_navConfigUrls addObject:qchatNav];
            }
        }  
    }
    return _navConfigUrls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self setupUI];
}

- (void)setAddedNavDict:(NSDictionary *)navDict {
    self.navDict = navDict;
    self.navTitle = [navDict objectForKey:QIMNavNameKey];
    self.navUrl = [navDict objectForKey:QIMNavUrlKey];
    self.added = YES;
}

- (void)setEditedNavDict:(NSDictionary *)navDict {
    self.navDict = navDict;
    self.navTitle = [navDict objectForKey:QIMNavNameKey];
    self.navUrl = [navDict objectForKey:QIMNavUrlKey];
    self.edited = YES;
}

- (void)setupUI {
    _navNickNameLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.width - 40, 20)];
    [_navNickNameLable setText:@"导航服务器名称"];
    [_navNickNameLable setBackgroundColor:[UIColor clearColor]];
    [_navNickNameLable setFont:[UIFont systemFontOfSize:14]];
    [_navNickNameLable setTextColor:[UIColor qtalkTextLightColor]];
    [_navNickNameLable setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:_navNickNameLable];
    
    _navNickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(_navNickNameLable.left, _navNickNameLable.bottom + 10, _navNickNameLable.width, 36)];
    [_navNickNameTextField setBackgroundColor:[UIColor clearColor]];
    [_navNickNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_navNickNameTextField setFont:[UIFont systemFontOfSize:14]];
    [_navNickNameTextField setTextColor:[UIColor qtalkTextBlackColor]];
    [_navNickNameTextField setPlaceholder:@"我的导航服务器名称"];
    if (self.navTitle.length > 0) {
        [_navNickNameTextField setText:self.navTitle];
    }
    [self.view addSubview:_navNickNameTextField];
    [_navNickNameTextField becomeFirstResponder];
    
    _navAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_navNickNameTextField.left, _navNickNameTextField.bottom+10, _navNickNameTextField.width, 20)];
    [_navAddressLabel setBackgroundColor:[UIColor clearColor]];
    [_navAddressLabel setFont:[UIFont systemFontOfSize:14]];
    [_navAddressLabel setTextColor:[UIColor qtalkTextLightColor]];
    [_navAddressLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:_navAddressLabel];
    if ([[QIMKit sharedInstance] qimNav_Debug]) {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"[测试环境]" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor redColor]}]];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"导航服务器地址" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor qtalkTextBlackColor]}]];
        [_navAddressLabel setAttributedText:attrStr];
    } else {
        [_navAddressLabel setText:@"导航服务器地址/域名"];
    }
    
    _navAddressTextField = [[UITextField alloc] initWithFrame:CGRectMake(_navAddressLabel.left, _navAddressLabel.bottom + 10, _navAddressLabel.width - 45, 36)];
    [_navAddressTextField setBackgroundColor:[UIColor clearColor]];
    [_navAddressTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_navAddressTextField setFont:[UIFont systemFontOfSize:14]];
    [_navAddressTextField setTextColor:[UIColor qtalkTextBlackColor]];
    [_navAddressTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    if (self.navUrl) {
        [_navAddressTextField setText:self.navUrl];
    } else {
        [_navAddressTextField setPlaceholder:@"请输入域名，如qunar.com"];
    }
    [self.view addSubview:_navAddressTextField];
    
    _qrcodeNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _qrcodeNavBtn.frame = CGRectMake(_navAddressLabel.right - 36, _navAddressLabel.bottom + 10, 36, 36);
    _qrcodeNavBtn.layer.masksToBounds = YES;
    _qrcodeNavBtn.layer.cornerRadius = CGRectGetWidth(_qrcodeNavBtn.frame) / 2.0;
    [_qrcodeNavBtn setImage:[UIImage imageNamed:@"qunar-qrcode_o"] forState:UIControlStateNormal];
    [_qrcodeNavBtn addTarget:self action:@selector(scanNav:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_qrcodeNavBtn];
}

- (void)scanNav:(id)sender {
    __weak typeof(self) weakSelf = self;
    QIMZBarViewController *vc=[[QIMZBarViewController alloc] initWithBlock:^(NSString *str, BOOL isScceed) {
        if (isScceed) {
            QIMVerboseLog(@"str : %@", str);
            weakSelf.navUrl = str;
            if ([str containsString:@"publicnav?c="]) {
                str = [[str componentsSeparatedByString:@"publicnav?c="] lastObject];
            }
            _navAddressTextField.text = str;
            if (!_navNickNameTextField.text.length) {
                _navNickNameTextField.text = str;
            }
        }
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setupNav {
    
    self.title = self.navTitle.length > 0 ? self.navTitle : @"新增导航服务器";
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    [self.navigationItem setLeftBarButtonItem:cancelItem];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    [self.navigationItem setRightBarButtonItem:saveItem];
}

- (void)onCancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSave{
    NSString *navHttpName = _navNickNameTextField.text;
    if (!self.navUrl) {
        self.navUrl = _navAddressTextField.text;
    }
    if (self.navUrl.length > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __block NSDictionary *userWillsaveNavDict = @{QIMNavNameKey:navHttpName?navHttpName:[[self.navUrl.lastPathComponent componentsSeparatedByString:@"="] lastObject], QIMNavUrlKey:self.navUrl};
        [[QIMKit sharedInstance] setUserObject:userWillsaveNavDict forKey:@"QC_UserWillSaveNavDict"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL success = [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    BOOL containNavDict = NO;
                    for (NSDictionary *dict in self.navConfigUrls) {
                        if ([[dict objectForKey:QIMNavUrlKey] isEqualToString:self.navUrl]) {
                            containNavDict = YES;
                            break;
                        }
                    }
                    if (containNavDict == NO || self.edited == YES) {
                        if (self.edited == YES) {
                            [self.navConfigUrls removeObject:self.navDict];
                        }
                        [self.navConfigUrls addObject:userWillsaveNavDict];
                        [[QIMKit sharedInstance] setUserObject:self.navConfigUrls forKey:@"QC_NavAllDicts"];
                        [[QIMKit sharedInstance] setUserObject:userWillsaveNavDict forKey:@"QC_CurrentNavDict"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:NavConfigSettingChanged object:nil];
                        });
                        [self onCancel];
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                            message:@"已存在的导航地址"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
                        [alertView show];
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
    }
}

@end
