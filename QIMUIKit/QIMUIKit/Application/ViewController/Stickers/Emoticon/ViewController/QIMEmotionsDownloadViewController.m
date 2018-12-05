//
//  QIMEmotionsDownloadViewController.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#import "QIMEmotionsDownloadViewController.h"
#import "QIMEmotionsDownloadCell.h"
#import "UIBarButtonItem+Utility.h"
#import "QIMEmotion.h"
#import "QIMMyEmotionsManagerViewController.h"
#import "QIMEmotionSave.h"
#import "QIMEmotionManager.h"

static NSString *cellID = @"QIMEmotionsDownloadCell";

@interface QIMEmotionsDownloadViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) UIButton *managerBtn;

@end

@implementation QIMEmotionsDownloadViewController

#pragma mark - setter and getter

- (NSMutableArray *)dataList {
    
    if (!_dataList) {
        
        _dataList = [NSMutableArray arrayWithArray:[[QIMEmotionManager sharedInstance] getHttpEmotions]];
        
        [[QIMEmotionSave sharedInstance] saveEmotionDownloadData:_dataList];
    }
    return _dataList;
}

- (UITableView *)mainTableView {
    
    if (!_mainTableView) {
        
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_mainTableView registerClass:[QIMEmotionsDownloadCell class] forCellReuseIdentifier:cellID];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [UIView new];
    }
    return _mainTableView;
}

- (UIButton *)managerBtn {
    
    if (!_managerBtn) {
        
        _managerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _managerBtn.frame =  CGRectMake(0, 0, 90, 44);
        [_managerBtn setTitle:@"我的表情" forState:UIControlStateNormal];
        [_managerBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [_managerBtn addTarget:self action:@selector(myEmotionsHandel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _managerBtn;
}

- (void)initUI {
    self.title = @"表情";
    [self setUpNav];
    [self.view addSubview:self.mainTableView];
}

- (void)setUpNav {
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createBarButtonItemWithTitle:@"关闭" imageName:nil target:self action:@selector(quitItemHandle:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.managerBtn];
}

- (void)quitItemHandle:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)myEmotionsHandel:(id)sender {
    
    QIMMyEmotionsManagerViewController *myEmotionVC = [[QIMMyEmotionsManagerViewController alloc] init];
    [self.navigationController pushViewController:myEmotionVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionListUpdate:) name:kEmotionListUpdateNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notifycation

- (void)emotionListUpdate:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.mainTableView reloadData];
    });
}


#pragma mark - UITableViewDelegate UITableViewDataSource Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QIMEmotionsDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    QIMEmotion *emotion = [[QIMEmotion alloc] initWithDict:self.dataList[indexPath.row]];
    cell.emotion = emotion;
    
    if ([[[QIMEmotionManager sharedInstance] getEmotionPackageIdList] containsObject:emotion.pkgid]) {
        [cell setEmotionState:EmotionStateDone];
    }else{
        [cell setEmotionState:EmotionStateDownload];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)viewDidLayoutSubviews
{
    if ([self.mainTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mainTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.mainTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mainTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


@end
