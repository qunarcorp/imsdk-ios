//
//  QTalkNotesCategoriesVc.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/17.
//
//

#import "QTalkNotesCategoriesVc.h"
#import "QTNoteTrashViewController.h"
#import "PasswordBoxListVc.h"
#import "TodoListMainVc.h"
#import "QIMNoteManager.h"
#import "QIMXMenu.h"
#import "QIMXMenuItem.h"
#import "QTalkEverNotebookVC.h"
#import "QIMNoteUICommonFramework.h"

@interface QTalkNotesCategoriesVc () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation QTalkNotesCategoriesVc

- (NSMutableArray *)items {
    if (!_items) {
        
        _items = [NSMutableArray arrayWithCapacity:3];
        for (NSString *item in self.dataSource) {
            [_items addObject:[QIMXMenuItem menuTitle:item WithIcon:nil]];
        }
    }
    return _items;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:3];
        [_dataSource addObject:@"password"];
//        [_dataSource addObject:@"TodoList"];
        [_dataSource addObject:@"Notes"];
        /*
         if ([[QIMKit sharedInstance] qimNav_WikiUrl].length > 0) {
            [_dataSource addObject:@"WiKi"];
        } */
    }
    return _dataSource;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.backgroundColor= [UIColor whiteColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [UIView new];
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self updateLocalMainItems];
}

- (void)updateLocalMainItems {
    [[QIMNoteManager sharedInstance] batchSyncToRemoteMainItems];
}

- (void)setupUI {
    self.title = [NSBundle qim_localizedStringForKey:@"explore_tab_notes"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNav];
    [self.view addSubview:self.mainTableView];
}

- (void)setupNav {
    
    UIButton *newItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    newItemBtn.adjustsImageWhenHighlighted = NO;
    [newItemBtn setImage:[UIImage imageNamed:@"new_somthing_icon"] forState:UIControlStateNormal];
    [newItemBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
    [newItemBtn addTarget:self action:@selector(addNewItem:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *trashBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(pushTrashVc:)];
    
    [self.navigationItem setRightBarButtonItems:@[trashBtnItem]];
}

- (void)addNewItem:(id)sender {
    
    UIButton *barItem = sender;
    CGRect rect = CGRectMake(barItem.left, 0, barItem.width, 0);
    __weak typeof(self) weakSelf = self;
    [QIMXMenu showMenuInView:self.view fromRect:rect menuItems:self.items selected:^(NSInteger index, QIMXMenuItem *item) {
        if ([item.title isEqualToString:@"password"]) {
            [weakSelf addNewPassword];
        } else if ([item.title isEqualToString:@"TodoList"]) {
            [weakSelf addNewTodoList];
        } else if ([item.title isEqualToString:@"Notes"]) {
            [weakSelf addNewEverNote];
        }
    }];
}

- (void)pushTrashVc:(id)sender {
    QTNoteTrashViewController *trashVc = [[QTNoteTrashViewController alloc] init];
    trashVc.isSelect = YES;
    UINavigationController *trashNav = [[UINavigationController alloc] initWithRootViewController:trashVc];
    [self presentViewController:trashNav animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = [self.dataSource objectAtIndex:indexPath.row];
    NSString *cellId = [NSString stringWithFormat:@"%@", item];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if ([item isEqualToString:@"password"]) {
        cell.imageView.image = [UIImage imageNamed:@"explore_tab_password"];
    } else if ([item isEqualToString:@"TodoList"]) {
        cell.imageView.image = [UIImage imageNamed:@"explore_tab_todoList"];
    } else if ([item isEqualToString:@"Notes"]) {
        cell.imageView.image = [UIImage imageNamed:@"explore_tab_notes"];
    }
    cell.textLabel.text = [NSBundle qim_localizedStringForKey:item];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *item = [self.dataSource objectAtIndex:indexPath.row];
    if ([item isEqualToString:@"password"]) {
        PasswordBoxListVc *pBoxListVc = [[PasswordBoxListVc alloc] init];
        [self.navigationController pushViewController:pBoxListVc animated:YES];
    } else if ([item isEqualToString:@"TodoList"]) {
        
        TodoListMainVc *todoListVc = [[TodoListMainVc alloc] init];
        UINavigationController *todoListNav = [[UINavigationController alloc] initWithRootViewController:todoListVc];
        [self presentViewController:todoListNav animated:YES completion:nil];
    } else if ([item isEqualToString:@"Notes"]) {
        QTalkEverNotebookVC *vc = [[QTalkEverNotebookVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        
    }
}

- (void)addNewPassword {
    QIMVerboseLog(@"%s", __func__);
}

- (void)addNewTodoList {
    QIMVerboseLog(@"%s", __func__);
}

- (void)addNewEverNote {
    QIMVerboseLog(@"%s", __func__);
}

@end
