//
//  QIMCreatePgroupVC.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/18.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMCreatePgroupVC.h"
#import "QIMPGroupSelectionView.h"
#import "QIMViewHelper.h"

@interface QIMCreatePgroupVC ()<UITableViewDataSource,UITableViewDelegate,SelectionResultDelegate,UITextFieldDelegate>
{
    UITableView     * _tableView;
    
    UITextField     * groupNameTextField;
    
    NSMutableArray  * _selectionArray;
    
}
@end

@implementation QIMCreatePgroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavBar];
    
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)initNavBar
{
//    _navBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kNavigationBarHeight)];
//    
//    [_navBar setTitle:self.title];
//    
//    
//    [self.view addSubview:_navBar];
//    
//    BarButton *leftButton = [[BarButton alloc] initWithTitle:@"返回" style:eBarButtonStyleBack target:self action:@selector(goBack:)];
//    
//    [_navBar setLeftBarItem:leftButton];
    
    
//    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
//    
//    [rightView setBackgroundColor:[UIColor clearColor]];
//    
//    [_navBar setRightBarItem:rightView];
//    
//    [_navBar setTitle:@"创建群组"];
    [self.navigationItem setTitle:@"创建群组"];
}

-(void)initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    [_tableView reloadData];
}
- (void)goBack:(id)sender{
    
    //    [[QIMKit sharedInstance] updateMessageReadStateWithSessionId:self.chatSession.sessionId];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [VCController popVCAnimated:YES];
}


#pragma mark - view for head

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 20.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    if ((section == 0)||(section == 1)|| (section == 2)) {
        
        
        UIView * headView = [[UIView alloc] init];
        
        [headView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        
        [headView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        
        return headView;
    }
    else
    {
        return nil;
    }
    
    
    
}
#pragma mark -UITableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0) {
        return  1;
    }else if (section == 1) {
        
        return 2;
    }else if (section == 2) {
        
        return 1;
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSUInteger row = [indexPath row];
    //
    //    // 父窗口尺寸
    //    CGRect parentFrame = [tableView frame];
    
    // Name
    
    
    NSString *reusedIdentifer = @"Group Setting cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifer];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reusedIdentifer];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor whiteColor]];
        
    }
    
    
    [self setupTableCellNameSubs:[cell contentView] indexPath:indexPath];
    
    
    //[[cell contentView] setFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
    
    // 创建contentView
    //        CGSize contentViewSize = CGSizeMake(parentFrame.size.width, RSelfContactModifyTableCellHeight);
    //        [[cell groupContentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    //        [self setupTableCellNameSubs:[cell groupContentView] inSize:&contentViewSize];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 2) {
        return  800;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSUInteger row = [indexPath row];
    //
    //    // 父窗口尺寸
    //    CGRect parentFrame = [tableView frame];
    //
    //    // Name
    //    if(row == 0)
    //    {
    //        NSString *reusedIdentifer = @"Group Setting cell";
    //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifer];
    //        if (cell == nil)
    //        {
    //            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
    //                                                 reuseIdentifier:reusedIdentifer];
    //            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    //            [cell setBackgroundColor:[UIColor whiteColor]];
    //
    //            // 初始化
    //           // [self initTableCellNameSubs:[cell groupContentView]];
    //        }
    //
    //        // 创建contentView
    ////        CGSize contentViewSize = CGSizeMake(parentFrame.size.width, RSelfContactModifyTableCellHeight);
    ////        [[cell groupContentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    ////        [self setupTableCellNameSubs:[cell groupContentView] inSize:&contentViewSize];
    //
    //        return cell;
    //    }
    
    if ((indexPath.section == 1) && indexPath.row == 0) {
        
        QIMPGroupSelectionView * pgroupSelectionView  = [[QIMPGroupSelectionView alloc]init];
        
        [pgroupSelectionView setDelegate:self];
        
//        [pgroupSelectionView setGroupID:self.groupID];
//        
//        [pgroupSelectionView setGroupName:self.groupName];
        
//        [VCController pushVC:pgroupSelectionView animated:YES];
        [self.navigationController pushViewController:pgroupSelectionView animated:YES];
        
    }
}


