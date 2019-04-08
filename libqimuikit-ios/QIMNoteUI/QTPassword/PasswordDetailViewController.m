//
//  PasswordDetailViewController.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/11.
//
//

#import "PasswordDetailViewController.h"
#import "NewAddPasswordViewController.h"
#import "PasswordHistoryViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "QIMNoteModel.h"
//#import "QIMMenuImageView.h"
#import "AESCrypt.h"
#import "QIMAES256.h"
#import "QIMMenuView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PasswordDetailViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
    MFMailComposeViewController* _mailControlle;
}

@property (nonatomic, strong) UIScrollView *detailScrollView;

@property (nonatomic, strong) NSMutableArray *detailExpandSource;

@property (nonatomic, strong) QIMNoteModel *noteModel;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *showPwdView;

@property (nonatomic, strong) UILabel *showAccountLabel;

@property (nonatomic, strong) UILabel *showLastPwdLabel;

@property (nonatomic, strong) UIMenuController *accountMenuVc;

@property (nonatomic, strong) UIMenuController *menuVc;

@property (nonatomic, strong) UITableView *detailExpandTableView;

@property (nonatomic, copy) NSString *pwdValue;

@property (nonatomic, copy) NSString *accountValue;

@end

@implementation PasswordDetailViewController

- (void)setQIMNoteModel:(QIMNoteModel *)noteModel {
    if (noteModel != nil) {
        self.noteModel = noteModel;
        NSString *pwd = [[QIMNoteManager sharedInstance] getPasswordWithCid:self.noteModel.c_id];
        NSString *contentJson = [AESCrypt decrypt:self.noteModel.qs_content password:pwd];
        if (!contentJson) {
            contentJson = [QIMAES256 decryptForBase64:self.noteModel.qs_content password:pwd];
        }
        NSDictionary *contentDic = [[QIMJSONSerializer sharedInstance] deserializeObject:contentJson error:nil];
        self.pwdValue = [contentDic objectForKey:@"P"];
        self.accountValue = [contentDic objectForKey:@"U"];
    }
}

- (UIScrollView *)detailScrollView {
    if (!_detailScrollView) {
        _detailScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _detailScrollView.backgroundColor = [UIColor clearColor];
        _detailScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 1.2 * SCREEN_HEIGHT);
        _detailScrollView.showsVerticalScrollIndicator = NO;
        _detailScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _detailScrollView;
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
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconView.right + 15, iconView.top, SCREEN_WIDTH - iconView.right - 15, 30)];
        _titleLabel.text = self.noteModel.qs_title ? self.noteModel.qs_title : [NSBundle qim_localizedStringForKey:@"Password"];
        _titleLabel.tag = 1;
        [_headerView addSubview:_titleLabel];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom + 2, _titleLabel.width, 20)];
        categoryLabel.text = [NSBundle qim_localizedStringForKey:@"Password"];
        categoryLabel.textColor = [UIColor qtalkTextLightColor];
        categoryLabel.font = [UIFont systemFontOfSize:12];
        [_headerView addSubview:categoryLabel];
    }
    return _headerView;
}

