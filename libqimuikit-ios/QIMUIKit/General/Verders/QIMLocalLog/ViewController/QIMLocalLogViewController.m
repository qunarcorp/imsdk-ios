//
//  QIMLocalLogViewController.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/10.
//
//

#import "QIMLocalLogViewController.h"
#import "QIMUUIDTools.h"
#import "QIMHTTPRequest.h"
#import "QIMHTTPClient.h"
#import "QIMStringTransformTools.h"
#import "QIMJSONSerializer.h"
#import "NSBundle+QIMLibrary.h"

#if defined (QIMLogEnable) && QIMLogEnable == 1
#import "QIMLocalLog.h"
#endif
#import "QIMLocalLogTableViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "QIMZipArchive.h"

@interface QIMLocalLogViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) NSMutableArray *selectIndexPathArray;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSMutableArray *logFileAttributeArray;
@property (nonatomic, strong) MFMailComposeViewController *mailControlle;


@end

@implementation QIMLocalLogViewController

#pragma mark - setter and getter

- (void)setLogFileAttributeArray:(NSArray *)logFileAttributeArray {
    _logFileAttributeArray = [NSMutableArray arrayWithArray:logFileAttributeArray];
    if (!_logFileAttributeArray) {
        _logFileAttributeArray = [NSMutableArray arrayWithCapacity:5];
    }
}

- (NSMutableArray *)selectIndexPathArray {
    if (!_selectIndexPathArray) {
        _selectIndexPathArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _selectIndexPathArray;
}

- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _selectArray;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
    }
    return _mainTableView;
}

- (void)initUI {
    [self.view addSubview:self.mainTableView];
    self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"explore_tab_my_file"];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBackBtnHandle)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllBtnHandle:)];
    self.navigationItem.rightBarButtonItem.tag = 10002;
    if (self.isSelect) {
        _mainTableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 64);
        [self showBottomViewEnabled:NO];
    }
}

