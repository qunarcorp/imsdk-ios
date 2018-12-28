//
//  NewAddPasswordViewController.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/11.
//
//

#import "NewAddPasswordViewController.h"
#import "QIMPasswordGenerate.h"
#import "QIMNoteManager.h"
#import "AESCrypt.h"
#import "AES256.h"
#import "QIMNoteModel.h"
#import "QIMNoteUICommonFramework.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface NewAddPasswordViewController () <QIMPasswordModelUpdateDelegate, UITextFieldDelegate>

@property (nonatomic, strong) QIMNoteModel *noteModel;

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) NSMutableDictionary *contentDic;

/**
 头视图
 */
@property (nonatomic, strong) UIView *headerView;

/**
 查看密码或输入密码面板
 */
@property (nonatomic, strong) UIView *passwordView;

/**
 生成密码的规则面板
 */
@property (nonatomic, strong) UIView *gengeratePasswordView;

/**
 密码title输入框
 */
@property (nonatomic, strong) UITextField *titleTextField;


/**
 账号输入框
 */
@property (nonatomic, strong) UITextField *accountTextField;

/**
 密码输入框
 */
@property (nonatomic, strong) UITextField *passwordTextField;

/**
 显示密码Btn
 */
@property (nonatomic, strong) UIButton *showPasswordBtn;

/**
 生成新密码Btn
 */
@property (nonatomic, strong) UIButton *gengerateNewPasswordBtn;

/**
 重新生成密码Btn
 */
@property (nonatomic, strong) UIButton *resetPasswordBtn;

/**
 密码长度滑块
 */
@property (nonatomic, strong) UISlider *passwordLenghtSlider;

/**
 密码长度Label
 */
@property (nonatomic, strong) UILabel *plSliderValueLable;

/**
 包含数字滑块
 */
@property (nonatomic, strong) UISlider *passwordNumberSlider;

/**
 包含数字个数Label
 */
@property (nonatomic, strong) UILabel *pnSliderValueLable;

/**
 包含字符滑块
 */
@property (nonatomic, strong) UISlider *passwordSymbolSlider;

/**
 包含字符个数Label
 */
@property (nonatomic, strong) UILabel *psSliderValueLable;

/**
 包含大写字母滑块
 */
@property (nonatomic, strong) UISlider *passwordUpWordSlider;

/**
 包含大写字母个数Label
 */
@property (nonatomic, strong) UILabel *pUSliderValueLable;

/**
 包含小写字母滑块
 */
@property (nonatomic, strong) UISlider *passwordLowerWordSlider;

/**
 包含小写字母个数Label
 */
@property (nonatomic, strong) UILabel *plowerSliderValueLable;

/**
 Account
 */
@property (nonatomic, copy) NSString *accountValue;

/**
 密码明文值
 */
@property (nonatomic, copy) NSString *passwordValue;

@end

@implementation NewAddPasswordViewController

- (void)setQIMNoteModel:(QIMNoteModel *)noteModel {
    
    if (noteModel != nil) {
        _noteModel = noteModel;
        _noteModel.pwdDelegate = self;
        NSString *pwd = [[QIMNoteManager sharedInstance] getPasswordWithCid:self.noteModel.c_id];
        NSString *contentJson = [AESCrypt decrypt:_noteModel.qs_content password:pwd];
        if (!contentJson) {
            contentJson = [AES256 decryptForBase64:_noteModel.qs_content password:pwd];
        }
        NSDictionary *contentDic = [[QIMJSONSerializer sharedInstance] deserializeObject:contentJson error:nil];
        self.contentDic = [NSMutableDictionary dictionaryWithDictionary:contentDic];
        self.passwordValue = [self.contentDic objectForKey:@"P"];
        self.accountValue = [self.contentDic objectForKey:@"U"];
    }
}

- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 1.2 * SCREEN_HEIGHT);
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.userInteractionEnabled = YES;
    }
    return _mainScrollView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, SCREEN_WIDTH, 80)];
        _headerView.backgroundColor = [UIColor whiteColor];
        _headerView.layer.borderWidth = 0.5f;
        _headerView.layer.borderColor = [UIColor grayColor].CGColor;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.image = [UIImage imageNamed:@"explore_tab_password"];
        [_headerView addSubview:iconView];
        iconView.centerY = _headerView.centerY;
        
        _titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(iconView.right + 15, iconView.top + 15, SCREEN_WIDTH - iconView.right - 15, 30)];
        _titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _titleTextField.placeholder = [NSBundle qim_localizedStringForKey:@"password_tab_textPlaceholder"];
        _titleTextField.text = self.noteModel.qs_title ? self.noteModel.qs_title : [NSBundle qim_localizedStringForKey:@"Password"];
        _titleTextField.delegate = self;
        _titleTextField.tag = 1;
        [_headerView addSubview:_titleTextField];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_titleTextField.left, _titleTextField.bottom + 2, _titleTextField.width, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_headerView addSubview:lineView];
    }
    return _headerView;
}

- (UIView *)passwordView {
    if (!_passwordView) {
        _passwordView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom + 20, SCREEN_WIDTH, 200)];
        _passwordView.backgroundColor = [UIColor whiteColor];
        _passwordView.layer.borderWidth = 0.5f;
        _passwordView.layer.borderColor = [UIColor grayColor].CGColor;
        
        //账号提示Label
        UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 8, 42, 21)];
        accountLabel.font = [UIFont systemFontOfSize:14];
        accountLabel.textColor = [UIColor qtalkTextLightColor];
        accountLabel.text = [NSBundle qim_localizedStringForKey:@"account"];
        [accountLabel sizeToFit];
        [_passwordView addSubview:accountLabel];
        
        UITextField *accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(accountLabel.left, accountLabel.bottom + 8, SCREEN_WIDTH - accountLabel.left, 21)];
        accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        accountTextField.placeholder = [NSBundle qim_localizedStringForKey:@"account"];
        accountTextField.delegate = self;
        
        accountTextField.text = self.accountValue ? self.accountValue : @"";
        accountTextField.tag = 2;
        [_passwordView addSubview:accountTextField];
        self.accountTextField = accountTextField;
        
        UIView *accountlineView = [[UIView alloc] initWithFrame:CGRectMake(accountTextField.left, accountTextField.bottom + 2, accountTextField.width, 0.5)];
        accountlineView.backgroundColor = [UIColor lightGrayColor];
        [_passwordView addSubview:accountlineView];
        
        //密码提示Label
        UILabel *pwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, accountlineView.bottom + 8, 42, 21)];
        pwdLabel.font = [UIFont systemFontOfSize:14];
        pwdLabel.textColor = [UIColor qtalkTextLightColor];
        pwdLabel.text = [NSBundle qim_localizedStringForKey:@"password"];
        [pwdLabel sizeToFit];
        [_passwordView addSubview:pwdLabel];
        
        UITextField *pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(pwdLabel.left, pwdLabel.bottom + 8, SCREEN_WIDTH - pwdLabel.left, 21)];
        pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        pwdTextField.placeholder = [NSBundle qim_localizedStringForKey:@"password"];
        pwdTextField.secureTextEntry = YES;
        pwdTextField.delegate = self;
        pwdTextField.text = self.passwordValue ? self.passwordValue : @"";
        pwdTextField.tag = 2;
        [_passwordView addSubview:pwdTextField];
        self.passwordTextField = pwdTextField;
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(pwdTextField.left, pwdTextField.bottom + 2, pwdTextField.width, 0.5)];
        lineView1.backgroundColor = [UIColor lightGrayColor];
        [_passwordView addSubview:lineView1];
        
        self.showPasswordBtn = [self addPasswordButtonWithTitle:[NSBundle qim_localizedStringForKey:@"password_tab_show"] selector:@selector(showPassword:) BaseView:_passwordView lastLineView:lineView1];
        UIView *lineView2 = [self addLineViewWithLastView:self.showPasswordBtn BaseView:_passwordView bottomMargin:2];
        
        self.gengerateNewPasswordBtn = [self addPasswordButtonWithTitle:[NSBundle qim_localizedStringForKey:@"password_tab_new"]  selector:@selector(gengerateNewPassword:) BaseView:_passwordView lastLineView:lineView2];
        UIView *lineView3 = [self addLineViewWithLastView:self.gengerateNewPasswordBtn BaseView:_passwordView bottomMargin:2];

        _passwordView.height = lineView3.bottom + 20;
    }
    return _passwordView;
}

