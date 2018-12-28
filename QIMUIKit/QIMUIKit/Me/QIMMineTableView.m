//
//  QIMMineTableView.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/25.
//

#import "QIMMineTableView.h"
#import "QIMCommonTableViewCellData.h"
#import "QIMCommonTableViewCellManager.h"
#import "QIMCommonFont.h"
#import "QIMUserInfoModel.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMMineTableView ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) QIMCommonTableViewCellManager *tableViewManager;

@property (nonatomic) NSMutableArray<NSArray<QIMCommonTableViewCellData *> *> *dataSource;

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDictionary *userVCardInfo;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) QIMUserInfoModel *model;


@end

@implementation QIMMineTableView

#pragma mark - setter and getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0f];
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset=UIEdgeInsetsMake(0,20, 0, 0);           //top left bottom right 左右边距相同
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}

- (NSMutableArray<NSArray<QIMCommonTableViewCellData *> *> *)dataSource {
    _dataSource = [NSMutableArray arrayWithCapacity:5];
    NSArray<QIMCommonTableViewCellData *> *section0 = @[[[QIMCommonTableViewCellData alloc] initWithTitle:@"我" iconName:nil cellDataType:QIMCommonTableViewCellDataTypeMine]                                               ];
    
    NSArray<QIMCommonTableViewCellData *> *section1 = @[[[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_red_package"] iconName:@"\U0000f0e4"   cellDataType:QIMCommonTableViewCellDataTypeMyRedEnvelope],
                                                 [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_balance"] iconName:@"\U0000f0f1" cellDataType:QIMCommonTableViewCellDataTypeBalanceInquiry],
                                                 ];
    NSArray<QIMCommonTableViewCellData *> *section2 = @[[[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"explore_tab_account_information"] iconName:@"\U0000f0e2" cellDataType:QIMCommonTableViewCellDataTypeAccountInformation]];
    

    NSArray<QIMCommonTableViewCellData *> *section3 = @[];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        section3 =  @[
                      [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"explore_tab_sign_in_check"] iconName:@"\U0000f1b7" cellDataType:QIMCommonTableViewCellDataTypeAttendance],[[QIMCommonTableViewCellData alloc] initWithTitle:@"QTalk Token" iconName:@"\U0000f1b7" cellDataType:QIMCommonTableViewCellDataTypeTotpToken],
                      [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"explore_tab_my_file"] iconName:@"\U0000e213" cellDataType:QIMCommonTableViewCellDataTypeMyFile],
                      ];
    } else {
        section3 = @[[[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"explore_tab_my_file"] iconName:@"\U0000e213" cellDataType:QIMCommonTableViewCellDataTypeMyFile]];
    }
    NSArray<QIMCommonTableViewCellData *> *section4 = @[[[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_setting"] iconName:@"\U0000f0ed" cellDataType:QIMCommonTableViewCellDataTypeSetting],
                                                 ];
    [_dataSource addObject:section0];
    [_dataSource addObject:section1];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk && [[QIMKit sharedInstance] qimNav_ShowOA]) {
        [_dataSource addObject:section2];
    }
    [_dataSource addObject:section3];
    [_dataSource addObject:section4];
    return _dataSource;
}

- (QIMCommonTableViewCellManager *)tableViewManager {
    if (!_tableViewManager) {
        _tableViewManager = [[QIMCommonTableViewCellManager alloc] initWithRootViewController:self.rootViewController];
    }
    _tableViewManager.dataSource = self.dataSource;
    return _tableViewManager;
}


#pragma mark - NSNotification

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyHeader) name:kUserHeaderImgUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyHeader) name:kMyHeaderImgaeUpdateSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:kNotificationCurrentFontUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSwitchAccount:) name:kNotifySwichUserSuccess object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI

- (void)initUI {
    self.backgroundColor = [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0f];
    [self addSubview:self.tableView];
}

#pragma mark - life ctyle

- (void)loadUserInfo {
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        self.userInfo = [NSMutableDictionary dictionaryWithDictionary:[[QIMKit sharedInstance] getQChatUserInfoForUser:[QIMKit getLastUserName]]];
        _userId = [[QIMKit sharedInstance] getLastJid];
        
        NSString *type = [_userInfo objectForKey:@"type"];
        if ([type isEqualToString:@"merchant"]) {
            [[QIMKit sharedInstance] setIsMerchant:YES];
        } else {
            [[QIMKit sharedInstance] setIsMerchant:NO];
        }
        
        NSString * qCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
        NSString * vCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
        NSString * tCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
        
        NSMutableDictionary * passwordDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [passwordDic setQIMSafeObject:qCookie forKey:@"q"];
        [passwordDic setQIMSafeObject:vCookie forKey:@"v"];
        [passwordDic setQIMSafeObject:tCookie forKey:@"t"];
        [passwordDic setQIMSafeObject:type forKey:@"type"];
        
        [[QIMKit sharedInstance] setUserObject:passwordDic forKey:@"QChatCookie"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserTypeInfoDidChangeNotification" object:nil];
        });
    } else {
        self.userInfo = [NSMutableDictionary dictionaryWithDictionary:[[QIMKit sharedInstance] getUserInfoByUserId:[[QIMKit sharedInstance] getLastJid]]];
        self.userId = [self.userInfo objectForKey:@"XmppId"];
    }
}

- (void)loadUserModel {
    self.model = [[QIMUserInfoModel alloc]init];
    NSString *name = [self.userInfo objectForKey:@"Name"];
    if (name.length <= 0) {
        name = [self.userId componentsSeparatedByString:@"@"].firstObject;
    }
    self.model.name       = name;
    self.model.ID         = self.userId;
    self.model.department = [self.userInfo valueForKey:@"DescInfo"];
    self.model.personalSignature = [self.userVCardInfo objectForKey:@"M"];
}

- (void)getUserVcardInfo {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (weakSelf.userId) {
            NSDictionary * usersInfo = [[QIMKit sharedInstance] getRemoteUserProfileForUserIds:@[weakSelf.userId]];
            if (usersInfo.count > 0) {
                weakSelf.userVCardInfo = [NSDictionary dictionaryWithDictionary:usersInfo[weakSelf.userId]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.model.personalSignature = [weakSelf.userVCardInfo objectForKey:@"M"];
                    [weakSelf.tableView reloadData];
                });
            }
        }
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerObserver];
        [self loadUserInfo];
        [self getUserVcardInfo];
        [self loadUserModel];
        [self initUI];
    }
    return self;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    _rootViewController = rootViewController;
//    [self loadUserModel];
    self.tableViewManager.model = self.model;
    self.tableView.delegate = self.tableViewManager;
    self.tableView.dataSource = self.tableViewManager;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden == NO) {
        [self.rootViewController.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"tab_title_myself"]];
    }
}

#pragma mark - NSNotification

- (void)refreshSwitchAccount:(NSNotification *)nofity {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self updateMineTableViewManager];
    });
}

- (void)updateMyHeader {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.tableView reloadData];
    });
}

- (void)updateMineTableViewManager {
    [self loadUserInfo];
    [self getUserVcardInfo];
    [self loadUserModel];
    self.tableViewManager.model = self.model;
    [self.tableView reloadData];
}

- (void)updateFont:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
