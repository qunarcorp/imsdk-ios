//
//  QIMContactSelectionViewController.m
//  qunarChatIphone
//
//  Created by may on 15/7/7.
//
//

#import "QIMContactSelectionViewController.h"
#import "UIApplication+QIMApplication.h"
#import "QIMContactUserCell.h"
#import "SearchBar.h"
#import "QIMGroupListVC.h"
#import "QIMUserListVC.h"
#import "QIMGroupChatVC.h"
#import "QIMChatVC.h"
#import "QIMBuddyItemCell.h"
#import "QIMGroupViewCell.h"
#import "QIMPinYinForObjc.h"
#import "QIMFriendListSelectionVC.h"
#import "QIMIconInfo.h"
#import "NSBundle+QIMLibrary.h"

#define kKeywordSearchBarHeight 44

@interface QIMContactSelectionViewController ()<UITableViewDataSource,UITableViewDelegate,SearchBarDelgt,UIGestureRecognizerDelegate,QIMGroupListVCDelegate,QIMUserListVCDelegate,QIMFriendListSelectionVCDelegate>{
    UITableView     * _tableView;
    NSMutableArray *_itemArray;
    SearchBar *_searchBarKeyTmp;
    NSMutableArray *_searchResults;
    NSMutableArray * _searchGroupResults;
    NSMutableArray         * _myGroups;
    NSDictionary * _selectInfoDic;
}
@end

@implementation QIMContactSelectionViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    }else{
        return YES;
    }
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft;
    }else{
        return UIInterfaceOrientationPortrait;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (_searchBarKeyTmp.isFirstResponder) {
        [_searchBarKeyTmp resignFirstResponder];
    }
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    _itemArray = [NSMutableArray arrayWithCapacity:5];
    NSArray *temp = [[QIMKit sharedInstance] getSessionList];
    NSMutableArray *tempStickList = [NSMutableArray array];
    NSMutableArray *normalList = [NSMutableArray array];
    
    for (NSDictionary *infoDic in temp) {
        
        ChatType chatType = [[infoDic objectForKey:@"ChatType"] integerValue];
        NSString *xmppId = [infoDic objectForKey:@"XmppId"];
        NSString *realJid = [infoDic objectForKey:@"RealJid"];
        NSString *combineJid = (realJid.length > 0) ? [NSString stringWithFormat:@"%@<>%@", xmppId, realJid] : [NSString stringWithFormat:@"%@<>%@", xmppId, xmppId];
        if ([[QIMKit sharedInstance] isStickWithCombineJid:combineJid]) {
            [tempStickList addObject:infoDic];
        } else {
            if (chatType == ChatType_System || [xmppId hasPrefix:@"rbt-notice"] || [xmppId hasPrefix:@"rbt-qiangdan"] || [xmppId hasPrefix:@"rbt-zhongbao"]) {
            } else {
                [normalList addObject:infoDic];
            }
        }
    }
    [_itemArray addObjectsFromArray:tempStickList];
    [_itemArray addObjectsFromArray:normalList];
    _myGroups = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getMyGroupList]];
    
    [self initNavBar];
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNavBar {
    UIBarButtonItem *leftBarButtonBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    [[self navigationItem] setLeftBarButtonItem:leftBarButtonBar];
    [self.navigationItem setTitle:@"发送到"];
}

-(void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    if ([[QIMKit sharedInstance] getIsIpad]) {
        _tableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] width], [[UIScreen mainScreen] height]);
    }
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.backgroundColor = [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0f];
    CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorInset=UIEdgeInsetsMake(0, 50, 0, 0);           //top left bottom right 左右边距相同
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    [self initTableViewHeader];
}

-(void)setupSearchBar {
    _searchBarKeyTmp = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
    [_searchBarKeyTmp setPlaceHolder:[NSBundle qim_localizedStringForKey:@"search_bar_placeholder"]];
    [_searchBarKeyTmp setReturnKeyType:UIReturnKeySearch];
    [_searchBarKeyTmp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBarKeyTmp setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBarKeyTmp setDelegate:self];
    [_searchBarKeyTmp setText:nil];
    [_searchBarKeyTmp setFrame:CGRectMake(0, 0, self.view.width, kKeywordSearchBarHeight)];
}

- (void)initTableViewHeader {
    UIView * headerBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kKeywordSearchBarHeight + 54 + 21)];
    //搜索框
    [self setupSearchBar];
    [headerBG addSubview:_searchBarKeyTmp];
    
    UIView *friendView = [[UIView alloc] initWithFrame:CGRectMake(0, _searchBarKeyTmp.bottom, self.view.width, 54)];
    friendView.backgroundColor = [UIColor whiteColor];
    UILabel *friendTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.width - 30, 54)];
    friendTitleLabel.text = @"选择一个好友";
    friendTitleLabel.textColor = [UIColor qtalkTextBlackColor];
    [friendView addSubview:friendTitleLabel];
