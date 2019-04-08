//
//  QIMGroupATNotifyVC.m
//  qunarChatIphone
//
//  Created by wangshihai on 15/4/22.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMGroupATNotifyVC.h"
#import "SessionCell.h"
#import "SearchBar.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMGroupATNotifyVC () <UITableViewDataSource,UITableViewDelegate> {
    SearchBar *_searchBarKeyTmp;
    NSMutableArray *_searchResults;
}

@property (nonatomic, strong) UITableView    *groupMemberListView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@interface QIMGroupATNotifyVC (Search)<SearchBarDelgt>

@end


@implementation QIMGroupATNotifyVC (Search)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    }else{
        return YES;
    }
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft;
    }else{
        return UIInterfaceOrientationPortrait;
    }
}

// =======================================================================
#pragma mark - SectionSearchBar代理函数
// =======================================================================
- (void)searchBarTextDidBeginEditing:(SearchBar *)SectionSearchBar
{
    //[self enterInputSearchKeyWord];
}
- (void)searchBar:(SearchBar *)SectionSearchBar textDidChange:(NSString *)searchText
{
    if (_searchResults == nil) {
        _searchResults = [[NSMutableArray alloc]init];
    }
    [_searchResults removeAllObjects];
    
    if (searchText.length > 0 && [[self groupID] length] > 0) {
        [_searchResults addObjectsFromArray:[[QIMKit sharedInstance] searchGroupUserBySearchStr:searchText inGroup:[self groupID]]];
        QIMVerboseLog(@"_searchResults :%@", _searchResults);
    }
    [self.groupMemberListView reloadData];
}

- (void)searchBarTextDidEndEditing:(SearchBar *)searchBar {

}

- (BOOL)searchBar:(SearchBar *)SectionSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)searchBarBarButtonClicked:(SearchBar *)SectionSearchBar
{
    
    // 取消焦点
}

- (void)searchBarBackButtonClicked:(SearchBar *)SectionSearchBar
{
    
}

- (void)searchBarSearchButtonClicked:(SearchBar *)SectionSearchBar
{
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidChange:(NSInteger)index
{
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidClicked:(NSInteger)index
{
    // 取消焦点
    // [self cancelInputSearchKeyWord:SectionSearchBar];
}

//取消搜索
- (void)cancelInputSearchKeyWord:(id)sender
{
    
}

// 进入搜索
- (void)enterInputSearchKeyWord
{
    
}

@end

@implementation QIMGroupATNotifyVC

#pragma mark - setter and getter

- (UITableView *)groupMemberListView {
    if (!_groupMemberListView) {
        _groupMemberListView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _groupMemberListView.delegate = self;
        _groupMemberListView.dataSource = self;
        _groupMemberListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [self.view addSubview:_groupMemberListView];
    return _groupMemberListView;
}

#pragma mark - init UI

- (void)initWithNav{
    [self.navigationItem setTitle:@"选择提醒的人"];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:leftItem];
}

- (void)setupSearchBar {
    _searchBarKeyTmp = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
    [_searchBarKeyTmp setPlaceHolder:[NSBundle qim_localizedStringForKey:@"common_search_tips"]];
    [_searchBarKeyTmp setReturnKeyType:UIReturnKeySearch];
    [_searchBarKeyTmp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBarKeyTmp setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBarKeyTmp setDelegate:self];
    [_searchBarKeyTmp setText:nil];
    [_searchBarKeyTmp setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    UIView *atAllView = [[UIView alloc] initWithFrame:CGRectMake(0, _searchBarKeyTmp.bottom, self.view.frame.size.width, 59)];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    iconView.image = [QIMKit defaultGroupHeaderImage];
    [atAllView addSubview:iconView];
    UILabel *atAllLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconView.right + 10, 10, 100, 30)];
    atAllLabel.text = @"全体成员";
    [atAllLabel setTextColor:[UIColor spectralColorBlueColor]];
    [atAllView addSubview:atAllLabel];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(atAllAction:)];
    [atAllView addGestureRecognizer:tapGesture];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, atAllView.bottom, self.view.frame.size.width, 0.5f)];
    lineView.backgroundColor = [UIColor qtalkSplitLineColor];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 104)];
    [headerView addSubview:_searchBarKeyTmp];
    [headerView addSubview:atAllView];
    [headerView addSubview:lineView];
    [self.groupMemberListView setTableHeaderView:headerView];
}

