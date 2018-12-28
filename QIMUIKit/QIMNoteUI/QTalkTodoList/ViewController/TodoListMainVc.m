//
//  TodoListMainVc.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/27.
//
//

#import "TodoListMainVc.h"
#import "MJRefresh.h"
#import "MJRefreshHeader.h"
#import "NewAddTodoListVc.h"
#import "TodoListDoneVC.h"
#import "TODOListDIYHeader.h"
#import "TodoListUpArrowFooter.h"
#import "TodoListTableViewCell.h"
#import "QIMNoteManager.h"
#import "MGSwipeTableCell.h"
#import "QIMNoteUICommonFramework.h"

#define TEST_USE_MG_DELEGATE 1

@interface TodoListMainVc () <UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation TodoListMainVc

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = YES;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        /*
        if (@available(iOS 11.0, *)) {
            _mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        } */
        self.automaticallyAdjustsScrollViewInsets = NO;
        _mainTableView.mj_header = [TODOListDIYHeader headerWithRefreshingTarget:self refreshingAction:nil];
        _mainTableView.mj_footer = [TodoListUpArrowFooter footerWithRefreshingTarget:self refreshingAction:nil];
    }
    return _mainTableView;
}

- (NSArray *)firstLoadPlaceHolders {
    NSMutableArray *placeHolders = [NSMutableArray arrayWithCapacity:30];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FirstTime" ofType:@"plist"];
    NSArray *firstTimeDicts = [[NSArray alloc] initWithContentsOfFile:bundlePath];
    for (NSDictionary *dict in firstTimeDicts) {
        QIMNoteModel *placeHolderModle = [[QIMNoteModel alloc] init];
        NSString *randomTextStr = @"";
        if ([[[QIMKit sharedInstance] currentLanguage] containsString:@"zh-Hant"]) {
            randomTextStr = [dict objectForKey:@"zh-Hant"];
        } else if ([[[QIMKit sharedInstance] currentLanguage] containsString:@"en"]) {
            randomTextStr = [dict objectForKey:@"en"];
        } else if ([[[QIMKit sharedInstance] currentLanguage] containsString:@"zh-Hans"]) {
            randomTextStr = [dict objectForKey:@"zh-Hans"];
        }
        placeHolderModle.c_id = [[QIMNoteManager sharedInstance] getMaxQTNoteMainItemCid] + 1;
        placeHolderModle.q_type = QIMNoteTypeTodoList;
        placeHolderModle.q_title = randomTextStr;
        placeHolderModle.q_state = QIMNoteStateNormal;
        placeHolderModle.q_ExtendedFlag = QIMNoteExtendedFlagStateNoNeedUpdatedd;
        [placeHolders addObject:placeHolderModle];
        [[QIMNoteManager sharedInstance] saveNewQTNoteMainItem:placeHolderModle];
    }
    [[QIMKit sharedInstance] setUserObject:@(YES) forKey:@"todoListOldUser"];
    return placeHolders;
}

- (void)loadTodoLists {
    self.dataSource = [NSMutableArray arrayWithCapacity:5];
    NSArray *array = [[QIMNoteManager sharedInstance] getMainItemWithType:QIMNoteTypeTodoList WithExceptState:QIMNoteStateDelete];
    BOOL todoListOldUser = [[[QIMKit sharedInstance] userObjectForKey:@"todoListOldUser"] boolValue];
    if (array.count < 1 && (!todoListOldUser || todoListOldUser == NO)) {
        [self.dataSource addObjectsFromArray:[self firstLoadPlaceHolders]];
    } else {
        [self.dataSource addObjectsFromArray:array];
    }
    [self.mainTableView reloadData];
}

- (void)getRemoteTodoLists {
    NSInteger version = [[QIMNoteManager sharedInstance] getQTNoteMainItemMaxTimeWithType:QIMNoteTypeTodoList];
    [[QIMNoteManager sharedInstance] getCloudRemoteMainWithVersion:version WithType:QIMNoteTypeTodoList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self registerNotification];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTodoLists) name:QTNoteManagerGetCloudMainSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTodoLists) name:QTNoteManagerGetCloudSubSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTodoLists) name:QTNoteManagerSaveCloudMainSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewTodolist) name:@"MJRefreshStateRefreshing" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTodoLists) name:@"MJRefreshUpArrowStateRefreshing" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self getRemoteTodoLists];
    [self loadTodoLists];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view = self.mainTableView;
    [self setupNav];
}

