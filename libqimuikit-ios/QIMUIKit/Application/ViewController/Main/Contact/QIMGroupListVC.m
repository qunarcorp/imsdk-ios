//
//  QIMGroupListVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/3.
//
//

#import "QIMGroupListVC.h"
#import "SearchBar.h"
#import "QIMPinYinForObjc.h"
#import "QIMGroupViewCell.h"
#import "QIMGroupChatVC.h"
#import "QIMCreatePgroupVC.h"
#import "QIMGroupCardVC.h"
#import "QIMJoinGroupVC.h"
#import "QIMGroupCreateVC.h"
#import "QIMCommonFont.h"
#import "QIMIconInfo.h"
#import "NSBundle+QIMLibrary.h"

#define kKeywordSearchBarHeight 44

@interface QIMGroupListVC ()<UITableViewDataSource,UITableViewDelegate,SearchBarDelgt,UIGestureRecognizerDelegate>

@end 

@implementation QIMGroupListVC{
    UITableView     *_tableView;
    UIView          *_actionMenuView;
    UIButton        *_actionMenuButton;
    
    NSMutableArray  *_recentContactArray;
    NSMutableArray  *_searchResults;
    SearchBar       *_searchBarKeyTmp;
    
    NSMutableArray  *_groupListArray;       //所有公开群
    NSMutableArray  *_myGroupListArray;     //我的群组
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    //绑定通知，刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupList) name:kMyGroupListUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyGroupList) name:kUserListUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupList) name:kGroupNickNameChanged object:nil];
    //初始化ui
    [self initWithNav];
    [self initWithTableView];
    [self setupSearchBar];
    
    //右上角弹窗浮层
    _actionMenuView       = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - 80,  8, 80, 70)];
    _actionMenuView.alpha = 0;
    [self.view addSubview:_actionMenuView];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _actionMenuView.width, _actionMenuView.height)];
    [bgView setImage:[[UIImage imageNamed:@"MoreFunctionFrame"] stretchableImageWithLeftCapWidth:10 topCapHeight:20]];
    [_actionMenuView addSubview:bgView];
    
    UIButton *addGroupButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 14, _actionMenuView.width-10, 20)];
    [addGroupButton.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
    [addGroupButton setTitle:@"加入群组" forState:UIControlStateNormal];
    [addGroupButton addTarget:self action:@selector(onJoinGroup:) forControlEvents:UIControlEventTouchUpInside];
    [_actionMenuView addSubview:addGroupButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, addGroupButton.bottom+4, _actionMenuView.width, 0.2)];
    [lineView setBackgroundColor:[UIColor spectralColorLightColor]];
    [_actionMenuView addSubview:lineView];
    
    UIButton *createGroupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, lineView.bottom, _actionMenuView.width, 20)];
    [createGroupButton.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
    [createGroupButton setTitle:@"创建群组" forState:UIControlStateNormal];
    [createGroupButton addTarget:self action:@selector(CreateGroup:) forControlEvents:UIControlEventTouchUpInside];
    [_actionMenuView addSubview:createGroupButton];
    
    //获取列表数据
    [self updateMyGroupList];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self getGroupList];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init ui
- (void)initWithNav{
    
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_group"]];
    
    UIButton *createGrouButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createGrouButton.frame = CGRectMake(0, 0, 28, 28);
    [createGrouButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3e1" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
    [createGrouButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3e1" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateSelected];
    [createGrouButton addTarget:self action:@selector(onCreateGroupClcik) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:createGrouButton];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
}

- (void)onCreateGroupClcik{
    QIMGroupCreateVC * groupCreateVC = [[QIMGroupCreateVC alloc] init];
    [self.navigationController pushViewController:groupCreateVC animated:YES];
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
    [_tableView setAccessibilityIdentifier:@"GroupList"];
    [self.view addSubview:_tableView];
}

#pragma mark - init data

//所有群组
- (void)updateGroupList
{
    NSArray *groups = [[QIMKit sharedInstance] getGroupList];
    _groupListArray = [[NSMutableArray alloc] initWithArray:[self sortGroups:groups]];
    [_tableView reloadData];
}

- (void)getGroupList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
            [[QIMKit sharedInstance] getIncrementMucList:0];
        } else {
            [[QIMKit sharedInstance] quickJoinAllGroup];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _myGroupListArray = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getMyGroupList]];
            [_tableView reloadData];
        });
    });
}