- (UIView *)showPwdView {
    if (!_showPwdView) {
        _showPwdView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom + 30, SCREEN_WIDTH, 200)];
        _showPwdView.backgroundColor = [UIColor whiteColor];
        _showPwdView.layer.borderWidth = 0.5f;
        _showPwdView.layer.borderColor = [UIColor grayColor].CGColor;
        
        //账号提示Label
        CGFloat originX = 15;
        CGFloat topMargin = 8;
        CGFloat originWidth = SCREEN_WIDTH - 2 * originX;
        CGFloat originHeight = 21;
        CGFloat maxHeight = 0;
        UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, maxHeight + topMargin, originWidth, originHeight)];
        accountLabel.font = [UIFont systemFontOfSize:14];
        accountLabel.textColor = [UIColor systemBlueColor];
        accountLabel.text = [NSBundle qim_localizedStringForKey:@"account"];
        [accountLabel sizeToFit];
        [_showPwdView addSubview:accountLabel];
        
        UILabel *showAccountLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, accountLabel.bottom + topMargin, originWidth, originHeight + 15)];
        showAccountLabel.text = self.accountValue;
        showAccountLabel.userInteractionEnabled = YES;
        [_showPwdView addSubview:showAccountLabel];
        UITapGestureRecognizer *showAccountTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAccountHandleTap:)];
        showAccountTouch.numberOfTapsRequired = 1;
        [showAccountLabel addGestureRecognizer:showAccountTouch];
        self.showAccountLabel = showAccountLabel;
        
        //密码提示Label
        UILabel *pwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, showAccountLabel.bottom + topMargin, originWidth, originHeight)];
        pwdLabel.font = [UIFont systemFontOfSize:14];
        pwdLabel.textColor = [UIColor systemBlueColor];
        pwdLabel.text = [NSBundle qim_localizedStringForKey:@"password"];
        [pwdLabel sizeToFit];
        [_showPwdView addSubview:pwdLabel];

        
        UILabel *showPwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, pwdLabel.bottom + topMargin, originWidth, originHeight + 15)];
        showPwdLabel.text = @"*********";
        showPwdLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPwdLabelHandleTap:)];
        touch.numberOfTapsRequired = 1;
        [showPwdLabel addGestureRecognizer:touch];

        self.showLastPwdLabel = showPwdLabel;
        
        [_showPwdView addSubview:showPwdLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(originX, showPwdLabel.bottom + 2, originWidth, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_showPwdView addSubview:lineView];
        
        //动作按钮
        UIButton *newPwdBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        newPwdBtn.frame = CGRectMake(lineView.left, lineView.bottom + 8, lineView.width, 30);
        newPwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [newPwdBtn setTitle:[NSBundle qim_localizedStringForKey:@"password_tab_history"] forState:UIControlStateNormal];
        [newPwdBtn setTitleColor:[UIColor qtalkTextBlackColor] forState:UIControlStateSelected];
        [newPwdBtn addTarget:self action:@selector(showMorePasswordHistory:) forControlEvents:UIControlEventTouchUpInside];
        [_showPwdView addSubview:newPwdBtn];
        
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(originX, newPwdBtn.bottom + 2, originWidth, 0.5)];
        lineView2.backgroundColor = [UIColor lightGrayColor];
        [_showPwdView addSubview:lineView2];
        
        maxHeight = lineView2.bottom + topMargin;
        _showPwdView.height = maxHeight + 20;
    }
    return _showPwdView;
}

- (void)showMorePasswordHistory:(id)sender {
    QIMVerboseLog(@"查看密码更改记录");
    NSArray *historyModels = [[QIMNoteManager sharedInstance] getCloudRemoteSubHistoryWithQSid:self.noteModel.qs_id];
    if (historyModels.count) {
        PasswordHistoryViewController *pwdHistoryVc = [[PasswordHistoryViewController alloc] init];
//        [pwdHistoryVc setPk:self.noteModel.privateKey];
        [pwdHistoryVc setHistoryModels:historyModels];
        [self.navigationController pushViewController:pwdHistoryVc animated:YES];
    }
}

- (CGFloat)addShowPwdViewWithTitles:(NSArray *)titles passwordModel:(QIMNoteModel *)model baseView:(UIView *)baseView {
    
    CGFloat originX = 15;
    CGFloat topMargin = 8;
    CGFloat originWidth = SCREEN_WIDTH - 2 * originX;
    CGFloat originHeight = 21;
    CGFloat maxHeight = 0;
    for (NSInteger i = 0; i < titles.count; i++) {
        //密码提示Label
        UILabel *pwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, maxHeight + topMargin, originWidth, originHeight)];
        pwdLabel.font = [UIFont systemFontOfSize:14];
        pwdLabel.textColor = [UIColor qim_colorWithHex:0x1296db alpha:1.0];
        pwdLabel.text = titles[i];
        [pwdLabel sizeToFit];
        [_showPwdView addSubview:pwdLabel];
        
        UILabel *showPwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, pwdLabel.bottom + topMargin, originWidth, originHeight + 15)];
        showPwdLabel.text = self.pwdValue;
        showPwdLabel.tag = i;
        showPwdLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPwdLabelHandleTap:)];
        touch.numberOfTapsRequired = 1;
        [showPwdLabel addGestureRecognizer:touch];
        
        [_showPwdView addSubview:showPwdLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(originX, showPwdLabel.bottom + 2, originWidth, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_showPwdView addSubview:lineView];
        
        maxHeight = lineView.bottom + topMargin;
    }
    return maxHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor qtalkTableDefaultColor];
    UIBarButtonItem *editBtnItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"Edit"] style:UIBarButtonItemStyleDone target:self action:@selector(editPassword)];
    [self.navigationItem setRightBarButtonItem:editBtnItem];
    [self.view addSubview:self.detailScrollView];
    [self.detailScrollView addSubview:self.headerView];
    [self.detailScrollView addSubview:self.showPwdView];
    [self.detailScrollView addSubview:self.detailExpandTableView];
}