- (void)setupNav {
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(self.view.width - 60, self.view.height - 60, 45, 45);
    closeBtn.layer.masksToBounds = YES;
    closeBtn.layer.cornerRadius = CGRectGetWidth(closeBtn.frame) / 2.0;
    [closeBtn setImage:[UIImage imageNamed:@"videoCall_btn_close"] forState:UIControlStateNormal];
    [closeBtn setBackgroundColor:[UIColor redColor]];
    [closeBtn addTarget:self action:@selector(exitTodoList:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:closeBtn];
    self.closeBtn = closeBtn;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)exitTodoList:(id)sender {
    [self.closeBtn removeFromSuperview];
    self.closeBtn = nil;
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *model = [self.dataSource objectAtIndex:indexPath.row];
    NSString *cellId = [NSString stringWithFormat:@"%ld_%@", (long)model.c_id, model.q_title];
    TodoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[TodoListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    [cell setTodoListModel:model];
    cell.delegate = self;
    cell.allowsMultipleSwipe = YES;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *model = [self.dataSource objectAtIndex:indexPath.row];
    CGSize titleSize = [model.q_title boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
    if (titleSize.height > 20) {
        return titleSize.height + 40;
    } else {
        return 54;
    }
}

- (UIImage *)favoriteButtonIcon:(QIMNoteModel *)model {
    return (model.q_state == QIMNoteStateFavorite) ? [UIImage imageNamed:@"aboutMore_29x28_"] : [UIImage imageNamed:@"heart_16x14_"];
}

#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell canSwipe:(MGSwipeDirection) direction {
    return YES;
}

- (NSArray<UIView *> *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings {
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    __weak __typeof(self) weakSelf = self;
    __block QIMNoteModel *todoListModel = [self.dataSource objectAtIndex:[self.mainTableView indexPathForCell:cell].row];
    //从左向右滑
    if (direction == MGSwipeDirectionLeftToRight) {
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 2;
        
        MGSwipeButton *complete = [MGSwipeButton buttonWithTitle:@"---" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            todoListModel.q_state = 0;
            QIMVerboseLog(@"完成滑动的Model Title = %@", todoListModel.q_title);
            [(TodoListTableViewCell *)cell setHasCompleted:YES];
            todoListModel.q_introduce = QTTodolistStateComplete;
            [[QIMNoteManager sharedInstance] updateQTNoteMainItemWithModel:todoListModel];
            [(TodoListTableViewCell *)cell refreshUI];
            return YES;
        }];
        
        MGSwipeButton * favorite = [MGSwipeButton buttonWithTitle:@"" icon:[weakSelf favoriteButtonIcon:todoListModel] backgroundColor:[UIColor whiteColor] padding:5 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            
            todoListModel.q_state = QIMNoteStateFavorite;
            [[QIMNoteManager sharedInstance] updateQTNoteMainItemStateWithModel:todoListModel];
            QIMVerboseLog(@"收藏滑动的Model Title = %@", todoListModel.q_title);
            [(UIButton*)[cell.leftButtons objectAtIndex:1] setImage:[weakSelf favoriteButtonIcon:todoListModel] forState:UIControlStateNormal];
            return YES;
        }];
        if ([todoListModel.q_introduce isEqualToString:QTTodolistStateComplete]) {
            return @[favorite];
        } else {
            return @[complete, favorite];
        }
    }
    //从右向左滑
    else {
        
        expansionSettings.fillOnTrigger = YES;
        CGFloat padding = 10;
        MGSwipeButton * edit = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"编辑_12x13_"] backgroundColor:[UIColor whiteColor] padding:padding callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            NewAddTodoListVc *editTodoListVc = [[NewAddTodoListVc alloc] init];
            [editTodoListVc setEdited:YES];
            [editTodoListVc setTodoListModel:todoListModel];
            UINavigationController *editTodoListNav = [[UINavigationController alloc] initWithRootViewController:editTodoListVc];
            [self presentViewController:editTodoListNav animated:NO completion:nil];
            
            return YES;
        }];
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"删除_12x12_"] backgroundColor:[UIColor whiteColor] padding:padding callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            todoListModel.q_state = QIMNoteStateBasket;
            NSIndexPath *path = [_mainTableView indexPathForCell:cell];
            [_dataSource removeObjectAtIndex:path.row];
            [_mainTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
            [[QIMNoteManager sharedInstance] updateQTNoteMainItemStateWithModel:todoListModel];
            return YES;
        }];
        return @[trash, edit];
    }
    return nil;
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    QIMVerboseLog(@"Tapped accessory button");
}

#pragma mark - PresentVC

- (void)addNewTodolist {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.mainTableView reloadData];
        [weakSelf.mainTableView.mj_header endRefreshing];
        NewAddTodoListVc *newTodoListVc = [[NewAddTodoListVc alloc] init];
        UINavigationController *newTodoListNav = [[UINavigationController alloc] initWithRootViewController:newTodoListVc];
        [self presentViewController:newTodoListNav animated:NO completion:nil];
    });
}

- (void)searchTodoLists {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.mainTableView reloadData];
        [weakSelf.mainTableView.mj_footer endRefreshing];
        TodoListDoneVC *searchTodoListVc = [[TodoListDoneVC alloc] init];
        UINavigationController *searchTodoListNav = [[UINavigationController alloc] initWithRootViewController:searchTodoListVc];
        [self presentViewController:searchTodoListNav animated:NO completion:nil];
    });
}

@end
