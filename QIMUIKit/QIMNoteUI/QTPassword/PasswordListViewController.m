//
//  PasswordListViewController.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/11.
//
//

#import "PasswordListViewController.h"
#import "NewAddPasswordViewController.h"
#import "PasswordDetailViewController.h"
#import "QIMNoteManager.h"
#import "PasswordCell.h"
#import "QIMNoteModel.h"
#import "AESCrypt.h"
#import "AES256.h"
#import "QIMNoteUICommonFramework.h"

@interface PasswordListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) UIView *pwdVerficationView;

@property (nonatomic, strong) UITextField *pwdTextField;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) QIMNoteModel *model;

@end

@implementation PasswordListViewController

- (UIView *)pwdVerficationView {
    if (!_pwdVerficationView) {
        _pwdVerficationView = [[UIView alloc] initWithFrame:self.view.bounds];
        _pwdVerficationView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reginPwdTextField:)];
        tapGesture.numberOfTouchesRequired = 1; //手指数
        tapGesture.numberOfTapsRequired = 1; //tap次数
        [_pwdVerficationView addGestureRecognizer:tapGesture];
        _pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 50, self.view.width - 120, 45)];
        _pwdTextField.center = _pwdVerficationView.center;
        _pwdTextField.textAlignment = NSTextAlignmentCenter;
        _pwdTextField.secureTextEntry = YES;
        _pwdTextField.delegate = self;
        _pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
        _pwdTextField.placeholder = @"主密码";
        _pwdTextField.returnKeyType = UIReturnKeyGo;
        [_pwdVerficationView addSubview:_pwdTextField];
        
        UILabel *commitBtn = [[UILabel alloc] initWithFrame:CGRectMake(_pwdTextField.left, _pwdTextField.bottom + 40, _pwdTextField.width, 40)];
        commitBtn.backgroundColor = [UIColor clearColor];
        commitBtn.userInteractionEnabled = YES;
        commitBtn.layer.borderColor = [UIColor qim_colorWithHex:0x11cd6e alpha:1.0].CGColor;
        commitBtn.layer.borderWidth = 1;
        commitBtn.layer.cornerRadius = 3;
        commitBtn.clipsToBounds = YES;
        commitBtn.textColor = [UIColor qim_colorWithHex:0x11cd6e alpha:1.0];
        commitBtn.textAlignment = NSTextAlignmentCenter;
        commitBtn.font = [UIFont boldSystemFontOfSize:17];
        commitBtn.text = @"验证密码箱";
        [_pwdVerficationView addSubview:commitBtn];
        
        UITapGestureRecognizer * commitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchVerification)];
        [commitBtn addGestureRecognizer:commitTap];
    }
    return _pwdVerficationView;
}

- (void)reginPwdTextField:(UIGestureRecognizer *)gesture {
    [self.pwdTextField resignFirstResponder];
}

