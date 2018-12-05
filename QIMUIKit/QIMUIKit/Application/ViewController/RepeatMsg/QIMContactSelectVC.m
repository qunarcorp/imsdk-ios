//
//  QIMContactSelectVC.m
//  qunarChatIphone
//
//  Created by chenjie on 2016/09/20.
//
//

#import "QIMContactSelectVC.h"
#import "QIMContactUserCell.h"
#import "QIMPinYinForObjc.h"
#import "QIMFriendListSelectionVC.h"
#import "QIMGroupListVC.h"

#define kSelectUserImgTagFrom   1000

@interface QIMContactSelectVC () <UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,QIMFriendListSelectionVCDelegate,QIMGroupListVCDelegate>
{
    UITableView         * _tableView;
    NSArray             * _recentlyUserList;
    NSMutableArray      * _searchUserList;
    NSMutableArray      * _searchGroupList;
    NSMutableArray      * _selectedUsers;
    NSMutableArray      * _myGroups;
    
    UITextField         * _searchBar;
    UIScrollView        * _displayView;
    UIView              * _headerView;
    
    UIView              * _markView;
}
@end

@implementation QIMContactSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.allowMulSelect = YES;
    [self initNavBar];
    [self getRecentUserList];
    [[self headerView] addSubview:[self displayView]];
    [[self headerView] addSubview:[self searchBar]];
    [self.view addSubview:[self headerView]];
    [self.view addSubview:[self tableView]];
    
    [self preSelect];
    
    UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tapGes.delegate = self;
    [self.view addGestureRecognizer:tapGes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)selectedUsers {
    if (_selectedUsers == nil) {
        _selectedUsers = [NSMutableArray arrayWithCapacity:1];
    }
    return _selectedUsers;
}

- (NSArray *)recentlyUserList {
    if (_recentlyUserList == nil) {
        _recentlyUserList = [NSArray array];
    }
    return _recentlyUserList;
}

- (NSMutableArray *)searchUserList {
    if (_searchUserList == nil) {
        _searchUserList = [NSMutableArray arrayWithCapacity:1];
    }
    return _searchUserList;
}

- (NSMutableArray *)searchGroupList {
    if (_searchGroupList == nil) {
        _searchGroupList = [NSMutableArray arrayWithCapacity:1];
    }
    return _searchGroupList;
}

- (UITextField *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.view.width - 20, [self headerView].height)];
        _searchBar.placeholder = @"搜索联系人/群组";
        _searchBar.font = [UIFont systemFontOfSize:15];
        _searchBar.backgroundColor = [UIColor clearColor];
        _searchBar.textColor = [UIColor spectralColorGrayDarkColor];
        _searchBar.tintColor = [UIColor spectralColorGrayBlueColor];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UIView *)markView {
    if (_markView == nil) {
        _markView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _markView.backgroundColor = [UIColor blackColor];
        _markView.alpha = 0.5;
        _markView.layer.cornerRadius  = 5;
    }
    return _markView;
}

- (UIScrollView *) displayView {
    if (_displayView == nil) {
        _displayView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _displayView.showsVerticalScrollIndicator = NO;
        _displayView.showsHorizontalScrollIndicator = NO;
    }
    return _displayView;
}
- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [self headerView].height, self.view.width, self.view.height - [self headerView].height) style:UITableViewStylePlain];
        if ([[QIMKit sharedInstance] getIsIpad]) {
            _tableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] width], [[UIScreen mainScreen] height]);
        }
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setShowsHorizontalScrollIndicator:NO];
        [_tableView setShowsVerticalScrollIndicator:NO];
        _tableView.editing = self.allowMulSelect;
        [_tableView setTableHeaderView:[self tableViewHeaderView]];
    }
    return _tableView;
}