- (UIView *)gengeratePasswordView {
    if (!_gengeratePasswordView) {
        _gengeratePasswordView = [[UIView alloc] initWithFrame:CGRectMake(10, self.passwordView.bottom + 20, SCREEN_WIDTH - 20, 240)];
        _gengeratePasswordView.backgroundColor = [UIColor whiteColor];
        _gengeratePasswordView.layer.borderWidth = 0.2f;
        _gengeratePasswordView.layer.borderColor = [UIColor grayColor].CGColor;
        
        UILabel *characterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 0, 0)];
        characterLabel.text = [NSBundle qim_localizedStringForKey:@"password_slider_characters"];
        characterLabel.textColor = [UIColor qtalkTextLightColor];
        characterLabel.font = [UIFont systemFontOfSize:10];
        [characterLabel sizeToFit];
        characterLabel.centerX = _gengeratePasswordView.centerX;
        [_gengeratePasswordView addSubview:characterLabel];
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(_gengeratePasswordView.left + 8, characterLabel.bottom + 5, SCREEN_WIDTH - 60, 0.5)];
        lineView1.backgroundColor = [UIColor lightGrayColor];
        [_gengeratePasswordView addSubview:lineView1];
        
        self.resetPasswordBtn = [self addPasswordButtonWithTitle:[NSBundle qim_localizedStringForKey:@"password_tab_reset"] selector:@selector(gengerateNewPassword:) BaseView:_gengeratePasswordView lastLineView:lineView1];
        UIView *lineView2 = [self addLineViewWithLastView:self.resetPasswordBtn BaseView:_gengeratePasswordView bottomMargin:2];
        
        //长度滑块
        UILabel *label1 = [self addPasswordRuleLabelWithTitle:[NSBundle qim_localizedStringForKey:@"password_slider_length"] BaseView:_gengeratePasswordView lastLineView:lineView2];
        self.passwordLenghtSlider = [self addPasswordRulesSliderWithMaximumValue:64 minimumValue:4 selector:@selector(updatePasswordLength:) RuleTitleLabel:label1 BaseView:_gengeratePasswordView lastLineView:lineView2];
        self.plSliderValueLable = [self addPasswordRulesSliderLabelWithSlider:self.passwordLenghtSlider BaseView:_gengeratePasswordView lastLineView:lineView2];
        //滑块宽度更新
        self.passwordLenghtSlider.width = self.plSliderValueLable.left - 8 - label1.right - 8;
        UIView *lineView3 = [self addSliderLineViewWithLastView:label1 BaseView:_gengeratePasswordView bottomMargin:8];

        //数字滑块
        UILabel *label2 = [self addPasswordRuleLabelWithTitle:[NSBundle qim_localizedStringForKey:@"password_slider_digits"] BaseView:_gengeratePasswordView lastLineView:lineView3];
        self.passwordNumberSlider = [self addPasswordRulesSliderWithMaximumValue:10 minimumValue:0 selector:@selector(updatePasswordNumber:) RuleTitleLabel:label2 BaseView:_gengeratePasswordView lastLineView:lineView3];
        self.pnSliderValueLable = [self addPasswordRulesSliderLabelWithSlider:self.passwordNumberSlider BaseView:_gengeratePasswordView lastLineView:lineView3];
        self.passwordNumberSlider.width = self.plSliderValueLable.left - 8 - label2.right - 8;
//        UIView *lineView4 = [self addSliderLineViewWithLastView:label2 BaseView:_gengeratePasswordView bottomMargin:8];
        
        //符号滑块
        UILabel *label3 = [self addPasswordRuleLabelWithTitle:[NSBundle qim_localizedStringForKey:@"password_slider_symbols"] BaseView:_gengeratePasswordView lastLineView:label2];
        self.passwordSymbolSlider = [self addPasswordRulesSliderWithMaximumValue:10 minimumValue:0 selector:@selector(updatePasswordSymbol:) RuleTitleLabel:label3 BaseView:_gengeratePasswordView lastLineView:label2];
        self.psSliderValueLable = [self addPasswordRulesSliderLabelWithSlider:self.passwordSymbolSlider BaseView:_gengeratePasswordView lastLineView:label2];
        self.passwordSymbolSlider.width = self.plSliderValueLable.left - 8 - label3.right - 8;