- (void)touchVerification {
    NSString *str = [AESCrypt decrypt:self.model.q_content password:self.pwdTextField.text];
    if (!str) {
        str = [AES256 decryptForBase64:self.model.q_content password:self.pwdTextField.text];
    }
    if (str.length > 0) {
        [self.pwdVerficationView removeAllSubviews];
        [self.pwdVerficationView removeFromSuperview];
        NSString *timeAkey = [NSString stringWithFormat:@"%ld_%@", (long)self.model.q_id, self.model.q_title];
        [[QIMNoteManager sharedInstance] setPassword:self.pwdTextField.text ForCid:self.model.c_id];
        [[QIMKit sharedInstance] setUserObject:@([NSDate timeIntervalSinceReferenceDate]) forKey:timeAkey];
//        self.model.privateKey = self.pwdTextField.text;
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"密码错误，请再尝试一次" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
     if (self.pwdTextField == textField) {
        [self touchVerification];
    }
    else {
        [textField becomeFirstResponder];
    }
    return YES;
}

- (void)setQIMNoteModel:(QIMNoteModel *)model {
    if (model != nil) {
        _model = model;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataSource = [NSMutableArray arrayWithCapacity:5];
    [self getRemotePasswords];
    [self.dataSource addObjectsFromArray:[self loadLocalPasswords]];
    NSString *qid = [NSString stringWithFormat:@"%ld", (long)self.model.q_id];
    [[QIMNoteManager sharedInstance] batchSyncToRemoteSubItemsWithMainQid:qid];
    [self.mainTableView reloadData];
}

- (NSArray *)loadLocalPasswords {
    NSInteger q_id = self.model.c_id;
    NSArray *array = [[QIMNoteManager sharedInstance] getSubItemWithCid:q_id WithExpectState:QIMNoteStateDelete];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (QIMNoteModel *model in array) {
        model.q_id = self.model.q_id;
        [models addObject:model];
    }
    return models;
}

- (void)getRemotePasswords {
    NSInteger maxTime = [[QIMNoteManager sharedInstance] getQTNoteSubItemMaxTimeWitModel:self.model];
    [[QIMNoteManager sharedInstance] getCloudRemoteSubWithQid:self.model.q_id Cid:self.model.c_id version:maxTime type:self.model.q_type];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.pwdTextField canResignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)setUpUI {
    [self initNav];
    self.view = self.mainTableView;
    NSString *timeAkey = [NSString stringWithFormat:@"%ld_%@", (long)self.model.q_id, self.model.q_title];
    NSInteger lastVerficationTime = [[[QIMKit sharedInstance] userObjectForKey:timeAkey] integerValue];
    NSInteger securitySettingTime = [[[QIMKit sharedInstance] userObjectForKey:@"securityMinute"] integerValue];
    if (securitySettingTime == 0) {
        [[QIMKit sharedInstance] setUserObject:@(15 * 60) forKey:@"securityMinute"];
    }
    NSInteger nowTime = [NSDate timeIntervalSinceReferenceDate];
    NSString *pwd = [[QIMNoteManager sharedInstance] getPasswordWithCid:self.model.c_id];
    if (nowTime - lastVerficationTime > securitySettingTime || !pwd) {
        
        [[QIMNoteManager sharedInstance] setPassword:nil ForCid:self.model.c_id];
        
        [[QIMKit sharedInstance] removeUserObjectForKey:timeAkey];
        [self.mainTableView addSubview:self.pwdVerficationView];
    } else {
//        NSString *privateKey = [[QIMKit sharedInstance] userObjectForKey:pwdAkey];
//        self.model.privateKey = privateKey;
    }
}

- (void)initNav {
    self.title = self.model.q_title;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_mainTableView setShowsHorizontalScrollIndicator:NO];
        [_mainTableView setShowsVerticalScrollIndicator:NO];
        [_mainTableView setTableFooterView:[UIView new]];
    }
    if ([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_mainTableView setSeparatorInset:UIEdgeInsetsMake(0, 50, 0, 0)];
    }
    if ([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_mainTableView setLayoutMargins:UIEdgeInsetsMake(0, 50, 0, 0)];
    }
    return _mainTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@""];
    PasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[PasswordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    QIMNoteModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [cell setQIMNoteModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PasswordCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //请求数据源提交的插入或删除指定行接收者。
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataSource];
        __block NSInteger row = indexPath.row;
        if ((row < [tempArray count]) && (row >= 0)) {
            QIMNoteModel *model = [tempArray objectAtIndex:row];
            model.qs_state = QIMNoteStateBasket;
            [[QIMNoteManager sharedInstance] updateQTNoteSubItemStateWithQSModel:model];
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

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NSBundle qim_localizedStringForKey:@"password_box_moveToBasket"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QIMNoteModel *model = [self.dataSource objectAtIndex:indexPath.row];
    PasswordDetailViewController *pwdDetailVc = [[PasswordDetailViewController alloc] init];
    [pwdDetailVc setQIMNoteModel:model];
    [self.navigationController pushViewController:pwdDetailVc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 50, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 50, 0, 0)];
    }
}


- (void)onCreateNewPasswdClcik {
    QIMVerboseLog(@"%s", __func__);
    NewAddPasswordViewController *newPwdVc = [[NewAddPasswordViewController alloc] init];
    newPwdVc.QID = self.model.q_id;
    newPwdVc.CID = self.model.c_id;
//    newPwdVc.pk = self.model.privateKey;
    [self.navigationController pushViewController:newPwdVc animated:YES];
}

@end