- (void)showBottomViewEnabled:(BOOL)enabled
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_bottomView];
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:line];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_delete"] forState:UIControlStateNormal];
        deleteBtn.frame = CGRectMake(10, 7, 50, 30);
        [deleteBtn addTarget:self action:@selector(deleteBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = 10000;
        [_bottomView addSubview:deleteBtn];
        
        UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [sendBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_send"] forState:UIControlStateNormal];
        sendBtn.frame = CGRectMake(_bottomView.width - 70, 7, 50, 30);
        [sendBtn addTarget:self action:@selector(sendBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        sendBtn.tag = 100001;
        [_bottomView addSubview:sendBtn];
        
        _mainTableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 44);
    }
    [(UIButton *)[_bottomView viewWithTag:10000] setEnabled:enabled];
    [(UIButton *)[_bottomView viewWithTag:100001] setEnabled:enabled];
    self.navigationItem.title = enabled ? [NSString stringWithFormat:@"已选择%lu个文件", (unsigned long)self.selectArray.count] : @"选择文件";
    [self.navigationItem.rightBarButtonItem setTitle:enabled ? @"全不选" : @"全选"];
}

#pragma mark - life ctyle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}

#pragma mark - Button Action 

- (void)goBackBtnHandle {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectAllBtnHandle:(id)sender {
    if (self.selectArray.count) {
        [self.selectArray removeAllObjects];
        [self.selectIndexPathArray removeAllObjects];
        [self.mainTableView reloadData];
    } else {
        self.selectArray = [NSMutableArray arrayWithArray:self.logFileAttributeArray];
        for (NSInteger i = 0; i < self.logFileAttributeArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.selectIndexPathArray addObject:indexPath];
        }
        [self.mainTableView reloadData];
    }
    [self showBottomViewEnabled:self.selectArray.count > 0];
}

- (void)sendBtnHandle:(id)sender {
    QIMVerboseLog(@"发送日志文件");
    [self sendLogAlertMessage];
    
}

- (void)deleteBtnHandle:(id)sender {
    
    for (NSInteger i = 0; i < self.selectArray.count; i++) {
        NSDictionary *logFileDict = self.selectArray[i];
        NSString *filePath = [logFileDict objectForKey:@"LogFilePath"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [self.logFileAttributeArray removeObject:logFileDict];
        }
    }
    QIMVerboseLog(@"删除日志文件");
    [self.selectArray removeAllObjects];
    [self.mainTableView deleteRowsAtIndexPaths:self.selectIndexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.selectIndexPathArray removeAllObjects];
    [self showBottomViewEnabled:self.selectArray.count > 0];
}

- (void)sendLogAlertMessage {
#if defined (QIMLogEnable) && QIMLogEnable == 1
    NSMutableArray *logArray = [NSMutableArray arrayWithCapacity:5];
    for (NSInteger i = 0; i < self.selectArray.count; i++) {
        NSDictionary *logFileDict = self.selectArray[i];
        NSString *filePath = [logFileDict objectForKey:@"LogFilePath"];
        [logArray addObject:filePath];
    }
    NSString *zipFileName = [NSString stringWithFormat:@"%@-log.zip", [[QIMKit sharedInstance] getLastJid]];

    NSString *zipFilePath = [[QIMZipArchive sharedInstance] zipFiles:logArray ToFile:[[QIMLocalLog sharedInstance] getLocalZipLogsPath] ToZipFileName:zipFileName WithZipPassword:@"lilulucas.li"];
    NSString *httpUrl = [QIMKit updateLoadFile:[NSData dataWithContentsOfFile:zipFilePath] WithMsgId:nil WithMsgType:QIMMessageType_File WihtPathExtension:zipFilePath.pathExtension];
    if (httpUrl.length) {
        if (![httpUrl qim_hasPrefixHttpHeader]) {
            httpUrl = [NSString stringWithFormat:@"%@/%@", @"https://qt.qunar.com", httpUrl];
        }
        [self submitLogWithFileUrl:httpUrl];
    }
#endif
//    [self sendMailWithFile:[NSData dataWithContentsOfFile:zipFilePath] WithFileName:zipFileName];
    
    /*
    __block UIAlertController *sendLogAlertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入App故障时间及详细Case，并确认将日志文件以文件消息形式发送给lilulucas.li?" preferredStyle:UIAlertControllerStyleAlert];
    [sendLogAlertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        textField.placeholder = @"00:00App出现未登录情况";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"cancel"] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        [self sendLogWithDetail:sendLogAlertVc.textFields.firstObject.text];
    }];
    okAction.enabled = NO;
    [sendLogAlertVc addAction:cancelAction];
    [sendLogAlertVc addAction:okAction];
    [self presentViewController:sendLogAlertVc animated:YES completion:nil]; */
}

- (void)submitLogWithFileUrl:(NSString *)fileUrl {
    NSString *title = [NSString stringWithFormat:@"【IOS】来自：%@的反馈日志",[[QIMKit sharedInstance] getLastJid]];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic setObject:@"qchat@qunar.com" forKey:@"from"];
    [requestDic setObject:@"QChat Team" forKey:@"from_name"];
    [requestDic setObject:@[@{@"to":@"lilulucas.li@qunar.com",@"name":@"李露"}] forKey:@"tos"];
    [requestDic setObject:title forKey:@"subject"];
    [requestDic setObject:fileUrl forKey:@"body"];
    [requestDic setObject:@"日志反馈" forKey:@"alt_body"];
    [requestDic setObject:@(YES) forKey:@"is_html"];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:requestDic error:nil];
    NSURL *requestUrl = [NSURL URLWithString:@"http://qt.qunar.com/test_public/public/mainSite/sendMail.php"];
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:requestData];
    [request setHTTPRequestHeaders:@{@"Content-type" : @"application/json;"}];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            if ([[responseDic objectForKey:@"ok"] boolValue]) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"感谢你的问题反馈，我们会及时处理的" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf goBackBtnHandle];
                    }];
                    [alertVc addAction:okAction];
                    [weakSelf presentViewController:alertVc animated:YES completion:nil];
                });
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)alertTextFieldDidChange:(NSNotification *)notify {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *detailTextField = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = detailTextField.text.length > 2;
    }
}