//    [headerBG addSubview:friendView];
    UITapGestureRecognizer *friendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userBtnClick:)];
    [friendView addGestureRecognizer:friendTap];
    
    UIView *groupView = [[UIView alloc] initWithFrame:CGRectMake(0, _searchBarKeyTmp.bottom + 0.5f, self.view.width, 54)];
    groupView.backgroundColor = [UIColor whiteColor];
    UILabel *groupTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.width - 60, 54)];
    groupTitleLabel.text = @"选择一个群聊";
    groupTitleLabel.textColor = [UIColor qtalkTextBlackColor];
    [groupView addSubview:groupTitleLabel];
    [headerBG addSubview:groupView];
    
    UIImageView *indiorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(groupTitleLabel.right + 5, 15, 24, 24)];
    indiorImageView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3c8" size:24 color:[UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1/1.0]]];
    [groupView addSubview:indiorImageView];
    
    UITapGestureRecognizer *groupTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(groupBtnHandle:)];
    [groupView addGestureRecognizer:groupTap];

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, groupView.bottom, self.view.width, 20)];
    [titleView setBackgroundColor:[UIColor spectralColorLightColor]];
    [titleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerBG addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setText:@"最近聊天"];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleView addSubview:titleLabel];
    
    _tableView.tableHeaderView = headerBG;
}

- (void)goBack:(id)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)groupBtnHandle:(UIButton *)btn {
    QIMGroupListVC * groupListVC = [[QIMGroupListVC alloc] init];
    [groupListVC setDelegate:self];
    [self.navigationController pushViewController:groupListVC animated:YES];
}

- (void)userBtnClick:(UIButton *)btn {
    QIMFriendListSelectionVC *listVC = [[QIMFriendListSelectionVC alloc] init];
    [listVC setDelegate:self];
    [self.navigationController pushViewController:listVC animated:YES];
}

- (NSDictionary *)getSelectInfoDic {
    return _selectInfoDic;
}

#pragma mark - SectionSearchBar代理函数

- (void)searchBar:(SearchBar *)SectionSearchBar textDidChange:(NSString *)searchText {
    if (_searchResults == nil) {
        _searchResults = [[NSMutableArray alloc]init];
    }
    [_searchResults removeAllObjects];
    if (searchText.length > 0) {
        [_searchResults addObjectsFromArray:[[QIMKit sharedInstance] searchUserListBySearchStr:searchText]];
    }
    
    if (_searchGroupResults == nil) {
        _searchGroupResults = [[NSMutableArray alloc] init];
    }
    [_searchGroupResults removeAllObjects];
    
    //群组
    NSString * keyName = @"Name";
    NSMutableArray *searchDictArray  = nil;
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
            [_searchGroupResults addObject:dict];
        }
    }
    
    [_tableView reloadData];
}

