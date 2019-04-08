//
//  QIMChatBubbleFontChangeViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 16/2/19.
//
//

#define kChangeBtnTagFrom       1000
#define kColorSelectViewTag     2000

typedef enum {
    ChangeBtnTypeOtherBubble,
    ChangeBtnTypeOtherFont,
    ChangeBtnTypeMyBubble,
    ChangeBtnTypeMyFont,
    ChangeBtnTypeRestore,
} ChangeBtnType;

#import "QIMChatBubbleFontChangeViewController.h"
#import "QIMGroupChatCell.h"
#import "QIMJSONSerializer.h"
#import "KZColorPicker.h"
#import "HSV.h"
#import "QIMUUIDTools.h"
#import "QIMSTAlertView.h"
#import "QIMMessageParser.h"
#import "QIMTextContainer.h"
#import "QIMMessageCellCache.h"
#import "MBProgressHUD.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMChatBubbleFontChangeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView             * _dispalyTableView;
    UIView                  * _settingView;
    UIButton                * _otherBubbleColorBtn;
    UIButton                * _otherFontColorBtn;
    UIButton                * _myBubbleColorBtn;
    UIButton                * _myFontColorBtn;
    UIButton                * _restoreColorsBtn;
    
    NSMutableDictionary     * _chatColorInfo;
    NSMutableDictionary     * _lastChatColorInfo;
    
    NSMutableArray          * _placeholderMsgs;
    ChangeBtnType             _changeBtnType;
    BOOL                      _isSaved;
    
    MBProgressHUD          * _tipHUD;
    KZColorPicker           * _picker;
    QIMSTAlertView             * _RgbPopView;
    
    
    BOOL                      _isValueChange;
}

@end

@interface QIMChatBubbleFontChangeViewController ()<UIAlertViewDelegate>

@end

@implementation QIMChatBubbleFontChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isSaved = YES;
    _isValueChange = NO;
    _chatColorInfo = [NSMutableDictionary dictionary];
    NSDictionary *dic = [[QIMKit sharedInstance] userObjectForKey:kChatColorInfo];
    if (dic) {
        [_chatColorInfo setDictionary:dic];
    }
    if (_chatColorInfo.count == 0) {
        NSMutableDictionary * infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [infoDic setQIMSafeObject:@{@"colorHex":@(0x3cc97c),@"alpha":@(1.0)} forKey:kMyBubbleColor];
        [infoDic setQIMSafeObject:@{@"colorHex":@(0xffffff),@"alpha":@(1.0)} forKey:kMyFontColor];
        [infoDic setQIMSafeObject:@{@"colorHex":@(0xffffff),@"alpha":@(1.0)} forKey:kOtherBubbleColor];
        [infoDic setQIMSafeObject:@{@"colorHex":@(0x000000),@"alpha":@(1.0)} forKey:kOtherFontColor];
        _chatColorInfo = [NSMutableDictionary dictionaryWithDictionary:infoDic];
        
    }
    _lastChatColorInfo = [NSMutableDictionary dictionaryWithDictionary:_chatColorInfo];
    
    [self initPlaceholderMsgs];
    
    [self initNavBar];
    [self initDisplayTableView];
    [self initSettingView];
}

- (void)initNavBar{
    
    self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"custom_color_title"];
}

- (void)initDisplayTableView{
    if (_dispalyTableView == nil) {
        _dispalyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 220) style:UITableViewStylePlain];
        _dispalyTableView.dataSource = self;
        _dispalyTableView.delegate = self;
        _dispalyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _dispalyTableView.backgroundColor = [UIColor qtalkTableDefaultColor];
        [self.view addSubview:_dispalyTableView];
    }
}

