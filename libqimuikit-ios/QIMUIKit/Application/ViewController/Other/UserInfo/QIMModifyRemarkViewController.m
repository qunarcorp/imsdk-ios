//
//  QIMModifyRemarkViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 16/5/11.
//
//

#define kMaxTextCout        96

#import "QIMModifyRemarkViewController.h"
@interface InsetsTextField : UITextField
@end

@implementation InsetsTextField
//控制 placeHolder 的位置，左右缩 20
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 20 , 0 );
}

// 控制文本的位置，左右缩 20
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 20 , 0 );
}
@end


@interface QIMModifyRemarkViewController ()<UITextFieldDelegate>
{
    InsetsTextField * _inputView;
    UILabel     * _inputCountLabel;
}
@end

@implementation QIMModifyRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor qtalkChatBgColor];
    
    [self initNavBar];
    
    [self initSubViews];
}


- (void)initNavBar{
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38 , 44)];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(onDoneBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    self.navigationItem.title = @"修改备注";
}

- (void)initSubViews{
    if (_inputView == nil) {
        _inputView = [[InsetsTextField alloc] initWithFrame:CGRectMake(-1, 20, self.view.width + 2, 50)];
        _inputView.delegate = self;
        _inputView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputView.returnKeyType = UIReturnKeyDone;
        _inputView.backgroundColor = [UIColor whiteColor];
        _inputView.layer.borderColor = [UIColor spectralColorGrayColor].CGColor;
        _inputView.layer.borderWidth = .5;
        _inputView.placeholder = @"请输入备注...";
        [_inputView setAccessibilityIdentifier:@"input Remark"];
        [self.view addSubview:_inputView];
    }
    
    if (_inputCountLabel == nil) {
        _inputCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 50, _inputView.bottom + 10, 40, 20)];
        _inputCountLabel.backgroundColor = [UIColor clearColor];
        _inputCountLabel.textAlignment = NSTextAlignmentCenter;
        _inputCountLabel.font = [UIFont systemFontOfSize:14];
        _inputCountLabel.textColor = [UIColor spectralColorGrayDarkColor];
        [self.view addSubview:_inputCountLabel];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.jid];
    [_inputView setText:remarkName];
    [_inputCountLabel setText:[NSString stringWithFormat:@"%@/%@",@(_inputView.text.length),@(kMaxTextCout)]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_inputView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)onDoneBtnClick{
    [[QIMKit sharedInstance] updateUserMarkupNameWithUserId:self.jid WithMarkupName:_inputView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length + string.length <= kMaxTextCout) {
        [_inputCountLabel setText:[NSString stringWithFormat:@"%@/%@",@(textField.text.length + string.length),@(kMaxTextCout)]];
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    [_inputCountLabel setText:[NSString stringWithFormat:@"%@/%@",@(0),@(kMaxTextCout)]];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self onDoneBtnClick];
    return YES;
}


@end
