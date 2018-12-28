//
//  QIMMyEmotionsManagerViewController.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#import "QIMMyEmotionsManagerViewController.h"
#import "QIMEmotion.h"
#import "QIMMyEmotionsManagerCell.h"
#import "QIMEmotionSave.h"
#import "QIMEmotionManager.h"

//排序已在本Vc做好，移除需要发送remove通知，download同理
static NSString *cellID = @"QIMMyEmotionsManagerCell";

@interface QIMMyEmotionsManagerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation QIMMyEmotionsManagerViewController

#pragma mark - setter and getter

/**
{
    desc = "\U6269\U5c55\U8868\U60c5";
    file = "https://qt.qunar.com/file/v1/emo/d/z/qq";
    "file_size" = 1983898;
    md5 = C044285E87955383B46A4F4B8430851C;
    name = "qq\U8868\U60c5";
    pkgid = qq;
    thumb = "https://qt.qunar.com/file/v1/emo/d/e/qq/tpx/fixed";
}
*/
- (NSMutableArray *)dataList {
    
    if (!_dataList) {
    
        NSString *path = [[QIMEmotionSave sharedInstance] getEmotionInfoDataPath];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        NSArray *EmotionPaclageIdList = [[QIMEmotionManager sharedInstance] getEmotionPackageIdList];
        NSMutableArray *emotions = [NSMutableArray array];
        
        for (int i = 2; i < EmotionPaclageIdList.count; i++) {
            
            NSString *pkID = EmotionPaclageIdList[i];

            for (int j = 0; j < array.count; j++) {
                
                NSDictionary *emotion = array[j];
                if ([emotion[@"pkgid"] isEqualToString:pkID]) {
                    
                    [emotions addObject:emotion];
                }
            }
            
        }
        _dataList = [NSMutableArray arrayWithArray:emotions];
    }
    return _dataList;
}

- (UILabel *)promptLabel {
    
    if (!_promptLabel) {
        
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, self.view.width, 30)];
        _promptLabel.text = @"聊天面板中的表情";
        _promptLabel.font = [UIFont systemFontOfSize:13];
        _promptLabel.textColor = [UIColor qtalkTextLightColor];
    }
    return _promptLabel;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        CGFloat tableViewY = CGRectGetMaxY(self.promptLabel.frame);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, self.view.width, self.view.height - tableViewY) style:UITableViewStylePlain];
        _tableView.bounces = NO;
        [_tableView registerClass:[QIMMyEmotionsManagerCell class] forCellReuseIdentifier:cellID];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (UIButton *)editBtn {
    
    if (!_editBtn) {
        
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame =  CGRectMake(0, 0, 44, 44);
        [_editBtn setTitle:@"排序" forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editHandel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

- (void)editHandel:(id)sender {
    
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    [self.tableView setEditing:btn.selected animated:YES];
    NSString *title = btn.selected ? @"完成" : @"排序";
    NSString *promptTitle = btn.selected ? @"可以调整表情在聊天界面中的排序" : @"聊天面板中的表情";
    [self.editBtn setTitle:title forState:UIControlStateNormal];
    [self.promptLabel setText:promptTitle];
}


- (void)initUI {
    
    self.title = @"我的表情";
    [self setUpNav];
    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.tableView];
}

- (void)setUpNav {

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    //已下载表情包更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionListUpdate:) name:kEmotionListUpdateNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notifycation

//只接受移除表情包的通知
- (void)emotionListUpdate:(NSNotification *)notify {
    if ([notify.object isKindOfClass:[NSDictionary class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *notifyDict = notify.object;
            NSUInteger type = [[notifyDict objectForKey:@"EmotionListUpdateType"] unsignedIntegerValue];
            NSString * pkId = notifyDict[@"pkId"];
            if (type == EmotionListRemove) {
                if (pkId) {
                    for (NSDictionary * infoDic in _dataList) {
                        if ([[infoDic objectForKey:@"pkgid"] isEqualToString:pkId]) {
                            
                            [self.dataList removeObject:infoDic];
                            [self.tableView reloadData];
                            break;
                        }
                    }
                }
            }
        });
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource Method

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSDictionary *dict = self.dataList[sourceIndexPath.row];
    [self.dataList removeObjectAtIndex:sourceIndexPath.row];
    
    [self.dataList insertObject:dict atIndex:destinationIndexPath.row];
    
    NSMutableArray *newCollectionFaceList = [NSMutableArray array];
    [newCollectionFaceList addObject:@"kEmotionCollectionPKId"];
    [newCollectionFaceList addObject:@"qunar_camel"];
    [newCollectionFaceList addObject:@"EmojiOne"];
    for (NSDictionary *emotion in self.dataList) {
        if ([[emotion[@"pkgid"] stringValue] isEqualToString:@"kEmotionCollectionPKId"] || [[emotion[@"pkgid"] stringValue] isEqualToString:@"qunar_camel"] || [[emotion[@"pkgid"] stringValue] isEqualToString:@"EmojiOne"]) {
            continue;
        }
        [newCollectionFaceList addObject:emotion[@"pkgid"]];
        
    }
    [[QIMEmotionManager sharedInstance] updateEmotions:newCollectionFaceList];
    
    [self.tableView reloadData];
}


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
    
    QIMMyEmotionsManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    QIMEmotion *emotion = [[QIMEmotion alloc] initWithDict:self.dataList[indexPath.row]];
    cell.emotion = emotion;

    return cell;
}

- (UITableViewCellEditingStyle )tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleNone;
}

//返回表格视图是否可以滚动

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
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