- (void)sendLogWithDetail:(NSString *)detailLog {
    
    [[QIMKit sharedInstance] sendMessage:detailLog WithInfo:nil ToUserId:@"lilulucas.li@ejabhost1" WihtMsgType:QIMMessageType_Text];
    
    for (NSInteger i = 0; i < self.selectArray.count; i++) {
        NSDictionary *logFileDict = self.selectArray[i];
        NSString *filePath = [logFileDict objectForKey:@"LogFilePath"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data.length > 0 && data) {
            NSString *msgId = [QIMUUIDTools UUID];
            NSString *httpUrl = [QIMKit updateLoadFile:data WithMsgId:msgId WithMsgType:QIMMessageType_File WihtPathExtension:filePath.pathExtension];
            NSDictionary * attributes = [logFileDict objectForKey:@"logFileAttribute"];
            NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
            NSString *fileSizeStr = [QIMStringTransformTools CapacityTransformStrWithSize:theFileSize.longLongValue];
            NSString *httpfileName = [filePath lastPathComponent];
            if (attributes && theFileSize && data && httpUrl && httpfileName && fileSizeStr) {
                NSString *messageStr = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"HttpUrl":httpUrl, @"FileName":httpfileName, @"FileSize":fileSizeStr, @"FileLength":theFileSize}];
                [[QIMKit sharedInstance] sendMessage:messageStr WithInfo:nil ToUserId:@"lilulucas.li@ejabhost1" WihtMsgType:QIMMessageType_File];
            }
        }
    }
    [self goBackBtnHandle];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
    });
}

#pragma mark - UITablViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logFileAttributeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *localFileDic = [self.logFileAttributeArray objectAtIndex:indexPath.row];
    if (!localFileDic) {
        return nil;
    }
    NSString *filePath = [localFileDic objectForKey:@"LogFilePath"];
    QIMLocalLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:filePath];
    if (!cell) {
        cell = [[QIMLocalLogTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:filePath
                ];
    }
    [cell setLogFileDict:localFileDic];
    [cell setCellSelected:[self.selectArray containsObject:localFileDic]];
    cell.isSelect = self.isSelect;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelect) {
        QIMLocalLogTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSDictionary *logfileDic = [self.logFileAttributeArray objectAtIndex:indexPath.row];
        [cell setCellSelected:![cell isCellSelected]];
        if ([cell isCellSelected]) {
            [self.selectArray addObject:logfileDic];
            [self.selectIndexPathArray addObject:indexPath];
        } else {
            [self.selectArray removeObject:logfileDic];
            [self.selectIndexPathArray removeObject:indexPath];
        }
        [self showBottomViewEnabled:self.selectArray.count > 0];
    } else {
        
    }
}

- (void)sendMailWithFile:(NSData *)fileData WithFileName:(NSString *)fileName{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailPicker = [[MFMailComposeViewController alloc] init];
        mailPicker.mailComposeDelegate = self;
        //设置收件人
        [mailPicker setToRecipients:@[[NSString stringWithFormat:@"lilulucas.li@qunar.com"]]];
        //设置主题
        [mailPicker setSubject:[NSString stringWithFormat:@"%@的log文件",[[QIMKit sharedInstance] getMyNickName]]];
        //添加附件
        [mailPicker addAttachmentData:fileData mimeType:@"" fileName:fileName];
        
        [self presentViewController:mailPicker animated:YES completion:nil];
        _mailControlle = mailPicker;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先配置邮箱账户或该设备不支持发邮件！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    __weak __typeof(self) weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            [weakSelf goBackBtnHandle];
        } else {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[error description] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
    _mailControlle = nil;
}

@end
