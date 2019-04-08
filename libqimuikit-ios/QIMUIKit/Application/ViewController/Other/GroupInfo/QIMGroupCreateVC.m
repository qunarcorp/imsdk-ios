//
//  QIMGroupCardVC.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/15.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMGroupCreateVC.h"
#import "QIMUUIDTools.h"
#import "QIMGroupChatVC.h"
#import "QIMGroupNameCell.h"
#import "QIMGroupCardTopicCell.h"
#import "QIMGroupSettingCell.h"
#import "QIMQRCodeCell.h"
#import "QIMViewHelper.h"
#import "QIMPGroupSelectionView.h"
#import "MBProgressHUD.h"

@interface GroupMemberButton : UIButton
@property (nonatomic, strong) NSDictionary *memberDic;
@end
@implementation GroupMemberButton

- (void)dealloc{
    [self setMemberDic:nil];
}

@end

@interface QIMGroupCreateVC ()<UITableViewDataSource,UITableViewDelegate,SelectionResultDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    NSArray *_oldMembers;
    BOOL _atGroupIn;
    NSString *_nickName;
    NSDictionary *_groupCardDic;
    
    UITextField     * groupNameTextField;
    NSMutableArray  * _memberArrays;
    
    UIView *_loadingView;
    NSString *_groupId;
    
}

@end

@implementation QIMGroupCreateVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _groupId = [QIMUUIDTools UUID];
    _memberArrays = [NSMutableArray arrayWithCapacity:1];
    if ([self userId]) { 
        [_memberArrays addObject:[self userId]];
    } else { 
        [_memberArrays addObject:[[QIMKit sharedInstance] getLastJid]];
    }
    
    [self initWithNavbar];
    [self initWithTableView];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMember) name:@"groupmemberChanged" object:nil];
}

- (void) reloadMember {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *memberList = [NSMutableArray arrayWithCapacity:1];
        for (NSString * userID in _memberArrays) {
            NSDictionary * userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userID];
            if (userInfo) {
                NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userID];
                [memberList addObject:@{@"name" : (remarkName?remarkName:[userInfo objectForKey:@"Name"]),@"UserId" : userID}];
            }
        }
        [memberList addObject:@{@"type" : @"add"}];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (memberList.count > 0) {
                int row = ((int)memberList.count - 1)/4 + 1;
                CGFloat cap = 30;
                CGFloat width = (self.view.width - cap * 5) / 4.0;
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, row * (width + cap  + 10) + 40)];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                for (int i = 0; i < memberList.count; i++) {
                    
                    //获取用户信息
                    NSDictionary *memDic = [memberList objectAtIndex:i];
                    
                    if ([memDic objectForKey:@"type"] && [[memDic objectForKey:@"type"] isEqualToString:@"add"]) {
                        
                        // 增加拉人逻辑
                        UIButton *addLabel = [[UIButton alloc] initWithFrame:CGRectMake(cap + i % 4 * (width + cap), 20+i/4*(width+cap+10), width, width)];
                        [addLabel setBackgroundColor:[UIColor clearColor]];
                        [addLabel setTitle:@"➕" forState:UIControlStateNormal];
                        
                        [addLabel addTarget:self action:@selector(invitePeople:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [headerView addSubview:addLabel];
                        
                    } else {
                        
                        NSString *newMemberJid = [memDic objectForKey:@"UserId"];
                        NSString *name = [memDic objectForKey:@"name"];
                        UIImage *headerImage = [[QIMImageManager sharedInstance] getUserHeaderImageByUserId:newMemberJid];
                      
                        BOOL isUserOnline = [[QIMKit sharedInstance] isUserOnline:newMemberJid];
                        if (isUserOnline == NO) {
                            headerImage = [headerImage qim_grayImage];
                        }
                        
                        GroupMemberButton *headerButton = [[GroupMemberButton alloc] initWithFrame:CGRectMake(cap + i % 4 * (width + cap), 20+i/4*(width+cap+10), width, width)];
                        [headerButton setMemberDic:memDic];
                        [headerButton setBackgroundImage:headerImage forState:UIControlStateNormal];
                        [headerButton.layer setCornerRadius:5];
                        [headerButton setClipsToBounds:YES];
                        [headerButton addTarget:self action:@selector(singlePeople:) forControlEvents:UIControlEventTouchUpInside];
                        [headerView addSubview:headerButton];
                        
                        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerButton.left-2, headerButton.bottom+5, headerButton.width+5, 20)];
                        [titleLabel setBackgroundColor:[UIColor clearColor]];
                        [titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 4]];
                        [titleLabel setTextColor:[UIColor grayColor]];
                        [titleLabel setTextAlignment:NSTextAlignmentCenter];
                        [titleLabel setText:[NSString stringWithFormat:@"%@%@",name, isUserOnline ? @"(在线)" : @""]];
                        [headerView addSubview:titleLabel];
                    }
                }
                [_tableView setTableHeaderView:headerView];
            } 
        });
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerNotify:(BOOL)isRegister{
    if (isRegister) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onJoinSuccessNotify:) name:kMyJoinGroup object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupErrorNotify:) name:kChatGroupError object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - init ui

