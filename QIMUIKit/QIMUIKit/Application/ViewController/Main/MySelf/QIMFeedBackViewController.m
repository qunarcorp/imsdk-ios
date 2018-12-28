//
//  QIMFeedBackViewController.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 16/9/6.
//
//

#import "QIMFeedBackViewController.h"
#import "QIMFriendListCell.h"
#import "QIMChatVC.h"
#import "NSBundle+QIMLibrary.h"
@interface QIMFeedBackViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSArray *sectionTitleList;

@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation QIMFeedBackViewController

#pragma mark - setter and getter

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        
        NSArray *AndroidTeam = [NSArray arrayWithObjects:@"lihaibin.li@ejabhost1", nil];
        NSArray *MacTeam = [NSArray arrayWithObjects:@"cjjie.chen@ejabhost1", nil];
        NSArray *iOSTeam = [NSArray arrayWithObjects:@"lilulucas.li@ejabhost1", nil];
        NSArray *PCTeam = [NSArray arrayWithObjects:@"huajun.liu@ejabhost1", nil];
        _dataSource = [NSMutableArray arrayWithCapacity:5];
        [_dataSource addObject:AndroidTeam];
        [_dataSource addObject:MacTeam];
        [_dataSource addObject:iOSTeam];
        [_dataSource addObject:PCTeam];
    }
    return _dataSource;
}

- (NSArray *)sectionTitleList {
    
    if (!_sectionTitleList) {
        
        _sectionTitleList = [NSArray arrayWithObjects:@"Android客户端技术人员", @"Mac客户端技术人员", @"iOS客户端技术人员", @"PC端技术人员", nil];
    }
    return _sectionTitleList;
}

- (UILabel *)promptLabel {
    
    if (!_promptLabel) {
        
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, self.view.width, 30)];
        _promptLabel.text = @"QTalk有问题?第一时间我们的技术人员为您排忧解难";
        _promptLabel.font = [UIFont systemFontOfSize:13];
        _promptLabel.textColor = [UIColor qtalkTextLightColor];
    }
    return _promptLabel;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        CGFloat tableViewY = CGRectGetMaxY(self.promptLabel.frame);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, self.view.width, self.view.height - tableViewY) style:UITableViewStyleGrouped];
//        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = view;
    }
    return _tableView;
}

- (void)initUI {
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setUpNavBar];
    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.tableView];
    
}

- (void)setUpNavBar {

    self.title = [NSBundle qim_localizedStringForKey:@"About_tab_feedBack"];
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initUI];
}

- (void)goBack {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *str = self.sectionTitleList[section];
    return str;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *item = [self.dataSource objectAtIndex:indexPath.section][indexPath.row];
    NSDictionary *dict = [[QIMKit sharedInstance] getUserInfoByUserId:item];
    [self openEngineerSessionWithEngineerUserinfo:dict];
}

- (void)openEngineerSessionWithEngineerUserinfo:(NSDictionary *)dict {
    
    NSString *jid = [dict objectForKey:@"XmppId"];
    [QIMFastEntrance openSingleChatVCByUserId:jid];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellID";
    NSString *value = [self.dataSource objectAtIndex:indexPath.section][indexPath.row];
    NSDictionary *dict = [[QIMKit sharedInstance] getUserInfoByUserId:value];
    QIMFriendListCell *nodeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nodeCell == nil) {
        nodeCell = [[QIMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [nodeCell setUserInfoDic:dict];
    [nodeCell refreshUI];
    return nodeCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *item = [_dataSource objectAtIndex:indexPath.section][indexPath.row];
    NSDictionary *dict = [[QIMKit sharedInstance] getUserInfoByUserId:item];
    return [QIMFriendListCell getCellHeightForDesc:[dict objectForKey:@"DescInfo"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 27;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.001;
}

@end