- (UITableView *)detailExpandTableView {
    if (!_detailExpandTableView) {
        _detailExpandTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.showPwdView.bottom + 30, SCREEN_WIDTH, self.detailExpandSource.count * 50) style:UITableViewStylePlain];
        _detailExpandTableView.backgroundColor = [UIColor whiteColor];
        _detailExpandTableView.layer.borderWidth = 0.5f;
        _detailExpandTableView.layer.borderColor = [UIColor grayColor].CGColor;
        _detailExpandTableView.delegate = self;
        _detailExpandTableView.dataSource = self;
        _detailExpandTableView.scrollEnabled = NO;
    }
    if ([_detailExpandTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_detailExpandTableView setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    if ([_detailExpandTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_detailExpandTableView setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    return _detailExpandTableView;
}

- (NSMutableArray *)detailExpandSource {
    if (!_detailExpandSource) {
        _detailExpandSource = [NSMutableArray arrayWithCapacity:5];
        [_detailExpandSource addObject:@"Favorite"];
        [_detailExpandSource addObject:@"Copy"];
        [_detailExpandSource addObject:@"Share"];
//        [_detailExpandSource addObject:@"Export"];
    }
    return _detailExpandSource;
}

- (UIMenuController *)accountMenuVc {
    //创建UIMenuController的控件
    if (!_accountMenuVc) {
        _accountMenuVc = [UIMenuController sharedMenuController];
        [_accountMenuVc setMenuVisible:NO];
    }
    [_accountMenuVc setTargetRect:self.showAccountLabel.frame inView:self.showAccountLabel.superview];
    [self updateMenuItems2];
    return _accountMenuVc;
}

- (UIMenuController *)menuVc {
    //创建UIMenuController的控件
    if (!_menuVc) {
        _menuVc = [UIMenuController sharedMenuController];
        [_menuVc setMenuVisible:NO];
    }
    [_menuVc setTargetRect:self.showLastPwdLabel.frame inView:self.showLastPwdLabel.superview];
    [self updateMenuItems];
    return _menuVc;
}

- (void)updateMenuItems2 {
    UIMenuItem *copyAccount = [[UIMenuItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"password_tab_copy"] action:@selector(copyAccount:)];
    [_accountMenuVc setMenuItems:[NSArray arrayWithObjects:copyAccount, nil]];
}

- (void)updateMenuItems {
    UIMenuItem *copyPasswd = [[UIMenuItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"password_tab_copy"] action:@selector(copyPassword:)];
    UIMenuItem *showPasswd = [[UIMenuItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"password_menu_reveal"] action:@selector(showPassword:)];
    UIMenuItem *hidePasswd = [[UIMenuItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"password_menu_conceal"]  action:@selector(hidePassword:)];
    UIMenuItem *bigShowPasswd = [[UIMenuItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"password_menu_large"] action:@selector(bigShowPassword:)];
    if ([self.showLastPwdLabel.text isEqualToString:self.pwdValue]) {
        [_menuVc setMenuItems:[NSArray arrayWithObjects:copyPasswd, hidePasswd,/* bigShowPasswd,*/ nil]];
    } else {
        [_menuVc setMenuItems:[NSArray arrayWithObjects:copyPasswd, showPasswd,/* bigShowPasswd,*/ nil]];
    }
}

-(void)showAccountHandleTap:(UIGestureRecognizer*) recognizer {
    [self becomeFirstResponder];
    
    [self.accountMenuVc setTargetRect:self.showAccountLabel.frame inView:self.showAccountLabel.superview];
    [self.accountMenuVc setMenuVisible:YES animated:YES];
}
-(void)showPwdLabelHandleTap:(UIGestureRecognizer*) recognizer {
    //是当前的对象成为第一响应者
    [self becomeFirstResponder];
    
    [self.menuVc setTargetRect:self.showLastPwdLabel.frame inView:self.showLastPwdLabel.superview];
    [self.menuVc setMenuVisible:YES animated:YES];
}

#pragma mark UIMenuController 控件方法

- (void)copyAccount:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.accountValue];
}

- (void)copyPassword:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.pwdValue];
}

