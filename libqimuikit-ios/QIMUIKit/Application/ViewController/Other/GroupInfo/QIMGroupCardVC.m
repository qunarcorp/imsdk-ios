//
//  QIMGroupCardVC.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/15.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMGroupCardVC.h"
#import "QIMCommonFont.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMGroupChatVC.h"
#import "QIMGroupNameCell.h"
#import "QIMGroupCardTopicCell.h"
#import "QIMGroupPushSettingCell.h"
#import "QIMGroupSettingCell.h"
#import "QIMQRCodeCell.h"
#import "QIMViewHelper.h"
#import "QIMPGroupSelectionView.h"
#import "QIMGroupChangeNameVC.h"
#import "QIMGroupChangeTopicVC.h"
//#import "GroupSettingVC.h"
#import "QIMGroupMemManCell.h"
#import "UIImage+ImageEffects.h"
#import "QIMGroupMembersCell.h"
#import "QIMGroupMemberListVC.h"
#import "QIMMenuView.h"
#import <MessageUI/MFMailComposeViewController.h>

#define kKickMemberAlertViewTag   10000
#define kQuitGroupAlertViewTag   10001


@interface MemberButton : UIButton
@property (nonatomic, strong) NSDictionary *memberDic;
@end
@implementation MemberButton

- (void)dealloc{
    [self setMemberDic:nil];
}

@end

@interface QIMGroupCardVC ()<UITableViewDataSource,UITableViewDelegate,SelectionResultDelegate,MFMailComposeViewControllerDelegate,QIMGroupMembersCellDelegate,UIActionSheetDelegate>{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    NSArray *_oldMembers;
    BOOL _atGroupIn;
    NSString *_nickName;
    NSDictionary *_groupCardDic;
    NSString *_oldNavTitle;
    BOOL        _canDel;
    NSDictionary * _currentMemberInfo;
    UILabel * _titleLabel;
    NSMutableArray * _memberList;
    UIButton * _doneButton;
}

@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) BOOL isAdmin;

@end

@implementation QIMGroupCardVC

- (void)updateUI{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
    
    [_doneButton setTitle:_atGroupIn? [NSBundle qim_localizedStringForKey:@"group_quit"] : [NSBundle qim_localizedStringForKey:@"group_join"] forState:UIControlStateNormal];
    [_doneButton setBackgroundColor:_atGroupIn?[UIColor qunarRedColor]:[UIColor qtalkIconSelectColor]];
    
    [self setGroupName:[_groupCardDic objectForKey:@"Name"]];
    [self setGroupTopic:[_groupCardDic objectForKey:@"Topic"]];
    _dataSource = [[NSMutableArray alloc] init];
    [_dataSource addObject:@"GroupName"];
    [_dataSource addObject:@"GroupId"];
    [_dataSource addObject:@"GroupTopic"];
    [_dataSource addObject:@"Cap"];
    [_dataSource addObject:@"GroupMembers"];
    [_dataSource addObject:@"Cap"];
    [_dataSource addObject:@"QRCode"];
    [_dataSource addObject:@"Cap"];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        [_dataSource addObject:@"PUSH"];
        [_dataSource addObject:@"Cap"];
    }
    
    if ([[QIMKit sharedInstance] isGroupOwner:self.groupId]) {
        //群设置暂时屏蔽
//        [_dataSource addObject:@"GroupSetting"];
//        [_dataSource addObject:@"Cap"];
    }
//    if (self.isOwner || self.isAdmin) {
//        [_dataSource addObject:@"GroupMemberManager"];
//        [_dataSource addObject:@"Cap"];
//    }
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
//        [_dataSource addObject:@"SendMail"];
//        [_dataSource addObject:@"Cap"];
    }
    
//    [_dataSource addObject:@"GroupMsgSetting"];
    [_dataSource addObject:@"Cap"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *members = [[QIMKit sharedInstance] getGroupMembersByGroupId:[self groupId]];
//        [[QIMKit sharedInstance] bulkInsertGroupMember:members WithGroupId:[self groupId]];
        _atGroupIn = [[QIMKit sharedInstance] isGroupMemberByGroupId:self.groupId];
        _groupCardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.groupId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    });
    
    [self initWithNavbar];
    [self initWithTableView];
    [self registerNotification];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMember) name:kChatRoomResgisterInviteUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMember) name:kChatRoomMemberChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMember) name:kChatRoomRemoveMember object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupCard:) name:kGroupCardChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupCard:) name:kGroupNickNameChanged object:nil];
}