- (UIView *)tableViewHeaderView {
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIButton * friendListJump = [UIButton buttonWithType:UIButtonTypeCustom];
    friendListJump.frame = CGRectMake(10, 0, headerView.width - 20, 50);
    [friendListJump setTitle:@"从朋友列表中选择" forState:UIControlStateNormal];
    [friendListJump setTitleColor:[UIColor spectralColorGrayDarkColor] forState:UIControlStateNormal];
    [friendListJump setTitleEdgeInsets:UIEdgeInsetsMake(0, - self.view.width / 2, 0, 0)];
    [friendListJump addTarget:self action:@selector(jumpToFriendList:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:friendListJump];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(10, friendListJump.bottom, headerView.width - 20, 0.5)];
    line.backgroundColor = [UIColor qtalkSplitLineColor];
    [headerView addSubview:line];
    
    UIButton * groupListJump = [UIButton buttonWithType:UIButtonTypeCustom];
    groupListJump.frame = CGRectMake(10, friendListJump.bottom + 0.5, headerView.width - 20, 50);
    [groupListJump setTitle:@"从群组列表中选择" forState:UIControlStateNormal];
    [groupListJump setTitleColor:[UIColor spectralColorGrayDarkColor] forState:UIControlStateNormal];
    [groupListJump setTitleEdgeInsets:UIEdgeInsetsMake(0, - self.view.width / 2, 0, 0)];
    [groupListJump addTarget:self action:@selector(jumpToGroupList:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:groupListJump];
    
    return headerView;
}

- (void)initNavBar {
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    [[self navigationItem] setLeftBarButtonItem:leftBar];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(complete:)];
    [[self navigationItem] setRightBarButtonItem:rightBar];
}

- (void)getRecentUserList {
    _recentlyUserList = [[QIMKit sharedInstance] getSessionList];
    if (_recentlyUserList.count > 0) {
        __block id tempDic = nil;
        __block NSMutableArray *temp = [NSMutableArray arrayWithArray:_recentlyUserList];
        [temp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            int chatType = [[obj objectForKey:@"ChatType"] intValue];
            if (chatType == ChatType_System) {
                tempDic = obj;
            }
            [temp removeObject:tempDic];
        }];
        _recentlyUserList = temp;
    }
    
    _myGroups = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getMyGroupList]];
}

- (void)refreshDisplayUsers {
    [[self displayView] removeAllSubviews];
    NSInteger i = 0;
    for (NSDictionary * infoDic in _selectedUsers) {
        BOOL isGroup = [infoDic[@"isGroup"] boolValue];
        NSString * jid = infoDic[@"userId"];
        /*
        UIImage * headImage = nil;
        if (isGroup) {
            headImage = [[QIMKit sharedInstance] getGroupImageFromLocalByGroupId:jid];
        }else{
            headImage = [[QIMKit sharedInstance] getUserHeaderImageByUserId:jid];
        }
        */
        UIImageView * heaerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 35 + 5, 10, 30, 30)];
        if (isGroup) {
            [heaerImgView qim_setImageWithJid:jid WithChatType:ChatType_GroupChat];
        } else {
            [heaerImgView qim_setImageWithJid:jid];
        }
//        heaerImgView.image = headImage;
        heaerImgView.tag = kSelectUserImgTagFrom + i;
        heaerImgView.layer.cornerRadius = 0.5;
        heaerImgView.clipsToBounds = YES;
        heaerImgView.userInteractionEnabled =  YES;
        [[self displayView] addSubview:heaerImgView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImgTapHandle:)];
        [heaerImgView addGestureRecognizer:tap];
        
        i ++;
    }
    [self displayView].frame = CGRectMake(0, 0, MIN(_selectedUsers.count * 35 + 5, self.view.width - 150),  [self headerView].height);
    [[self displayView] setContentSize:CGSizeMake(_selectedUsers.count * 35 + 5, [self headerView].height)];
    [[self displayView] scrollRectToVisible:CGRectMake(_selectedUsers.count * 35 + 5, 0, 1, 1) animated:YES];
    
    [self searchBar].frame = CGRectMake([self displayView].right, 0, [self headerView].width - [self displayView].right , [self headerView].height);
}

- (void)preSelect {
    if (self.defaultSelectIds.count) {
        for (NSString * userId in self.defaultSelectIds) {
            NSDictionary *infoDic = nil;
            BOOL  isGroup = NO;
            if ([userId rangeOfString:@"conference"].location != NSNotFound) {
                infoDic = [[QIMKit sharedInstance] getGroupCardByGroupId:userId];
                isGroup = YES;
            }else{
                infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
            }
            NSString * nickName = [infoDic objectForKey:@"Name"];
            
            if (self.allowMulSelect) {
                if (![self isExistisForJid:userId]) {
                    [[self selectedUsers] addObject:@{@"userId":userId,@"nick":nickName,@"isGroup":@(isGroup)}];
                }
            }
        }
        [[self tableView] reloadData];
        [self refreshDisplayUsers];
    }
}

- (BOOL)isExistisForJid:(NSString *)jid {
    __block BOOL needSelect = NO;
    [[self selectedUsers] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:@"userId"] isEqualToString:jid]) {
            * stop = YES;
            needSelect = YES;
        }
    }];
    return needSelect;
}

#pragma mark - action

