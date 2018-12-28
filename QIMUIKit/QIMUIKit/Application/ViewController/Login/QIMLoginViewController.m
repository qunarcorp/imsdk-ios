//
//  QIMLoginViewController.m
//  qunarChatIphone
//
//  Created by ping.xue on 14-3-4.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMLoginViewController.h"
#import "QIMRSACoder.h"
#import "QIMJSONSerializer.h"
#import "LineView.h"
#import "QIMViewHelper.h"
#import "HYCircleLoadingView.h"
#import "QIMAgreementViewController.h"
#import "QIMNavConfigManagerVC.h"

#define kQZAlert 10001
#define kTJAlert 10002

@interface QIMLoginViewController ()<UIAlertViewDelegate>
{
    UIImageView * _backImageView; 
    HYCircleLoadingView * _loadingView;
    UIButton *_settingButton;
}
@end


@implementation QIMLoginViewController{
}

@synthesize linkUrl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        _clearColor = NO;
//        _cancelMyLoadView = YES;
//        _changeStatueBarY = YES;
//       IMMessageContent *msg = [XmppXMLHelper getIMMessageContentByXMLStr:@"<body platformType=\"2\" msgType=\"1\" id=\"3D5B1AFD08F240868C9D06F014DAA7CB\">asdfadsf</body>"];
//        QIMVerboseLog(@"%@",msg);
    }
    return self;
}

- (void)onSettingClick:(UIButton *)sender{
    QIMNavConfigManagerVC *navURLsSettingVc = [[QIMNavConfigManagerVC alloc] init];
    QIMNavController *navURLsSettingNav = [[QIMNavController alloc] initWithRootViewController:navURLsSettingVc];
    [self presentViewController:navURLsSettingNav animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initWithUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotify:) name:kNotificationLoginState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotify:) name:kNotificationRegisterState object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([linkUrl length] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否更新" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
        [alertView show];
    }
    
    [[self view] bringSubviewToFront:_loadingView];
}

- (void)viewDidUnload {
    self.usernameTextField = nil;
    self.passwordTextField = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//登录
-(void)login:(id)sender
{
    if (([[self.passwordTextField text] length] > 0)&&([[self.usernameTextField text] length] > 0)) {

        [self.loginButton setTitle:@"请您耐心等待, 登录中..." forState:UIControlStateDisabled];
        //登录动画
        [self.view bringSubviewToFront:_loadingView];
        [_loadingView startAnimation];
        [self disableLoginUI];
        [self backgroundTap:nil];
        [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES];
        NSString * RSAPassword = [QIMRSACoder RSAForPassword:[self.passwordTextField text]];
        
        //type:username | email | mobile
        
        NSString * type = @"username";
        if ([self validateEmail:self.usernameTextField.text]) {
            type = @"email";
        }else if ([self validateMobile:self.usernameTextField.text]){
            type = @"mobile";
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 

            NSDictionary * loginDic = [[QIMKit sharedInstance] QChatLoginWithUserId:self.usernameTextField.text rsaPassword:RSAPassword type:type];
            if ([[loginDic objectForKey:@"ret"] boolValue]) {
                NSDictionary * cookieDic = [[loginDic objectForKey:@"data"] firstObject];
                NSString *userName = [cookieDic objectForKey:@"username"];
                NSString *type = [cookieDic objectForKey:@"type"];
                if ([type isEqualToString:@"merchant"]) {
                    [[QIMKit sharedInstance] setIsMerchant:YES];
                } else {
                    [[QIMKit sharedInstance] setIsMerchant:NO];
                }
                
                NSMutableDictionary * passwordDic = [NSMutableDictionary dictionaryWithCapacity:1];
                [passwordDic setQIMSafeObject:[cookieDic objectForKey:@"qcookie"] forKey:@"q"];
                [passwordDic setQIMSafeObject:[cookieDic objectForKey:@"vcookie"] forKey:@"v"];
                [passwordDic setQIMSafeObject:[cookieDic objectForKey:@"tcookie"] forKey:@"t"];
                [passwordDic setQIMSafeObject:[cookieDic objectForKey:@"type"] forKey:@"type"];
                NSString *password = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"cookie":passwordDic}];
                
                [[QIMKit sharedInstance] setUserObject:passwordDic forKey:@"QChatCookie"];
                
                //同步http cookie
                [self syncWebviewCookie];
                [[QIMKit sharedInstance] loginWithUserName:userName WithPassWord:password];
                [[QIMKit sharedInstance] saveUserInfoWithName:userName passWord:[self.passwordTextField text]];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{ 
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"[%d] %@",[[loginDic objectForKey:@"errcode"] intValue],[loginDic objectForKey:@"errmsg"]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    
                    //登录动画
                    [_loadingView stopAnimation];
                    [self enableLoginUI];
                });
            }
        });
       
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"用户名密码无效" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