- (void)updateGroupCard:(NSNotification *)notify {
    NSArray *groupIds = notify.object;
    if ([groupIds containsObject:self.groupId]) {
        _groupCardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.groupId];
        [self updateUI];
    }
}

- (void)reloadMember {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _oldMembers = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getGroupMembersByGroupId:self.groupId]];
        
        NSMutableArray *onlineList = [NSMutableArray array];
        NSMutableArray *offlineList = [NSMutableArray array];
        NSString *affiliation = @"none";
        for (NSDictionary *dic in _oldMembers) {
//            NSString *name = [dic objectForKey:@"name"];
            NSString *memberJid = [dic objectForKey:@"xmppjid"];
            NSString *presence = [[QIMKit sharedInstance] userOnlineStatus:memberJid];

            /*
            NSDictionary *infoDic = [[QIMKit sharedInstance] getUserInfoByName:name];
            NSString *xmppId = [infoDic objectForKey:@"XmppId"];
            NSString *presence = [[QIMKit sharedInstance] userOnlineStatus:xmppId]; */
            if ([presence isEqualToString:@"online"]) {
                [onlineList addObject:dic];
            } else if ([presence isEqualToString:@"away"]){
                [onlineList addObject:dic];
            } else {
                [offlineList addObject:dic];
            }
            if ([memberJid isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
                affiliation = [dic objectForKey:@"affiliation"];
            }
        }
        
        if (!_memberList) {
            _memberList = [NSMutableArray array];
        }else{
            [_memberList removeAllObjects];
        }
        [_memberList addObjectsFromArray:onlineList];
        [_memberList addObjectsFromArray:offlineList];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_memberList.count > 0) {
                int row = ((int)_memberList.count - 1)/4 + 1;
                CGFloat cap = 30;
                CGFloat width = (self.view.width - cap * 5) / 4.0;
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, row * (width + cap  + 10) + 40)];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                NSInteger onlineMemNum = 0;
                for (int i = 0; i < _memberList.count; i++) {
                    //获取用户信息
                    NSDictionary *memDic = [_memberList objectAtIndex:i];
                    if ([memDic objectForKey:@"type"] && [[memDic objectForKey:@"type"] isEqualToString:@"add"]) {
                        
                    } else {
                        NSString *memberXmppJid = [memDic objectForKey:@"xmppjid"];
                        UIImage *headerImage = [[QIMImageManager sharedInstance] getUserHeaderImageByUserId:memberXmppJid];
                        //判断用户在线状态
                        BOOL isUserOnline = [[QIMKit sharedInstance] isUserOnline:memberXmppJid];
                        if (isUserOnline == NO) {
                            headerImage = [headerImage qim_grayImage];
                        }else{
                            onlineMemNum ++;
                        }
                    }
                }
                [_tableView reloadData];
            }
        });
    });
}

- (void)viewWillAppear:(BOOL)animated{
    if (_oldNavTitle) {
        [_titleLabel setText:_oldNavTitle];
    }
    [super viewWillAppear:animated];
    [[QIMKit sharedInstance] updateGroupCardByGroupId:self.groupId];
    [self reloadMember];
    [_tableView reloadData];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _oldNavTitle = self.navigationItem.title;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void)initWithNavbar{
    [_titleLabel setText:[NSBundle qim_localizedStringForKey:@"common_group_card"]];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -20, self.view.width, self.view.height + 20) style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setBackgroundColor:[UIColor qim_colorWithHex:0xf0eff5 alpha:1]];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
    
