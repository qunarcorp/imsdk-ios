//
//  QIMMySignatureViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 16/2/2.
//
//

#import "QIMMySignatureViewController.h"

@interface QIMMySignatureViewController ()<UITextViewDelegate>
{
    UITextView              * _textView;
    UILabel                 * _fontCountLabel;
}
@end

@implementation QIMMySignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor qim_colorWithHex:0xebebf1 alpha:1];
    
    [self initNav];
    [self initUI];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _textView.text = self.playholder;
    [_textView setAccessibilityIdentifier:@"input Signature"];
    _fontCountLabel.text = [NSString stringWithFormat:@"%@",@(30 - _textView.text.length)];
    [_textView becomeFirstResponder];
    _fontCountLabel.text = [NSString stringWithFormat:@"%@",@(30 - _textView.text.length)];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)initNav{
    
    self.navigationItem.title = @"个性签名";
    
    UIView *rightItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 60, 30)];
    [doneButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(onDoneClick) forControlEvents:UIControlEventTouchUpInside];
    [rightItemView addSubview:doneButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemView];
    [self.navigationItem setRightBarButtonItem:rightItem];
}


- (void)initUI{

    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, self.view.width, 90)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 10, bgView.width - 30, bgView.height - 20)];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont systemFontOfSize:18];
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.textColor = [UIColor qtalkTextBlackColor];
    _textView.delegate = self;
    [bgView addSubview:_textView];

    _fontCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgView.width - 40, bgView.height - 20, 30, 20)];
    _fontCountLabel.textColor = [UIColor qtalkTextLightColor];
    _fontCountLabel.text = @"30";
    _fontCountLabel.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:_fontCountLabel];
}

#pragma mark - action

- (void)onDoneClick{
    if (_textView.text.length > 0) {
        [[QIMKit sharedInstance] updateUserSignatureForUser:[[QIMKit sharedInstance] getLastJid] signature:_textView.text];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您并没有写下任何东西~" delegate:nil cancelButtonTitle:@"俺 know~" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self onDoneClick];
        return NO;
    }
    if (textView.text.length + text.length > 30) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"亲，最多只能输入30个字儿哦~" delegate:nil cancelButtonTitle:@"晓得了！" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    _fontCountLabel.text = [NSString stringWithFormat:@"%@",@(30 - textView.text.length - text.length)];
    return YES;
}

@end