-(void)setupTableCellNameSubs:(UIView *)parentView  indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        UIImageView * headView  = [[UIImageView alloc] init];
        [headView setFrame:CGRectMake(10, 8, 30, 30)];
        [headView setImage:[UIImage imageNamed:@"singleHeaderDefault" ]];
        [parentView addSubview:headView];
        
        if (groupNameTextField == nil) {
               groupNameTextField  = [[UITextField alloc]init];
        }

        [groupNameTextField setFrame: CGRectMake(headView.frame.size.width + 15,2, 250, 40)];
        [groupNameTextField setKeyboardType:UIKeyboardTypeDefault];
        [groupNameTextField setTextColor:[UIColor spectralColorGrayDarkColor]];
        [groupNameTextField setPlaceholder:@"请输入群的名称"];
        [groupNameTextField setReturnKeyType:UIReturnKeyDone];
        [groupNameTextField setFont:[UIFont fontWithName:FONT_NAME size:14]];
        [groupNameTextField setDelegate:self];
        [QIMViewHelper setTextFieldLeftView:groupNameTextField];
        [parentView addSubview:groupNameTextField];
    }
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            UILabel * addNameToGroupLabel  = [[UILabel alloc]init];
            [addNameToGroupLabel setFrame: CGRectMake(15 + 15,15, 300, 20)];
            [addNameToGroupLabel setText:@"邀请群成员"];
            [addNameToGroupLabel setFont:[UIFont fontWithName:FONT_NAME size:14]];
            [addNameToGroupLabel setTextColor:[UIColor spectralColorGrayDarkColor]];
            [parentView addSubview:addNameToGroupLabel];
            
            UIImageView * arrowView =  [[UIImageView alloc] init];
            [arrowView setFrame:CGRectMake(self.view.frame.size.width - 30, 15, 20, 20)];
            [arrowView setImage:[UIImage imageNamed:@"icon_arrow_r" ]];
            [parentView addSubview:arrowView];
        }
        else if(indexPath.row == 1)
        {
            UILabel * addNameToGroupLabel  = [[UILabel alloc]init];
            [addNameToGroupLabel setFrame: CGRectMake(15 + 15,15, 300, 20)];
            [addNameToGroupLabel setText:@"群简介"];
            [addNameToGroupLabel setFont:[UIFont fontWithName:FONT_NAME size:14]];
            [addNameToGroupLabel setTextColor:[UIColor spectralColorGrayDarkColor]];
            [parentView addSubview:addNameToGroupLabel];
            
            UIImageView * arrowView =  [[UIImageView alloc] init];
            [arrowView setFrame:CGRectMake(self.view.frame.size.width - 30, 15, 20, 20)];
            [arrowView setImage:[UIImage imageNamed:@"icon_arrow_r" ]];
            [parentView addSubview:arrowView];
        }
    }
    else if(indexPath.section == 2)
    {
        UIButton * createGroupBtn  = [[UIButton alloc] init];
        [createGroupBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:14]];
        [createGroupBtn setFrame:CGRectMake(self.view.frame.size.width /2 - 110, 20, 220, 40)];
        [createGroupBtn setBackgroundColor:[UIColor spectralColorBlueColor]];
        [createGroupBtn setTitleColor:[UIColor spectralColorWhiteColor] forState:UIControlStateNormal];
        [createGroupBtn setTitleColor:[UIColor spectralColorGrayColor] forState:UIControlStateSelected];
        [createGroupBtn setTitle:@"创建" forState:UIControlStateNormal];
        [createGroupBtn addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
        [QIMViewHelper setRadiusToView:createGroupBtn];
        [parentView  addSubview:createGroupBtn];
    }
    
}

-(void)createGroup
{
    if ( ( [[groupNameTextField text] length] > 0 )&& ([_selectionArray count] > 0)) {
        
        //TODO:no such method
//        if ([[QIMKit sharedInstance] createGroupByGroupName:groupName WithMyNickName:[infoDic objectForKey:@"Name"] WithInviteMember:temp WithSetting:settingDic WithTopic:_groupTopic.stringValue])
//        [[QIMKit sharedInstance] createGroupByGroupName:[groupNameTextField text]
//                                            WithMyNickName:[[QIMKit sharedInstance] getMyNickName]
//                                          WithInviteMember:_selectionArray WithSetting:[[QIMKit sharedInstance] defaultGroupSetting]
//                                                 WithTopic:@""];
        [[QIMKit sharedInstance] createGroupByGroupName:[groupNameTextField text]
                                            WithMyNickName:[[QIMKit sharedInstance] getMyNickName]
                                          WithInviteMember:_selectionArray
                                               WithSetting:[[QIMKit sharedInstance] defaultGroupSetting]
                                                  WithDesc:@""
                                         WithGroupNickName:@""
                                              WithComplate:^(BOOL finish,NSString *groupId) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNickNameChanged
                                                            object:@[groupId]]; 
        }];
//        [[QIMKit sharedInstance] createGroupByName:[groupNameTextField text] WithSelectionMember:_selectionArray];
        
//        [VCController popVCAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([[groupNameTextField text] length] == 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"群名称不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
        else if([_selectionArray count] == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择群成员" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
        

    }
    
    
}

- (void)selectionBuddiesArrays:(NSArray *)memberArrays;
{
    _selectionArray = (NSMutableArray *)memberArrays;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
@end
