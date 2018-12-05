//
//  QIMGroupMemberListVC.m
//  qunarChatIphone
//
//  Created by chenjie on 15/11/19.
//
//

#import "QIMGroupMemberListVC.h"
#import "QIMGroupMemberCell.h"
#import "QIMPGroupSelectionView.h"
#import "QIMGroupNickNameHelper.h"
#import "QIMFastEntrance.h"

@interface QIMGroupMemberListVC ()<UITableViewDataSource,UITableViewDelegate,SelectionResultDelegate>
{
    UITableView         * _mainTableView;
    GroupMemberIDType     _memberType;
    NSIndexPath         * _willIndexPath;
    UILabel             * _addMemberLabel;
}
@end

@implementation QIMGroupMemberListVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"group_member"]];
    
    [self getMyMemberType];
    
    if (_memberType > GroupMemberIDTypeNone) {
        [self.navigationItem setRightBarButtonItem:self.editButtonItem];
    }
    
    [self initTableView];
    [self groupmemberChangedHandle:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupmemberChangedHandle:) name:@"groupmemberChanged"
    //聊天室成员变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupmemberChangedHandle:) name:kChatRoomResgisterInviteUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupmemberChangedHandle:) name:kChatRoomMemberChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupmemberChangedHandle:) name:kChatRoomRemoveMember object:nil];
    //群成员头像更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeaderImgUpdate:) name:kUserHeaderImgUpdate object:nil];

}

- (void)userHeaderImgUpdate:(NSNotification *)notify {
    [_mainTableView reloadData];
}

- (void)getMyMemberType{
    for (NSDictionary * memDic in self.items) {
        NSString * name = memDic[@"name"];
        if ([name isEqualToString:[[QIMKit sharedInstance] getMyNickName]]) {
            if ([[memDic objectForKey:@"affiliation"] isEqualToString:@"owner"]) {
                _memberType = GroupMemberIDTypeOwner;
            } else if ([[memDic objectForKey:@"affiliation"] isEqualToString:@"admin"]) {
                _memberType = GroupMemberIDTypeAdmin;
            } else{
                _memberType = GroupMemberIDTypeNone;
            }
            break;
        }
    }
}

- (void)groupmemberChangedHandle:(id)notify
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.items = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getGroupMembersByGroupId:self.groupID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mainTableView reloadData];
        });
    });
}

- (void)initTableView
{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_mainTableView];
    }
}

- (void)setAddMemberViewEnabled:(BOOL)enabled
{
    if (!_addMemberLabel && enabled) {
        _addMemberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _mainTableView.width, 50)];
        _addMemberLabel.backgroundColor = [UIColor qtalkIconSelectColor];
        _addMemberLabel.textAlignment = NSTextAlignmentCenter;
        _addMemberLabel.textColor = [UIColor whiteColor];
        _addMemberLabel.text = @"添加新成员";
        _addMemberLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [_addMemberLabel addGestureRecognizer:tap];
    }
    if (enabled) {
        _addMemberLabel.frame = CGRectMake(0, 0, _mainTableView.width, 0);
    }else{
        _addMemberLabel.frame = CGRectMake(0, 0, _mainTableView.width, 50);
    }
    [UIView animateWithDuration:0.5 animations:^{
        if (!enabled) {
            _addMemberLabel.frame = CGRectMake(0, 0, _mainTableView.width, 0);
        }else{
            _addMemberLabel.frame = CGRectMake(0, 0, _mainTableView.width, 50);
        }
        [_mainTableView setTableHeaderView:enabled ? _addMemberLabel : nil];
    }];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_mainTableView setEditing:self.editing animated:animated];
    [self setAddMemberViewEnabled:editing];
}

- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    QIMPGroupSelectionView * pgroupSelectionView  = [[QIMPGroupSelectionView alloc] init];
    [pgroupSelectionView setDelegate:self];
    pgroupSelectionView.existGroup = YES;
    [pgroupSelectionView setAlreadyExistsMember:[self.items valueForKey:@"xmppjid"] withGroupId:self.groupID];
    [self.navigationController pushViewController:pgroupSelectionView animated:YES];
}

