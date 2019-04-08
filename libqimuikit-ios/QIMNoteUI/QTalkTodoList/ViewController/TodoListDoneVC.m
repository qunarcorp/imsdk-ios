//
//  TodoListDoneVC.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/27.
//
//

#import "TodoListDoneVC.h"
#import "QIMNoteManager.h"
#import "QIMNoteModel.h"
#import "TODOListDIYHeader.h"
#import "TodoListDownArrowHeader.h"
#import "QIMNoteUICommonFramework.h"

#define kEMPTYSEARCHIMAGEVIEWW 270
#define kEMPTYSEARCHIMAGEVIEWH 300

@interface TodoListDoneVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) UIButton *settingBtn;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIImageView *emptySearchImageView;

@end

@implementation TodoListDoneVC

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        searchButton.frame = CGRectMake(10, 10, 30, 30);
        [searchButton setImage:[UIImage imageNamed:@"search_32x_32_"] forState:UIControlStateNormal];
        
        UITextField *searchText = [[UITextField alloc] initWithFrame:CGRectMake(40, 2, [UIScreen mainScreen].bounds.size.width - 90, 48)];
        searchText.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchText.textAlignment = NSTextAlignmentLeft;
        searchText.borderStyle = UITextBorderStyleNone;
        searchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [searchText addTarget:self action:@selector(searchTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_headerView addSubview:searchText];
        [_headerView addSubview:searchButton];
        self.searchTextField = searchText;
        
        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        settingBtn.frame = CGRectMake(searchText.right + 10, 10, 30, 30);
        [settingBtn setImage:[UIImage imageNamed:@"setup_38x38_"] forState:UIControlStateNormal];
        [settingBtn addTarget:self action:@selector(todoListSetting:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:settingBtn];
        self.settingBtn = settingBtn;
        searchButton.centerY = searchText.centerY;
        settingBtn.centerY = searchText.centerY;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, searchText.bottom + 5, self.view.width, 0.5)];
        lineView.layer.shadowOpacity = 0.5;// 阴影透明度
        lineView.layer.shadowColor = [UIColor grayColor].CGColor;// 阴影的颜色
        lineView.layer.shadowRadius = 0.5;// 阴影扩散的范围控制
        lineView.layer.shadowOffset = CGSizeMake(1, 1); //阴影的范围
        lineView.backgroundColor = [UIColor grayColor];
        [_headerView addSubview:lineView];
    }
    return _headerView;
}

- (UIImageView *)emptySearchImageView {
    if (!_emptySearchImageView) {
        _emptySearchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, kEMPTYSEARCHIMAGEVIEWW, kEMPTYSEARCHIMAGEVIEWH)];
        _emptySearchImageView.image = [UIImage imageNamed:@"noHistory-en_273x304_"];
        _emptySearchImageView.hidden = YES;
    }
    return _emptySearchImageView;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.tableHeaderView = [self headerView];
        _mainTableView.mj_header = [TodoListDownArrowHeader headerWithRefreshingTarget:self refreshingAction:nil];
    }
    return _mainTableView;
}

- (void)searchTextDidChange:(id)sender {
    if (sender == self.searchTextField) {
        NSString *str = self.searchTextField.text;
        if (str.length > 0) {
            NSArray *searchResult = [[QIMNoteManager sharedInstance] getMainItemWithType:QIMNoteTypeTodoList Keywords:str];
            if (searchResult.count > 0) {
                [self.emptySearchImageView setHidden:YES];
                self.dataSource = nil;
                self.dataSource = [NSMutableArray arrayWithCapacity:5];
                [self.dataSource addObjectsFromArray:searchResult];
            } else {
                [self.emptySearchImageView setHidden:NO];
                self.dataSource = nil;
            }
        } else {
            [self.emptySearchImageView setHidden:YES];
            [self loadCompleteTodoLists];
        }
        [self.mainTableView reloadData];
    }
}

- (void)loadCompleteTodoLists {
    NSArray *array = [[QIMNoteManager sharedInstance] getTodoListItemWithCompleteState:QTTodolistStateComplete];
    self.dataSource = [NSMutableArray arrayWithCapacity:5];
    [self.dataSource addObjectsFromArray:array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self loadCompleteTodoLists];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"MJRefreshDownArrowStateRefreshing" object:nil];
    [self setupUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view = self.mainTableView;
    [self.view addSubview:self.emptySearchImageView];
    self.emptySearchImageView.center = self.view.center;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *model = [self.dataSource objectAtIndex:indexPath.row];
    NSString *cellId = [NSString stringWithFormat:@"%ld", (long)model.c_id];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.detailTextLabel.hidden = YES;
    }
    cell.textLabel.text = model.q_title;
    NSString *timeStr = [[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:model.q_time] qim_formattedDateDescription];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", timeStr];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.hidden = !cell.selected;
    cell.selected = !cell.selected;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //请求数据源提交的插入或删除指定行接收者。
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataSource];
        __block NSInteger row = indexPath.row;
        if ((row < [tempArray count]) && (row >= 0)) {
            QIMNoteModel *model = [tempArray objectAtIndex:row];
            model.q_state =QIMNoteStateDelete;
            [[QIMNoteManager sharedInstance] updateQTNoteMainItemStateWithModel:model];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mainTableView beginUpdates];
                [tempArray removeObjectAtIndex:row];
                _dataSource = [NSMutableArray arrayWithArray:tempArray];
                [_mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_mainTableView endUpdates];
            });
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchTextField resignFirstResponder];
}

- (void)todoListSetting:(id)sender {
    QIMVerboseLog(@"%s", __func__);
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
