//
//  PasswordHistoryViewController.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/20.
//
//

#import "PasswordHistoryViewController.h"
#import "QIMNoteModel.h"
#import "AESCrypt.h"
#import "QIMAES256.h"
#import "QIMNoteUICommonFramework.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface PasswordHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *models;

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) UIView *modelView;

@end

@implementation PasswordHistoryViewController

- (void)setHistoryModels:(NSArray *)historyModels {
    if (historyModels.count > 0) {
        _models = historyModels;
    }
    [self.mainTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view = self.mainTableView;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [UIView new];
    }
    return _mainTableView;
}

- (UIView *)setUpModelViewWithQIMNoteModel:(QIMNoteModel *)noteModel ContentView:(UIView *)contentView {
    
    UIView *backView = [[UIView alloc] initWithFrame:contentView.bounds];
    backView.backgroundColor = [UIColor clearColor];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.layer.borderWidth = 0.5f;
    headerView.layer.borderColor = [UIColor grayColor].CGColor;
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.image = [UIImage imageNamed:@"explore_tab_password"];
    [headerView addSubview:iconView];
    iconView.centerY = headerView.centerY;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconView.right + 15, iconView.top, SCREEN_WIDTH - iconView.right - 15, 30)];
    titleLabel.text = noteModel.qs_title ? noteModel.qs_title : [NSBundle qim_localizedStringForKey:@"Password"];
    titleLabel.tag = 1;
    [headerView addSubview:titleLabel];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom + 2, titleLabel.width, 20)];
    categoryLabel.text = [NSBundle qim_localizedStringForKey:@"Password"];
    categoryLabel.textColor = [UIColor qtalkTextLightColor];
    categoryLabel.font = [UIFont systemFontOfSize:12];
    [headerView addSubview:categoryLabel];
    
    
    UIView *showPwdView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.bottom + 30, SCREEN_WIDTH, 200)];
    showPwdView.backgroundColor = [UIColor whiteColor];
    showPwdView.layer.borderWidth = 0.5f;
    showPwdView.layer.borderColor = [UIColor grayColor].CGColor;
    
    //密码提示Label
    CGFloat originX = 15;
    CGFloat topMargin = 8;
    CGFloat originWidth = SCREEN_WIDTH - 2 * originX;
    CGFloat originHeight = 21;
    CGFloat maxHeight = 0;
    UILabel *pwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, maxHeight + topMargin, originWidth, originHeight)];
    pwdLabel.font = [UIFont systemFontOfSize:14];
    pwdLabel.textColor = [UIColor systemBlueColor];
    pwdLabel.text = [NSBundle qim_localizedStringForKey:@"password"];
    [pwdLabel sizeToFit];
    [showPwdView addSubview:pwdLabel];
    
    
    UITextView *showPwdTextView = [[UITextView alloc] initWithFrame:CGRectMake(originX, pwdLabel.bottom + topMargin, originWidth, originHeight + 15)];
    NSString *content = [AESCrypt decrypt:noteModel.qs_content password:self.pk];
    if (!content) {
        content = [QIMAES256 decryptForBase64:noteModel.qs_content password:self.pk];
    }
    showPwdTextView.text = content;
    showPwdTextView.textColor = [UIColor qtalkTextLightColor];
    showPwdTextView.font = [UIFont systemFontOfSize:12];
    [showPwdView addSubview:showPwdTextView];
    
    [backView addSubview:headerView];
    [backView addSubview:showPwdView];
    
    return backView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *model = [self.models objectAtIndex:indexPath.row];
    NSString *cellId = [NSString stringWithFormat:@"%@", model.qs_content];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    UIView *headerView = [self setUpModelViewWithQIMNoteModel:model ContentView:cell.contentView];
    [cell.contentView addSubview:headerView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

@end