//    [self initWithHeaderView];
    [self setUpTableViewHeader];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
    [_tableView setTableFooterView:footerView];
    
    _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 4, footerView.width - 40, 40)];
    [_doneButton.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
    [_doneButton setBackgroundColor:[UIColor qtalkIconSelectColor]];
    [_doneButton setTitle:_atGroupIn ? [NSBundle qim_localizedStringForKey:@"group_quit"] : [NSBundle qim_localizedStringForKey:@"group_join"] forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(onDoneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton.layer setBorderColor:[UIColor clearColor].CGColor];
    [_doneButton.layer setCornerRadius:_doneButton.height / 2.0];
    _doneButton.clipsToBounds = YES;
    [footerView addSubview:_doneButton];
    
    [self reloadMember];
}

- (void)setUpTableViewHeader {
    
    UIImage *headerImage = [[QIMKit sharedInstance] getGroupImageFromLocalByGroupId:self.groupId];
    UIImageView *header = [[UIImageView alloc] initWithImage:[headerImage qim_blurImageWithRadius:5]];
    header.frame = CGRectMake(0, 0, _tableView.width, 200);
    header.contentMode = UIViewContentModeScaleAspectFill;
    header.clipsToBounds = YES;
    header.userInteractionEnabled = YES;
    
    UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 85, 85)];
    headView.center = CGPointMake(header.centerX, header.centerY + 20);
    headView.layer.cornerRadius = headView.height / 2.0;
    headView.layer.borderWidth = 3.0f;
    headView.layer.borderColor = [UIColor whiteColor].CGColor;
    headView.clipsToBounds = YES;
    headView.image = headerImage;
    [header addSubview:headView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 74)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayer.bounds = bgView.bounds;
    gradientLayer.borderWidth = 0;
    gradientLayer.frame = bgView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor qim_colorWithHex:0x0 alpha:0.2] CGColor],
                            (id)[[UIColor clearColor] CGColor],  nil];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [bgView.layer insertSublayer:gradientLayer atIndex:0];
    [self.view addSubview:bgView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(5, 25, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"titlebar_back_nor"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"titlebar_back_pressed"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, backBtn.top, _tableView.width, backBtn.height)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = [NSBundle qim_localizedStringForKey:@"common_group_card"];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:_titleLabel];
    [_tableView setTableHeaderView:header];
}

- (void)initWithHeaderView {
    
    [self reloadMember];
}

#pragma mark - other method
- (void)invitePeople:(id) sender {
    
    QIMPGroupSelectionView *pgroupSelectionView  = [[QIMPGroupSelectionView alloc] init];
    [pgroupSelectionView setDelegate:self];
    pgroupSelectionView.existGroup = YES;
    [self.navigationController pushViewController:pgroupSelectionView animated:YES];
    [pgroupSelectionView setAlreadyExistsMember:[_oldMembers valueForKey:@"xmppjid"] withGroupId:_groupId];
}