- (void)headerImgTapHandle:(UITapGestureRecognizer *)tap {
    [[self selectedUsers] removeObjectAtIndex:tap.view.tag - kSelectUserImgTagFrom];
    [self refreshDisplayUsers];
    [[self tableView] reloadData];
}

- (void)goBack:(id)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)complete:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(QIMContactSelectVC:completeWithUsersInfo:)]) {
        [self.delegate QIMContactSelectVC:self completeWithUsersInfo:[self selectedUsers]];
    }
    [self goBack:sender];
}

- (void)jumpToFriendList:(id)sender {
    QIMFriendListSelectionVC *listVC = [[QIMFriendListSelectionVC alloc] init];
    [listVC setDelegate:self];
    [self.navigationController pushViewController:listVC animated:YES];
}


- (void)jumpToGroupList:(id)sender {
    QIMGroupListVC * groupListVC = [[QIMGroupListVC alloc] init];
    [groupListVC setDelegate:self];
    [self.navigationController pushViewController:groupListVC animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([self searchBar].isFirstResponder) {
        [[self searchBar] resignFirstResponder];
    }
    return NO;
}
#pragma mark keyboardNotification

- (void)keyboardWillShow:(NSNotification*)notification{
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double keyboardDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    
    [UIView animateWithDuration:keyboardDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self tableView].frame = CGRectMake(0, [self headerView].height, self.view.width, self.view.height - [self headerView].height - keyboardRect.size.height);
                     } completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)notification{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self tableView].frame = CGRectMake(0, [self headerView].height, self.view.width, self.view.height - [self headerView].height);
                     } completion:nil];
    
}

#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [[self searchUserList] removeAllObjects];
    NSMutableString * searchText = [NSMutableString stringWithString:textField.text];
    [searchText replaceCharactersInRange:range withString:string];
    if (textField.text.length + string.length - range.length > 0) {
        [[self searchUserList] addObjectsFromArray:[[QIMKit sharedInstance] searchUserListBySearchStr:searchText]];
    }
    
    [[self searchGroupList] removeAllObjects];
    
    //群组
    NSString * keyName  =  @"Name";
    NSMutableArray *  searchDictArray  = nil;
    searchDictArray = [NSMutableArray arrayWithArray:_myGroups];
    for (NSDictionary * dict in searchDictArray) {
        
        NSString *pinyin = [dict objectForKey:@"pinyin"];
        if (pinyin == nil){
            pinyin = [QIMPinYinForObjc chineseConvertToPinYin:[dict objectForKey:keyName]];
            NSMutableDictionary *dicn = [NSMutableDictionary dictionaryWithDictionary:dict];
            [dicn setObject:pinyin forKey:@"pinyin"];
            NSUInteger index = [searchDictArray indexOfObject:dict];
            [_myGroups removeObject:dict];
            [_myGroups insertObject:dicn atIndex:index];
        }
        if ([pinyin rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [[dict objectForKey:keyName] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            [[self searchGroupList] addObject:dict];
        }
    }
    if (_searchUserList.count + _searchGroupList.count > 0) {
        [[self tableView] setTableHeaderView:nil];
    }else{
        [[self tableView] setTableHeaderView:[self tableViewHeaderView]];
    }
    
    [_tableView reloadData];
    return YES;
}



#pragma mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchUserList.count + _searchGroupList.count > 0) {
        return _searchUserList.count + _searchGroupList.count;
    }else{
        return _recentlyUserList.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_searchUserList.count + _searchGroupList.count > 0) {
        return 0;
    }else{
        return 30;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 30)];
    [view setBackgroundColor:[UIColor spectralColorLightColor]];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.width - 20, 24)];
    label.text = @"最近联系人";
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
    
    [view addSubview:label];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"cell";
    QIMContactUserCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[QIMContactUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    if (_searchUserList.count + _searchGroupList.count > 0) {
        NSDictionary * dic = nil;
        NSString * jid = nil;
        if (indexPath.row >= _searchUserList.count) {
            dic = [_searchGroupList objectAtIndex:[indexPath row] - _searchUserList.count];
            jid = [dic objectForKey:@"GroupId"];
        }else{
            dic = [_searchUserList objectAtIndex:[indexPath row]];
            jid = [dic objectForKey:@"XmppId"];
        }
        [cell setIsGroup:indexPath.row >= _searchUserList.count];
        [cell setJid:jid];
        [cell setInfoDic:dic];
        [cell setName:[dic objectForKey:@"Name"]];
        [cell refreshUI];
        if ([self isExistisForJid:jid]) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return cell;
    } else {
        NSMutableDictionary * dict  =  [_recentlyUserList objectAtIndex:indexPath.row];
        BOOL isGroup = [[dict objectForKey:@"ChatType"] intValue]==ChatType_GroupChat;
        [cell setIsGroup:isGroup];
        [cell setJid:[dict objectForKey:@"XmppId"]];
        [cell setInfoDic:dict];
        [cell setName:[dict objectForKey:@"Name"]];
        [cell refreshUI];
        if ([self isExistisForJid:[dict objectForKey:@"XmppId"]]) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return cell;
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.allowMulSelect;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary * dic = nil;
    NSString * jid = nil;
    NSString * nickName = nil;
    BOOL  isGroup = NO;
    if (_searchUserList.count + _searchGroupList.count > 0) {
        if (indexPath.row >= _searchUserList.count) {
            dic = [_searchGroupList objectAtIndex:[indexPath row] - _searchUserList.count];
            jid = [dic objectForKey:@"GroupId"];
            isGroup = YES;
        }else{
            dic = [_searchUserList objectAtIndex:[indexPath row]];
            jid = [dic objectForKey:@"XmppId"];
            isGroup = NO;
        }
        nickName = [dic objectForKey:@"Name"];
    } else {
        dic  =  [_recentlyUserList objectAtIndex:indexPath.row];
        isGroup = [[dic objectForKey:@"ChatType"] intValue]==ChatType_GroupChat;
        jid = [dic objectForKey:@"XmppId"];
        nickName = [dic objectForKey:@"Name"];
    }
    jid = jid?jid:@"";
    nickName = nickName?nickName:@"";
    if (self.allowMulSelect) {
        [[self selectedUsers] addObject:@{@"userId":jid,@"nick":nickName,@"isGroup":@(isGroup)}];
        [self refreshDisplayUsers];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(QIMContactSelectVC:completeWithUsersInfo:)]) {
            [self.delegate QIMContactSelectVC:self completeWithUsersInfo:@[@{@"userId":jid,@"nick":nickName,@"isGroup":@(isGroup)}]];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary * dic = nil;
    NSString * jid = nil;
    if (_searchUserList.count + _searchGroupList.count > 0) {
        if (indexPath.row >= _searchUserList.count) {
            dic = [_searchGroupList objectAtIndex:[indexPath row] - _searchUserList.count];
            jid = [dic objectForKey:@"GroupId"];
        }else{
            dic = [_searchUserList objectAtIndex:[indexPath row]];
            jid = [dic objectForKey:@"XmppId"];
        }
    } else {
        dic  =  [_recentlyUserList objectAtIndex:indexPath.row];
        jid = [dic objectForKey:@"XmppId"];
    }
    if (jid.length) {
        [_selectedUsers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"userId"] isEqualToString:jid]) {
                *stop = YES;
                [_selectedUsers removeObject:obj];
                [self refreshDisplayUsers];
            }
        }];
    }
}

