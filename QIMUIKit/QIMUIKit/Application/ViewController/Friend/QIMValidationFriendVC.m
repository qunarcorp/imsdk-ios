//
//  ValidationFriendVC.m
//  qunarChatIphone
//
//  Created by admin on 15/11/24.
//
//

#import "QIMValidationFriendVC.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMValidationFriendVC()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation QIMValidationFriendVC{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    UILabel *_questionLabel;
    UITextView *_validationTextView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initWithNav];
    [self initWithTabelView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init ui
- (void)onDoneClick{
    if (_validationTextView.text.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入答案内容。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [[QIMKit sharedInstance] validationFriendWihtXmppId:self.xmppId WithReason:_validationTextView.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)initWithNav{
    [self.navigationItem setTitle:@"好友验证"];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_send"] style:UIBarButtonItemStyleDone target:self action:@selector(onDoneClick)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)initWithTabelView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor qtalkTableDefaultColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
}

- (UIView *)getContentView{
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, _tableView.height)];
    
    UILabel *validationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, contentView.width - 20, 20)];
    [validationLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [validationLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 4]];
    [validationLabel setTextColor:[UIColor qtalkTextBlackColor]];
    [validationLabel setBackgroundColor:[UIColor clearColor]];
    [validationLabel setText:@"验证信息："];
    [contentView addSubview:validationLabel];
    
    _validationTextView = [[UITextView alloc] initWithFrame:CGRectMake(validationLabel.left, validationLabel.bottom + 10, validationLabel.width, 120)];
    [_validationTextView setFont:[UIFont systemFontOfSize:16]];
    [_validationTextView setTextColor:[UIColor qtalkTextBlackColor]];
    [_validationTextView setText:@"我是"];
    [contentView addSubview:_validationTextView];
    
    return contentView;
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _tableView.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"Setting Cell";
    UITableViewCell *contentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (contentCell == nil) {
        contentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [contentCell setBackgroundColor:[UIColor clearColor]];
        [contentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [contentCell.contentView addSubview:[self getContentView]];
    }
    return contentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