- (void)initSettingView{
    if (_settingView == nil) {
        _settingView = [[UIView alloc] initWithFrame:CGRectMake(0, _dispalyTableView.bottom, self.view.width, self.view.height - _dispalyTableView.bottom)];
        _settingView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_settingView];
        
        float btnWidth = (self.view.width - 15 * 3) / 2;
        float btnHeight = 50;
        
        _otherBubbleColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _otherBubbleColorBtn.frame = CGRectMake(15, 20, btnWidth, btnHeight);
        [_otherBubbleColorBtn setTitle:[NSBundle qim_localizedStringForKey:@"custom_target_bubble_color"]
                              forState:UIControlStateNormal];
        _otherBubbleColorBtn.tag = kChangeBtnTagFrom + ChangeBtnTypeOtherBubble;
        [_otherBubbleColorBtn addTarget:self action:@selector(changeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_settingView addSubview:_otherBubbleColorBtn];
        
        _otherFontColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _otherFontColorBtn.frame = CGRectMake(15, _otherBubbleColorBtn.bottom + 10, btnWidth, btnHeight);
        [_otherFontColorBtn setTitle:[NSBundle qim_localizedStringForKey:@"custom_target_font_color"]
                            forState:UIControlStateNormal];
        _otherFontColorBtn.tag = kChangeBtnTagFrom + ChangeBtnTypeOtherFont;
        [_otherFontColorBtn addTarget:self action:@selector(changeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_settingView addSubview:_otherFontColorBtn];
        
        _myBubbleColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _myBubbleColorBtn.frame = CGRectMake(_otherBubbleColorBtn.right + 15, _otherBubbleColorBtn.top, btnWidth, btnHeight);
        [_myBubbleColorBtn setTitle:[NSBundle qim_localizedStringForKey:@"custom_myself_bubble_color"]
                           forState:UIControlStateNormal];
        _myBubbleColorBtn.tag = kChangeBtnTagFrom + ChangeBtnTypeMyBubble;
        [_myBubbleColorBtn addTarget:self action:@selector(changeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_settingView addSubview:_myBubbleColorBtn];
        
        _myFontColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _myFontColorBtn.frame = CGRectMake(_myBubbleColorBtn.left, _myBubbleColorBtn.bottom + 10, btnWidth, btnHeight);
        [_myFontColorBtn setTitle:[NSBundle qim_localizedStringForKey:@"custom_myself_font_color"]
                         forState:UIControlStateNormal];
        _myFontColorBtn.tag = kChangeBtnTagFrom + ChangeBtnTypeMyFont;
        [_myFontColorBtn addTarget:self action:@selector(changeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_settingView addSubview:_myFontColorBtn];
        
        _restoreColorsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _restoreColorsBtn.frame = CGRectMake(_otherBubbleColorBtn.left , _myFontColorBtn.bottom + 10, _settingView.width - _otherBubbleColorBtn.left * 2, btnHeight);
        [_restoreColorsBtn setTitle:[NSBundle qim_localizedStringForKey:@"custom_back_to_normal"]
                           forState:UIControlStateNormal];
        _restoreColorsBtn.tag = kChangeBtnTagFrom + ChangeBtnTypeRestore;
        [_restoreColorsBtn addTarget:self action:@selector(changeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_restoreColorsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_restoreColorsBtn setBackgroundColor:[UIColor qunarRedColor]];
        [_settingView addSubview:_restoreColorsBtn];
    }
    CGFloat alpha = [_chatColorInfo[kOtherFontColor][@"alpha"] floatValue];
    if (alpha == 0) {
        alpha = 0.05;
    }
    [_otherBubbleColorBtn setTitleColor:[UIColor qim_colorWithHex:[_chatColorInfo[kOtherFontColor][@"colorHex"] integerValue] alpha:alpha] forState:UIControlStateNormal];
    [_otherBubbleColorBtn setBackgroundColor:[UIColor qim_colorWithHex:[_chatColorInfo[kOtherBubbleColor][@"colorHex"] integerValue] alpha:[_chatColorInfo[kOtherBubbleColor][@"alpha"] floatValue]]];
    [_otherFontColorBtn setTitleColor:[UIColor qim_colorWithHex:[_chatColorInfo[kOtherFontColor][@"colorHex"] integerValue] alpha:alpha] forState:UIControlStateNormal];
    [_otherFontColorBtn setBackgroundColor:[UIColor qim_colorWithHex:[_chatColorInfo[kOtherBubbleColor][@"colorHex"] integerValue] alpha:[_chatColorInfo[kOtherBubbleColor][@"alpha"] floatValue]]];
    alpha = [_chatColorInfo[kMyFontColor][@"alpha"] floatValue];
    if (alpha == 0) {
        alpha = 0.05;
    }
    [_myBubbleColorBtn setTitleColor:[UIColor qim_colorWithHex:[_chatColorInfo[kMyFontColor][@"colorHex"] integerValue] alpha:alpha] forState:UIControlStateNormal];
    [_myBubbleColorBtn setBackgroundColor:[UIColor qim_colorWithHex:[_chatColorInfo[kMyBubbleColor][@"colorHex"] integerValue] alpha:[_chatColorInfo[kMyBubbleColor][@"alpha"] floatValue]]];
    [_myFontColorBtn setTitleColor:[UIColor qim_colorWithHex:[_chatColorInfo[kMyFontColor][@"colorHex"] integerValue] alpha:alpha] forState:UIControlStateNormal];
    [_myFontColorBtn setBackgroundColor:[UIColor qim_colorWithHex:[_chatColorInfo[kMyBubbleColor][@"colorHex"] integerValue] alpha:[_chatColorInfo[kMyBubbleColor][@"alpha"] floatValue]]];
}

- (void)initPlaceholderMsgs{
    if (_placeholderMsgs == nil) {
        _placeholderMsgs = [NSMutableArray arrayWithCapacity:1];
    }else{
        [_placeholderMsgs removeAllObjects];
    }
    
    Message * msg = [Message new];
    msg.messageId = [QIMUUIDTools UUID];
    msg.messageType = QIMMessageType_Text;
    msg.message = [NSBundle qim_localizedStringForKey:@"custom_bubble_preview"];
    msg.messageDirection = MessageDirection_Sent;
    msg.nickName = [QIMKit getLastUserName];
    [_placeholderMsgs addObject:msg];
    
    Message * msg1 = [Message new];
    msg1.messageId = [QIMUUIDTools UUID];
    msg1.messageType = QIMMessageType_Text;
    msg1.message = [NSBundle qim_localizedStringForKey:@"Custom_Color_Choose_Btn"];
    msg1.messageDirection = MessageDirection_Received;
    msg1.nickName = [NSBundle qim_localizedStringForKey:@"qtalk_team"];
    [_placeholderMsgs addObject:msg1];
    
    Message * msg2 = [Message new];
    msg2.messageId = [QIMUUIDTools UUID];
    msg2.messageType = QIMMessageType_Text;
    msg2.message = [NSBundle qim_localizedStringForKey:@"Custom_Color_FeedBack"];
    msg2.messageDirection = MessageDirection_Received;
    msg2.nickName = [NSBundle qim_localizedStringForKey:@"qtalk_team"];
    [_placeholderMsgs addObject:msg2];
    
    Message * msg3 = [Message new];
    msg3.messageId = [QIMUUIDTools UUID];
    msg3.messageType = QIMMessageType_Text;
    msg3.message = [NSBundle qim_localizedStringForKey:@"thanks"];
    msg3.messageDirection = MessageDirection_Sent;
    msg3.nickName = [QIMKit getLastUserName];
    [_placeholderMsgs addObject:msg3];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_isSaved == NO) {
        [[QIMKit sharedInstance] setUserObject:_lastChatColorInfo forKey:kChatColorInfo];
    }
    if (_isValueChange) {
        NSString *infoDicStr = [[QIMJSONSerializer sharedInstance] serializeObject:_chatColorInfo];
        [[QIMKit sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKChatColorInfo WithSubKey:[[QIMKit sharedInstance] getLastJid] WithConfigValue:infoDicStr WithDel:NO];
        [[QIMMessageCellCache sharedInstance] clearUp];
    }
}

#pragma mark - UIAlertViewDelegete

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self onSaveClick:nil];
    }else{
        [self cancelBtnHandle:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action 

- (void) changeBtnHandle:(UIButton *)sender{
    _changeBtnType = sender.tag - kChangeBtnTagFrom;
    if (_changeBtnType == ChangeBtnTypeRestore) {
        [self restoreChatColorInfo];
        [[self tipHUDWithText:@"正在恢复..."] show:YES];
        [self performSelector:@selector(closeHUD) withObject:nil afterDelay:0.5];
        return;
    }
    if (_picker == nil) {
        _picker = [[KZColorPicker alloc] initWithFrame:_settingView.frame];
        _picker.tag = kColorSelectViewTag;
        [_picker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
        
        
        UIButton * RGBInputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [RGBInputBtn setImage:[UIImage imageNamed:@"rgb_input"] forState:UIControlStateNormal];
        RGBInputBtn.frame = CGRectMake(_picker.right - 30 - 30, 10, 30 , 30);
        [RGBInputBtn addTarget:self action:@selector(RGBInputBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_picker addSubview:RGBInputBtn];
        
        UIButton * preViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [preViewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [preViewBtn setTitle:@"保  存" forState:UIControlStateNormal];
        [preViewBtn setBackgroundColor:[UIColor qtalkIconSelectColor]];
        preViewBtn.frame = CGRectMake(0, _settingView.height - 50, _settingView.width / 2 - 0.5, 50);
        [preViewBtn addTarget:self action:@selector(preViewBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_picker addSubview:preViewBtn];
        
        UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取  消" forState:UIControlStateNormal];
        [cancelBtn setBackgroundColor:[UIColor qtalkIconSelectColor]];
        cancelBtn.frame = CGRectMake(_settingView.width / 2 + 0.5, _settingView.height - 50, _settingView.width / 2 - 0.5, 50);
        [cancelBtn addTarget:self action:@selector(cancelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_picker addSubview:cancelBtn];
    }
    [self.view addSubview:_picker];
    _picker.selectedColor = (sender.tag % 2) == 0 ? sender.backgroundColor : [sender titleColorForState:UIControlStateNormal];
    _picker.oldColor = (sender.tag % 2) == 0 ? sender.backgroundColor : [sender titleColorForState:UIControlStateNormal];
    
    
    
    
}

- (void)RGBInputBtnHandle:(id)sender{
    [self showRGBColorColorPopView];
}

- (void)packUpBtnHandle:(id)sender{
    [[self.view viewWithTag:kColorSelectViewTag] removeFromSuperview];
}

- (void)preViewBtnHandle:(id)sender{
    [self onSaveClick:sender];
    [[self.view viewWithTag:kColorSelectViewTag] removeFromSuperview];
}

- (void)cancelBtnHandle:(id)sender{
    _isSaved = YES;
    [[self.view viewWithTag:kColorSelectViewTag] removeFromSuperview];
    _chatColorInfo = [NSMutableDictionary dictionaryWithDictionary:_lastChatColorInfo];
    [[QIMKit sharedInstance] setUserObject:_lastChatColorInfo forKey:kChatColorInfo];
    [self refresh];
}

- (void)pickerChanged:(KZColorPicker *)cp
{
    _isSaved = NO;
//    KZColorPicker * cp = [self.view viewWithTag:kColorSelectViewTag];
    NSInteger colorHex = [self changeUIColorToHex:cp.selectedColor];
    float sctAlpha = [cp selectAlpha];
    switch (_changeBtnType) {
        case ChangeBtnTypeMyBubble:
        {
            [_chatColorInfo setQIMSafeObject:@{@"colorHex":@(colorHex),@"alpha":@(sctAlpha)} forKey:kMyBubbleColor];
            
        }
            break;
        case ChangeBtnTypeMyFont:
        {
            [_chatColorInfo setQIMSafeObject:@{@"colorHex":@(colorHex),@"alpha":@(sctAlpha)} forKey:kMyFontColor];
        }
            break;
        case ChangeBtnTypeOtherBubble:
        {
            [_chatColorInfo setQIMSafeObject:@{@"colorHex":@(colorHex),@"alpha":@(sctAlpha)} forKey:kOtherBubbleColor];
        }
            break;
        case ChangeBtnTypeOtherFont:
        {
            [_chatColorInfo setQIMSafeObject:@{@"colorHex":@(colorHex),@"alpha":@(sctAlpha)} forKey:kOtherFontColor];
        }
            break;
        default:
            break;
    }
    [[QIMKit sharedInstance] setUserObject:_chatColorInfo forKey:kChatColorInfo];
//    [[QC_IMManager sharedInstance] setUserCurrentConfigDicWithNewConfigDic:_lastChatColorInfo Key:kChatColorInfo];
    [self refresh];
}

-(void)onSaveClick:(id)sender{
    if (_isSaved == NO) {
        _lastChatColorInfo = [NSMutableDictionary dictionaryWithDictionary:_chatColorInfo];
        [[QIMKit sharedInstance] setUserObject:_chatColorInfo forKey:kChatColorInfo];
        _isSaved = YES;
    }
    if (_isValueChange == NO) {
        _isValueChange = YES;
    }
    [[self tipHUDWithText:@"正在保存..."] show:YES];
    [self performSelector:@selector(closeHUD) withObject:nil afterDelay:0.5];
}

- (void)refresh{
    [self initSettingView];
    for (Message * msg in _placeholderMsgs) {
        [[QIMMessageCellCache sharedInstance] removeObjectForKey:msg.messageId];
    }
    [_dispalyTableView reloadData];
    
}

- (void)restoreChatColorInfo{
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [infoDic setQIMSafeObject:@{@"colorHex":@(0x568bdf),@"alpha":@(1.0)} forKey:kMyBubbleColor];
    [infoDic setQIMSafeObject:@{@"colorHex":@(0xffffff),@"alpha":@(1.0)} forKey:kMyFontColor];
    [infoDic setQIMSafeObject:@{@"colorHex":@(0xb2b2b2),@"alpha":@(1.0)} forKey:kOtherBubbleColor];
    [infoDic setQIMSafeObject:@{@"colorHex":@(0x000000),@"alpha":@(1.0)} forKey:kOtherFontColor];
    _chatColorInfo = [NSMutableDictionary dictionaryWithDictionary:infoDic];
    _lastChatColorInfo = [NSMutableDictionary dictionaryWithDictionary:infoDic];
    [[QIMKit sharedInstance] setUserObject:_chatColorInfo forKey:kChatColorInfo];
    _isSaved = YES;
    [self refresh];
}


#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _placeholderMsgs.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message * message = [_placeholderMsgs objectAtIndex:indexPath.row];
    QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
    return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + (message.messageDirection == MessageDirection_Sent?30:60);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message * message = [_placeholderMsgs objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell text %@",@(message.messageDirection)];
    QIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setFrameWidth:self.view.frame.size.width];
    }
    [cell setChatType:ChatType_GroupChat];
    [cell setMessage:message];
    [cell refreshUI];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - change
//颜色转16进制值
- (NSInteger) changeUIColorToHex:(UIColor *)color{
    const CGFloat *cs=CGColorGetComponents(color.CGColor);
    NSInteger colorHex = 0;
    colorHex += (((NSInteger)(cs[0] * 255)) << 16);
    colorHex += (((NSInteger)(cs[1] * 255)) << 8);
    colorHex += ((NSInteger)(cs[2] * 255));
    return colorHex;
}


#pragma mark - HUD
- (MBProgressHUD *)tipHUDWithText:(NSString *)text {
    if (!_tipHUD) {
        _tipHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _tipHUD.minSize = CGSizeMake(120, 120);
        _tipHUD.minShowTime = 1;
        [_tipHUD setLabelText:@""];
        [self.view addSubview:_tipHUD];
    }
    [_tipHUD setDetailsLabelText:text];
    return _tipHUD;
}

- (void)closeHUD{
    if (_tipHUD) {
        [_tipHUD hide:YES];
    }
}

#pragma mark - RGB color pop view
- (void)showRGBColorColorPopView{
    _RgbPopView = [[QIMSTAlertView alloc] initWithTitle:@"请输入RGB颜色值"
                               message:@"RGB颜色值为6位16进制正整数"
                         textFieldHint:@"请输入RGB颜色值,如0xFFFFFF"
                        textFieldValue:nil
                     cancelButtonTitle:@"返回"
                     otherButtonTitles:@"确定"
     
                     cancelButtonBlock:^{
                     } otherButtonBlock:^(NSString * result){
                         NSString * colorHex = result;
                         if ([colorHex hasPrefix:@"0x"] && colorHex.length > 2) {
                             colorHex = [colorHex substringFromIndex:2];
                         }else if([colorHex hasPrefix:@"0x"]){
                             colorHex = nil;
                         }
                         if (colorHex.length && [self isValidateColorHex:colorHex]) {
                             UInt64 mac1 =  strtoul([colorHex UTF8String], 0, 16);
                             _picker.selectedColor = [UIColor qim_colorWithHex:mac1 alpha:1.0];
                             _picker.oldColor = [UIColor qim_colorWithHex:mac1 alpha:1.0];
                         }else{
                             _RgbPopView = [[QIMSTAlertView alloc] initWithTitle:@"颜色设置出错"
                                                                      message:@"您输入的RGB颜色值格式或者数值不正确，请确保输入正确！"
                                                            cancelButtonTitle:@"我知道了！"
                                                            otherButtonTitles:nil
                                            
                                                            cancelButtonBlock:^{
                                                            } otherButtonBlock:^{
                                                            }];
                         }
                     }];
}

-(BOOL)isValidateColorHex:(NSString *)colorHex {
    
    NSString *emailRegex = @"[\\da-fA-F]{6}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:colorHex];
    
}


@end