#pragma mark - QIMFriendListSelectionVCDelegate,QIMGroupListVCDelegate

- (void)selectContactWithJid:(NSString *)jid{
    [self.navigationController popViewControllerAnimated:YES];
    NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
    NSString * nickName = [infoDic objectForKey:@"Name"];
    BOOL  isGroup = NO;
    
    if (self.allowMulSelect) {
        if (![self isExistisForJid:jid]) {
            [[self selectedUsers] addObject:@{@"userId":jid,@"nick":nickName,@"isGroup":@(isGroup)}];
            [[self tableView] reloadData];
        }
        [self refreshDisplayUsers];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(QIMContactSelectVC:completeWithUsersInfo:)]) {
            [self.delegate QIMContactSelectVC:self completeWithUsersInfo:@[@{@"userId":jid,@"nick":nickName,@"isGroup":@(isGroup)}]];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}

- (void)selectGroupWithJid:(NSString *)jid{
    [self.navigationController popViewControllerAnimated:YES];
    NSDictionary *infoDic = [[QIMKit sharedInstance] getGroupCardByGroupId:jid];
    NSString * nickName = [infoDic objectForKey:@"Name"];
    BOOL  isGroup = YES;
    
    if (self.allowMulSelect) {
        if (![self isExistisForJid:jid]) {
            [[self selectedUsers] addObject:@{@"userId":jid,@"nick":nickName,@"isGroup":@(isGroup)}];
            [[self tableView] reloadData];
        }
        [self refreshDisplayUsers];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(QIMContactSelectVC:completeWithUsersInfo:)]) {
            [self.delegate QIMContactSelectVC:self completeWithUsersInfo:@[@{@"userId":jid,@"nick":nickName,@"isGroup":@(isGroup)}]];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


@end
