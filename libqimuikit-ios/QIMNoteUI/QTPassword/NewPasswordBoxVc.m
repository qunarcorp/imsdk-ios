//
//  NewPasswordBoxVc.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/17.
//
//

#import "NewPasswordBoxVc.h"
#import "QIMNoteModel.h"
#import "AESCrypt.h"
#import "QIMAES256.h"
#import "QIMNoteUICommonFramework.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface NewPasswordBoxVc ()

@property (nonatomic, strong) UITextField *nameTextField;

@property (nonatomic, strong) UIBarButtonItem *createBarItem;

@property (nonatomic, strong) UITextField *pwdBoxField;

@property (nonatomic, strong) UITextField *repeatPwdBoxField;

@property (nonatomic, strong) UIButton *agreeBtn;

@end

@implementation NewPasswordBoxVc


- (UITextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 30, SCREEN_WIDTH - 40, 80)];
        _nameTextField.textAlignment = NSTextAlignmentCenter;
        _nameTextField.placeholder = @"PassBox Name";
    }
    return _nameTextField;
}

- (UITextField *)pwdBoxField {
    if (!_pwdBoxField) {
        _pwdBoxField = [[UITextField alloc] initWithFrame:CGRectMake(20, self.nameTextField.bottom + 50, SCREEN_WIDTH - 40, 60)];
        _pwdBoxField.keyboardType = UIKeyboardTypeASCIICapable;
        _pwdBoxField.textAlignment = NSTextAlignmentCenter;
        _pwdBoxField.secureTextEntry = YES;
        _pwdBoxField.placeholder = @"PassBox Password";
    }
    return _pwdBoxField;
}

- (UITextField *)repeatPwdBoxField {
    if (!_repeatPwdBoxField) {
        _repeatPwdBoxField = [[UITextField alloc] initWithFrame:CGRectMake(20, self.pwdBoxField.bottom + 50, SCREEN_WIDTH - 40, 60)];
        _repeatPwdBoxField.keyboardType = UIKeyboardTypeASCIICapable;
        _repeatPwdBoxField.textAlignment = NSTextAlignmentCenter;
        _repeatPwdBoxField.secureTextEntry = YES;
        _repeatPwdBoxField.placeholder = @"Repeat PassBox Password";
    }
    return _repeatPwdBoxField;
}

- (UIButton *)agreeBtn {
    if (!_agreeBtn) {
        _agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeBtn.frame = CGRectMake(self.nameTextField.left, self.repeatPwdBoxField.bottom + 80, 18, 18);
        [_agreeBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
        [_agreeBtn setImage:[UIImage imageNamed:@"checkbox_click"] forState:UIControlStateSelected];
        _agreeBtn.selected = NO;
        [_agreeBtn addTarget:self action:@selector(agreeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeBtn;
}

- (UIBarButtonItem *)createBarItem {
    if (!_createBarItem) {
        _createBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(createNewPassBox:)];
    }
    return _createBarItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"New Password Box";
    [self.view addSubview:self.nameTextField];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(20, self.nameTextField.bottom + 20, SCREEN_WIDTH - 40, 0.5)];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView1];
    
    [self.view addSubview:self.pwdBoxField];
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(20, self.pwdBoxField.bottom + 20, SCREEN_WIDTH - 40, 0.5)];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView2];
    [self.view addSubview:self.repeatPwdBoxField];
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(20, self.repeatPwdBoxField.bottom + 20, SCREEN_WIDTH - 40, 0.5)];
    lineView3.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView3];
    
    [self.view addSubview:self.agreeBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.agreeBtn.right + 5, lineView3.bottom + 60, SCREEN_WIDTH - self.agreeBtn.right - 40, 150)];
    label.text = @"  注意！密码箱钥匙（进入密码）一旦丢失将无法打开，数据将无法恢复！密码箱的加密算法基于QTalk的对端加密算法，其密钥并不会被QTalk获取并保存，这意味着一旦密钥忘记，密码将无法恢复！请务必了解清楚之后再开始使用！";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    self.agreeBtn.centerY = label.centerY;
    
    self.navigationItem.rightBarButtonItem = self.createBarItem;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)agreeBtnHandle:(id)sender {
    UIButton *agreenBtn = sender;
    agreenBtn.selected = !agreenBtn.selected;
}

- (void)createNewPassBox:(id)sender {
    if ([self checkNameAndPassword]) {
        QIMVerboseLog(@"创建新的密码箱");
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        model.c_id = [[QIMNoteManager sharedInstance] getMaxQTNoteMainItemCid] + 1;
        model.q_title = self.nameTextField.text;
        model.privateKey = self.pwdBoxField.text;
        model.q_type = QIMNoteTypePassword;
        model.q_state = QIMNoteStateNormal;
//        NSString *encryptStr = [AESCrypt encrypt:model.q_title password:model.privateKey];
        NSString *encryptStr = [QIMAES256 encryptForBase64:model.q_title password:model.privateKey];
        model.q_content = encryptStr;
        model.q_time = [[NSDate date] timeIntervalSince1970] * 1000;
        [[QIMNoteManager sharedInstance] saveNewQTNoteMainItem:model];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)checkNameAndPassword {
    NSString *name = self.nameTextField.text;
    NSString *pwd = self.pwdBoxField.text;
    NSString *repeatPwd = self.repeatPwdBoxField.text;
    if (name.length <= 0) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"密码箱名称不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.pwdBoxField resignFirstResponder];
            [self.repeatPwdBoxField resignFirstResponder];
            [self.nameTextField becomeFirstResponder];
        }];
        [alertVc addAction:action];
        [self presentViewController:alertVc animated:YES completion:nil];
        return NO;
    }
    if (pwd.length <= 0) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"密码箱主密码不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.nameTextField resignFirstResponder];
            [self.repeatPwdBoxField resignFirstResponder];
            [self.pwdBoxField becomeFirstResponder];
        }];
        [alertVc addAction:action];
        [self presentViewController:alertVc animated:YES completion:nil];
        return NO;
    }
    if (repeatPwd.length <= 0) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请确认密码箱主密码" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.nameTextField resignFirstResponder];
            [self.pwdBoxField resignFirstResponder];
            [self.repeatPwdBoxField becomeFirstResponder];
        }];
        [alertVc addAction:action];
        [self presentViewController:alertVc animated:YES completion:nil];
        return NO;
    }
    if (![pwd isEqualToString:repeatPwd]) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"密码箱主密码不一致" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.nameTextField resignFirstResponder];
            [self.pwdBoxField resignFirstResponder];
            [self.repeatPwdBoxField becomeFirstResponder];
        }];
        [alertVc addAction:action];
        [self presentViewController:alertVc animated:YES completion:nil];
        return NO;
    }
    if (!self.agreeBtn.selected) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请仔细阅读注意事项，同意后勾选选项" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.nameTextField resignFirstResponder];
            [self.pwdBoxField resignFirstResponder];
            [self.repeatPwdBoxField becomeFirstResponder];
        }];
        [alertVc addAction:action];
        [self presentViewController:alertVc animated:YES completion:nil];
        return NO;
    }
    return YES;
}

@end
