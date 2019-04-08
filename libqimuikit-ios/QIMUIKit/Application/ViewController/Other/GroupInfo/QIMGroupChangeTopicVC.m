//
//  QIMGroupChangeTopicVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMGroupChangeTopicVC.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMGroupChangeTopicVC ()<UITextViewDelegate>{
    UITextView *_textView;
}

@end

@implementation QIMGroupChangeTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"group_update_topic"]];
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_save"] style:UIBarButtonItemStylePlain target:self action:@selector(onSaveGroupName)];
    [self.navigationItem setRightBarButtonItem:rightBarItem];
    
    UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(10,20, self.view.width - 20, 150)];
    [textBgView setBackgroundColor:[UIColor whiteColor]];
    [textBgView.layer setCornerRadius:10];
    [textBgView.layer setMasksToBounds:YES];
    [self.view addSubview:textBgView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, textBgView.width-20, textBgView.height-20)];
    [_textView setBackgroundColor:[UIColor whiteColor]];
    [_textView setKeyboardType:UIKeyboardTypeDefault];
    [_textView setTextColor:[UIColor spectralColorGrayDarkColor]];
    [_textView setReturnKeyType:UIReturnKeyDone];
    [_textView setFont:[UIFont fontWithName:FONT_NAME size:14]];
    [_textView setDelegate:self];
    [_textView setTextAlignment:NSTextAlignmentLeft];
    [_textView setText:self.groupTopic];
    [textBgView addSubview:_textView];
    
    [_textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSaveGroupName{ 
    if (![self.groupTopic isEqualToString:_textView.text]) {
        [[QIMKit sharedInstance] setMucVcardForGroupId:self.groupId WithNickName:nil WithTitle:_textView.text WithDesc:nil WithHeaderSrc:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
