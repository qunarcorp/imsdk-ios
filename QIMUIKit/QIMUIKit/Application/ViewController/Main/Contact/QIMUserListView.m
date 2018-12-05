//
//  QIMUserListView.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/15.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMUserListView.h"
#import "QIMBuddyTitleCell.h"
#import "QIMBuddyItemCell.h"
#import "SearchBar.h"
#import "QIMPinYinForObjc.h"
#import "QIMGroupListVC.h"
#import "QIMMessageHelperVC.h"
#import "QIMPublicNumberVC.h"
#import "QIMMainVC.h"
#import "QIMFriendListViewController.h"
#import "QIMAddIndexViewController.h"
#import "QIMOrganizationalVC.h"
#import "QIMFriendNodeItem.h"
#import "QIMFriendListCell.h"
#import "QIMBMChineseSort.h"
#import "QIMUserTableViewCell.h"
#import "QIMUserListCategoryView.h"
#import "NSBundle+QIMLibrary.h"

#define kKeywordSearchBarHeight 44
#define kQIMUserListViewCellHeight 54

@interface QIMUserListView()<UITableViewDataSource,UITableViewDelegate,SearchBarDelgt,UIGestureRecognizerDelegate, QIMUserListCategoryViewDelegate>

@property (nonatomic, strong) UITableView *friendTableView;
@property (nonatomic, strong) QIMUserListCategoryView *categoriesListView;
@property (nonatomic, strong) NSMutableArray *categoriesList;
@property (nonatomic, strong) UIButton *addFriendBtn;
@property (nonatomic, strong) NSMutableArray *friendList;
@property (nonatomic, strong) NSMutableArray *indexArray;       //出现过的首字母数组
@property (nonatomic, strong) NSMutableArray *letterResultArray;    //排序好的结果

@end

@implementation QIMUserListView{

}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:kNotificationCurrentFontUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFriendList) name:kFriendListUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSwitchAccount:) name:kNotifySwichUserSuccess object:nil];
    }
    return self;
}

- (void)initUI {

    [self loadFriendList];
    [self sortFriendList];
    [self addSubview:self.friendTableView];
}

- (void)refreshSwitchAccount:(NSNotification *)notify {
    self.categoriesList = nil;
    self.categoriesListView = nil;
    self.friendTableView = nil;
    self.friendList = nil;
    self.indexArray = nil;
    self.letterResultArray = nil;
    [self initUI];
}

- (void)updateFont:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.categoriesListView reloadData];
        [self.friendTableView reloadData];
    });
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init ui

- (UIButton *)addFriendBtn {
    if (!_addFriendBtn) {
        UIButton *addFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addFriendBtn.frame = CGRectMake(0, 0, 28, 28);
        [addFriendBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0ca" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
        [addFriendBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0ca" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateSelected];
        [addFriendBtn addTarget:self action:@selector(addNewFriend:) forControlEvents:UIControlEventTouchUpInside];
        _addFriendBtn = addFriendBtn;
    }
    return _addFriendBtn;
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden == NO) {
        [self.rootViewController.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"tab_title_contact"]];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.rootViewController.searchBar.height + self.categoriesListView.height)];
        [headerView addSubview:self.rootViewController.searchBar];
        [headerView addSubview:self.categoriesListView];
        [self.friendTableView setTableHeaderView:headerView];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.addFriendBtn];
        [self.rootViewController.navigationItem setRightBarButtonItem:rightBarItem];
    }else{
        [self.friendTableView setTableHeaderView:nil];
    }
}

- (UITableView *)friendTableView {
    if (!_friendTableView) {
        _friendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStyleGrouped];
        [_friendTableView setBackgroundColor:[UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0f]];
        [_friendTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        _friendTableView.estimatedRowHeight = 0;
        _friendTableView.estimatedSectionHeaderHeight = 0;
        _friendTableView.estimatedSectionFooterHeight = 0;
        [_friendTableView setDelegate:self];
        [_friendTableView setDataSource:self];
        [_friendTableView setShowsHorizontalScrollIndicator:NO];
        [_friendTableView setShowsVerticalScrollIndicator:NO];
        _friendTableView.tableFooterView = [UIView new];
        _friendTableView.separatorInset=UIEdgeInsetsMake(0, 54, 0, 10);           //top left bottom right 左右边距相同
        _friendTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        _friendTableView.sectionIndexColor = [UIColor grayColor];//设置默认时索引值颜色
        _friendTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];//设置选中时，索引背景颜色
        _friendTableView.sectionIndexBackgroundColor = [UIColor clearColor];//设置默认时，索引的背景颜色
        [_friendTableView setAccessibilityIdentifier:@"QTalkContact"];
    }
    [_friendTableView setAccessibilityValue:[NSString stringWithFormat:@"%lu", self.friendList.count]];
    return _friendTableView;
}

