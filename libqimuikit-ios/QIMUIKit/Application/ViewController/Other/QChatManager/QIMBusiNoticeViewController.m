//
//  QIMBusiNoticeViewController.m
//  qunarChatIphone
//
//  Created by admin on 15/11/13.
//
//

#import "QIMBusiNoticeViewController.h"
#import "QIMContactDatasourceManager.h"
#import "QIMDatasourceItem.h"
#import "HeadView.h"
#import "QIMJSONSerializer.h"
#import "QIMUUIDTools.h"
#import "QIMBusiNoticeTitleCell.h"
#import "QIMBusiNoticeMemberCell.h"

@interface QIMBusiNoticeViewController ()<UITableViewDataSource,UITableViewDelegate,HeadViewDelegate>

@end

@implementation QIMBusiNoticeViewController{
    UIView *_headerView;
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    UIButton *_busiTypeButton;
    UIButton *_supTypeButton;
    UIButton *_userTypeButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[QIMContactDatasourceManager getInstance] createUnMeregeDataSource];
    [self initNav];
    [self initHeaderView];
    [self initTableView];
    [self loadContractList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init ui
- (void)initNav{
    [self.navigationItem setTitle:@"发布公告"];
}

- (void)initTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                               _headerView.height,
                                                               self.view.width,
                                                               self.view.height-_headerView.height)
                                              style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    [_tableView reloadData];
}

- (void)initHeaderView{
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    [_headerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_headerView];
    
    CGFloat width = self.view.width / 3.0;
    
    _busiTypeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, _headerView.height)];
    [_busiTypeButton setImage:[UIImage imageNamed:@"check_box_checked"] forState:UIControlStateSelected];
    [_busiTypeButton setImage:[UIImage imageNamed:@"check_box_uncheck"] forState:UIControlStateNormal];
    [_busiTypeButton setTitleColor:[UIColor qtalkTextLightColor] forState:UIControlStateNormal];
    [_busiTypeButton setTitleColor:[UIColor qtalkTextSelectedColor] forState:UIControlStateSelected];
    [_busiTypeButton setTitle:@"业务线" forState:UIControlStateNormal];
    [_busiTypeButton addTarget:self action:@selector(onBusiTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_busiTypeButton];

    _supTypeButton = [[UIButton alloc] initWithFrame:CGRectMake(width, 0, width, _headerView.height)];
    [_supTypeButton setImage:[UIImage imageNamed:@"check_box_checked"] forState:UIControlStateSelected];
    [_supTypeButton setImage:[UIImage imageNamed:@"check_box_uncheck"] forState:UIControlStateNormal];
    [_supTypeButton setTitleColor:[UIColor qtalkTextLightColor] forState:UIControlStateNormal];
    [_supTypeButton setTitleColor:[UIColor qtalkTextSelectedColor] forState:UIControlStateSelected];
    [_supTypeButton setTitle:@"供应商" forState:UIControlStateNormal];
    [_supTypeButton addTarget:self action:@selector(onSupTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_supTypeButton];
    
    _userTypeButton = [[UIButton alloc] initWithFrame:CGRectMake(width*2, 0, width, _headerView.height)];
    [_userTypeButton setImage:[UIImage imageNamed:@"check_box_checked"] forState:UIControlStateSelected];
    [_userTypeButton setImage:[UIImage imageNamed:@"check_box_uncheck"] forState:UIControlStateNormal];
    [_userTypeButton setTitleColor:[UIColor qtalkTextLightColor] forState:UIControlStateNormal];
    [_userTypeButton setTitleColor:[UIColor qtalkTextSelectedColor] forState:UIControlStateSelected];
    [_userTypeButton setTitle:@"供应商" forState:UIControlStateNormal];
    [_userTypeButton addTarget:self action:@selector(onUserTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_userTypeButton];
    [self onBusiTypeClick:_busiTypeButton];
}

#pragma mark - action method
- (void)onBusiTypeClick:(UIButton *)button{
    [_busiTypeButton setSelected:YES];
    [_supTypeButton setSelected:NO];
    [_userTypeButton setSelected:NO];
}
- (void)onSupTypeClick:(UIButton *)button{
    [_busiTypeButton setSelected:NO];
    [_supTypeButton setSelected:YES];
    [_userTypeButton setSelected:NO];
}
- (void)onUserTypeClick:(UIButton *)button{
    [_busiTypeButton setSelected:NO];
    [_supTypeButton setSelected:NO];
    [_userTypeButton setSelected:YES];
//    curl -i -H 'content-type: application/json' -X POST -d '{"type":2,"business":1,"send_type":1,"to_data":"xxx,xxx","data":{"title":"标题,例:[退款消息]","content":"内容,例:[产品名称:XXXXXXX]12324213123","link_url":"公告touch页地址"}}' http://qt.qunar.com/robot/robot.php
    NSString *msgId = [QIMUUIDTools UUID];
    NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
    [msgDic setObject:@(1) forKey:@"opt_type"];
    [msgDic setObject:msgId forKey:@"msgid"];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:@(2) forKey:@"type"];
    [dataDic setObject:@(1) forKey:@"business"];
    [dataDic setObject:@(1) forKey:@"send_type"];
    [dataDic setObject:@"xxx,xxx" forKey:@"to_data"];
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:@"标题" forKey:@"title"];
    [contentDic setObject:@"内容：xxxxxxxxxxxxxxx" forKey:@"content"];
    [contentDic setObject:@"url" forKey:@"lint_url"];
    [dataDic setObject:contentDic forKey:@"data"];
    [msgDic setObject:[[QIMJSONSerializer sharedInstance] serializeObject:dataDic] forKey:@"data"];
    NSString *message = [[QIMJSONSerializer sharedInstance] serializeObject:msgDic];
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:@"ping.xue" forKey:@"from"];
    [msg setObject:message forKey:@"body"];
    message = [[QIMJSONSerializer sharedInstance] serializeObject:msg];
    [[QIMKit sharedInstance] sendMessage:message ToPublicNumberId:@"rbt_busi_manager" WithMsgId:msgId WihtMsgType:6];
    
}
#pragma mark  - load contact list data
-(void)loadContractList
{
    [[QIMContactDatasourceManager getInstance] createUnMeregeDataSource];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QIMDatasourceItem * item  = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem]  objectAtIndex:indexPath.row];
    
    CGFloat height  = item.isParentNode ? 35 : 60;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //    if (_isShowContactList)
    //        return 30;
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headIdentifier = @"header";
    
    HeadView *headView = (HeadView *)[tableView dequeueReusableCellWithIdentifier:headIdentifier];
    if (headView == nil) {
        headView = [[HeadView alloc] initWithReuseIdentifier:headIdentifier];
         [headView setDelegate:self];
    }
    
    NSDictionary *info = [_dataSource objectAtIndex:section];
    [headView  setTitle:[info objectForKey:@"name"]
                 online:[[info objectForKey:@"online"] intValue]
                  count:[[info objectForKey:@"total"] intValue]];
    [headView setSection:section];
    return headView;
}


