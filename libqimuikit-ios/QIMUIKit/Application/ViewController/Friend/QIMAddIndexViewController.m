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
#import "SearchBar.h"

static NSInteger limitCount = 15;
@interface QIMAddIndexViewController ()<UITableViewDataSource,UITableViewDelegate,SearchBarDelgt>{
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

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SearchBar *searchBar;

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation QIMAddIndexViewController{
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

- (SearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
        [_searchBar setPlaceHolder:[NSBundle qim_localizedStringForKey:@"common_search_tips"]];
        [_searchBar setReturnKeyType:UIReturnKeySearch];
        [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_searchBar setDelegate:self];
        [_searchBar setText:nil];
        [_searchBar setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];
    }
    return _searchBar;
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

- (void)loadEmptyNotReadMsgList {
    [self.emptyView removeAllSubviews];
    [self.emptyView removeFromSuperview];
    self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 130)];
    self.emptyView.backgroundColor = [UIColor whiteColor];
    self.emptyView.center = self.view.center;
    UIImageView *emptyIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    emptyIconView.backgroundColor = [UIColor whiteColor];
    emptyIconView.image = [UIImage imageNamed:@"EmptyNotReadList"];
    [self.emptyView addSubview:emptyIconView];
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyIconView.bottom + 5, 150, 25)];
    [emptyLabel setText:@"查无此人"];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyView addSubview:emptyLabel];
    [self.view addSubview:self.emptyView];
    [self.view bringSubviewToFront:self.emptyView];
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

- (NSInteger)getIndexWithSelectedRowString:(NSString *)rowString {
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.stringsArray.count; i++) {
        NSString *selectRow = [self.stringsArray objectAtIndex:i];
        if ([selectRow isEqualToString:rowString]) {
            index = i;
            break;
        }
    }
    return index;
}

- (void)selectDomain {
//    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view endEditing:YES];
        [MMPickerView dismissWithCompletion:^(NSString *str) {
            
        }];

    } completion:^(BOOL finished) {
        __weak typeof(self) weakSelf = self;
        NSDictionary *dict = @{MMbackgroundColor: [UIColor whiteColor],
                               MMtextColor: [UIColor blackColor],
                               MMtoolbarColor: [UIColor whiteColor],
                               MMbuttonColor: [UIColor blueColor],
                               MMfont: [UIFont systemFontOfSize:18],
                               MMvalueY: @3,
                               MMselectedObject:_selectedString};
        
        [MMPickerView showPickerViewInView:self.view withStrings:_stringsArray withOptions:dict completion:^(NSString *selectedString) {
            weakSelf.selectedString = selectedString;
            [weakSelf.selectDomainBtn setTitle:selectedString forState:UIControlStateNormal];
            NSInteger index = [weakSelf getIndexWithSelectedRowString:selectedString];
            weakSelf.domainURL = self.objectsArray[index][@"url"];
            weakSelf.domainId = self.objectsArray[index][@"id"];
            QIMVerboseLog(@"selectDomainUrl === %@", weakSelf.domainURL);
            QIMVerboseLog(@"selectDomainUrlRow === %@", selectedString);
        }];
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = 0;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)initWithTabelView{
    
    [self.view addSubview:self.tableView];
    
    [self.tableView setTableHeaderView:self.searchBar];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.searchBar resignFirstResponder];
    [MMPickerView dismissWithCompletion:^(NSString *dismissRow) {
        
    }];
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

- (void)searchList {

    NSString *searchString = self.searchBar.text;
    NSArray *searchList = [[QIMKit sharedInstance] searchUserListBySearchStr:searchString Url:self.domainURL id:self.domainId limit:limitCount offset:0];
    [_searchResults removeAllObjects];
    if (searchList) {
        
        [_searchResults addObjectsFromArray:searchList];
    }

    NSLog(@"_searchResults : %@", _searchResults);
    [self.tableView reloadData];
    if (_searchResults.count <= 0) {
        [self loadEmptyNotReadMsgList];
    } else {
        [self.emptyView removeFromSuperview];
    }
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

- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

- (BOOL)searchBar:(SearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(SearchBar *)searchBar {
    limitCount = 12;
    [MMPickerView dismissWithCompletion:^(NSString *str) {
        
    }];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(SearchBar *)searchBar {
    
}

- (BOOL)searchBarShouldEndEditing:(SearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidEndEditing:(SearchBar *)searchBar {
    
}

- (void)searchBarSearchButtonClicked:(SearchBar *)searchBar {
    [self searchList];
}

- (void)searchBarBackButtonClicked:(SearchBar *)searchBar {
    
}

- (void)searchBarBarButtonClicked:(SearchBar *)searchBar {
}

@end
