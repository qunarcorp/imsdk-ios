//
//  QIMGroupPassworVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMGroupPassworVC.h"
#import "QIMViewHelper.h"
#import "NSBundle+QIMLibrary.h"
@interface QIMGroupPassworVC ()<UITextFieldDelegate>{
    UITextField *_textField;
}

@end

@implementation QIMGroupPassworVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    [self.navigationItem setTitle:@"修改群密码"];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_save"] style:UIBarButtonItemStylePlain target:self action:@selector(onSaveGroupName)];
    [self.navigationItem setRightBarButtonItem:rightBarItem];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0,20, self.view.width, 30)];
    [_textField setClearButtonMode:UITextFieldViewModeAlways];
    [_textField setBackgroundColor:[UIColor whiteColor]];
    [_textField setKeyboardType:UIKeyboardTypeDefault];
    [_textField setTextColor:[UIColor blackColor]];
    [_textField setText:self.password];
    [_textField setReturnKeyType:UIReturnKeyDone];
    [_textField setFont:[UIFont fontWithName:FONT_NAME size:14]];
    [_textField setDelegate:self];
    [QIMViewHelper setTextFieldLeftView:_textField];
    [_textField setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:_textField];
    
    [_textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSaveGroupName{
    if (_textField.text.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入要修改的群名称" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (![self.password isEqualToString:_textField.text]) {
        if ([self.delegate respondsToSelector:@selector(setGroupPassword:)]) {
            [self.delegate setGroupPassword:_textField.text];
        }
    
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