#pragma mark - tableView dataSounce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //    if (!_isShowContactList) {
    //        return 1;
    //    } else {
    //        int count = [_dataSource count];
    //        return count;
    //    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int count = (int)[[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMDatasourceItem * item =   [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] objectAtIndex:indexPath.row];
    if (item.isParentNode ) {
        NSString *cellIdentifier2 = [NSString stringWithFormat:@"Cell Title Level {%d}",(int)item.nLevel];
        QIMBusiNoticeTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMBusiNoticeTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            [cell setNLevel:(int)item.nLevel];
            [cell initSubControls];
        }
        NSString * userName  =  item.nodeName;
        [cell setUserName:userName];
        [cell setExpanded:item.isExpand];
        [cell refresh];
        return cell;
    }else{
        NSString *cellIdentifier2 = [NSString stringWithFormat:@"Cell PGroup Level {%d}",(int)item.nLevel];
        QIMBusiNoticeMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMBusiNoticeMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            [cell setNlevel:(int)item.nLevel];
            [cell initSubControls];
        }
        NSString * userName  =  item.nodeName;
        NSString *  jid      =   item.jid; 
        [cell setUserName:userName];
        [cell setJid:jid];
        [cell refrash];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count] > 0 ) {
        QIMDatasourceItem  * qtalkItem =    [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] objectAtIndex:indexPath.row];
        if ([qtalkItem isParentNode]) {
            if ([qtalkItem isExpand]) {
                [[QIMContactDatasourceManager getInstance] collapseBranchAtIndex:indexPath.row];
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass: [QIMBusiNoticeTitleCell class]]) {
                    [cell setExpanded:NO];
                    [_tableView reloadData];
                }
            }
            else
            {
                [[QIMContactDatasourceManager getInstance] expandBranchAtIndex:indexPath.row];
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass: [QIMBusiNoticeMemberCell class]]) {
                    [cell setExpanded:YES];
                    [_tableView reloadData];
                }
            }
        }}
}

@end