- (QIMUserListCategoryView *)categoriesListView {
    if (!_categoriesListView || !self.categoriesList.count) {
        _categoriesListView = [[QIMUserListCategoryView alloc] initWithFrame:CGRectMake(0, 56, self.width, kQIMUserListViewCellHeight * self.categoriesList.count - 1) WithCategoryList:self.categoriesList];
        [_categoriesListView setBackgroundColor:[UIColor whiteColor]];
        _categoriesListView.categoryViewDelegate = self;
    }
    return _categoriesListView;
}

- (void)didSelectUserListCategoryRowAtCategoryType:(UserListCategoryType)categoryType {
    QIMVerboseLog(@"%s", __func__);
    switch (categoryType) {
        case UserListCategoryTypeNotRead: {
            QIMMessageHelperVC *helperVC = [[QIMMessageHelperVC alloc] init];
            [self.rootViewController.navigationController pushViewController:helperVC animated:YES];
        }
            break;
        case UserListCategoryTypeFriend: {
            QIMFriendListViewController *friendListVC = [[QIMFriendListViewController alloc] init];
            [self.rootViewController.navigationController pushViewController:friendListVC animated:YES];
        }
            break;
        case UserListCategoryTypeGroup: {
            QIMGroupListVC * groupListVC = [[QIMGroupListVC alloc] init];
            [self.rootViewController.navigationController pushViewController:groupListVC animated:YES];
        }
            break;
        case UserListCategoryTypePublicNumber: {
            QIMPublicNumberVC *publicVC = [[QIMPublicNumberVC alloc] init];
            [self.rootViewController.navigationController pushViewController:publicVC animated:YES];
        }
            break;
        case UserListCategoryTypeOrganizational: {
            QIMOrganizationalVC *friendListVC = [[QIMOrganizationalVC alloc] init];
            [self.rootViewController.navigationController pushViewController:friendListVC animated:YES];
        }
            break;
        default:
            break;
    }
}

- (NSMutableArray *)categoriesList {
    if (!_categoriesList) {
        _categoriesList = [NSMutableArray arrayWithArray:@[@(UserListCategoryTypeNotRead), @(UserListCategoryTypeGroup), @(UserListCategoryTypePublicNumber)]];
        if ([[QIMKit sharedInstance] qimNav_ShowOrganizational]) {
            [_categoriesList addObject:@(UserListCategoryTypeOrganizational)];
        }
    }
    return _categoriesList;
}

- (NSMutableArray *)friendList {
    if (!_friendList) {
        _friendList = [NSMutableArray arrayWithCapacity:5];
    }
    return _friendList;
}


#pragma mark - other method

- (void)addNewFriend:(id)sender {
    QIMAddIndexViewController *indexVC = [[QIMAddIndexViewController alloc] init];
    [self.rootViewController.navigationController pushViewController:indexVC animated:YES];
}

- (void)loadFriendList {
    [self.friendList removeAllObjects];
    int onlineCount = 0;
    for (NSDictionary *infoDic in [[QIMKit sharedInstance] selectFriendList]) {
        NSString *jid = [infoDic objectForKey:@"XmppId"];
        QIMFriendNodeItem *item = [[QIMFriendNodeItem alloc] init];
        [item setIsParentNode:NO];
        [item setName:[infoDic objectForKey:@"Name"]];
        [item setContentValue:infoDic];
        if ([[QIMKit sharedInstance] isUserOnline:jid]) {
            [_friendList insertObject:item atIndex:onlineCount];
            onlineCount++;
        }else{
            [_friendList addObject:item];
        }
    }
    [[self.friendList lastObject] setIsLast:YES];
}

- (void)sortFriendList {
    self.indexArray = [QIMBMChineseSort IndexWithArray:self.friendList Key:@"name"];
    self.letterResultArray = [QIMBMChineseSort sortObjectArray:self.friendList Key:@"name"];
}

#pragma mark - table delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.indexArray objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.indexArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [[self.letterResultArray objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kQIMUserListViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    QIMFriendNodeItem *item = [[self.letterResultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *cellIdentifier = @"Friend Cell";
    QIMUserTableViewCell *nodeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [nodeCell setAccessibilityIdentifier:item.name];
    if (nodeCell == nil) {
        nodeCell = [[QIMUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [nodeCell setUserInfoDic:item.contentValue];
    [nodeCell refreshUI];
    return nodeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QIMFriendNodeItem *item = [[self.letterResultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *jid = [item.contentValue objectForKey:@"XmppId"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [QIMFastEntrance openUserCardVCByUserId:jid];
    });
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.friendTableView) {
        return self.indexArray;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.000001f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont systemFontOfSize:14];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}


@end