- (void)initUI {
    [self initWithNav];
    [self setupSearchBar];
}

#pragma mark - life ctyle
- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadGroupData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initUI];
        });
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.dataSource = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] syncgroupMember:[self groupID]]];
        QIMVerboseLog(@"后备线程请求群组成员数据 : %@", self.dataSource);
        dispatch_async(dispatch_get_main_queue(), ^{
            QIMVerboseLog(@"刷新界面");
            [self.groupMemberListView reloadData];
        });
    });
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroup:) name:kGroupNickNameChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadGroup:(NSNotification *)notify {
    
    NSArray *groupIds = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([groupIds containsObject:self.groupID]) {
            NSArray *members = [[QIMKit sharedInstance] qimDB_getGroupMember:[self groupID]];
            [[QIMKit sharedInstance] bulkInsertGroupMember:members WithGroupId:[self groupID]];
            self.dataSource = [NSMutableArray arrayWithArray:members];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_groupMemberListView reloadData];
            });
        }
    });
}

- (void)loadGroupData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray *roomMembers = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getGroupMembersByGroupId:self.groupID]];
        QIMVerboseLog(@"roomMembers == %@", roomMembers);
        self.dataSource = [NSMutableArray arrayWithArray:roomMembers];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_groupMemberListView reloadData];
        });
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SessionCell getCellHeight];
}

#pragma mark - table view data sounce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchBarKeyTmp.text.length > 0) {
        return _searchResults.count;
    }
    return [self.dataSource count];
}
/*
{
    affiliation = none;
    jid = "qtalk\U5ba2\U6237\U7aef\U5f00\U53d1\U7fa4@conference.ejabhost1/\U674e\U9732";
    name = "\U674e\U9732lucas";
    xmppjid = "lilulucas.li@ejabhost1";
}
*/
/*
 第一次未拉下群成员的时候
{
    affiliation = none;
    domain = ejabhost2;
    jid = "ucvg8633@ejabhost2";
    name = ucvg8633;
    "real_jid" = ucvg8633;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (_searchBarKeyTmp.text.length > 0) {
        NSMutableDictionary * dict  =  [_searchResults objectAtIndex:indexPath.row];
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:[dict objectForKey:@"XmppId"]];

        [cell setJid:[dict objectForKey:@"XmppId"]];
        [cell setHasAtCell:YES];
        [cell setName:remarkName?remarkName:[dict objectForKey:@"Name"]];
        [cell refreshUI];
    } else {
        
        NSMutableDictionary * dict  =  [self.dataSource objectAtIndex:indexPath.row];
        NSString *jid = [dict objectForKey:@"xmppjid"];
        if (jid == nil) {
            jid = [dict objectForKey:@"jid"];
        }
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
        
        NSString *realUserName = [userInfo objectForKey:@"Name"];
        //备注
        if (!realUserName) {
            realUserName = [dict objectForKey:@"name"];
        }
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
        NSString * name  = remarkName?remarkName:realUserName;
        [cell setJid:jid];
        [cell setHasAtCell:YES];
        [cell setName:name];
        [cell refreshUI];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SessionCell *cell = (SessionCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary * dict  = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString * name  = nil;
    if (_searchBarKeyTmp.text.length > 0) {
        dict = [_searchResults objectAtIndex:indexPath.row];
        name = [dict objectForKey:@"Name"];
    } else {
        dict = [self.dataSource objectAtIndex:indexPath.row];
        name = [dict objectForKey:@"name"];
    }
    NSString *jid = cell.jid;
    NSDictionary *memberInfoDic = @{@"name":name.length?name:@"", @"jid":jid.length?jid:@""};
    if (_funBlock!=nil) {
        
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                _funBlock(memberInfoDic);
            }];
        } else {
            _funBlock(memberInfoDic);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)atAllAction:(UIButton *)sender {
    if (_funBlock!=nil) {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                _funBlock(@{@"name":@"all"});
            }];
        } else {
            _funBlock(@{@"name":@"all"});
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)selectMember:(onSelectMemberBlock)block {
    _funBlock = [block copy];
}

-(void)goBack:(id)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            _funBlock(@{});
        }];
    } else {
        //适配iPad Push进来
        _funBlock(@{});
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