- (BOOL)searchBar:(SearchBar *)SectionSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchResults.count + _searchGroupResults.count > 0) {
        return _searchResults.count + _searchGroupResults.count;
    } else {
        return [_itemArray count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_searchResults.count + _searchGroupResults.count > 0) {
        return 60;
    } else {
        return [QIMContactUserCell getCellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchResults.count + _searchGroupResults.count > 0) {
        if (indexPath.row >= _searchResults.count) {
            static NSString *cellIdentifier2 = @"GROUPCONTACT_LIST";
            QIMGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
            if (cell == nil) {
                cell = [[QIMGroupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            }
            NSDictionary * dic = [_searchGroupResults objectAtIndex:[indexPath row] - _searchResults.count];
            [cell setUserName: [dic objectForKey:@"Name"]];
            [cell setGroupID:[dic objectForKey:@"GroupId"]];
            [cell refresh];
            return cell;
        }else{
            static NSString *cellIdentifier2 = @"cell2";
            QIMBuddyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
            if (cell == nil) {
                cell = [[QIMBuddyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            }
            [cell initSubControls];
            
            NSDictionary * dic = [_searchResults objectAtIndex:[indexPath row]];
            
            NSString *jid = [dic objectForKey:@"XmppId"];
            NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
            NSString *userName = [userInfo objectForKey:@"Name"];
            NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
            [cell setUserName:(remarkName.length > 0) ? remarkName : userName];
            [cell setJid:jid];
            [cell refrash];
            return  cell;
        }
    } else {
        NSMutableDictionary * dict  =  [_itemArray objectAtIndex:indexPath.row];
        NSString *xmppId = [dict objectForKey:@"XmppId"];
        NSString *realJid = [dict objectForKey:@"RealJid"];
        NSString *combineJid = (realJid.length > 0) ? [NSString stringWithFormat:@"%@<>%@", xmppId, realJid] : [NSString stringWithFormat:@"%@<>%@", xmppId, xmppId];
        QIMContactUserCell *cell = [tableView dequeueReusableCellWithIdentifier:combineJid];
        if (cell == nil){
            cell = [[QIMContactUserCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:combineJid];
        }
        [cell setIsGroup:[[dict objectForKey:@"ChatType"] intValue]==ChatType_GroupChat];
        [cell setIsSystem:[[dict objectForKey:@"ChatType"] intValue]==ChatType_System];
        [cell setJid:xmppId];
        [cell setInfoDic:dict];
        [cell refreshUI];
        [cell setAccessibilityIdentifier:xmppId];
        if ([[QIMKit sharedInstance] isStickWithCombineJid:combineJid]) {
            [cell setBackgroundColor:[UIColor spectralColorLightColor]];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchBarKeyTmp resignFirstResponder];
    NSDictionary *dic = nil;
    if (_searchResults.count + _searchGroupResults.count > 0) {
        if (indexPath.row >= _searchResults.count) {
            dic = [_searchGroupResults objectAtIndex:[indexPath row] - _searchResults.count];
            NSString *xmppId = [dic objectForKey:@"GroupId"];
            [self redeemDidSelectContactWithJid:xmppId chatType:ChatType_GroupChat];
        }else{
            dic = [_searchResults objectAtIndex:[indexPath row]];
            NSString *xmppId = [dic objectForKey:@"XmppId"];
            [self redeemDidSelectContactWithJid:xmppId chatType:ChatType_SingleChat];
        }
        
    }else{
        dic = [_itemArray objectAtIndex:indexPath.row];
        NSString *xmppId = [dic objectForKey:@"XmppId"];
        int chatType = [[dic objectForKey:@"ChatType"] intValue];
        if (chatType == ChatType_SingleChat) {
            [self redeemDidSelectContactWithJid:xmppId chatType:ChatType_SingleChat];
        } else if (chatType == ChatType_GroupChat) {
            [self redeemDidSelectContactWithJid:xmppId chatType:ChatType_GroupChat];
        }
    }
}

- (void)redeemDidSelectContactWithJid:(NSString *)jid chatType:(ChatType)chatType {
    
    __block NSString *didSelectJid = jid;
    __block ChatType didSelectChatType = chatType;
    NSDictionary *infoDic = nil;
    NSString *name = nil;
    if (chatType == ChatType_SingleChat) {
        infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
    } else {
        infoDic = [[QIMKit sharedInstance] getGroupCardByGroupId:jid];
    }
    name = [infoDic objectForKey:@"Name"];
    
    NSString *redeemContactMsg = [NSString stringWithFormat:@"确认转发聊天记录到%@?", name];
    if (self.ExternalForward) {
        redeemContactMsg = [NSString stringWithFormat:@"确认发送给%@?", name];
    }
    UIAlertController *redeemContactVc = [UIAlertController alertControllerWithTitle:@"提示" message:redeemContactMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"cancel"] style:UIAlertActionStyleCancel handler:nil];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (didSelectChatType == ChatType_SingleChat) {
            [weakSelf selectContactWithJid:didSelectJid];
        } else if (didSelectChatType == ChatType_GroupChat) {
            [weakSelf selectGroupWithJid:didSelectJid];
        }
    }];
    [redeemContactVc addAction:cancelAction];
    [redeemContactVc addAction:okAction];
    [self presentViewController:redeemContactVc animated:YES completion:nil];
}

//解析原始消息
- (NSDictionary *)getOriginMessageWithMsg:(Message *)msg {
    if (msg.messageId.length <= 0) {
        return nil;
    }
    QIMVerboseLog(@"msgId : %@", msg.messageId);
    NSDictionary *msgDic = [[QIMKit sharedInstance] getMsgDictByMsgId:msg.messageId];
    if (msgDic.count > 0) {
        id msgRaw = msgDic[@"MsgRaw"];
        NSDictionary *messageHeaders = msgDic[@"MessageHeaders"];
        NSString * content = nil;
        NSString * extnedInfo = nil;
        NSString * backupInfo = nil;
        if (msgRaw) {
            NSDictionary * originMsgDic = [[QIMKit sharedInstance] parseMessageByMsgRaw:msgRaw];
            content = originMsgDic[@"content"];
            messageHeaders = originMsgDic[@"MessageHeaders"];
            extnedInfo = messageHeaders[@"extendInfo"];
            backupInfo = messageHeaders[@"backupinfo"];
        }
        QIMMessageType msgType = [[msgDic objectForKey:@"MsgType"] intValue];
        NSString *msgContent = [msgDic objectForKey:@"Content"];
        NSString *msgExtendInfo = [msgDic objectForKey:@"ExtendInfo"];
        NSDictionary *originMsg = @{@"Content":extnedInfo.length?content:msgContent, @"ExtendInfo":extnedInfo.length?extnedInfo:((msgExtendInfo.length > 0) ? msgExtendInfo : @""), @"MsgType":@(msgType), @"backupInfo": backupInfo.length?backupInfo:@""};
        return originMsg;
    }
    return nil;
}

//转发到单人会话
- (void)selectContactWithJid:(NSString *)jid{
    [[QIMKit sharedInstance] clearNotReadMsgByJid:jid];
    NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
    QIMChatVC *chatVC = (QIMChatVC *)[[QIMFastEntrance sharedInstance] getSingleChatVCByUserId:jid];
    /*
    QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
    [chatVC setStype:kSessionType_Chat];
    [chatVC setChatId:jid];
    [chatVC setName:[infoDic objectForKey:@"Name"]];
    [chatVC setTitle:[infoDic objectForKey:@"Name"]];
    */
    _selectInfoDic = @{@"userId":jid,@"isGroup":@(NO)};
    if (self.ExternalForward) {
        Message *newMsg = [[QIMKit sharedInstance] createMessageWithMsg:self.message.message extenddInfo:self.message.extendInformation userId:jid userType:ChatType_SingleChat msgType:self.message.messageType backinfo:nil];
        [[QIMKit sharedInstance] sendMessage:newMsg ToUserId:jid];
    } else {
        if (self.message) {
            NSString *msgContent = self.message.message;
            NSString *msgExtendInfo = self.message.extendInformation;
            if (msgContent.length > 0 && msgExtendInfo.length > 0) {
                Message *newMsg = [[QIMKit sharedInstance] createMessageWithMsg:msgContent extenddInfo:msgExtendInfo userId:jid userType:ChatType_SingleChat msgType:self.message.messageType backinfo:self.message.backupInfo];
                [[QIMKit sharedInstance] sendMessage:newMsg ToUserId:jid];
            } else {
                NSDictionary *originMsg = [self getOriginMessageWithMsg:self.message];
                NSString *msgContent = [originMsg objectForKey:@"Content"];
                NSString *msgExtendInfo = [originMsg objectForKey:@"ExtendInfo"];
                NSString *backUpInfo = [originMsg objectForKey:@"backupInfo"];
                QIMMessageType msgType = [[originMsg objectForKey:@"MsgType"] integerValue];
                if (msgType == QIMMessageType_None && !self.ExternalForward) {
                    [[QIMKit sharedInstance] sendMessage:self.message.message WithInfo:self.message.extendInformation ToUserId:jid WihtMsgType:self.message.messageType];
                } else {
                    Message *newMsg = [[QIMKit sharedInstance] createMessageWithMsg:msgContent extenddInfo:msgExtendInfo userId:jid userType:ChatType_SingleChat msgType:msgType backinfo:backUpInfo];
                    [[QIMKit sharedInstance] sendMessage:newMsg ToUserId:jid];
                }
            }
        } else if (self.messageList.count){
            for (Message * msg in self.messageList) {
                NSDictionary *originMsg = [self getOriginMessageWithMsg:msg];
                NSString *msgContent = [originMsg objectForKey:@"Content"];
                NSString *msgExtendInfo = [originMsg objectForKey:@"ExtendInfo"];
                NSString *backUpInfo = [originMsg objectForKey:@"backupInfo"];
                QIMMessageType msgType = [[originMsg objectForKey:@"MsgType"] integerValue];
                if (msgType == QIMMessageType_None && !self.ExternalForward) {
                    [[QIMKit sharedInstance] sendMessage:msg.message WithInfo:msg.extendInformation ToUserId:jid WihtMsgType:msg.messageType];
                } else {
                    Message *newMsg = [[QIMKit sharedInstance] createMessageWithMsg:msgContent extenddInfo:msgExtendInfo userId:jid userType:ChatType_SingleChat msgType:msgType backinfo:backUpInfo];
                    [[QIMKit sharedInstance] sendMessage:newMsg ToUserId:jid];
                }
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(contactSelectionViewController:chatVC:)]) {
                [self.delegate contactSelectionViewController:self chatVC:chatVC];
            }
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!self.isTransfer) {
        id nav = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if ([nav isKindOfClass:[QIMNavController class]]) {
            [nav popToRootVCThenPush:chatVC animated:YES];
        } else {
            nav = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
            [nav popToRootVCThenPush:chatVC animated:YES];
        }
    }
}

//转发到群会话
- (void)selectGroupWithJid:(NSString *)jid{
    
#warning 转发消息 可能出现丢字段的情况，需要从本地数据库取出原始消息拼接
    [[QIMKit sharedInstance] clearNotReadMsgByGroupId:jid];
    NSDictionary *infoDic = [[QIMKit sharedInstance] getGroupCardByGroupId:jid];
    QIMGroupChatVC *chatGroupVC = [[QIMFastEntrance sharedInstance] getGroupChatVCByGroupId:jid];
    /*
    QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
    [chatGroupVC setTitle:[infoDic objectForKey:@"Name"]];
    [chatGroupVC setChatId:jid];
     */
    _selectInfoDic = @{@"userId":jid,@"isGroup":@(YES)};
    if (self.ExternalForward) {
        Message *newMsg = [[QIMKit sharedInstance] createMessageWithMsg:self.message.message extenddInfo:self.message.extendInformation userId:jid userType:ChatType_GroupChat msgType:self.message.messageType backinfo:nil];
        Message *tempMsg = [[QIMKit sharedInstance] sendMessage:newMsg ToUserId:jid];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:jid userInfo:@{@"message":tempMsg}];
    } else {
        if (self.message) {
            NSString *msgContent = self.message.message;
            NSString *msgExtendInfo = self.message.extendInformation;
            if (msgContent.length > 0 && msgExtendInfo.length > 0) {
                Message *newMsg = [[QIMKit sharedInstance] createMessageWithMsg:msgContent extenddInfo:msgExtendInfo userId:jid userType:ChatType_GroupChat msgType:self.message.messageType backinfo:self.message.backupInfo];
                [[QIMKit sharedInstance] sendMessage:newMsg ToUserId:jid];
            } else {
                NSDictionary *originMsg = [self getOriginMessageWithMsg:self.message];
                NSString *msgContent = [originMsg objectForKey:@"Content"];
                NSString *msgExtendInfo = [originMsg objectForKey:@"ExtendInfo"];
                NSString *backUpInfo = [originMsg objectForKey:@"backupInfo"];
                QIMMessageType msgType = [[originMsg objectForKey:@"MsgType"] integerValue];
                if (msgType == QIMMessageType_None && !self.ExternalForward) {
                    [[QIMKit sharedInstance] sendMessage:self.message.message WithInfo:self.message.extendInformation ToGroupId:jid WihtMsgType:self.message.messageType];
                } else {
                    Message *newMsg = [[QIMKit sharedInstance] createMessageWithMsg:msgContent extenddInfo:msgExtendInfo userId:jid userType:ChatType_GroupChat msgType:msgType backinfo:backUpInfo];
                    [[QIMKit sharedInstance] sendMessage:newMsg ToUserId:jid];
                }
            }
        } else if (self.messageList.count){
            for (Message * msg in self.messageList) {
                NSDictionary *originMsg = [self getOriginMessageWithMsg:msg];
                NSString *msgContent = [originMsg objectForKey:@"Content"];
                NSString *msgExtendInfo = [originMsg objectForKey:@"ExtendInfo"];
                NSString *backUpInfo = [originMsg objectForKey:@"backupInfo"];
                QIMMessageType msgType = [[originMsg objectForKey:@"MsgType"] integerValue];
                if (msgType == QIMMessageType_None && self.ExternalForward) {
                    [[QIMKit sharedInstance] sendMessage:self.message.message WithInfo:self.message.extendInformation ToGroupId:jid WihtMsgType:self.message.messageType];
                } else {
                    Message *newMsg = [[QIMKit sharedInstance] createMessageWithMsg:msgContent extenddInfo:msgExtendInfo userId:jid userType:ChatType_GroupChat msgType:msgType backinfo:backUpInfo];
                    [[QIMKit sharedInstance] sendMessage:newMsg ToUserId:jid];
                }
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(contactSelectionViewController:groupChatVC:)]) {
                [self.delegate contactSelectionViewController:self groupChatVC:chatGroupVC];
            }
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    id nav = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if ([nav isKindOfClass:[QIMNavController class]]) {
        [nav popToRootVCThenPush:chatGroupVC animated:YES];
    } else {
        nav = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        [nav popToRootVCThenPush:chatGroupVC animated:YES];
    }
}

@end
