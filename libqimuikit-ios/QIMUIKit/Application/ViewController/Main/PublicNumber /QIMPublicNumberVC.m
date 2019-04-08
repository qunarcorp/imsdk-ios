//
//  QIMPublicNumberVC.m
//  qunarChatIphone
//
//  Created by admin on 15/8/26.
//
//

#import "QIMPublicNumberVC.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMPublicNumberCell.h"
#import "QIMPublicNumberRobotVC.h"
#import "QIMPublicNumberSearchVC.h"
#import "QIMZBarViewController.h"
#import "QIMJumpURLHandle.h"
#import "QIMPublicNumberCardVC.h"
#import "QIMMicroTourGuideVC.h"
#import "QIMNavBackBtn.h"

@interface QIMPublicNumberVC ()<UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIAlertViewDelegate>{
    
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    NSArray *_searchDataSource;
    UIView *_moreView;
    UIView *_moreMenuView;
    BOOL _hiddenMoreView;
    CGRect _moreMenuRect;
    UISearchDisplayController *_mySearchDisplayController;

}

@end

@implementation QIMPublicNumberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataSource = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getPublicNumberList]];
    [self initWithNav];
    [self initWithTableView];
    [self initMoreView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotReadCount:) name:kMsgNotReadCountChange object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBackBtn {
    QIMNavBackBtn *backBtn = [QIMNavBackBtn sharedInstance];
    [backBtn addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarBtn = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //将宽度设为负值
    spaceItem.width = -15;
    //将两个BarButtonItem都返回给N
    self.navigationItem.leftBarButtonItems = @[spaceItem,backBarBtn];
}

- (void)updateNotReadCount:(NSNotification *)notify {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self setBackBtn];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)leftBarBtnClicked:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - init UI

- (void)onMoreClick{
    
    if (_hiddenMoreView) {
        [UIView animateWithDuration:0.3 animations:^{
            [_moreView setAlpha:1];
            [_moreMenuView setFrame:_moreMenuRect];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [_moreView setAlpha:0];
            [_moreMenuView setFrame:CGRectMake(_moreMenuRect.origin.x+_moreMenuRect.size.width, _moreMenuRect.origin.y, 0, 0)];
        }];
    }
    _hiddenMoreView = !_hiddenMoreView;
}