- (void)showPassword:(id)sender {
    self.showLastPwdLabel.text = self.pwdValue;
    [self updateMenuItems];
}

- (void)hidePassword:(id)sender {
    self.showLastPwdLabel.text = @"*********";
    [self updateMenuItems];
}

- (void)bigShowPassword:(id)sender {

}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action == @selector(copyPassword:)){
        return YES;
    }else if (action == @selector(showPassword:)){
        return YES;
    }else if (action == @selector(bigShowPassword:)){
        return YES;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.detailExpandSource.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellId = [NSString stringWithFormat:@"CellId%ld", (long)indexPath.row];
    NSString *item = [self.detailExpandSource objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if ([item isEqualToString:@"Copy"]) {
        cell.textLabel.text = [NSBundle qim_localizedStringForKey:@"password_tab_copy"];
        cell.imageView.image = [UIImage imageNamed:@"Password_copy"];
    } else if ([item isEqualToString:@"Share"]) {
        cell.textLabel.text = [NSBundle qim_localizedStringForKey:@"password_tab_share"];
        cell.imageView.image = [UIImage imageNamed:@"Password_share"];
    } else if ([item isEqualToString:@"Export"]) {
        cell.textLabel.text = [NSBundle qim_localizedStringForKey:@"password_tab_export"];
        cell.imageView.image = [UIImage imageNamed:@"Password_export"];
    } else if ([item isEqualToString:@"Favorite"]) {
        if (self.noteModel.qs_state == QIMNoteStateFavorite) {
            cell.textLabel.text = [NSBundle qim_localizedStringForKey:@"password_tab_removeFavorite"];
            cell.imageView.image = [UIImage imageNamed:@"PasswordBox_favorite_selected"];
        } else {
            cell.textLabel.text = [NSBundle qim_localizedStringForKey:@"password_tab_favorite"];
            cell.imageView.image = [UIImage imageNamed:@"PasswordBox_favorite_normal"];
        }
    }
    cell.textLabel.textColor = [UIColor systemBlueColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *item = [self.detailExpandSource objectAtIndex:indexPath.row];
    if ([item isEqualToString:@"Copy"]) {
        [[UIPasteboard generalPasteboard] setString:self.pwdValue?self.pwdValue:@""];
    } else if ([item isEqualToString:@"Share"]) {
        __weak __typeof(self) weakSelf = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle qim_localizedStringForKey:@"password_share_title"] message:[NSBundle qim_localizedStringForKey:@"password_share_message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"password_share_undestand"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf sendMail];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    } else if ([item isEqualToString:@"Export"]) {
        
    } else if ([item isEqualToString:@"Favorite"]) {
        if (self.noteModel.qs_state == QIMNoteStateFavorite) {
            self.noteModel.qs_state = QIMNoteStateNormal;
        } else {
            self.noteModel.qs_state = QIMNoteStateFavorite;
        }
        [[QIMNoteManager sharedInstance] updateQTNoteSubItemStateWithQSModel:self.noteModel];
        [self.detailExpandTableView reloadData];
    }
}

- (void)sendMail{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSString *modelTitle = self.noteModel.qs_title;
        NSString *modelPwd = self.pwdValue;
        NSString *body = [NSString stringWithFormat:@"Password\%@\r\r\r password: %@\r From Iphone QTalk.", modelTitle, modelPwd];
        [controller setToRecipients:@[[NSString stringWithFormat:@"%@@qunar.com",[QIMKit getLastUserName]]]];
        [controller setSubject:[NSString stringWithFormat:@"From %@",[[QIMKit sharedInstance] getMyNickName]]];
        [controller setMessageBody:body isHTML:NO];
        [self presentViewController:controller animated:YES completion:nil];
        _mailControlle = controller;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先配置邮箱账户或该设备不支持发邮件！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            
        } else {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[error description] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
    _mailControlle = nil;
}

- (void)editPassword {
    NewAddPasswordViewController *editPasswordVc = [[NewAddPasswordViewController alloc] init];
    editPasswordVc.edited = YES;
    [editPasswordVc setQIMNoteModel:self.noteModel];
    [self.navigationController pushViewController:editPasswordVc animated:YES];
}

@end