//        UIView *lineView5 = [self addSliderLineViewWithLastView:label3 BaseView:_gengeratePasswordView bottomMargin:8];
        
        float upperMaximumValue = self.passwordLenghtSlider.value - self.passwordNumberSlider.value - self.passwordSymbolSlider.value;
        //大写滑块
        UILabel *label4 = [self addPasswordRuleLabelWithTitle:[NSBundle qim_localizedStringForKey:@"password_slider_upper"] BaseView:_gengeratePasswordView lastLineView:label3];
        self.passwordUpWordSlider = [self addPasswordRulesSliderWithMaximumValue:upperMaximumValue minimumValue:0 selector:@selector(updatePasswordUpper:) RuleTitleLabel:label4 BaseView:_gengeratePasswordView lastLineView:label3];
        self.pUSliderValueLable = [self addPasswordRulesSliderLabelWithSlider:self.passwordUpWordSlider BaseView:_gengeratePasswordView lastLineView:label3];
        self.passwordUpWordSlider.width = self.pUSliderValueLable.left - 8 - label4.right - 8;
        UIView *lineView6 = [self addSliderLineViewWithLastView:label4 BaseView:_gengeratePasswordView bottomMargin:8];
        
        _gengeratePasswordView.height = lineView6.bottom + 20;
    }
    return _gengeratePasswordView;
}

-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

- (UILabel *)addPasswordRuleLabelWithTitle:(NSString *)ruleTitle BaseView:(UIView *)baseView lastLineView:(UIView *)lineView {
    //引导显示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(lineView.left, lineView.bottom + 12, 10, 45)];
    label.text = ruleTitle;
    label.font = [UIFont systemFontOfSize:16.0];
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentLeft;
    [baseView addSubview:label];
    return label;
}

- (UISlider *)addPasswordRulesSliderWithMaximumValue:(float)maximumValue minimumValue:(float)minimumValue selector:(SEL)sel RuleTitleLabel:(UILabel *)label BaseView:(UIView *)baseView lastLineView:(UIView *)lineView {
    //滑块
    UIImage *image = [self OriginImage:[UIImage imageNamed:@"dynamicfontprogress"] scaleToSize:CGSizeMake(24, 24)];
    UISlider *newSlider = [[UISlider alloc] initWithFrame:CGRectMake(label.right + 5, lineView.bottom + 8, 60, 45)];
    [newSlider setMinimumValue:maximumValue];
    [newSlider setMinimumValue:minimumValue];
    [newSlider setThumbImage:image forState:UIControlStateNormal];
    newSlider.value = maximumValue/2;
    [newSlider addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [baseView addSubview:newSlider];
    newSlider.centerY = label.centerY;
    return newSlider;
}

- (UILabel *)addPasswordRulesSliderLabelWithSlider:(UISlider *)slider BaseView:(UIView *)baseView lastLineView:(UIView *)lineView{
    //滑块值显示Label
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(baseView.width - 36 - 10, lineView.bottom, 20, 45)];
    label2.font = [UIFont systemFontOfSize:16.0];
    label2.textAlignment = NSTextAlignmentRight;
    label2.text = [NSString stringWithFormat:@"%d", (int)(slider.value)];
    [baseView addSubview:label2];
    label2.centerY = slider.centerY;
    return label2;
}

- (UIButton *)addPasswordButtonWithTitle:(NSString *)buttonTitle selector:(SEL)sel BaseView:(UIView *)baseView lastLineView:(UIView *)lineView {
    //动作按钮
    UIButton *newPwdBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    newPwdBtn.frame = CGRectMake(lineView.left, lineView.bottom + 8, lineView.width, 30);
    newPwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [newPwdBtn setTitle:buttonTitle forState:UIControlStateNormal];
    [newPwdBtn setTitleColor:[UIColor qtalkTextBlackColor] forState:UIControlStateSelected];
    [newPwdBtn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:newPwdBtn];
    return newPwdBtn;
}

