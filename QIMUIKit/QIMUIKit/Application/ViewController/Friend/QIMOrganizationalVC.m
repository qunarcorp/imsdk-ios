//
//  QIMOrganizationalVC.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/17.
//

#import "QIMOrganizationalVC.h"
#import "QIMBuddyTitleCell.h"
#import "QIMBuddyItemCell.h"
#import "QIMDatasourceItem.h"
#import "QIMContactDatasourceManager.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMOrganizationalVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation QIMOrganizationalVC

- (void)loadRosterList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count] == 0) {
            [[QIMContactDatasourceManager getInstance] createUnMeregeDataSource];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor qim_colorWithHex:0xeaeaea alpha:1]];
    [self initWithNav];
    [self initWithTableView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadRosterList];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAccessibilityIdentifier:@"QTalkOrganizational"];
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
}

- (void)initWithNav{
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"组织架构"]];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count2 = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count];
    return count2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QIMDatasourceItem * item2 = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem]  objectAtIndex:indexPath.row];
    CGFloat height  = item2.isParentNode ? 38 : 60;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    QIMDatasourceItem * item = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] objectAtIndex:indexPath.row];
    
    if (item.isParentNode ) {
        
        NSString *cellIdentifier1 = [NSString stringWithFormat:@"CONTACT_BUDDY_TITLE_%ld", (long)[item nLevel]];
        QIMBuddyTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell == nil) {
            cell = [[QIMBuddyTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            [cell initSubControls];
        }
        NSString * userName  =  item.nodeName;
        [cell setUserName:userName];
        [cell setExpanded:item.isExpand];
        [cell setNLevel:(int32_t)item.nLevel];
        [cell refresh];
        return cell;
    }
    else {
        static NSString *cellIdentifier2 = @"CONTACT_BUDDY";
        QIMBuddyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMBuddyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        NSString * userName  =  item.nodeName;
        NSString *jid      =   item.jid;
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
        [cell initSubControls];
        [cell setNLevel:item.nLevel];
        [cell setUserName:remarkName?remarkName:userName];
        [cell setJid:jid];
        [cell refrash];
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count] > 0) {
        QIMDatasourceItem *qtalkItem = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] objectAtIndex:indexPath.row];
        if ([qtalkItem isParentNode]) {
            if ([qtalkItem isExpand]) {
                [[QIMContactDatasourceManager getInstance] collapseBranchAtIndex:indexPath.row];
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass:[QIMBuddyTitleCell class]]) {
                    [cell setExpanded:NO];
                    [_tableView reloadData];
                }
            }
            else {
                [[QIMContactDatasourceManager getInstance] expandBranchAtIndex:indexPath.row];
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass:[QIMBuddyTitleCell class]]) {
                    [cell setExpanded:YES];
                    [_tableView reloadData];
                }
            }
        } else {
            NSString *jid = qtalkItem.jid;
            dispatch_async(dispatch_get_main_queue(), ^{
                [QIMFastEntrance openUserCardVCByUserId:jid];
            });
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
