//
//  QIMFriendListViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMFriendListViewController.h"
#import "QIMJSONSerializer.h"
#import "QIMFriendNodeItem.h"
#import "QIMFriendListCell.h"
#import "QIMFriendTitleListCell.h"
#import "QIMAddIndexViewController.h"
#import "QIMAddSomeViewController.h"
#import "QIMContactDatasourceManager.h"
#import "QIMDatasourceItem.h"
#import "QIMBuddyTitleCell.h"
#import "QIMBuddyItemCell.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMFriendListViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    UITableView *_tableView;
    NSMutableArray *_rosterList;
    NSMutableArray *_friendList;
    NSMutableArray *_dataSource;
    BOOL _friendIsExpanded;
    BOOL _blackIsExpanded;
    BOOL _rosterIsExpanded;
}

@end

@implementation QIMFriendListViewController


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

- (void)updateFriendList{
    [_friendList removeAllObjects];
    [_dataSource removeAllObjects];
    int onlineCount = 0;
    for (NSDictionary *infoDic in [[QIMKit sharedInstance] selectFriendList]) {
        NSString *jid = [infoDic objectForKey:@"XmppId"];
        QIMFriendNodeItem *item = [[QIMFriendNodeItem alloc] init];
        [item setIsParentNode:NO];
        [item setName:[NSBundle qim_localizedStringForKey:@"contact_tab_friend"]];
        [item setContentValue:infoDic];
        if ([[QIMKit sharedInstance] isUserOnline:jid]) {
            [_friendList insertObject:item atIndex:onlineCount];
            onlineCount++;
        }else{
            [_friendList addObject:item];
        }
    }
    [[_friendList lastObject] setIsLast:YES];
 
    QIMFriendNodeItem *friendNode = [[QIMFriendNodeItem alloc] init];
    [friendNode setIsParentNode:YES];
    [friendNode setIsFriend:YES];
    [friendNode setName:[NSBundle qim_localizedStringForKey:@"contact_tab_friend"]];
    [friendNode setDescInfo:[NSString stringWithFormat:@"%d/%ld",onlineCount,(unsigned long)_friendList.count]];
    [friendNode setContentValue:_friendList];
    [_dataSource addObject:friendNode];
    if (_friendIsExpanded) {
        [_dataSource insertObjects:friendNode.contentValue atIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(1,_friendList.count)]];
    }
    
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendList) name:kFriendListUpdate object:nil];
    
    [self.view setBackgroundColor:[UIColor qim_colorWithHex:0xeaeaea alpha:1]];
    
    _dataSource = [NSMutableArray array];
    _friendList = [NSMutableArray array];
    [self updateFriendList];
    [self initWithNav];
    [self initWithTableView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat && [[QIMKit sharedInstance] isMerchant]) {
        [self loadRosterList];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - init UI
- (void)onAddClick{
    QIMAddIndexViewController *indexVC = [[QIMAddIndexViewController alloc] init];
    [self.navigationController pushViewController:indexVC animated:YES];
}

- (void)initWithNav{
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"contact_tab_friend"]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_add"] style:UIBarButtonItemStyleDone target:self action:@selector(onAddClick)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAccessibilityIdentifier:@"FriendList"];
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
    NSDictionary *valueCountDic = @{@"FriendCount":@(_friendList.count)};
    [_tableView setAccessibilityValue:[[QIMJSONSerializer sharedInstance] serializeObject:valueCountDic]];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0 && [QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        NSInteger count2 = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count];
        return count2;
    } else {
        return _dataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && [QIMKit getQIMProjectType] == QIMProjectTypeQChat) {

        QIMDatasourceItem * item2 = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem]  objectAtIndex:indexPath.row];
        CGFloat height  = item2.isParentNode ? 38 : 60;
        return height;
    } else {
        QIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
        if (item.isParentNode) {
            return [QIMFriendTitleListCell getCellHeight];
        } else {
            QIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
            return [QIMFriendListCell getCellHeightForDesc:[item.contentValue objectForKey:@"DescInfo"]];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && [QIMKit getQIMProjectType] == QIMProjectTypeQChat) {

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
            NSString *userName  =  item.nodeName;
            NSString *jid      =   item.jid;
            NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
            [cell initSubControls];
            [cell setNLevel:item.nLevel];
            [cell setUserName:remarkName?remarkName:userName];
            [cell setJid:jid];
            [cell refrash];
            
            return cell;
        }
    } else {
        QIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
        if (item.isParentNode) {
            NSString *cellIdentifier = @"Parent Node Cell";
            QIMFriendTitleListCell *titleCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (titleCell == nil) {
                titleCell = [[QIMFriendTitleListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            if (item.isFriend) {
                [titleCell setExpanded:_friendIsExpanded];
            } else {
                [titleCell setExpanded:_blackIsExpanded];
            }
            [titleCell setTitle:item.name];
            [titleCell setDesc:item.descInfo];
            [titleCell refresh];
            return titleCell;
        } else {
            NSString *cellIdentifier = @"Node Cell";
            QIMFriendListCell *nodeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nodeCell == nil) {
                nodeCell = [[QIMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            [nodeCell setUserInfoDic:item.contentValue];
            [nodeCell setIsLast:item.isLast];
            [nodeCell refreshUI];
            return nodeCell;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && [QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
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
    } else {
        QIMFriendNodeItem *item = [_dataSource objectAtIndex:indexPath.row];
        if (item.isParentNode) {
            QIMFriendTitleListCell *titleCell = [tableView cellForRowAtIndexPath:indexPath];
            [titleCell setExpanded:!titleCell.isExpanded];
            if (item.isFriend) {
                _friendIsExpanded = titleCell.isExpanded;
            } else {
                _blackIsExpanded = titleCell.isExpanded;
            }
            NSInteger loc = indexPath.row+1;
            NSInteger len = [item.contentValue count];
            if (titleCell.isExpanded) {
                [_dataSource insertObjects:item.contentValue atIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(loc,len)]];
            } else {
                [_dataSource removeObjectsInArray:item.contentValue];
            }
            [_tableView reloadData];
        } else {
            NSString *jid = [item.contentValue objectForKey:@"XmppId"];
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

@end