#pragma mark - SelectionResultDelegate
-(void)selectionBuddiesArrays:(NSArray *)memberArrays
{
    QIMVerboseLog(@"%@",memberArrays);
    [self.items addObjectsFromArray:memberArrays];
    [_mainTableView reloadData];
}

#pragma mark - <UITableViewDataSource,UITableViewDelegate>
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellId = @"cell";
    QIMGroupMemberCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[QIMGroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        
        cell.imageView.layer.cornerRadius = 15;
        cell.imageView.clipsToBounds = YES;
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(50, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, tableView.width - 50, 0.5)];
        line.backgroundColor = [UIColor qtalkTableDefaultColor];
        [cell.contentView addSubview:line];
        
    }
    NSString *userId = [self.items objectAtIndex:indexPath.row][@"xmppjid"];
    if (!userId) {
        userId = [self.items objectAtIndex:indexPath.row][@"jid"];
    }
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    NSString *name = (remarkName.length > 0) ? remarkName : [self.items objectAtIndex:indexPath.row][@"name"];
    cell.textLabel.text = (remarkName.length > 0) ? remarkName : name;
    BOOL isUserOnline  = [[QIMKit sharedInstance] isUserOnline:userId];

    [cell.imageView qim_setImageWithJid:userId];
    if ([[[self.items objectAtIndex:indexPath.row] objectForKey:@"affiliation"] isEqualToString:@"owner"]) {
        [cell setMemberIDType:GroupMemberIDTypeOwner];
    }else if ([[[self.items objectAtIndex:indexPath.row] objectForKey:@"affiliation"] isEqualToString:@"admin"]) {
        [cell setMemberIDType:GroupMemberIDTypeAdmin];
    }else {
        cell.isOnLine = isUserOnline;
        [cell setMemberIDType:GroupMemberIDTypeNone];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *userId =[self.items objectAtIndex:indexPath.row][@"xmppjid"];
    if (!userId) {
        userId = [self.items objectAtIndex:indexPath.row][@"jid"];
    }
    /*
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByName:[self.items objectAtIndex:indexPath.row][@"name"]];
    NSString *userId = [userInfo objectForKey:@"XmppId"];
    if (!userId) {
        userId = [self.items objectAtIndex:indexPath.row][@"xmppjid"];
    } */
    dispatch_async(dispatch_get_main_queue(), ^{
        [QIMFastEntrance openUserCardVCByUserId:userId];
    });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * memDic = [self.items objectAtIndex:indexPath.row];
    GroupMemberIDType memType = GroupMemberIDTypeNone;
    if ([[memDic objectForKey:@"affiliation"] isEqualToString:@"owner"]) {
        memType = GroupMemberIDTypeOwner;
    }else if ([[memDic objectForKey:@"affiliation"] isEqualToString:@"admin"]) {
        memType = GroupMemberIDTypeAdmin;
    }
    return memType < _memberType;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _willIndexPath = indexPath;
        [self delMember:[self.items objectAtIndex:indexPath.row]];
    }
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除";
}

- (void)delMember:(NSDictionary *)memDic
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"警告！" message:[NSString stringWithFormat:@"您即将将 %@ 踢出群组",memDic[@"name"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSDictionary *infoDic = self.items[_willIndexPath.row];
        NSString *name = [infoDic objectForKey:@"name"];
        NSString *jid = [infoDic objectForKey:@"xmppjid"];
        if (!jid) {
            jid = [infoDic objectForKey:@"jid"];
        }
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
            name = [jid componentsSeparatedByString:@"@"].firstObject;
        }
        BOOL success = [[QIMKit sharedInstance] removeGroupMemberWithName:name WithJid:jid ForGroupId:self.groupID];
        if (success) {
            [self.items removeObjectAtIndex:_willIndexPath.row];
            [_mainTableView deleteRowsAtIndexPaths:@[_willIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[QIMKit sharedInstance] bulkInsertGroupMember:self.items WithGroupId:self.groupID];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomRemoveMember object:nil];
            });
        } else {
            
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.items = nil;
}

@end