- (void)initWithNav{
    
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_public_number"]];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_icon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(onMoreClick)];
    [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
}

- (void)onMoreCancelClick{
    [self onMoreClick];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *publicNumberId = [textField text];
        
        NSDictionary *cardDic = [[QIMKit sharedInstance] getPublicNumberCardByJId:[NSString stringWithFormat:@"%@@%@",publicNumberId,[[QIMKit sharedInstance] getDomain]]];
        if (cardDic.count > 0) {
            QIMPublicNumberRobotVC *robotVC = [[QIMPublicNumberRobotVC alloc] init];
            [robotVC setRobotJId:[cardDic objectForKey:@"XmppId"]];
            [robotVC setPublicNumberId:publicNumberId];
            [robotVC setName:[cardDic objectForKey:@"Name"]];
            [robotVC setTitle:robotVC.name];
            [self.navigationController pushViewController:robotVC animated:YES];
        } else {
            QIMPublicNumberCardVC *cardVC = [[QIMPublicNumberCardVC alloc] init];
            [cardVC setJid:[NSString stringWithFormat:@"%@@%@",publicNumberId,[[QIMKit sharedInstance] getDomain]]];
            [cardVC setPublicNumberId:publicNumberId];
            [cardVC setNotConcern:YES];
            [self.navigationController pushViewController:cardVC animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

- (void)onSearchPublicNumber{
    [self onMoreCancelClick];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查找公众号" message:@"输入公众号ID打开名片，查看关注！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
//    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [alert show];
//    
//    return;
    QIMPublicNumberSearchVC *searchVC = [[QIMPublicNumberSearchVC alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)onQCodeClick{
    [self onMoreCancelClick];
    [QIMFastEntrance openQRCodeVC];
}

- (void)initMoreView{
    
    NSString *qrCodeStr = [NSBundle qim_localizedStringForKey:@"explore_tab_qrcode"];
    NSString *searchPNStr = [NSBundle qim_localizedStringForKey:@"common_search_public_number"];
    NSString *moreStr = [NSBundle qim_localizedStringForKey:@"common_more"];
    CGSize qrCodeStrSize = [qrCodeStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(INT32_MAX, 20) lineBreakMode:NSLineBreakByCharWrapping];
    CGSize searchPNStrSize = [searchPNStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(INT32_MAX, 20) lineBreakMode:NSLineBreakByCharWrapping];
    CGSize moreStrSize = [qrCodeStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(INT32_MAX, 20) lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat width = MAX(qrCodeStrSize.width, searchPNStrSize.width);
    width = MAX(width, moreStrSize.width);
    
    _moreView = [[UIView alloc] initWithFrame:_tableView.frame];
    [_moreView setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.3]];
    [self.view addSubview:_moreView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMoreCancelClick)];
    [_moreView addGestureRecognizer:tap];
    
    _moreMenuView = [[UIView alloc] initWithFrame:CGRectMake(_moreView.width - (width + 30) - 5, 5, width + 30, 0)];
    [_moreMenuView setClipsToBounds:YES];
    [_moreView addSubview:_moreMenuView];
    
    UIImageView *imageBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _moreMenuView.width, _moreMenuView.height)];
    [imageBgView setImage:[[UIImage imageNamed:@"mailapp_Attach_list"] stretchableImageWithLeftCapWidth:15 topCapHeight:20]];
    [_moreMenuView addSubview:imageBgView];
    
    CGFloat startY = 0;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, startY, _moreMenuView.width-30, 32)];
    [button setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qtalkTableDefaultColor]] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor qtalkTextBlackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button setTitle:qrCodeStr forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button addTarget:self action:@selector(onQCodeClick) forControlEvents:UIControlEventTouchUpInside];
    [_moreMenuView addSubview:button];
    
    startY += 32 + 2;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, startY, _moreMenuView.width - 30,0.5)];
    [lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
    [_moreMenuView addSubview:lineView];
    
    startY += 2;
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(15, startY, _moreMenuView.width-30, 32)];
    [button setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qtalkTableDefaultColor]] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor qtalkTextBlackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button setTitle:searchPNStr forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button addTarget:self action:@selector(onSearchPublicNumber) forControlEvents:UIControlEventTouchUpInside];
    [_moreMenuView addSubview:button];
    
    startY += 32 + 2;
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(15, startY, _moreMenuView.width - 30,0.5)];
    [lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
    [_moreMenuView addSubview:lineView];
    
    startY += 2;
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(15, startY, _moreMenuView.width-30, 32)];
    [button setTitleColor:[UIColor qtalkTextBlackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qtalkTableDefaultColor]] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button setTitle:moreStr forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button addTarget:self action:@selector(onMoreClick) forControlEvents:UIControlEventTouchUpInside];
    [_moreMenuView addSubview:button];
    
    startY += 32;
    
    [_moreMenuView setHeight:startY];
    [imageBgView setHeight:startY];
    _moreMenuRect = _moreMenuView.frame;
    
    [_moreView setAlpha:0];
    [_moreMenuView setFrame:CGRectMake(_moreMenuRect.origin.x+_moreMenuRect.size.width, _moreMenuRect.origin.y, 0, 0)];
    _hiddenMoreView = YES;
    
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [self.view addSubview:_tableView];
    
    _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[self getSearchBar] contentsController:self];
    _mySearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mySearchDisplayController setDelegate:self];
    [_mySearchDisplayController setSearchResultsDataSource:self];
    [_mySearchDisplayController setSearchResultsDelegate:self];
    [_mySearchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setTableHeaderView:_mySearchDisplayController.searchBar];
    [_tableView setAccessibilityIdentifier:@"PublicNumberList"];
    [_tableView setAccessibilityValue:[NSString stringWithFormat:@"%lu",(unsigned long)_dataSource.count]];
}