- (void)longGesHandle:(UILongPressGestureRecognizer *)sender
{
    if (_canDel == NO && sender.state ==  UIGestureRecognizerStateBegan) {
        if (self.isAdmin || self.isOwner) {
            _canDel = YES;
            [self reloadMember];
        }else{
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"然而，咱并不能踢出某个成员呐..." delegate:nil cancelButtonTitle:@"俺知道了" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)delMemHandle:(MemberButton *)sender {
    _currentMemberInfo = sender.memberDic;
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"警告！" message:[NSString stringWithFormat:@"您即将将 %@ 踢出群组",_currentMemberInfo[@"name"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = kKickMemberAlertViewTag;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kKickMemberAlertViewTag) {
        if (buttonIndex == 1) {
            NSDictionary *infoDic = _currentMemberInfo;
            NSString *name = [infoDic objectForKey:@"name"];
            NSString *jid = [infoDic objectForKey:@"xmppjid"];
            NSString *groupId = [[[infoDic objectForKey:@"jid"] componentsSeparatedByString:@"/"] firstObject];
            [[QIMKit sharedInstance] removeGroupMemberWithName:name WithJid:jid ForGroupId:groupId];
            [self reloadMember];
        }
    } else if (alertView.tag == kQuitGroupAlertViewTag){
        if (buttonIndex == 1) {
            BOOL result = [[QIMKit sharedInstance] quitGroupId:self.groupId];
            if (result) {
                [[QIMKit sharedInstance] removeStickWithCombineJid:[NSString stringWithFormat:@"%@<>%@", self.groupId, self.groupId] WithChatType:ChatType_GroupChat];
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"退群失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

- (void)goBack:(id)sender {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onDoneButtonClick:(UIButton *)sender {
    if (_atGroupIn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您是否确定要退出该群？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.tag = kQuitGroupAlertViewTag;
        [alert show];
    } else {
        [self registerNotify:YES];
        _nickName = [[QIMKit sharedInstance] getMyNickName];
        [[QIMKit sharedInstance] joinGroupId:self.groupId ByName:_nickName isInitiative:YES];
    }
}


- (void)onJoinSuccessNotify:(NSNotification *)notify {
    [self registerNotify:NO];
    if ([_groupId isEqualToString:notify.object]) { 
        [[QIMKit sharedInstance] openGroupSessionByGroupId:self.groupId ByName:self.groupName];
        [QIMFastEntrance openGroupChatVCByGroupId:self.groupId];
        /*
        QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
        [chatGroupVC setTitle:self.groupName];
        [chatGroupVC setChatId:self.groupId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        [self.navigationController popToRootVCThenPush:chatGroupVC animated:YES];
         */
    }
}

- (void)onGroupErrorNotify:(NSNotification *)notify {
    [self registerNotify:NO];
    if ([_groupId isEqualToString:notify.object]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"ERROR %@:%@",[notify.userInfo objectForKey:@"errCode"],[notify.userInfo objectForKey:@"errMsg"]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - QIMGroupMembersCellDelegate

-(void)groupMembersCell:(QIMGroupMembersCell *)cell handleForGes:(UIGestureRecognizer *)ges {
    
    [self invitePeople:nil];
}

#pragma mark - table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 20;
    NSString *value = [_dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"GroupName"]) {
        height = [QIMGroupNameCell getCellHeight];
    } else if ([value isEqualToString:@"GroupId"]) {
        CGSize size = [self.groupId qim_sizeWithFontCompatible:[UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 2] constrainedToSize:CGSizeMake(self.view.width - 100, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        height = size.height + 20;
    } else if ([value isEqualToString:@"GroupTopic"]) {
        height = [QIMGroupCardTopicCell getCellHeightWithTopic:self.groupTopic];
    } else if ([value isEqualToString:@"GroupSetting"]) {
        height = [QIMGroupSettingCell getCellHeight];
    } else if ([value isEqualToString:@"QRCode"]) {
        height = [QIMQRCodeCell getCellHeight];
    } else if ([value isEqualToString:@"PUSH"]) {
        return [[QIMCommonFont sharedInstance] currentFontSize] + 32;
    } else if ([value isEqualToString:@"SendMail"]) {
        return [[QIMCommonFont sharedInstance] currentFontSize] + 32;
    } else if ([value isEqualToString:@"GroupMembers"]) {
        return 100;
    } else if ([value isEqualToString:@"GroupMsgSetting"]){
        height = 50;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *value = [_dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"GroupName"]) {
        
        static NSString *cellIdentifier = @"GroupName Cell";
        QIMGroupNameCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMGroupNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
        }
        [cell setName:self.groupName];
        [cell refreshUI];
        return cell;
    } else if ([value isEqualToString:@"GroupMsgSetting"]) {
        
        static NSString *cellIdentifier = @"GroupMsgSetting Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"group_msg_setting"]];
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.textColor = [UIColor qtalkTextLightColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        BOOL remind = [[QIMKit sharedInstance] groupPushState:self.groupId];
        cell.detailTextLabel.text = remind ? [NSBundle qim_localizedStringForKey:@"group_setting_rcevRmd"]  : [NSBundle qim_localizedStringForKey:@"group_setting_rcevNoRmd"];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
        cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
        return cell;
    } else if ([value isEqualToString:@"GroupId"]) {
        
        static NSString *cellIdentifier = @"DescInfo cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"group_id"]];
            cell.detailTextLabel.text = self.groupId;
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.textColor = [UIColor qtalkTextLightColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.numberOfLines = 0;
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, [self tableView:tableView heightForRowAtIndexPath:indexPath], _tableView.width - 10, 0.5)];
            [line setBackgroundColor:[UIColor qtalkTableDefaultColor]];
            [cell.contentView addSubview:line];
            
            CGSize size = [self.groupId qim_sizeWithFontCompatible:[UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 2] constrainedToSize:CGSizeMake(self.view.width - 100, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            
            QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, size.height + 20)];
            menuView.coprText = self.groupId;
            [cell.contentView addSubview:menuView];
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
        cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
        return cell;
    } else if ([value isEqualToString:@"GroupTopic"]) {
        
        static NSString *cellIdentifier = @"GroupTopic Cell";
        QIMGroupCardTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMGroupCardTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
        }
        [cell setTopic:self.groupTopic];
        [cell refreshUI];
        return cell;
    } else if ([value isEqualToString:@"GroupSetting"]) {
        
        static NSString *cellIdentifier = @"GroupSetting Cell";
        QIMGroupSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMGroupSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell refreshUI];
        return cell;
    } else if([value isEqualToString:@"QRCode"]) {
        
        static NSString *cellIdentifier = @"QRCode Cell";
        QIMQRCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMQRCodeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell refreshUI];
        return cell;
    } else if ([value isEqualToString:@"PUSH"]) {
        
        static NSString *cellIdentifier = @"PUSHCell";
        QIMGroupPushSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMGroupPushSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setGroupId:self.groupId];
        [cell refreshUI];

        return cell;
    } else if ([value isEqualToString:@"SendMail"]) {
        
        static NSString *cellIdentifier = @"SendMail cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell.textLabel setText:@"发送邮件"];
            [cell.textLabel setBackgroundColor:[UIColor clearColor]];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [cell.textLabel setTextColor:[UIColor qtalkTextLightColor]];
            [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        return cell;
    } else if ([value isEqualToString:@"GroupMembers"]) {
        
        static NSString *cellIdentifier = @"GroupMembers cell";
        QIMGroupMembersCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QIMGroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        [cell setCount:_oldMembers.count];
        [cell setItems:_memberList];
        return cell;
        
    } else {
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *value = [_dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"GroupName"]) {
        return YES;
    } else if ([value isEqualToString:@"GroupTopic"]) {
        return YES;
    } else if ([value isEqualToString:@"GroupSetting"]) {
        return YES;
    } else if ([value isEqualToString:@"QRCode"]) {
        return YES;
    } else if ([value isEqualToString:@"SendMail"]) {
        return YES;
    } else if ([value isEqualToString:@"GroupMembers"]) {
        return YES;
    } else if ([value isEqualToString:@"GroupMsgSetting"]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *value = [_dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"QRCode"]) {
        [QIMFastEntrance showQRCodeWithQRId:self.groupId withType:QRCodeType_GroupQR];
    } else if ([value isEqualToString:@"GroupName"]) {
        QIMGroupChangeNameVC *changeNameVC = [[QIMGroupChangeNameVC alloc] init];
        [changeNameVC setGroupId:self.groupId];
        [changeNameVC setGroupName:self.groupName];
        [self.navigationController pushViewController:changeNameVC animated:YES];
    } else if ([value isEqualToString:@"GroupTopic"]) {
        QIMGroupChangeTopicVC *changeTopicVC = [[QIMGroupChangeTopicVC alloc] init];
        [changeTopicVC setGroupId:self.groupId];
        [changeTopicVC setGroupTopic:self.groupTopic];
        [self.navigationController pushViewController:changeTopicVC animated:YES];
    } else if ([value isEqualToString:@"GroupSetting"]) {
        /* Comment by lilulucas.li
        GroupSettingVC *changeTopicVC = [[GroupSettingVC alloc] init];
        [changeTopicVC setGroupId:self.groupId];
        [self.navigationController pushViewController:changeTopicVC animated:YES];
         */
    } else if ([value isEqualToString:@"SendMail"]) {
        [self sendMail];
    } else if ([value isEqualToString:@"GroupMembers"]) {
        QIMGroupMemberListVC * memberListVC = [[QIMGroupMemberListVC alloc] init];
        memberListVC.items = [NSMutableArray arrayWithArray:_memberList];
        memberListVC.groupID = self.groupId;
        [self.navigationController pushViewController:memberListVC animated:YES];
    } else if ([value isEqualToString:@"GroupMsgSetting"]) {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择该群的消息提醒方式" delegate:self cancelButtonTitle:[NSBundle qim_localizedStringForKey:@"common_cancel"] destructiveButtonTitle:[NSBundle qim_localizedStringForKey:@"group_setting_rcevRmd"] otherButtonTitles:[NSBundle qim_localizedStringForKey:@"group_setting_rcevNoRmd"], nil];
        [actionSheet showInView:self.view];
    }
    [cell setSelected:NO];
}

- (void)sendMail{
    NSMutableArray *recipients = [NSMutableArray array];
    for (NSDictionary *member in _oldMembers) {
        NSString *jid = [member objectForKey:@"xmppjid"];
        if (jid) {
            [recipients addObject:[NSString stringWithFormat:@"%@@qunar.com",[[jid componentsSeparatedByString:@"@"] firstObject]]];
        }
    }
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:recipients];
    [controller setSubject:[NSString stringWithFormat:@"From %@",[[QIMKit sharedInstance] getMyNickName]]];
    [controller setMessageBody:@"\r\r\r\r\r\r\r\r\r\r\r From Iphone QTalk." isHTML:NO];
    [self presentViewController:controller animated:YES completion:nil];
   
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            
        } else {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[error description] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}


#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL state = NO;
    if (buttonIndex == 0) {
        state = YES;
        //接收消息并提醒
    } else if (buttonIndex == 1){
        //接收消息但不提醒
        state = NO;
    }
    [[QIMKit sharedInstance] updatePushState:self.groupId withOn:state];
    [_tableView reloadData];
}

@end

