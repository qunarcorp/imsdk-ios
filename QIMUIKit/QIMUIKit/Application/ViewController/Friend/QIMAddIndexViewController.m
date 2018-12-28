//
//  QIMAddIndexViewController.m
//  qunarChatIphone
//
//  Created by admin on 16/2/1.
//
//

#import "QIMAddIndexViewController.h"
#import "QIMAddSomeViewController.h"
#import "MMPickerView.h"
#import "QIMJSONSerializer.h"
#import "QIMChatVC.h"
#import "QIMAddSomeCell.h"
#import "QIMHttpRequestMonitor.h"
#import "NSBundle+QIMLibrary.h"

static NSInteger limitCount = 15;
@interface QIMAddIndexViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchControllerDelegate,UISearchDisplayDelegate>{
    UILabel         * _justDoItLabel;
    NSDictionary    * _infoDic;
}

@property (nonatomic, strong) UILabel *selectDomainLabel;

@property (nonatomic, strong) NSMutableArray *stringsArray;
@property (nonatomic, strong) NSArray *objectsArray;

@property (nonatomic, assign) id selectedObject;
@property (nonatomic, strong) NSString * selectedString;


@property (nonatomic, strong) UILabel *titleLabel1;
@property (nonatomic, strong) UILabel *titleLabel2;
@property (nonatomic, strong) UIButton *selectDomainBtn;
@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, copy) NSString *domainURL;
@property (nonatomic, copy) NSString *domainId;

@end

@implementation QIMAddIndexViewController{
    UITableView *_tableView;
    UISearchDisplayController *_mySearchDisplayController;
    NSMutableArray *_dataSource;
    NSMutableArray *_searchResults;
}

#pragma mark - initUI

- (UIView *)titleView {
    
    if (!_titleView) {
        
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width / 2.0, 44)];
    }
    return _titleView;
}

- (UILabel *)titleLabel1 {
    
    if (!_titleLabel1) {
        _titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
        _titleLabel1.text = @"从";
        _titleLabel1.textColor = [UIColor darkTextColor];
    }
    return _titleLabel1;
}

- (UILabel *)titleLabel2 {
    
    if (!_titleLabel2) {
        _titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(self.titleView.width - 40, 0, 40, 44)];
        _titleLabel2.text = @"添加";
        _titleLabel2.textColor = [UIColor darkTextColor];
    }
    return _titleLabel2;
}

- (UIButton *)selectDomainBtn {
    
    if (!_selectDomainBtn) {
        
        self.selectDomainBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.selectDomainBtn.frame = CGRectMake(self.titleLabel1.width + 5, 5, self.titleView.width - self.titleLabel1.width - 5 - self.titleLabel2.width - 5, 34);
        self.selectDomainBtn.layer.borderWidth = 0.5;
        self.selectDomainBtn.layer.borderColor = [UIColor grayColor].CGColor;
        self.selectDomainBtn.layer.cornerRadius = 5.0f;
        self.selectDomainBtn.layer.masksToBounds = YES;
        self.selectDomainBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        self.selectDomainBtn.contentMode = UIViewContentModeCenter;
        self.selectDomainBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.selectDomainBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.selectDomainBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [self.selectDomainBtn addTarget:self action:@selector(selectDomain) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:self.selectDomainBtn];
    }
    [_selectDomainBtn setTitle:self.selectedString forState:UIControlStateNormal];
    return _selectDomainBtn;
}

- (UISearchBar *)getSearchBar
{
    UISearchBar *searchBar  = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [searchBar sizeToFit];
    searchBar.placeholder = [NSBundle qim_localizedStringForKey:@"search_bar_tab"];
    [searchBar setTintColor:[UIColor qtalkIconSelectColor]];
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
    [self getDomainList];
    _selectedObject = [_objectsArray objectAtIndex:0];
    _domainId = [_objectsArray objectAtIndex:0][@"id"];
    _domainURL = [_objectsArray objectAtIndex:0][@"url"];
    _selectedString = [_stringsArray objectAtIndex:0];
    [self initWithNav];
    [self initWithTabelView];
}

