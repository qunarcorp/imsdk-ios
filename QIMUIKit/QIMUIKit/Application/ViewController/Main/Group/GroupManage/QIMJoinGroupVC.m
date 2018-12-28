//
//  QIMJoinGroupVC.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/16.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMJoinGroupVC.h"
#import "QIMGroupChatVC.h"
#import "QIMViewHelper.h"
#import "SearchBar.h"
#import "QIMGroupViewCell.h"
#import "QIMGroupCardVC.h"
#import "QIMChineseInclude.h"
#import "QIMPinYinForObjc.h"
#import "NSBundle+QIMLibrary.h"

#define kKeywordSearchBarHeight 44

@interface QIMJoinGroupVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,SearchBarDelgt,UIGestureRecognizerDelegate>{
    
    UITextField *_groupNameField;
    UIButton *_joinButton;
    NSString *_nickName;
    UITableView *_tableView;
    
    NSMutableArray  *_searchResults;
    SearchBar       *_searchBarKeyTmp;
    
    NSMutableArray *_groupList;
    
}

@end

@implementation QIMJoinGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor spectralColorWhiteColor]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tempClick:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onJoinSuccessNotify:) name:kMyJoinGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupErrorNotify:) name:kChatGroupError object:nil];
    
    _groupList = [[NSMutableArray alloc] initWithArray:[[QIMKit sharedInstance] getGroupList]];
    
    [self initWithNav];
//    [self initWihtUI];
    [self initTableView];
    [self setupSearchBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self setGroupId:nil];
}

#pragma mark - init ui

- (void)initWithNav{
//    CGFloat height = kNavigationBarHeight;
//    _navbar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
//    [_navbar setTitle:@"加入群组"];
//    [self.view addSubview:_navbar];
//    
//    BarButton *leftButton = [[BarButton alloc] initWithTitle:@"返回" style:eBarButtonStyleBack target:self action:@selector(goBack:)];
//    [_navbar setLeftBarItem:leftButton];
    [self.navigationItem setTitle:@"加入群组"];
}

//- (void)initWihtUI{
//    
//    _groupNameField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 110, _navbar.bottom + 40, 220, 40)];
//    [_groupNameField setBorderStyle:UITextBorderStyleNone];
//    [_groupNameField setBackgroundColor:[UIColor spectralColorGrayColor]];
//    [_groupNameField setPlaceholder:@"群名称"];
//    [_groupNameField setFont:[UIFont fontWithName:FONT_NAME size:14]];
//    [_groupNameField setDelegate:self];
//    [QIMViewHelper setRadiusToView:_groupNameField];
//    [QIMViewHelper setTextFieldLeftView:_groupNameField];
//    [self.view addSubview:_groupNameField];
//    
//    _joinButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 110, _groupNameField.bottom  +30 , 220, 40)];
//    _joinButton.backgroundColor = [UIColor spectralColorBlueColor];
//    _joinButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:14];
//    [_joinButton setTitle:@"加入群聊" forState:UIControlStateNormal];
//    [_joinButton addTarget:self action:@selector(onDoneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [QIMViewHelper setRadiusToView:_joinButton];
//    [self.view  addSubview:_joinButton];
//}

- (void)initTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setContentOffset:CGPointMake(0, kKeywordSearchBarHeight)];
    [self.view addSubview:_tableView];
}

-(void)setupSearchBar{
    _searchBarKeyTmp = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
    [_searchBarKeyTmp setPlaceHolder:[NSBundle qim_localizedStringForKey:@"common_search_tips"]];
    [_searchBarKeyTmp setReturnKeyType:UIReturnKeySearch];
    [_searchBarKeyTmp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBarKeyTmp setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBarKeyTmp setDelegate:self];
    [_searchBarKeyTmp setText:nil];
    [_searchBarKeyTmp setFrame:CGRectMake(0, 0, self.view.frame.size.width, kKeywordSearchBarHeight)];
    [_tableView setTableHeaderView:_searchBarKeyTmp];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchResults.count > 0) {
        return _searchResults.count;
    } else {
        return _groupList.count;
    }
}