- (UISearchBar *)getSearchBar
{
    UISearchBar *searchBar  = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [searchBar sizeToFit];
    searchBar.placeholder = [NSBundle qim_localizedStringForKey:@"common_search_pn_tips"];
    [searchBar setTintColor:[UIColor spectralColorBlueColor]];
    [searchBar setShowsBookmarkButton:YES];
    if ([searchBar respondsToSelector:@selector(setBarTintColor:)]) {
        [searchBar setBarTintColor:[UIColor qim_colorWithHex:0xe6e7e9 alpha:1.0]];
    }
    [searchBar setBackgroundImage:[UIImage imageNamed:@"searchbar_bg"]];
    return searchBar;
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_mySearchDisplayController.searchResultsTableView]) {
        return _searchDataSource.count;
    } else {
        return _dataSource.count;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [QIMPublicNumberCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    QIMPublicNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QIMPublicNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([tableView isEqual:_mySearchDisplayController.searchResultsTableView]) {
        NSMutableDictionary *infoDic = [_searchDataSource objectAtIndex:indexPath.row];
        [cell setJid:[infoDic objectForKey:@"XmppId"]];
        [cell setPublicNumberId:[infoDic objectForKey:@"PublicNumberId"]];
        [cell setName:[infoDic objectForKey:@"Name"]];
        [cell setHeaderSrc:[infoDic objectForKey:@"HeaderSrc"]];
        [cell setMsgType:[[infoDic objectForKey:@"MsgType"] intValue]];
        [cell setContent:[infoDic objectForKey:@"Content"]];
        [cell setMsgDateTime:[[infoDic objectForKey:@"LastUpdateTime"] longLongValue]];
        [cell refreshUI];
        return cell;
    } else {
        NSMutableDictionary *infoDic = [_dataSource objectAtIndex:indexPath.row];
        [cell setJid:[infoDic objectForKey:@"XmppId"]];
        [cell setPublicNumberId:[infoDic objectForKey:@"PublicNumberId"]];
        [cell setName:[infoDic objectForKey:@"Name"]];
        [cell setHeaderSrc:[infoDic objectForKey:@"HeaderSrc"]];
        [cell setMsgType:[[infoDic objectForKey:@"MsgType"] intValue]];
        [cell setContent:[infoDic objectForKey:@"Content"]];
        [cell setMsgDateTime:[[infoDic objectForKey:@"LastUpdateTime"] longLongValue]];
        [cell refreshUI];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *publicNumberCardInfoDic = nil;
    if ([tableView isEqual:_mySearchDisplayController.searchResultsTableView]) {
        publicNumberCardInfoDic = [_searchDataSource objectAtIndex:indexPath.row];
    } else {
        publicNumberCardInfoDic = [_dataSource objectAtIndex:indexPath.row];
    }
    QIMPublicNumberCell *cell = (QIMPublicNumberCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (publicNumberCardInfoDic) {
        BOOL isMicroTourGuide = [[[publicNumberCardInfoDic objectForKey:@"PublicNumberInfo"] objectForKey:@"rawhtml"] boolValue];
        if (isMicroTourGuide) {
            QIMMicroTourGuideVC *microTourGuideVC = [[QIMMicroTourGuideVC alloc] init];
            [microTourGuideVC setUserId:cell.jid];
            [self.navigationController pushViewController:microTourGuideVC animated:YES];
        } else {
            QIMPublicNumberRobotVC *robotVC = [[QIMPublicNumberRobotVC alloc] init];
            [robotVC setRobotJId:cell.jid];
            [robotVC setPublicNumberId:cell.publicNumberId];
            [robotVC setName:cell.name];
            [robotVC setTitle:cell.name];
            [self.navigationController pushViewController:robotVC animated:YES];
        }
    }
    
}

#pragma mark UISearchBar and UISearchDisplayController Delegate Methods
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar { 
    _searchDataSource = [[QIMKit sharedInstance] searchPublicNumberListByKeyStr:[searchBar text]];
    [_mySearchDisplayController.searchResultsTableView reloadData];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchDataSource = [[QIMKit sharedInstance] searchPublicNumberListByKeyStr:searchString];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

@end