//注册
-(void)registerUser:(id)sender {
    [[QIMKit sharedInstance] registerWithUserName:self.usernameTextField.text.lowercaseString WithPassWord:self.passwordTextField.text];
}

- (void)loginNotify:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loadingView stopAnimation];
        [self enableLoginUI];
        
        if ([notify.object boolValue]) {
            [QIMFastEntrance showMainVc];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    });
}

- (void)registerNotify:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loadingView stopAnimation];
        [self enableLoginUI];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"暂不开放注册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
        
        if ([notify.object boolValue] == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    });
}


-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)backgroundTap:(id)sender {
    [self.passwordTextField resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kQZAlert) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkUrl]];
        exit(0);
    } else if (alertView.tag == kTJAlert) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkUrl]];
        }
    }
    
}

//邮箱
- (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


//手机号码验证
- (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - init UI
- (void)initWithUI
{
    
    //绘制虚线
    LineView *lineView = [[LineView alloc] initDottedWithFrame:CGRectMake(0, 0, 300, 4)];
    lineView.arrayColor = @[[UIColor spectralColorGrayColor], [UIColor clearColor]];
    [self.dashLineView addSubview:lineView];
    
    //设置圆角
    [QIMViewHelper setRadiusToView:self.usernameTextField];
    [QIMViewHelper setRadiusToView:self.passwordTextField];
    [QIMViewHelper setRadiusToView:self.loginButton];
    [QIMViewHelper setRadiusToView:self.registerButton];
    
    //设置textfield左部填充空白
    [QIMViewHelper setTextFieldLeftView:self.usernameTextField];
    [QIMViewHelper setTextFieldLeftView:self.passwordTextField];
    
    //初始化数据
    NSString *username = [QIMKit getLastUserName];
    NSString *password = [[QIMKit sharedInstance] getLastPassword];
    if (username && password) {
        [self.usernameTextField setText:username];
        [self.passwordTextField setText:password];
    }
    
    //加载的view
    if (_loadingView == nil) {
        _loadingView = [[HYCircleLoadingView alloc]initWithFrame:CGRectMake(self.view.center.x - 25, self.view.center.y - 25, 50, 50)];
        _loadingView.lineColor = [UIColor spectralColorBlueColor];
        [self.view addSubview:_loadingView];
    }
    
    CGFloat width = MIN(self.view.width, self.view.height);
    CGFloat height = MAX(self.view.width, self.view.height);
    
    UIButton * agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeBtn.frame = CGRectMake((width - 258) / 2, height + [UIApplication sharedApplication].statusBarFrame.size.height - 30, 18, 18);
    [agreeBtn setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    [agreeBtn setImage:[UIImage imageNamed:@"checkbox_click"] forState:UIControlStateSelected];
    agreeBtn.selected = YES;
    [agreeBtn addTarget:self action:@selector(agreeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreeBtn];
    
    UILabel * agreeLabel = [[UILabel  alloc] initWithFrame:CGRectMake(agreeBtn.right + 5, agreeBtn.top, 100, agreeBtn.height)];
    agreeLabel.backgroundColor = [UIColor clearColor];
    agreeLabel.text = @"我已阅读并同意";
    agreeLabel.textColor = [UIColor spectralColorGrayBlueColor];
    agreeLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:agreeLabel];
    
    UIButton * agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreementBtn.frame = CGRectMake(agreeLabel.right + 5, agreeBtn.top, 130, agreeBtn.height);
    [agreementBtn setTitle:@"使用条款和隐私政策" forState:UIControlStateNormal];
    [agreementBtn.titleLabel setFont:agreeLabel.font];
    [agreementBtn setTitleColor:[UIColor spectralColorBlueColor] forState:UIControlStateNormal];
    [agreementBtn addTarget:self action:@selector(agreementBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreementBtn];
    
    
    
    _settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.height - 60, self.view.width, 24)];
    [_settingButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_settingButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_settingButton setTitleColor:[UIColor qtalkTextBlackColor] forState:UIControlStateNormal];
    [_settingButton setTitle:@"设置服务地址" forState:UIControlStateNormal];
    [_settingButton setImage:[UIImage imageNamed:@"iconSetting"] forState:UIControlStateNormal];
    [_settingButton addTarget:self action:@selector(onSettingClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_settingButton];
}

- (void)agreeBtnHandle:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.loginButton.enabled = sender.selected;
    [self.loginButton setTitle:@"登录" forState:UIControlStateDisabled];
    if (sender.selected) {
        self.loginButton.backgroundColor = [UIColor spectralColorBlueColor];
    }else{
        self.loginButton.backgroundColor = [UIColor lightGrayColor];
    }
    
}

- (void)agreementBtnHandle:(UIButton *)sender
{
    QIMAgreementViewController * agreementVC = [[QIMAgreementViewController alloc] init];
    QIMNavController * nav = [[QIMNavController alloc]initWithRootViewController:agreementVC];
    [self presentViewController:nav animated:YES completion:nil];
}

//限制输入框
-(void)disableLoginUI
{
    self.usernameTextField.enabled = NO;
    self.passwordTextField.enabled = NO;
    self.loginButton.enabled       = NO;
    self.registerButton.enabled    = NO;
}

//取消输入框限制
-(void)enableLoginUI
{
    self.usernameTextField.enabled = YES;
    self.passwordTextField.enabled = YES;
    self.loginButton.enabled       = YES;
    self.registerButton.enabled    = YES;
}

#pragma mark - text field delegate

//自定义键盘按钮回调
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self login:nil];
        [self.usernameTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark - ui helper
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

//UI的位置调整，上移
- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

- (void)syncWebviewCookie
{
    NSString * qCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"q"];
    NSString * vCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"v"];
    NSString * tCookie = [[[QIMKit sharedInstance] userObjectForKey:@"QChatCookie"] objectForKey:@"t"];
    
    if ([qCookie qim_isStringSafe] && [vCookie qim_isStringSafe] && [tCookie qim_isStringSafe])
    {
        NSMutableDictionary *qcookieProperties = [NSMutableDictionary dictionary];
        [qcookieProperties setQIMSafeObject:@"_q" forKey:NSHTTPCookieName];
        [qcookieProperties setQIMSafeObject:qCookie forKey:NSHTTPCookieValue];
        [qcookieProperties setQIMSafeObject:@".qunar.com"forKey:NSHTTPCookieDomain];
        [qcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
        [qcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie*qcookie = [NSHTTPCookie cookieWithProperties:qcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qcookie];
        
        NSMutableDictionary *vcookieProperties = [NSMutableDictionary dictionary];
        [vcookieProperties setObject:@"_v" forKey:NSHTTPCookieName];
        [vcookieProperties setQIMSafeObject:vCookie forKey:NSHTTPCookieValue];
        [vcookieProperties setObject:@".qunar.com"forKey:NSHTTPCookieDomain];
        [vcookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
        [vcookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie*vcookie = [NSHTTPCookie cookieWithProperties:vcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:vcookie];
        
        NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
        [tcookieProperties setQIMSafeObject:@"_t" forKey:NSHTTPCookieName];
        [tcookieProperties setQIMSafeObject:tCookie forKey:NSHTTPCookieValue];
        [tcookieProperties setQIMSafeObject:@".qunar.com"forKey:NSHTTPCookieDomain];
        [tcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
        [tcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie*tcookie = [NSHTTPCookie cookieWithProperties:tcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:tcookie];
        
        NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [sharedHTTPCookieStorage cookies];
        QIMVerboseLog(@"cookie : %@",cookies);
        
    }
    else
    {
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookieArray = [NSArray arrayWithArray:[cookieJar cookies]];
        for (NSHTTPCookie *cookie in cookieArray)
        {
            if ([[cookie domain] qim_isStringSafe] && [[cookie domain] isEqual:@".qunar.com"] &&
                [[cookie name] qim_isStringSafe] &&
                ([[cookie name] isEqual:@"_q"] || [[cookie name] isEqual:@"_v"] || [[cookie name] isEqual:@"_t"]))
            {
                [cookieJar deleteCookie:cookie];
            }
        }
    }
}

@end
