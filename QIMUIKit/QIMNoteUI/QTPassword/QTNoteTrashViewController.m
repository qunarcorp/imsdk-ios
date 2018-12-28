//
//  QTNoteTrashViewController.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/20.
//
//

#import "QTNoteTrashViewController.h"
#import "QIMNoteModel.h"
#import "QIMNoteManager.h"
#import "PasswordCell.h"
#import "PasswordBoxCell.h"
#import "QIMNoteUICommonFramework.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface QTNoteTrashViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) NSMutableArray *selectIndexPathArray;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation QTNoteTrashViewController

- (NSMutableArray *)selectIndexPathArray {
    if (!_selectIndexPathArray) {
        _selectIndexPathArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _selectIndexPathArray;
}

- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _selectArray;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:5];
        NSArray *trashMainModels = [[QIMNoteManager sharedInstance] getMainItemWithType:QIMNoteTypePassword State:QIMNoteStateBasket];
        [self.dataSource addObjectsFromArray:trashMainModels];
        NSArray *subModels = [[QIMNoteManager sharedInstance] getSubItemWithState:QIMNoteStateBasket];
        [self.dataSource addObjectsFromArray:subModels];
    }
    return _dataSource;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.backgroundColor= [UIColor whiteColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [UIView new];
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackBtnHandle:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_all"] style:UIBarButtonItemStylePlain target:self action:@selector(selectAllBtnHandle:)];
    self.navigationItem.rightBarButtonItem.tag = 10002;
    [self.view addSubview:self.mainTableView];
    if (self.isSelect) {
        _mainTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
        [self showBottomViewEnabled:NO];
    }
}

- (void)goBackBtnHandle:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showBottomViewEnabled:(BOOL)enabled {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44)];
        if ([[QIMKit sharedInstance] getIsIpad]) {
            _bottomView.frame = CGRectMake(0, [[UIScreen mainScreen] height] - 44, [[UIScreen mainScreen] width], 44);
        }
        _bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_bottomView];
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:line];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_delete"] forState:UIControlStateNormal];
        deleteBtn.frame = CGRectMake(10, 7, 50, 30);
        [deleteBtn addTarget:self action:@selector(deleteQIMNoteModels:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = 10000;
        [_bottomView addSubview:deleteBtn];
        
        UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [sendBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_resume"] forState:UIControlStateNormal];
        sendBtn.frame = CGRectMake(_bottomView.width - 70, 7, 60, 30);
        [sendBtn addTarget:self action:@selector(resumeQIMNoteModels:) forControlEvents:UIControlEventTouchUpInside];
        sendBtn.tag = 100001;
        [_bottomView addSubview:sendBtn];
        
        _mainTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 44);
        if ([[QIMKit sharedInstance] getIsIpad]) {
            _mainTableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] width], [[UIScreen mainScreen] height] - 44);
        }
    }
    [(UIButton *)[_bottomView viewWithTag:10000] setEnabled:enabled];
    [(UIButton *)[_bottomView viewWithTag:100001] setEnabled:enabled];
    self.navigationItem.title = enabled ? [NSString stringWithFormat:@"已选择%lu项", (unsigned long)self.selectArray.count] : [NSBundle qim_localizedStringForKey:@"Password_tab_trash"];
    [self.navigationItem.rightBarButtonItem setTitle:enabled ? [NSBundle qim_localizedStringForKey:@"common_unselect_all"] : [NSBundle qim_localizedStringForKey:@"common_all"]];
}

- (void)deleteQIMNoteModels:(id)sender {
    for (QIMNoteModel *model in self.selectArray) {
        if (model.cs_id) {
            model.qs_state = QIMNoteStateDelete;
            [[QIMNoteManager sharedInstance] updateQTNoteSubItemStateWithQSModel:model];
        } else {
            model.q_state = QIMNoteStateDelete;
            [[QIMNoteManager sharedInstance] updateQTNoteMainItemStateWithModel:model];
        }
        [self.dataSource removeObject:model];
    }
    [self.selectArray removeAllObjects];
    [self.mainTableView deleteRowsAtIndexPaths:self.selectIndexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.selectIndexPathArray removeAllObjects];
    [self showBottomViewEnabled:self.selectArray.count > 0];
}

- (void)resumeQIMNoteModels:(id)sender {
    for (QIMNoteModel *model in self.selectArray) {
        if (model.cs_id) {
            model.qs_state = QIMNoteStateNormal;
            [[QIMNoteManager sharedInstance] updateQTNoteSubItemStateWithQSModel:model];
        } else {
            model.q_state = QIMNoteStateNormal;
            [[QIMNoteManager sharedInstance] updateQTNoteMainItemStateWithModel:model];
        }
        [self.dataSource removeObject:model];
    }
    [self.selectArray removeAllObjects];
    [self.mainTableView deleteRowsAtIndexPaths:self.selectIndexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.selectIndexPathArray removeAllObjects];
    [self showBottomViewEnabled:self.selectArray.count > 0];
}

- (void)selectAllBtnHandle:(id)sender {
    if (self.selectArray.count) {
        [self.selectArray removeAllObjects];
        [self.selectIndexPathArray removeAllObjects];
        [self.mainTableView reloadData];
    } else {
        self.selectArray = [NSMutableArray arrayWithArray:self.dataSource];
        for (NSInteger i = 0; i < self.dataSource.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.selectIndexPathArray addObject:indexPath];
        }
        [self.mainTableView reloadData];
    }
    [self showBottomViewEnabled:self.selectArray.count > 0];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *model = [self.dataSource objectAtIndex:indexPath.row];
    NSString *cellId = nil;
    UITableViewCell *cell = nil;
    if (model.cs_id) {
        cellId = [NSString stringWithFormat:@"%ld", (long)model.cs_id];
        PasswordCell *pwdCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!pwdCell) {
            pwdCell = [[PasswordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        }
        [pwdCell setCellSelected:[self.selectArray containsObject:model]];
        pwdCell.isSelect = self.isSelect;
        [pwdCell setQIMNoteModel:model];
        return pwdCell;
    } else {
        cellId = [NSString stringWithFormat:@"%ld", (long)model.c_id];
        PasswordBoxCell *pwdBoxcell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!pwdBoxcell) {
            pwdBoxcell = [[PasswordBoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        [pwdBoxcell setCellSelected:[self.selectArray containsObject:model]];
        pwdBoxcell.isSelect = self.isSelect;
        [pwdBoxcell setQIMNoteModel:model];
        return pwdBoxcell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *model = [self.dataSource objectAtIndex:indexPath.row];
    if (self.isSelect) {
        if (model.cs_id) {
            PasswordCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setCellSelected:![cell isCellSelected]];
            if ([cell isCellSelected]) {
                [self.selectArray addObject:model];
                [self.selectIndexPathArray addObject:indexPath];
            } else {
                [self.selectArray removeObject:model];
                [self.selectIndexPathArray removeObject:indexPath];
            }
        } else {
            PasswordBoxCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setCellSelected:![cell isCellSelected]];
            if ([cell isCellSelected]) {
                [self.selectArray addObject:model];
                [self.selectIndexPathArray addObject:indexPath];
            } else {
                [self.selectArray removeObject:model];
                [self.selectIndexPathArray removeObject:indexPath];
            }
        }
        [self showBottomViewEnabled:self.selectArray.count > 0];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *model = [self.dataSource objectAtIndex:indexPath.row];
    CGFloat height = 44;
    if (model.cs_id) {
        height = [PasswordCell getCellHeight];
    }
    return height;
}

@end