- (void)getDomainList {
    
    self.stringsArray = [NSMutableArray arrayWithCapacity:5];
    [[QIMHttpRequestMonitor sharedInstance] syncRunBlock:^{
        
        NSString *urlStr = @"https://qt.qunar.com/s/qtalk/domainlist.php?t=qtalk";
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
           urlStr = [urlStr stringByReplacingOccurrencesOfString:@"qtalk" withString:@"qchat"];
        }
        NSURL *url = [NSURL URLWithString:urlStr];
        NSDictionary *paramDic = @{@"version":@0};
        NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:paramDic error:nil];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"content-type" value:@"application/json"];
        [request appendPostData:requestData];
        [request setRequestMethod:@"POST"];
        [request startSynchronous];
        NSError *error = [request error];
        if ([request responseStatusCode] == 200 && !error) {
            
            NSDictionary *responseDict = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
            self.objectsArray = responseDict[@"data"][@"domains"];
        }
        
    } url:@"https://qt.qunar.com/s/qtalk/domainlist.php"];
    for (NSDictionary *dict in self.objectsArray) {
        if (dict) {
            if (dict[@"name"]) {
                [self.stringsArray addObject:dict[@"name"]];
            }
        }
    }
}

#pragma mark - init UI
- (void)initWithNav{
    
    [self.titleView addSubview:self.titleLabel1];
    [self.titleView addSubview:self.titleLabel2];
    [self.titleView addSubview:self.selectDomainBtn];
    [self.navigationItem setTitleView:self.titleView];
}

- (void)selectDomain {
    
    /*
    __weak typeof(self) weakSelf = self;
    NSDictionary *dict = @{MMbackgroundColor: [UIColor whiteColor],
                           MMtextColor: [UIColor blackColor],
                           MMtoolbarColor: [UIColor whiteColor],
                           MMbuttonColor: [UIColor blueColor],
                           MMfont: [UIFont systemFontOfSize:18],
                           MMvalueY: @3,
                           MMselectedObject:_selectedString};
    
    [MMPickerView showPickerViewInView:[UIApplication sharedApplication].keyWindow
                           withStrings:_stringsArray
                           withOptions:dict
                            completion:^(NSInteger selectedRow) {
                                
                                weakSelf.selectedString = self.stringsArray[selectedRow];
                                [weakSelf.selectDomainBtn setTitle:self.stringsArray[selectedRow] forState:UIControlStateNormal];
                                weakSelf.domainURL = self.objectsArray[selectedRow][@"url"];
                                weakSelf.domainId = self.objectsArray[selectedRow][@"id"];
                                QIMVerboseLog(@"selectDomainUrl === %@", weakSelf.domainURL);
                                QIMVerboseLog(@"selectDomainUrlRow === %ld", (long)selectedRow);
                            }];
     */
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
    }
    return 0;
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
    }
    return nil;
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText isEqualToString:@""]) {
        
        limitCount = 12;
        [_searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    QIMVerboseLog(@"changeg");
}
//called when text changes (including clear)

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    limitCount = 12;
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchList];
}

- (void)searchList {

    NSString *searchString = self.searchDisplayController.searchBar.text;
    NSArray *searchList = [[QIMKit sharedInstance] searchUserListBySearchStr:searchString Url:self.domainURL id:self.domainId limit:limitCount offset:0];
    [_searchResults removeAllObjects];
    if (searchList) {
        
        [_searchResults addObjectsFromArray:searchList];
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    unsigned long count = _searchResults.count;
    if (count>0) {

        CGFloat heigth = CGRectGetHeight(scrollView.frame);
        CGFloat contentYoffset = scrollView.contentOffset.y;
        CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
        if (distanceFromBottom < heigth) {
            
            QIMVerboseLog(@"end of tableView");
            limitCount += 12;
            [self searchList];
        }
        [self.view layoutIfNeeded];
    }
}

@end
