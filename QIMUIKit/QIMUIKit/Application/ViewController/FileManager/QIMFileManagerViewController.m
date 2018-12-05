//
//  QIMFileManagerViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/24.
//
//

#import "QIMFileManagerViewController.h"
#import "QIMFileManagerCell.h"
#import "QIMFilePreviewVC.h"
#import "QIMJSONSerializer.h"
//#import "NSBundle+QIMLibrary.h"

@interface QIMFileManagerViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView         * _mainTableView;
    NSMutableDictionary      * _filesDic;
    NSMutableArray           * _fileKeys;
    
    NSMutableArray           * _selectArr;
    UIView                   * _bottomView;
}

@end

@implementation QIMFileManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"explore_tab_my_file"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _selectArr = [NSMutableArray arrayWithCapacity:1];
    
    NSArray * fileMsgs = [[QIMKit sharedInstance] getMsgsForMsgType:QIMMessageType_File];
    QIMVerboseLog(@"file msgs = %@",fileMsgs);
//    _files = [NSMutableArray arrayWithArray:fileMsgs];
    
    [self parseFiles:fileMsgs];
    
    [self setUpMainTableView];
    
    if (self.isSelect) {
        
        _mainTableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 64);
        
        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnHandle:)];
        [self.navigationItem setRightBarButtonItem:item];
        
        self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"explore_tab_my_file"];
        
        [self showBottomViewEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mainTableView reloadData];
}


- (void)parseFiles:(NSArray *)files
{
    if (!_filesDic) {
        _filesDic = [NSMutableDictionary dictionaryWithCapacity:1];
        _fileKeys = [NSMutableArray arrayWithCapacity:1];
    }else{
        [_filesDic removeAllObjects];
        [_fileKeys removeAllObjects];
    }
    for (Message * msg in files) {
        long long msgDate = msg.messageDate; 
        NSString * key = [[[[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate] qim_formattedDateDescription] componentsSeparatedByString:@" "] firstObject];
        NSMutableArray * keyArr = [NSMutableArray arrayWithCapacity:1];
        if ([_filesDic.allKeys containsObject:key]) {
            [keyArr addObjectsFromArray:[_filesDic objectForKey:key]];
        }else{
            [_fileKeys addObject:key];
        }
        [keyArr addObject:msg];
        [_filesDic setObject:keyArr forKey:key];
    }
}

- (void)setUpMainTableView
{
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    [self.view addSubview:_mainTableView];
}

- (void)showBottomViewEnabled : (BOOL) enabled
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
        if ([[QIMKit sharedInstance] getIsIpad]) {
            _bottomView.frame = CGRectMake(0, [[UIScreen mainScreen] height] - 44, [[UIScreen mainScreen] width], 44);
        }
        _bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_bottomView];
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:line];
        
        UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [sendBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_send"] forState:UIControlStateNormal];
        sendBtn.frame = CGRectMake(_bottomView.width - 70, 7, 50, 30);
        [sendBtn addTarget:self action:@selector(sendBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        sendBtn.tag = 10000;
        [_bottomView addSubview:sendBtn];
        
        _mainTableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 44);
        if ([[QIMKit sharedInstance] getIsIpad]) {
            _mainTableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] width], [[UIScreen mainScreen] height] - 44);
        }
    }
    [(UIButton *)[_bottomView viewWithTag:10000] setEnabled:enabled];
}

- (void)sendBtnHandle:(UIButton *)sender
{
#if defined (QIMNoteEnable) && QIMNoteEnable == 1

    //获取加密状态
    QIMEncryptChatState encryptState = [[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.userId];
#endif
    for (Message * message in _selectArr) {
        Message *msg = message;
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
        if (encryptState == QIMEncryptChatStateEncrypting) {
            NSString *encryptContent = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:[msg messageType] WithOriginBody:msg.message WithOriginExtendInfo:msg.extendInformation WithUserId:self.userId];
            msg.message = @"加密文件消息iOS";
            msg.extendInformation = encryptContent;
            msg.messageType = QIMMessageType_Encrypt;
        }
#endif
        if (self.messageSaveType == ChatType_GroupChat) {
         msg = [[QIMKit sharedInstance] sendMessage:[msg message] WithInfo:[msg extendInformation] ToGroupId:self.userId WihtMsgType:[msg messageType]];
        }else{
         msg = [[QIMKit sharedInstance] sendMessage:[msg message] WithInfo:[msg extendInformation] ToUserId:self.userId WihtMsgType:[msg messageType]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:self.userId userInfo:@{@"message":msg}];
            });
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBtnHandle:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fileKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_filesDic objectForKey:[_fileKeys objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message * message = [[_filesDic objectForKey:[_fileKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    QIMFileManagerCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[QIMFileManagerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    [cell setCellMessage:message];
    cell.isSelect = self.isSelect;
    [cell setAccessibilityIdentifier:[NSString stringWithFormat:@"fileCell%ld", indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, tableView.width - 30, 20)];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.text = [_fileKeys objectAtIndex:section];
    label.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:label];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, bgView.height - 0.5, bgView.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:line];
    
    return bgView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSelect) {
        QIMFileManagerCell * cell = (QIMFileManagerCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setCellSelected:![cell isCellSelected]];
        if ([cell isCellSelected]) {
            [_selectArr addObject:[[_filesDic objectForKey:[_fileKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
        }else{
            Message * message = [[_filesDic objectForKey:[_fileKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            for (Message * msg in _selectArr) {
                if ([msg.messageId isEqualToString:message.messageId]) {
                    [_selectArr removeObject:msg];
                    break;
                }
            }
        }
        [self showBottomViewEnabled:_selectArr.count > 0];
    }else{
        QIMFilePreviewVC *preview = [[QIMFilePreviewVC alloc] init];
        [preview setMessage:[[_filesDic objectForKey:[_fileKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:preview animated:YES];
    }
}

#pragma mark - 删除

//要求委托方的编辑风格在表视图的ji一个特定的位置。
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;//默认没有编辑风格
        if ([tableView isEqual:_mainTableView]) {
                result = UITableViewCellEditingStyleDelete;//设置编辑风格为删除风格
        }
    return result;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{//设置是否显示一个可编辑视图的视图控制器。
        [super setEditing:editing animated:animated];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{//请求数据源提交的插入或删除指定行接收者。
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        Message * message = [[_filesDic objectForKey:[_fileKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        NSString *fileUrl = [infoDic objectForKey:@"HttpUrl"];
        NSString *fileName = [[fileUrl pathComponents] lastObject];
        NSString *filePath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [[QIMKit sharedInstance] deleteMsg:message ByJid:nil];
        
        [[_filesDic objectForKey:[_fileKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        NSMutableArray * arr = [NSMutableArray arrayWithArray:[_filesDic objectForKey:[_fileKeys objectAtIndex:indexPath.section]]];
        [arr removeObject:message];
        if (arr.count) {
            [_filesDic setObject:arr forKey:[_fileKeys objectAtIndex:indexPath.section]];
            [_mainTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [_filesDic removeObjectForKey:[_fileKeys objectAtIndex:indexPath.section]];
            [_fileKeys removeObjectAtIndex:indexPath.section];
            [_mainTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

@end
