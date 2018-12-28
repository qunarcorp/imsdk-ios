//
//  QIMAddSomeViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/11/23.
//
//

#import "QIMAddSomeViewController.h"
#import "QIMAddSomeCell.h"
#import "QIMChatVC.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMAddSomeViewController()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchControllerDelegate,UISearchDisplayDelegate>{
    UILabel         * _justDoItLabel;
    NSDictionary    * _infoDic;
}

@end

@implementation QIMAddSomeViewController{
    UITableView *_tableView;
    UISearchDisplayController *_mySearchDisplayController;
    NSMutableArray *_dataSource;
    NSMutableArray *_searchResults;
}

- (UISearchBar *)getSearchBar
{
    UISearchBar *searchBar  = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [searchBar sizeToFit];
    searchBar.placeholder = [NSBundle qim_localizedStringForKey:@"search_bar_placeholder"];
    [searchBar setTintColor:[UIColor spectralColorBlueColor]];
    if ([searchBar respondsToSelector:@selector(setBarTintColor:)]) {
        [searchBar setBarTintColor:[UIColor qim_colorWithHex:0xe6e7e9 alpha:1.0]];
    }
    [searchBar setBackgroundImage:[UIImage imageNamed:@"searchbar_bg"]];
    return searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _searchResults = [NSMutableArray array];
    _dataSource = [NSMutableArray array];
    
    [self initWithNav];
    [self initWithTabelView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveFriendPresence:) name:kFriendPresence object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    if (self.fromQChat) {
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar setText:self.searchStr];
//        [self searchList];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onReceiveFriendPresence:(NSNotification *)notify{
    if ([_infoDic[@"XmppId"] isEqualToString:notify.object]) {
        NSDictionary *presenceDic = notify.userInfo;
        //        NSString *from = [presenceDic objectForKey:@"from"];
        //        NSString *to = [presenceDic objectForKey:@"to"];
        //        int direction = [[presenceDic objectForKey:@"direction"] intValue];
        NSString *result = [presenceDic objectForKey:@"result"];
        //        NSString *reason = [presenceDic objectForKey:@"reason"];
        if ([result isEqualToString:@"success"]) {
            [self openChatSession];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加好友失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

//前往回话列表
- (void)openChatSession
{
    [[QIMKit sharedInstance] openChatSessionByUserId:_infoDic[@"XmppId"]];
    [QIMFastEntrance openSingleChatVCByUserId:_infoDic[@"XmppId"]];
    /*
    QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
    [chatVC setStype:kSessionType_Chat];
    [chatVC setChatId:_infoDic[@"XmppId"]];
    [chatVC setName:_infoDic[@"Name"]];
    [chatVC setTitle:_infoDic[@"Name"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
    [self.navigationController popToRootVCThenPush:chatVC animated:YES];
     */
}

#pragma mark - init UI
- (void)initWithNav{
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"common_add"]];
}

- (void)initWithTabelView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
    
    _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[self getSearchBar] contentsController:self];
    _mySearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mySearchDisplayController setDelegate:self];
    [_mySearchDisplayController setSearchResultsDataSource:self];
    [_mySearchDisplayController setSearchResultsDelegate:self];
    [_mySearchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setTableHeaderView:_mySearchDisplayController.searchBar];
}
#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchResults.count > 0) {
        return _searchResults.count;
    } else {
        return _dataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_searchResults.count > 0) {
        return [QIMAddSomeCell getCellHeight];
    }
    return _tableView.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_searchResults.count > 0) {
        NSString *cellIdentifier = @"Some Cell";
        QIMAddSomeCell *someCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (someCell == nil) {
            someCell = [[QIMAddSomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [someCell setUserInfoDic:[_searchResults objectAtIndex:indexPath.row]];
        [someCell refreshUI];
        return someCell;
    } else {
        NSString *cellIdentifier = @"Cell";
        UITableViewCell *contentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (contentCell == nil) {
            contentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [contentCell setBackgroundColor:[UIColor clearColor]];
            [contentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        return contentCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_searchResults.count > 0) {
        NSDictionary *userInfo = [_searchResults objectAtIndex:indexPath.row];
        NSString *userId = [userInfo objectForKey:@"XmppId"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:userId];
        });
    }
}

#pragma mark -
#pragma mark UISearchBar and UISearchDisplayController Delegate Methods
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchList{
    if (self.fromQChat) {
        NSString *searchString = self.searchDisplayController.searchBar.text;
        NSArray *searchList = [[QIMKit sharedInstance] searchQunarUserBySearchStr:searchString];
        [_searchResults removeAllObjects];
        if (searchList) {
            [_searchResults addObjectsFromArray:searchList];
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
        
    } else {
        NSArray *searchList = nil;
        NSString *searchString = self.searchDisplayController.searchBar.text;
        if (searchString.length > 0) {
            searchList = [[QIMKit sharedInstance] searchUserListBySearchStr:searchString];
        }
        [_searchResults removeAllObjects];
        if (searchList) {
            [_searchResults addObjectsFromArray:searchList];
        }
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (self.fromQChat) {
        if (!_justDoItLabel) {
            UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
            headerView.backgroundColor = [UIColor whiteColor];
            
            YLImageView * addFrientIcon = [[YLImageView alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
            addFrientIcon.image = [UIImage imageNamed:@"findPeople"];
            [headerView addSubview:addFrientIcon];
            
            _justDoItLabel = [[UILabel alloc] initWithFrame:CGRectMake(addFrientIcon.right + 10, 0, self.view.width - addFrientIcon.right - 20, 60)];
            _justDoItLabel.backgroundColor = [UIColor whiteColor];
            _justDoItLabel.font = [UIFont boldSystemFontOfSize:17];
            _justDoItLabel.textAlignment = NSTextAlignmentLeft;
            _justDoItLabel.numberOfLines = 0;
            _justDoItLabel.textColor = [UIColor qtalkIconSelectColor];
            [headerView addSubview:_justDoItLabel];
            
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(_justDoItLabel.left, headerView.height - 0.5, headerView.width - _justDoItLabel.left, 0.5)];
            line.backgroundColor = [UIColor qtalkSplitLineColor];
            [headerView addSubview:line];
            
            UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriend)];
            [headerView addGestureRecognizer:tapGes];
            [self.searchDisplayController.searchResultsTableView setTableHeaderView:headerView];
        }
        _justDoItLabel.text = [NSString stringWithFormat:@"点击加好友: %@ (用户名)",searchString];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchList) object:nil];
        [self performSelector:@selector(searchList) withObject:nil afterDelay:DEFAULT_DELAY_TIMES];
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchList];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *searchString = controller.searchBar.text;
        if (!_justDoItLabel) {
            UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
            headerView.backgroundColor = [UIColor whiteColor];
            
            YLImageView * addFrientIcon = [[YLImageView alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
            addFrientIcon.image = [UIImage imageNamed:@"findPeople"];
            [headerView addSubview:addFrientIcon];
            
            _justDoItLabel = [[UILabel alloc] initWithFrame:CGRectMake(addFrientIcon.right + 10, 0, self.view.width - addFrientIcon.right - 20, 60)];
            _justDoItLabel.backgroundColor = [UIColor whiteColor];
            _justDoItLabel.font = [UIFont systemFontOfSize:17];
            _justDoItLabel.textAlignment = NSTextAlignmentLeft;
            _justDoItLabel.numberOfLines = 0;
            _justDoItLabel.textColor = [UIColor qtalkTextBlackColor];
            [headerView addSubview:_justDoItLabel];
            
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(_justDoItLabel.left, headerView.height - 0.5, headerView.width - _justDoItLabel.left, 0.5)];
            line.backgroundColor = [UIColor qtalkSplitLineColor];
            [headerView addSubview:line];
            
            UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriend)];
            [headerView addGestureRecognizer:tapGes];
            [self.searchDisplayController.searchResultsTableView setTableHeaderView:headerView];
        }
        _justDoItLabel.text = [NSString stringWithFormat:@"点击加好友: %@ (用户名)",searchString];
    });
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
}

- (void)addFriend {
    NSArray * infoStrArr = [_justDoItLabel.text componentsSeparatedByString:@" "];
    if (infoStrArr.count > 1) {
        NSString *rtxID = infoStrArr[1];
        NSString *userXmppId = rtxID;
        if (self.fromQChat) {
            userXmppId = [NSString stringWithFormat:@"%@@%@",rtxID, @"ejabhost2"];
        } else {
            userXmppId = [NSString stringWithFormat:@"%@@%@",rtxID, [[QIMKit sharedInstance] getDomain]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:userXmppId];
        });
    }
}

@end