- (UIView *)addLineViewWithLastView:(UIView *)view BaseView:(UIView *)baseView bottomMargin:(float)bottomMargin {
    //我是底线
    UIView *LineView = [[UIView alloc] initWithFrame:CGRectMake(view.left, view.bottom + bottomMargin, view.width, 0.5)];
    LineView.backgroundColor = [UIColor lightGrayColor];
    [baseView addSubview:LineView];
    return LineView;
}

- (UIView *)addSliderLineViewWithLastView:(UIView *)view BaseView:(UIView *)baseView bottomMargin:(float)bottomMargin {
    //我是底线
    UIView *LineView = [[UIView alloc] initWithFrame:CGRectMake(view.left, view.bottom + bottomMargin, baseView.width - 36, 0.5)];
    LineView.backgroundColor = [UIColor lightGrayColor];
    [baseView addSubview:LineView];
    return LineView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.edited) {
        self.noteModel = [[QIMNoteModel alloc] init];
        self.noteModel.qs_type = QIMPasswordTypeText;
        self.noteModel.q_id = self.QID;
        self.noteModel.c_id = self.CID;
        self.noteModel.pwdDelegate = self;
    }
    [self initUI];
    [self.view endEditing:YES];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor qtalkTableDefaultColor];
    [self setupNav];
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.headerView];
    [self.mainScrollView addSubview:self.passwordView];
    [self.mainScrollView addSubview:self.gengeratePasswordView];
}

- (void)setupNav {
    UIBarButtonItem *saveBtnItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Save"] style:UIBarButtonItemStyleDone target:self action:@selector(savePassword)];
    [self.navigationItem setRightBarButtonItem:saveBtnItem];
}

- (void)showPassword:(id)sender {
    if (self.passwordTextField.text.length > 0) {
        [sender setTitle:self.passwordTextField.text forState:UIControlStateNormal];
        UIButton *btn = sender;
        btn.selected = !btn.selected;
        if (btn.selected) {
            [sender setTitle:self.passwordValue forState:UIControlStateSelected];
        } else {
            [sender setTitle:[NSBundle qim_localizedStringForKey:@"password_tab_show"] forState:UIControlStateNormal];
        }
    }
}

- (void)gengerateNewPassword:(id)sender {
    int bitNum = (int)(self.passwordLenghtSlider.value);
    int number = (int)(self.passwordNumberSlider.value);
    int symbol = (int)(self.passwordSymbolSlider.value);
    int upper = (int)(self.passwordUpWordSlider.value);
    int lower = self.passwordLenghtSlider.value - self.passwordNumberSlider.value - self.passwordSymbolSlider.value - self.passwordLowerWordSlider.value;
    if (lower < 0) {
        lower = 0;
    }
    
    NSString *newPwd = [[QIMPasswordGenerate sharedInstance] createPasswordWithBit:bitNum WithNumber:number WithUpperCase:upper WithLowerCase:lower WithSpecialCharacters:symbol WithAllowRepeat:YES];
    QIMVerboseLog(@"%@", newPwd);
    self.passwordValue = newPwd;
    self.passwordTextField.text = newPwd;
    [self updatePasswordModel];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    self.noteModel.qs_time = time;
}

- (void)updatePasswordLength:(id)sender {
    
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *slider = sender;
        self.plSliderValueLable.text = [NSString stringWithFormat:@"%d", (int)(slider.value)];
        [self updatePasswordUpper];
    }
}

- (void)updatePasswordNumber:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *slider = sender;
        self.pnSliderValueLable.text = [NSString stringWithFormat:@"%d", (int)(slider.value)];
        [self updatePasswordUpper];
    }
}

- (void)updatePasswordSymbol:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *slider = sender;
        self.psSliderValueLable.text = [NSString stringWithFormat:@"%d", (int)(slider.value)];
        [self updatePasswordUpper];
    }
}

- (void)updatePasswordUpper:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *slider = sender;
        int sliderValue = (int)slider.value;
        if (sliderValue < 1) {
            sliderValue = 0;
        }
        self.pUSliderValueLable.text = [NSString stringWithFormat:@"%d", (int)(sliderValue)];
    }
}

