//
//  QIMQNValidationFriendVC.m
//  qunarChatIphone
//
//  Created by admin on 15/11/24.
//
//

#import "QIMQNValidationFriendVC.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMQNValidationFriendVC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation QIMQNValidationFriendVC{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    UILabel *_questionLabel;
    UITextField *_answerTextField;
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
    if (_answerTextField.text.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入答案内容。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [[QIMKit sharedInstance] addFriendPresenceWithXmppId:self.xmppId WithAnswer:_answerTextField.text];
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
    
    NSString *question = [self.validDic objectForKey:@"question"];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, _tableView.height)];
    
    UIView *questionView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, contentView.width, 44)];
    [questionView setBackgroundColor:[UIColor whiteColor]];
    [contentView addSubview:questionView];
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, contentView.width - 20, 20)];
    [questionLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [questionLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 4]];
    [questionLabel setTextColor:[UIColor qtalkTextBlackColor]];
    [questionLabel setBackgroundColor:[UIColor clearColor]];
    [questionLabel setText:[NSString stringWithFormat:@"问题:%@",question]];
    [questionView addSubview:questionLabel];
    
    UIView *answerView = [[UIView alloc] initWithFrame:CGRectMake(0, questionView.bottom+20, contentView.width, 44)];
    [answerView setBackgroundColor:[UIColor whiteColor]];
    [contentView addSubview:answerView];
    
    UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 20)];
    [answerLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [answerLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 4]];
    [answerLabel setTextColor:[UIColor qtalkTextBlackColor]];
    [answerLabel setBackgroundColor:[UIColor clearColor]];
    [answerLabel setText:@"答案:"];
    [answerView addSubview:answerLabel];
    
    _answerTextField = [[UITextField alloc] initWithFrame:CGRectMake(answerLabel.right, 0, answerView.width - answerLabel.right - 10, answerView.height)];
    [_answerTextField setPlaceholder:@"输入答案"];
    [answerView addSubview:_answerTextField];
    
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
