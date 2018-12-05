//
//  QIMMySettingController.m
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "QIMMySettingController.h"
#import "QIMCommonTableViewCellData.h"
#import "QIMCommonTableViewCell.h"
#import "QIMCommonTableViewCellManager.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMMySettingController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QIMCommonTableViewCellManager *tableViewManager;
@property (nonatomic) NSArray <NSArray<QIMCommonTableViewCellData *> *> *dataSource;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation QIMMySettingController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset=UIEdgeInsetsMake(0,20, 0, 0);           //top left bottom right 左右边距相同
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray arrayWithCapacity:5];
        [_titleArray addObjectsFromArray:@[@"通知", @"对话", @"", @"通用设置", @"", @"其他", @""]];
    }
    return _titleArray;
}

- (NSArray<NSArray<QIMCommonTableViewCellData *> *> *)dataSource {
    if (!_dataSource) {
        
        QIMCommonTableViewCellData *onlinePush = [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_myPush"] iconName:nil  cellDataType:QIMCommonTableViewCellDataTypeMessageOnlineNotification];
        QIMCommonTableViewCellData *mconfig = [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_mconfig"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeMconfig];
        NSArray<QIMCommonTableViewCellData *> *section0 = nil;
        if ([[[QIMKit sharedInstance] qimNav_GetPushState] length] > 0 && [QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
            section0 = @[onlinePush, [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_notify_tone"] iconName:nil   cellDataType:QIMCommonTableViewCellDataTypeMessageNotification]];
        } else {
            section0 = @[[[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_notify_tone"] iconName:nil   cellDataType:QIMCommonTableViewCellDataTypeMessageNotification]];
        }
        
        NSArray<QIMCommonTableViewCellData *> *section1 = @[
                                                     [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"explore_tab_personality_dress_up"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeDressUp],
                                                     [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_show_mood"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeShowSignature]
                                                     ];
//
        NSArray<QIMCommonTableViewCellData *> *section2 = @[[[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"explore_tab_history"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeSearchHistory],
                                                     [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"explore_tab_clear_message_list"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeClearSessionList]];
        NSArray<QIMCommonTableViewCellData *> *section3 = nil;
        if ([[[QIMKit sharedInstance] qimNav_Mconfig] length] > 0) {
            section3 = @[
                         mconfig,
                         [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_update_config"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeUpdateConfig]
                         ];
        } else {
            if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
                section3 = @[
                             [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_service"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeServiceMode],
                             [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_update_config"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeUpdateConfig]
                             ];
            } else {
                section3 = @[
                             [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_update_config"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeUpdateConfig]
                             ];
            }
        }
        NSArray<QIMCommonTableViewCellData *> *section4 = @[
                                                     [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_clear_image"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeClearCache]
                                                     ];
        NSArray<QIMCommonTableViewCellData *> *section5 = @[
                                                    [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Setting_tab_Help"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeFeedback],
                                                     [[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_about"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeAbout],
                                                     ];
        
        NSArray<QIMCommonTableViewCellData *> *section6 = @[[[QIMCommonTableViewCellData alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_quit_log"] iconName:nil cellDataType:QIMCommonTableViewCellDataTypeLogout]];
        
        _dataSource = @[section0, section1, section2, section3, section4, section5, section6];
    }
    return _dataSource;
}

- (QIMCommonTableViewCellManager *)tableViewManager {
    if (!_tableViewManager) {
        _tableViewManager = [[QIMCommonTableViewCellManager alloc] initWithRootViewController:self];
        _tableViewManager.dataSource = self.dataSource;
        _tableViewManager.dataSourceTitle = self.titleArray;
     }
    return _tableViewManager;
}

#pragma mark - NSNotification

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeImageCache:) name:kQCRemoveImageCachePathSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:kNotificationCurrentFontUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyOnlinePushFlag:) name:kNotificationUserOnLinePushFlagUpdate object:nil];
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.dataSource = self.tableViewManager;
    self.tableView.delegate = self.tableViewManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    [self registerObserver];
    [self.view addSubview:self.tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.dataSource = nil;
    self.tableViewManager = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - NSNotification

- (void)removeImageCache:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)updateFont:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)updateMyOnlinePushFlag:(NSNotification *)notify {
    [self.tableView reloadData];
}

@end