//加入的群组
-(void)updateMyGroupList
{
    NSArray *groups = [[QIMKit sharedInstance] getMyGroupList];
    if (groups) {
        _myGroupListArray = [[NSMutableArray alloc] initWithArray:groups];
    } else {
        _myGroupListArray = [[NSMutableArray alloc] init];
    }
    [_tableView reloadData];
    [_tableView setAccessibilityValue:[NSString stringWithFormat:@"%lu",(unsigned long)groups.count]];
}

-(NSArray *)sortGroups:(NSArray *)groups
{
    return [groups sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1 = [obj1 objectForKey:@"Name"];
        if (name1 == nil) {
            name1 = [obj1 objectForKey:@"GroupId"];
        }
        NSString *name2 = [obj2 objectForKey:@"Name"];
        if (name2 == nil) {
            name2 = [obj2 objectForKey:@"GroupId"];
        }
        NSInteger result = [name1 compare:name2 options:NSCaseInsensitiveSearch];
        if (result == NSOrderedAscending) {
            result = NSOrderedDescending;
        } else if (result == NSOrderedDescending) {
            result = NSOrderedAscending;
        }
        return result;
    }];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchBarKeyTmp.text.length > 0) {
        return _searchResults.count;
    } else {
        return _myGroupListArray.count;
    }
}

#pragma mark - table delegate for cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *info = nil;
    if (_searchBarKeyTmp.text.length > 0) {
        info = [_searchResults objectAtIndex:[indexPath row]];
    }else {
        info = [_myGroupListArray objectAtIndex:[indexPath row]];
    }
    return [QIMGroupViewCell getCellHeightForGroupName:[info objectForKey:@"Name" ]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier2 = @"GROUPCONTACT_LIST";
    if (_searchBarKeyTmp.text.length > 0) {
        QIMGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMGroupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        [cell setUserName: [[_searchResults objectAtIndex:[indexPath row]] objectForKey:@"Name"]];
        [cell setGroupID:[[_searchResults objectAtIndex:[indexPath row]] objectForKey:@"GroupId"]];
        [cell refresh];
        return cell;
    }else {
        static NSString *cellIdentifier2 = @"GROUPCONTACT_LIST";
        QIMGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMGroupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        NSDictionary *info = [_myGroupListArray objectAtIndex:[indexPath row]];
        [cell setUserName: [info objectForKey:@"Name"]];
        [cell setGroupID:[info objectForKey:@"GroupId"]];
        [cell refresh];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_searchBarKeyTmp.text.length > 0) {
        id cell = [tableView cellForRowAtIndexPath:indexPath];
        [self openGroupChatVC:cell bAddGroupSession:YES];
    } else {
        QIMGroupViewCell *cell = (QIMGroupViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ( [[QIMKit sharedInstance] isGroupMemberByGroupId:cell.groupID]) {
            [[QIMKit sharedInstance] clearNotReadMsgByGroupId:cell.groupID];
            [cell refresh];
            [self openGroupChatVC:cell bAddGroupSession:YES];
        }else{
            //群名片页面
            QIMGroupCardVC * groupCardVC = [[QIMGroupCardVC alloc]init];
            [groupCardVC setGroupId:cell.groupID];
            [groupCardVC setGroupName:cell.userName];
            [self openGroupChatVC:cell bAddGroupSession:YES];
        }
    }
}

#pragma mark - table delegate for section header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 30)];
    header.backgroundColor = [UIColor spectralColorLightColor];
    UILabel *title  = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, tableView.width - 30, 30)];
    NSString *text = [NSString stringWithFormat:@"%@(%d)",(section == 0) ? [NSBundle qim_localizedStringForKey:@"common_my_group"] : [NSBundle qim_localizedStringForKey:@"common_all_group"],(int)(section==0?_myGroupListArray.count:_groupListArray.count)];
    title.text      = text;
    title.font      = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
    title.textColor = [UIColor spectralColorDarkBlueColor];
    title.backgroundColor = [UIColor spectralColorLightColor];
    [header addSubview:title];
    return header;
}