- (void)initWithNavbar {
    [self.navigationItem setTitle:@"创建群组"];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setBackgroundColor:[UIColor qim_colorWithHex:0xf0eff5 alpha:1]];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
    
    [self initWithHeaderView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
    [_tableView setTableFooterView:footerView];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 24, footerView.width - 20, 40)];
    [doneButton.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
    [doneButton setBackgroundColor:[UIColor qtalkIconSelectColor]];
    [doneButton setTitle:@"发起群聊" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(onDoneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [QIMViewHelper setRadiusToView:doneButton];
    [footerView addSubview:doneButton];
}

- (void)initWithHeaderView {
    
    [self reloadMember];
}

-(void)selectionBuddiesArrays:(NSArray *)memberArrays
{
    QIMVerboseLog(@"%@",memberArrays);
    [_memberArrays addObjectsFromArray:memberArrays];
    [self reloadMember];
}

#pragma mark - other method 

- (void)invitePeople:(id) sender {
    
    QIMPGroupSelectionView *pgroupSelectionView  = [[QIMPGroupSelectionView alloc] init];
    [pgroupSelectionView setDelegate:self];
    [self.navigationController pushViewController:pgroupSelectionView animated:YES];
    [pgroupSelectionView setAlreadyExistsMember:[_oldMembers valueForKey:@"xmppjid"] withGroupId:_groupId];
}

-(void)singlePeople:(GroupMemberButton *)sender {
//    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByName:sender.memberDic[@"name"]];
    NSString *userId = [sender.memberDic objectForKey:@"UserId"];
    if (userId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:userId];
        });
    }
}

- (void)goBack:(id)sender{
        
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onDoneButtonClick:(UIButton *)sender{
    
    _loadingView = [[UIView alloc] initWithFrame:_tableView.frame];
    [self.view addSubview:_loadingView];
    [MBProgressHUD showHUDAddedTo:_loadingView animated:YES];
    
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:_memberArrays];
    NSMutableString *groupName = [NSMutableString stringWithString:[temp count] > 1 ? @"":@"群组("];
    
    for (NSString *jid in temp) {
        NSDictionary * userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
        if (userInfo) {
            [groupName appendString:[userInfo objectForKey:@"Name"]];
        }
        
        [groupName appendString:([[temp lastObject] isEqual:jid]) ? temp.count>1?@"":@")" :@","];
    }
    NSString *nickName = [[QIMKit sharedInstance] getMyNickName];
    [[QIMKit sharedInstance] createGroupByGroupName:_groupId
                                        WithMyNickName:nickName
                                      WithInviteMember:_memberArrays
                                           WithSetting:[[QIMKit sharedInstance] defaultGroupSetting]
                                              WithDesc:@""
                                     WithGroupNickName:groupName
                                          WithComplate:^(BOOL finish,NSString *groupId) {
                                              
        [MBProgressHUD hideAllHUDsForView:_loadingView animated:YES];
        [_loadingView removeFromSuperview];
        _loadingView = nil;
        if (finish) {
            if ([groupNameTextField isFirstResponder]) {
                [groupNameTextField resignFirstResponder];
            }
            [[QIMKit sharedInstance] clearNotReadMsgByGroupId:groupId];
            [QIMFastEntrance openGroupChatVCByGroupId:groupId];
            /*
            QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
            [chatGroupVC setTitle:groupName];
            [chatGroupVC setChatId:groupId];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
            [self.navigationController popToRootVCThenPush:chatGroupVC animated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNickNameChanged object:@[groupId]];
            */
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"创建失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}


- (void)onJoinSuccessNotify:(NSNotification *)notify{
    
}

- (void)onGroupErrorNotify:(NSNotification *)notify{
    
}

#pragma mark - table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 60;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reusedIdentifer = @"Group Setting cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifer];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reusedIdentifer];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
    }
    
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.frame = CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, 50);
    [cell.contentView addSubview:bgView];
    
    UIImageView * headView  = [[UIImageView alloc] init];
    [headView setFrame:CGRectMake(10, 8, 30, 30)];
    [headView setImage:[UIImage imageNamed:@"singleHeaderDefault" ]];
    [bgView addSubview:headView];
    
    if (groupNameTextField == nil) {
        groupNameTextField  = [[UITextField alloc]init];
    }
    
    [groupNameTextField setFrame: CGRectMake(headView.frame.size.width + 15,5, 250, 40)];
    [groupNameTextField setKeyboardType:UIKeyboardTypeDefault];
    [groupNameTextField setTextColor:[UIColor spectralColorGrayDarkColor]];
    [groupNameTextField setPlaceholder:@"请输入群的名称发起群聊"];
    [groupNameTextField setReturnKeyType:UIReturnKeyDone];
    [groupNameTextField setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
    [groupNameTextField setDelegate:self];
    [QIMViewHelper setTextFieldLeftView:groupNameTextField];
    [bgView addSubview:groupNameTextField];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{

    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return;
}

@end

