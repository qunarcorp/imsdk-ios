//
//  QIMGroupMemberManagerController.m
//  qunarChatIphone
//
//  Created by chenjie on 15/8/17.
//
//

typedef enum {
    IdentityTypeOwner,
    IdentityTypeAdmin,
    IdentityTypeNomal,
} IdentityType;

#import "QIMGroupMemberManagerController.h"
#import "QIMGroupMemberManagerCell.h"

@interface QIMGroupMemberManagerController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView         * _mainTableView;
    NSMutableArray      * _members;
    IdentityType          _myIdentityType;
    
    NSIndexPath         * _currentIndexPath;
}
@end

@implementation QIMGroupMemberManagerController

-(instancetype)initWithMembers:(NSArray *)members
{
    if (self = [self init]) {
        _members = [NSMutableArray arrayWithArray:members];
        for (NSDictionary * _memberInfo in members) {
            if ([[_memberInfo objectForKey:@"xmppjid"] isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
                if ([[_memberInfo objectForKey:@"affiliation"] isEqualToString:@"owner"]) {
                    _myIdentityType = IdentityTypeOwner;
                } else if ([[_memberInfo objectForKey:@"affiliation"] isEqualToString:@"admin"] ) {
                    _myIdentityType = IdentityTypeAdmin;
                }else{
                    _myIdentityType = IdentityTypeNomal;
                }
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"群成员管理";
    
    [self setUpMainTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpMainTableView
{
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.backgroundColor = [UIColor qim_colorWithHex:0xf0eff5 alpha:1];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTableView];
}

- (void)getMembers
{
    
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QIMGroupMemberManagerCell  * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[QIMGroupMemberManagerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.memberInfo = [_members  objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * memberInfo = [_members  objectAtIndex:indexPath.row];
    if (_myIdentityType == IdentityTypeOwner) {
        if (![[memberInfo objectForKey:@"affiliation"] isEqualToString:@"owner"]) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    if (_myIdentityType == IdentityTypeAdmin) {
        if (![[memberInfo objectForKey:@"affiliation"] isEqualToString:@"owner"] && ![[memberInfo objectForKey:@"affiliation"] isEqualToString:@"admin"]) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _currentIndexPath = indexPath;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"警告！" message:@"是否确定将该成员从群组中移除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * member = [_members objectAtIndex:indexPath.row];
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByName:member[@"name"]];
    if (userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:[userInfo objectForKey:@"XmppId"]];
        });
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSDictionary *infoDic = [_members objectAtIndex:_currentIndexPath.row];
        NSString *name = [infoDic objectForKey:@"name"];
        NSString *jid = [infoDic objectForKey:@"jid"];
        BOOL success = [[QIMKit sharedInstance] removeGroupMemberWithName:name WithJid:jid ForGroupId:[infoDic objectForKey:@"jid"]];
        [_members removeObjectAtIndex:_currentIndexPath.row];
        [_mainTableView deleteRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

@end