- (void)updatePasswordUpper {
    int bitNum = (int)(self.passwordLenghtSlider.value);
    int number = (int)(self.passwordNumberSlider.value);
    int symbol = (int)(self.passwordSymbolSlider.value);
    int upper = bitNum - number - symbol;
    self.passwordLenghtSlider.minimumValue = 0;
    self.passwordNumberSlider.minimumValue = 0;
    self.passwordSymbolSlider.minimumValue = 0;
    self.passwordUpWordSlider.minimumValue = 0;
    self.passwordUpWordSlider.maximumValue = upper;
    if (upper < 1) {
        upper = 0;
    }
    if (self.passwordUpWordSlider.value >= upper) {
        self.passwordUpWordSlider.value = self.passwordUpWordSlider.maximumValue;
        upper = self.passwordUpWordSlider.maximumValue;
    }
    if (self.passwordUpWordSlider.value < 1) {
        self.passwordUpWordSlider.value = 0;
        upper = 0;
    }
    self.pUSliderValueLable.text = [NSString stringWithFormat:@"%d", (int)(upper)];
}

- (void)savePassword {
    
    if (!self.contentDic) {
        self.contentDic = [NSMutableDictionary dictionary];
    }
    self.passwordValue = self.passwordTextField.text;
    [self.contentDic setObject:self.accountTextField.text ? self.accountTextField.text : @"" forKey:@"U"];
    [self.contentDic setObject:self.passwordValue ? self.passwordValue : @"" forKey:@"P"];
//    [self.contentDic setObject:self.readmark ? self.readmark : @"" forKey:@"R"];
//    [self.contentDic setObject:self.passwordValue ? self.passwordValue : @"" forKey:@"W"];
//    [self.contentDic setObject:self.passwordValue ? self.passwordValue : @"" forKey:@"T"];
//    [self.contentDic setObject:self.passwordValue ? self.passwordValue : @"" forKey:@"P"];
//    [self.contentDic setObject:self.passwordValue ? self.passwordValue : @"" forKey:@"P"];
    NSString *contentJson = [[QIMJSONSerializer sharedInstance] serializeObject:self.contentDic];
//    NSString *content = [AESCrypt encrypt:contentJson password:[[QIMNoteManager sharedInstance] getPasswordWithCid:self.noteModel.c_id]];
    NSString *content = [AES256 encryptForBase64:contentJson password:[[QIMNoteManager sharedInstance] getPasswordWithCid:self.noteModel.c_id]];
    if (!self.noteModel.qs_title) {
        self.noteModel.qs_title = [NSBundle qim_localizedStringForKey:@"Password"];
    }
    self.noteModel.qs_content = content;
    if (!self.noteModel.qs_time) {
        self.noteModel.qs_time = [[NSDate date] timeIntervalSince1970] * 1000;
    }
    if (self.noteModel.cs_id < 1) {
        self.noteModel.cs_id = [[QIMNoteManager sharedInstance] getMaxQTNoteSubItemCSid] + 1;
    }
    if (!self.noteModel.q_id) {
        self.noteModel.q_id = self.QID;
    }
    if (!self.noteModel.c_id) {
        self.noteModel.c_id = self.CID;
    }
    if (self.edited == YES) {
        self.noteModel.qs_state = QIMNoteStateNormal;
        [[QIMNoteManager sharedInstance] updateQTNoteSubItemWithQSModel:self.noteModel];
    } else {
        self.noteModel.qs_state = QIMNoteStateNormal;
        [[QIMNoteManager sharedInstance] saveNewQTNoteSubItem:self.noteModel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 1) {
        self.noteModel.qs_title = self.titleTextField.text;
    }
    else if (textField.tag == 2) {
        if (self.showPasswordBtn.selected) {
            [self.showPasswordBtn setTitle:textField.text forState:UIControlStateSelected];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        self.noteModel.qs_title = self.titleTextField.text;
    }
    if (self.showPasswordBtn.selected) {
        [self.showPasswordBtn setTitle:self.passwordValue forState:UIControlStateSelected];
    }
    else if (textField.tag == 2) {
        if (self.showPasswordBtn.selected) {
            [self.showPasswordBtn setTitle:self.passwordValue forState:UIControlStateSelected];
        }
    }
}

#pragma mark - PasswordModelUpdateDelegate

- (void)updatePasswordModel {
    if (self.showPasswordBtn.selected) {
        [self.showPasswordBtn setTitle:self.passwordValue forState:UIControlStateSelected];
    }
}

@end
