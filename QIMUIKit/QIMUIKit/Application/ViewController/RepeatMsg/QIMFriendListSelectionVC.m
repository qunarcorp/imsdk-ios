//
//  QIMFriendListSelectionVC.m
//  qunarChatIphone
//
//  Created by admin on 16/3/18.
//
//

#import "QIMFriendListSelectionVC.h"
#import "SearchBar.h"
#import "QIMFriendListCell.h"
#import "QIMPinYinForObjc.h"
#import "NSBundle+QIMLibrary.h"
#define kKeywordSearchBarHeight 44.0f
@interface QIMFriendListSelectionVC ()<UITableViewDataSource,UITableViewDelegate,SearchBarDelgt,UIGestureRecognizerDelegate>

@end

@implementation QIMFriendListSelectionVC{
    UITableView     *_tableView;
    UIView          *_actionMenuView;
    UIButton        *_actionMenuButton;
    
    NSMutableArray  *_recentContactArray;
    NSMutableArray  *_searchResults;
    SearchBar       *_searchBarKeyTmp;
    
    NSMutableArray  *_friendList;     //我的好友
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
     //初始化ui
    [self initWithNav];
    [self initWithTableView];
    [self setupSearchBar];
    
    //获取列表数据
    [self updateFriendDataSource];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init ui
- (void)initWithNav{
    
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_friend"]];
}

-(void)setupSearchBar{
    _searchBarKeyTmp = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
    [_searchBarKeyTmp setPlaceHolder:[NSBundle qim_localizedStringForKey:@"common_search_tips"]];
    [_searchBarKeyTmp setReturnKeyType:UIReturnKeySearch];
    [_searchBarKeyTmp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBarKeyTmp setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBarKeyTmp setDelegate:self];
    [_searchBarKeyTmp setText:nil];
    [_searchBarKeyTmp setFrame:CGRectMake(0, 0, self.view.width, kKeywordSearchBarHeight)];
    [_tableView setTableHeaderView:_searchBarKeyTmp];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setContentOffset:CGPointMake(0, kKeywordSearchBarHeight)];
    [self.view addSubview:_tableView];
}

#pragma mark - init data
- (void)updateFriendDataSource{
    _friendList = [NSMutableArray array];
    NSArray *temp = [[QIMKit sharedInstance] selectFriendList];
    if (temp) {
        [_friendList addObjectsFromArray:temp];
    }
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchBarKeyTmp.text.length > 0) {
        return _searchResults.count;
    } else {
        return _friendList.count;
    }
}

#pragma mark - table delegate for cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *info = nil;
    if (_searchBarKeyTmp.text.length > 0) {
        info = [_searchResults objectAtIndex:[indexPath row]];
    }else {
        info = [_friendList objectAtIndex:[indexPath row]];
    }
    return [QIMFriendListCell getCellHeightForDesc:[info  objectForKey:@"DescInfo"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier2 = @"GROUPCONTACT_LIST";
    if (_searchBarKeyTmp.text.length > 0) {
        QIMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        [cell setUserInfoDic:[_searchResults objectAtIndex:indexPath.row]];
        [cell refreshUI];
        return cell;
    }else {
        static NSString *cellIdentifier2 = @"GROUPCONTACT_LIST";
        QIMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        [cell setUserInfoDic:[_friendList objectAtIndex:indexPath.row]];
        [cell refreshUI];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMFriendListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        if ([self.delegate respondsToSelector:@selector(selectContactWithJid:)]) {
            [self.delegate selectContactWithJid:[cell.userInfoDic objectForKey:@"XmppId"]];
        }
    }
}

#pragma mark - action method
- (void)goBack:(id)sende{
    //    [VCController popVCAnimated:YES];
}

- (void)onMoreClick:(id)sender{
    if (_actionMenuView.alpha == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            _actionMenuView.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _actionMenuView.alpha = 0;
        }];
    }
}

#pragma mark - gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.view];
    if (_searchBarKeyTmp.isFirstResponder) {
        [self searchBar:_searchBarKeyTmp textDidChange:[_searchBarKeyTmp text]];
        [_searchBarKeyTmp resignFirstResponder];
    }
    return NO;
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
    NSString * keyName  =  @"Name";
    [_searchResults removeAllObjects];
    if (searchText.length>0) {
        NSMutableArray *  searchDictArray  = nil;
        searchDictArray = [NSMutableArray arrayWithArray:_friendList];
        for (NSDictionary * dict in searchDictArray) {
            
            NSString *pinyin = [dict objectForKey:@"pinyin"];
            if (pinyin == nil){
                pinyin = [QIMPinYinForObjc chineseConvertToPinYin:[dict objectForKey:keyName]];
                NSMutableDictionary *dicn = [NSMutableDictionary dictionaryWithDictionary:dict];
                [dicn setObject:pinyin forKey:@"pinyin"];
                NSUInteger index = [searchDictArray indexOfObject:dict];
                [_friendList removeObject:dict];
                [_friendList insertObject:dicn atIndex:index];
            }
            if ([pinyin rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[dict objectForKey:keyName] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                [_searchResults addObject:dict];
            }
        }
    }
    [_tableView reloadData];
}
- (BOOL)searchBar:(SearchBar *)SectionSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

- (void)searchBarTextDidEndEditing:(SearchBar *)SectionSearchBar{
    
}

- (void)searchBarBarButtonClicked:(SearchBar *)SectionSearchBar{
    
}

- (void)searchBarBackButtonClicked:(SearchBar *)SectionSearchBar{
    
}

- (void)searchBarSearchButtonClicked:(SearchBar *)SectionSearchBar{
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidChange:(NSInteger)index{
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidClicked:(NSInteger)index{
    // 取消焦点
    // [self cancelInputSearchKeyWord:SectionSearchBar];
}

//取消搜索
- (void)cancelInputSearchKeyWord:(id)sender{
    
}

// 进入搜索
- (void)enterInputSearchKeyWord{
    
}

//隐藏键盘逻辑
-(void)tempClick:(UITapGestureRecognizer *)tap{
    
}

@end