#pragma mark - table delegate for cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier2 = @"GROUPCONTACT_LIST";
    if (_searchResults.count > 0) {
        QIMGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMGroupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        [cell setUserName: [[_searchResults objectAtIndex:[indexPath row]] objectForKey:@"roomName"]];
        [cell setGroupID:[[_searchResults objectAtIndex:[indexPath row]] objectForKey:@"groupId"]];
        [cell refresh];
        return cell;
    }else {
        static NSString *cellIdentifier2 = @"GROUPCONTACT_LIST";
        QIMGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMGroupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        NSDictionary *info = [_groupList objectAtIndex:[indexPath row]];
        [cell setUserName: [info objectForKey:@"roomName" ]];
        [cell setGroupID:[info objectForKey:@"groupId" ]];
        [cell refresh];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMGroupViewCell *cell = (QIMGroupViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    QIMGroupCardVC * groupCardVC = [[QIMGroupCardVC alloc]init];
    [groupCardVC setGroupId:cell.groupID];
    [groupCardVC setGroupName:cell.userName];
//    [VCController pushVC:groupCardVC animated:YES];
//    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:groupCardVC animated:YES];
}

#pragma mark - table delegate for section header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *title  = [[UILabel alloc] init];
    title.text      = @"   公开群组";
    title.font      = [UIFont fontWithName:FONT_NAME size:FONT_SIZE - 4];
    title.textColor = [UIColor spectralColorDarkBlueColor];
    title.backgroundColor = [UIColor spectralColorLightColor];
    return title;
}

#pragma mark - gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    _searchBarKeyTmp.text = nil;
    [_searchBarKeyTmp resignFirstResponder];
//    [self searchBar:_searchBarKeyTmp textDidChange:nil];
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
    
    NSString * keyName  =  @"roomName";
    
    [_searchResults removeAllObjects];
    if (searchText.length>0&&![QIMChineseInclude isIncludeChineseInString:searchText]) {
        NSMutableArray *  searchDictArray  = nil;
        searchDictArray = _groupList;
        for (NSDictionary * dict in searchDictArray) {
            if ([QIMChineseInclude isIncludeChineseInString:[dict objectForKey:keyName]]) {
                NSString *tempPinYinStr  =    [dict objectForKey:@"pinyin"]!=nil?[dict objectForKey:@"pinyin"]:[QIMPinYinForObjc chineseConvertToPinYin:[dict objectForKey:keyName]];
                NSRange titleResult=[tempPinYinStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:dict];
                }
            }
            else {
                NSRange titleResult=[[dict objectForKey:keyName] rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:dict];
                }
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

#pragma mark - method

- (void)goBack:(id)sender{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [VCController popVCAnimated:YES];
    
}

- (void)onDoneButtonClick:(UIButton *)sender{
    self.groupId = [NSString stringWithFormat:@"%@@%@.%@",_groupNameField.text,@"conference",[[QIMKit sharedInstance] getDomain]];
    _nickName = [[QIMKit sharedInstance] getMyNickName];
    if ([[QIMKit sharedInstance] isGroupMemberByGroupId:self.groupId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"已经是该群成员。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    } else {
        [[QIMKit sharedInstance] joinGroupId:self.groupId ByName:_nickName isInitiative:YES];
    }
}

- (void)textFieldDidChange:(NSNotification *)notify{
    UITextField *text = [notify object];
    if ([text isEqual:_groupNameField]) {
        if (_groupNameField.text.length > 0) {
            [_joinButton setEnabled:YES];
        } else {
            [_joinButton setEnabled:NO];
        }
    }
}

- (void)onJoinSuccessNotify:(NSNotification *)notify{
    if ([_groupId isEqualToString:notify.object]) {
      
        [[QIMKit sharedInstance] openGroupSessionByGroupId:self.groupId ByName:_groupNameField.text];
        [QIMFastEntrance openGroupChatVCByGroupId:self.groupId];
        /*
        QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
        [chatGroupVC setTitle:_groupNameField.text];
        [chatGroupVC setChatId:self.groupId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        [self.navigationController popToRootVCThenPush:chatGroupVC animated:YES];
         */
    }
}

- (void)onGroupErrorNotify:(NSNotification *)notify{
    if ([_groupId isEqualToString:notify.object]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"ERROR %@:%@",[notify.userInfo objectForKey:@"errCode"],[notify.userInfo objectForKey:@"errMsg"]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
