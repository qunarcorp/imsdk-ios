//
//  QIMFriendsSpaceViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 15/9/9.
//
//

#import "QIMFriendsSpaceViewController.h"
#import "QIMReplyMsgCell.h"
#import "QIMUUIDTools.h"
#import "QIMTextBar.h"
#import "QIMEmotionManager.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMFriendsSpaceViewController ()<UITableViewDataSource,UITableViewDelegate,QIMTextBarDelegate,UIGestureRecognizerDelegate,QIMReplyMsgCellDelegate>
{
    NSMutableArray      * _dataSource;
    Message             * _currentMsg;
    
    NSString *_replyMsgId;
    NSString *_replyUser;
}

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) QIMTextBar *textBar;

@end

@implementation QIMFriendsSpaceViewController

#pragma mark - setter and getter
- (UITableView *)mainTableView {
    
    if (!_mainTableView) {
        
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.backgroundColor = [UIColor whiteColor];
    }
    return _mainTableView;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FriendsSpacePopVc object:nil];
    });
}

- (QIMTextBar *)textBar {
    
    if (!_textBar) {
        _textBar = [QIMTextBar sharedIMTextBarWithBounds:self.view.frame WithExpandViewType:QIMTextBarExpandViewTypeGroup];
        _textBar.frame = CGRectMake(0,self.view.height - 35, self.view.width, 480);
        [_textBar setRootFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [_textBar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_textBar setDelegate:self];
        [_textBar setHasVoice:NO];
        [_textBar setHasExpandKeyboard:NO];
        __weak QIMTextBar * textBar = _textBar;
        [_textBar setSelectedEmotion:^(NSString * faceStr) {
            
            if ([faceStr length] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *text = [[QIMEmotionManager sharedInstance] getEmotionTipNameForShortCut:faceStr withPackageId:textBar.currentPKId];
                    text = [NSString stringWithFormat:@"[%@]",text];
                    [textBar insertEmojiTextWithTipsName:text shortCut:faceStr];
                });
            }
        }];
        
        [_textBar.layer setBorderColor:[UIColor qim_colorWithHex:0xadadad alpha:1].CGColor];
        [_textBar setHasAtFun:YES];
        [_textBar setBackgroundColor:[UIColor qim_colorWithHex:0xebecef alpha:1]];
        
        _textBar.hidden = YES;
        [_textBar setTextViewBackgroundImage:[[UIImage imageNamed:@"chat_bottom_textfield"] stretchableImageWithLeftCapWidth:5 topCapHeight:5]];
    }
    return _textBar;
}


#pragma mark - life ctyle
- (void)initUI {
    
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.textBar];
    UILongPressGestureRecognizer * longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesHandle:)];
    longGes.delegate = self;
    [self.view addGestureRecognizer:longGes];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"group_message_reply"];
    [self initData];
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyMsgDidTapedNotiHandle:) name:kReplyMsgDidTapedNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initData
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:1];
    }else{
        [_dataSource removeAllObjects];
    }
    if (self.msgId) {
        NSDictionary *dic = [[QIMKit sharedInstance] getFSMsgByMsgId:self.msgId];
        [_dataSource addObject:dic];
    } else if (self.groupId) {
        NSArray *list = [[QIMKit sharedInstance] getFSMsgByXmppId:self.groupId];
        if (list) {
            [_dataSource addObjectsFromArray:list];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.msgId) {
        Message * message = [_dataSource.firstObject objectForKey:@"MainMsg"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReplyMsgDidTapedNotification object:message userInfo:@{@"replyMsgId":self.msgId,@"replyUser":message.from ? message.from : @""}];
        
    }
}

- (void)replyMsgDidTapedNotiHandle:(NSNotification *)noti
{
    self.textBar.hidden = NO;
    _mainTableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 50);
    _currentMsg = noti.object;
    if ([noti.userInfo objectForKey:@"replyMsgId"]) {
        _replyMsgId = [noti.userInfo objectForKey:@"replyMsgId"];
        _replyUser = [noti.userInfo objectForKey:@"replyUser"];
    }
    [self.textBar setTextViewPlaceholder:[NSString stringWithFormat:@"回复%@:",_replyUser]];
    [self.textBar becomeFirstResponder];
}

- (void)longGesHandle:(UILongPressGestureRecognizer *)longGes
{
    
}


- (void)refresh
{
    [self initData];
    [_mainTableView reloadData];
}

#pragma mark - QIMReplyMsgCellDelegate

-(void)replyMsgCell:(QIMReplyMsgCell *)cell didClickedUserNickName:(NSString *)userNickName
{
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByName:userNickName];
    if (userInfo) {
        NSString *userId = [userInfo objectForKey:@"XmppId"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:userId];
        });
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.view];
    if (!CGRectContainsPoint(self.textBar.frame, point)) {
        [self.textBar resignFirstResponder];
    }
    
    return YES;
    
}


#pragma mark - IMTextBarDelegate

- (void)sendText:(NSString *)text
{
    text = [self.textBar getSendAttributedText];
    
    if ([text length] > 0) {
        text = [[QIMEmotionManager sharedInstance] decodeHtmlUrlForText:text];
        NSString * msgId = [QIMUUIDTools UUID];
        [[QIMKit sharedInstance] sendReplyMessageId:_replyMsgId  WithReplyUser:_replyUser WithMessageId:msgId WithMessage:text ToGroupId:self.groupId];
        
        [self performSelector:@selector(refresh) withObject:nil afterDelay:1];
        
    }
    
    [self.textBar resignFirstResponder];
}



- (void)emptyText:(NSString *)text
{
}

- (void)setKeyBoardHeight:(CGFloat)height WithScrollToBottom:(BOOL)flag
{
    if (height < 50) {
        self.textBar.hidden = YES;
        _mainTableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    }
}


#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = @"cell";
    QIMReplyMsgCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QIMReplyMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }
    [cell setMessage:[[_dataSource objectAtIndex:indexPath.row] objectForKey:@"MainMsg"]];
    [cell setReplyMsgList:[[_dataSource objectAtIndex:indexPath.row] objectForKey:@"ReplyMsgList"]];
    [cell refreshUI];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [QIMReplyMsgCell getCellHeightForMessage:[[_dataSource objectAtIndex:indexPath.row] objectForKey:@"MainMsg"] replyMsgList:[[_dataSource objectAtIndex:indexPath.row] objectForKey:@"ReplyMsgList"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
