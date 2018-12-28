//
//  QTalkEverNoteListVC.m
//  qunarChatIphone
//
//  Created by lihuaqi on 2017/9/20.
//
//

#import "QTalkEverNoteListVC.h"
#import "QTalkEverNoteVC.h"
#import "QIMNoteManager.h"
#import "QIMNoteModel.h"
#import "QTNoteCell.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
@interface QTalkEverNoteListVC () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UIButton *addBtn;//新建按钮
@property(nonatomic, strong) UITableView *tableView;//笔记列表
@property(nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation QTalkEverNoteListVC
- (void)getLocalEverNotes {
    self.dataSource = [NSMutableArray arrayWithCapacity:1];
    NSArray *array = [[QIMNoteManager sharedInstance] getSubItemWithCid:self.evernoteModel.c_id WithExpectState:QIMNoteStateDelete];
    [self.dataSource addObjectsFromArray:array];
    [self.tableView reloadData];
}

- (void)getRemoteEverNotes {
    
    NSInteger maxTime = [[QIMNoteManager sharedInstance] getQTNoteSubItemMaxTimeWitModel:self.evernoteModel];
    [[QIMNoteManager sharedInstance] getCloudRemoteSubWithQid:self.evernoteModel.q_id Cid:self.evernoteModel.c_id version:maxTime type:-1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getRemoteEverNotes];
    [self getLocalEverNotes];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self topbar];
    [self createUI];
    [self registerNotification];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLocalEverNotes) name:QTNoteManagerGetCloudSubSuccessNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)topbar {
    self.title = @"笔记";
    
    _addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _addBtn.frame = CGRectMake(0,0, 50, 25);
    _addBtn.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [_addBtn setTitle:@"新建" forState:UIControlStateNormal];
    [_addBtn addTarget:self action:@selector(addNoteAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc]initWithCustomView:_addBtn];
    self.navigationItem.rightBarButtonItem = addButton;
}

//新建笔记
- (void)addNoteAction {
    QTalkEverNoteVC *vc = [[QTalkEverNoteVC alloc] init];
    vc.everNoteType = ENUM_EverNote_TypeNew;
    QIMNoteModel *model = [[QIMNoteModel alloc] init];
    model.c_id = self.evernoteModel.c_id;
    model.q_id = self.evernoteModel.q_id;
    model.qs_type = QIMNoteTypeEverNote;
    vc.evernoteSModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)createUI {
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMNoteModel *evernoteSModel = self.dataSource[indexPath.row];
    QTNoteCell *cell = [QTNoteCell cellWithTableView:tableView];
    [cell refreshCellWithModel:evernoteSModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *evernoteSModel = self.dataSource[indexPath.row];
    QTalkEverNoteVC *vc = [[QTalkEverNoteVC alloc] init];
    vc.everNoteType = ENUM_EverNote_TypeEdit;
    vc.evernoteSModel = evernoteSModel;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  左滑cell时出现什么按钮
 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *evernoteSModel = self.dataSource[indexPath.row];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [[QIMNoteManager sharedInstance] deleteQTNoteSubItemWithQSModel:evernoteSModel];
        [self getLocalEverNotes];
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