#pragma mark - action method
- (void)goBack:(id)sende{
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

- (void)onJoinGroup:(id)sender{
    QIMJoinGroupVC *joinVC = [[QIMJoinGroupVC alloc] init];
    [self.navigationController pushViewController:joinVC animated:YES];
    _actionMenuView.alpha = 0;
}

-(void)CreateGroup:(id)sender{
    QIMCreatePgroupVC * createGroupVC  =  [[QIMCreatePgroupVC alloc] init];
    [self.navigationController pushViewController:createGroupVC animated:YES];
    _actionMenuView.alpha = 0;
}

-(void)openGroupChatVC:(QIMGroupViewCell *)groupViewCell bAddGroupSession:(BOOL)bAddGroupSession {
    
    if ([self.delegate respondsToSelector:@selector(selectGroupWithJid:)]) {
        [self.delegate selectGroupWithJid:groupViewCell.groupID];
    } else {
        if (bAddGroupSession == YES) {
            [[QIMKit sharedInstance] openGroupSessionByGroupId:groupViewCell.groupID ByName:groupViewCell.userName];
        }
        [QIMFastEntrance openGroupChatVCByGroupId:groupViewCell.groupID];
        /*
        QIMGroupChatVC * chatGroupVC = [[QIMGroupChatVC alloc] init];
        [chatGroupVC setTitle:groupViewCell.userName];
        [chatGroupVC setChatId:groupViewCell.groupID];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        [self.navigationController popToRootVCThenPush:chatGroupVC animated:YES];
        */
    }
}

#pragma mark - gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.view];
    if (!CGRectContainsPoint(_actionMenuView.frame, point)) {
        [UIView animateWithDuration:0.3 animations:^{
            _actionMenuView.alpha = 0;
        }];
        if (_searchBarKeyTmp.isFirstResponder) {
            [self searchBar:_searchBarKeyTmp textDidChange:[_searchBarKeyTmp text]];
            [_searchBarKeyTmp resignFirstResponder];
        }
        return NO;
    } else {
        if (_searchBarKeyTmp.isFirstResponder) {
            _searchBarKeyTmp.text = nil;
            [self searchBar:_searchBarKeyTmp textDidChange:nil];
            [_searchBarKeyTmp resignFirstResponder];
        }
        return NO;
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
    
    NSString * keyName  =  @"Name";
    
    [_searchResults removeAllObjects];
    if (searchText.length>0) {
        NSMutableArray *  searchDictArray  = nil;
        searchDictArray = [NSMutableArray arrayWithArray:_myGroupListArray];
        for (NSDictionary * dict in searchDictArray) {
            
            NSString *pinyin = [dict objectForKey:@"pinyin"];
            if (pinyin == nil){
                pinyin = [QIMPinYinForObjc chineseConvertToPinYin:[dict objectForKey:keyName]];
                NSMutableDictionary *dicn = [NSMutableDictionary dictionaryWithDictionary:dict];
                [dicn setObject:pinyin forKey:@"pinyin"];
                NSUInteger index = [searchDictArray indexOfObject:dict];
                [_myGroupListArray removeObject:dict];
                [_myGroupListArray insertObject:dicn atIndex:index];
            }
            if ([pinyin rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[dict objectForKey:keyName] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                [_searchResults addObject:dict];
            }
        }
    }
    [_tableView reloadData];
}
- (BOOL)searchBar:(SearchBar *)SectionSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(SearchBar *)SectionSearchBar
{
    
}

- (void)searchBarBarButtonClicked:(SearchBar *)SectionSearchBar
{
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

//隐藏键盘逻辑
-(void)tempClick:(UITapGestureRecognizer *)tap
{
    
}

@end
