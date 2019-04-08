//
//  QIMSystemVC.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/6/5.
//
//

#import "QIMSystemVC.h"
#import "QIMTapGestureRecognizer.h"
#import "QIMSingleChatVoiceCell.h"
#import "QIMSingleChatCell.h"
#import "QIMGroupChatCell.h"
#import "QIMMenuImageView.h"
#import "QIMMessageRefreshHeader.h"

#import "QIMVoiceRecordingView.h"

#import "QIMVoiceTimeRemindView.h"

//#import "TextCellCaChe.h"

#import <AVFoundation/AVFoundation.h>

#import "QIMRemoteAudioPlayer.h"

#define kPageCount 20

#import "QIMDisplayImage.h"

#import "QIMContactSelectionViewController.h"

#import "QIMPhotoBrowserNavController.h"

#import "QIMPublicNumberOrderMsgCell.h"
#import "QIMPublicNumberNoticeCell.h"

#import "QIMWebView.h"
#import "QIMTextBar.h"
#import "QIMMyFavoitesManager.h"
#import "QIMMessageParser.h"
#import "QIMTextContainer.h"
#import "QIMNavBackBtn.h"
#import "QIMMessageTableViewManager.h"
#import "QIMMWPhotoBrowser.h"

 @interface QIMSystemVC()<QTalkMessageTableScrollViewDelegate, UIGestureRecognizerDelegate,QIMSingleChatCellDelegate,QIMSingleChatVoiceCellDelegate,NSXMLParserDelegate,QIMMWPhotoBrowserDelegate,QIMMsgBaloonBaseCellDelegate,PNNoticeCellDelegate,PNOrderMsgCellDelegate>
{
    bool _isReloading;
    NSString *_currentPlayVoiceMsgId;
    float _currentDownloadProcess;
    CGRect _tableViewFrame;
    
    BOOL _notIsFirstChangeTableViewFrame;
    BOOL _playStop;
    
    NSMutableDictionary *_cellSizeDic;
    QIMRemoteAudioPlayer *_remoteAudioPlayer;
    UIView      * notificationView;
    UILabel     * commentCountLabel;
    UIImageView  * backImageView;
    QIMTapGestureRecognizer *_tap;
    NSMutableArray * _tempArray;
    
    NSMutableDictionary * _photos;
}

@property (nonatomic, strong) QIMMessageTableViewManager *messageManager;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation QIMSystemVC

#pragma mark - setter and getter

- (QIMMessageTableViewManager *)messageManager {
    if (!_messageManager) {
        _messageManager = [[QIMMessageTableViewManager alloc] initWithChatId:self.chatId ChatType:ChatType_System OwnerVc:self];
        _messageManager.delegate = self;
    }
    return _messageManager;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin];
        [_tableView setDelegate:self.messageManager];
        [_tableView setDataSource:self.messageManager];
        [_tableView setBackgroundColor:[UIColor qtalkChatBgColor]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
#endif
        _tableViewFrame = _tableView.frame;
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
        [_tableView setTableHeaderView:headerView];
        
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
        [_tableView setTableFooterView:footView];
        [_tableView setAccessibilityIdentifier:@"MessageTableView"];
    }
    return _tableView;
}

- (void)setUI {
    [self.view setBackgroundColor:[UIColor qtalkChatBgColor]];
    [self setupNav];
    [self.view addSubview:self.tableView];
}

- (void)setBackBtn {
    QIMNavBackBtn *backBtn = [QIMNavBackBtn sharedInstance];
    [backBtn addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarBtn = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //将宽度设为负值
    spaceItem.width = -15;
    //将两个BarButtonItem都返回给N
    self.navigationItem.leftBarButtonItems = @[spaceItem,backBarBtn];
}

- (void)setupNav {
    [self.navigationItem setTitle:self.title];
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    headerView.layer.cornerRadius  = 2.0;
    headerView.layer.masksToBounds = YES;
    headerView.clipsToBounds       = YES;
    headerView.backgroundColor     = [UIColor clearColor];
    UIImage *headImage = [UIImage imageNamed:@"icon_speaker_h39"];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        if ([self.chatId hasPrefix:@"rbt-notice"]) {
            headImage = [UIImage imageNamed:@"rbt_notice"];
        } else if ([self.chatId hasPrefix:@"rbt-qiangdan"] || [self.chatId hasPrefix:@"rbt-zhongbao"]) {
            headImage = [UIImage imageNamed:@"rbt-qiangdan"];
        } else {
            headImage = [UIImage imageNamed:@"icon_speaker_h39"];
        }
    } else {
        headImage = [UIImage imageNamed:@"icon_speaker_h39"];
    }
    [headerView setImage:headImage];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:headerView];
    
    [self.navigationItem setRightBarButtonItem:rightItem];
    [self setBackBtn];
}

#pragma mark - NSNotification

- (void)registerNSNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageList:) name:kNotificationMessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHistoryMessageList:) name:kNotificationGetHistoryMessage object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(refreshTableView) name:@"refreshTableView" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNSNotification];
    [self setUI];
    
    _photos = [[NSMutableDictionary alloc] init];
    _cellSizeDic = [NSMutableDictionary dictionary];
    [[QIMKit sharedInstance] setCurrentSessionUserId:self.chatId];

    self.tableView.mj_header = [QIMMessageRefreshHeader messsageHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewSystemMsgList)];
    [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [self loadData];
    [self addImageToImageList];
    
    //添加整个view的点击事件，当点击页面空白地方时，输入框收回
    UIGestureRecognizer *gesture = [[UIGestureRecognizer alloc] initWithTarget:self action:nil];
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
}

-(void)loadData
{
    [self.messageManager.dataSource removeAllObjects];
    __weak typeof(self) weakSelf = self;
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        
        NSString *domain = [[QIMKit sharedInstance] getDomain];
        [[QIMKit sharedInstance] getSystemMsgLisByUserId:self.chatId WithFromHost:domain WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
            [self.messageManager.dataSource addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
//            [weakSelf scrollToBottom_tableView];
        }];
    } else {
        [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:nil WihtLimit:kPageCount WithOffset:0 WihtComplete:^(NSArray *list) {
            [self.messageManager.dataSource addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
//            [weakSelf scrollToBottom_tableView];
        }];
    }
    [[QIMKit sharedInstance] clearSystemMsgNotReadWithJid:self.chatId];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_remoteAudioPlayer stop];
    _currentPlayVoiceMsgId = nil;
}

- (void)leftBarBtnClicked:(UITapGestureRecognizer *)tap
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)selfPopedViewController{
    [super selfPopedViewController];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
    [[QIMKit sharedInstance] clearNotReadMsgByJid:self.chatId];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)goBack:(id)sender{
    
    //    [[QIMKit sharedInstance] updateMessageReadStateWithSessionId:self.chatSession.sessionId];
    [[QIMKit sharedInstance] setCurrentSessionUserId:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[QIMKit sharedInstance] clearNotReadMsgByJid:self.chatId];
}

- (void)dealloc {
    
    [[QIMNavBackBtn sharedInstance] removeTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
#if kHasVoice
    _remoteAudioPlayer = nil;
#endif
    
    _currentPlayVoiceMsgId = nil;
    _cellSizeDic = nil;
}

- (void)viewDidUnload {
    _tableView = nil;
    [super viewDidUnload];
}



#if kHasVoice

#pragma mark - Audio Method

- (BOOL)playingVoiceWithMsgId:(NSString *)msgId{
    
    return [msgId isEqualToString:_currentPlayVoiceMsgId];
    
}



- (void)playVoiceWithMsgId:(NSString *)msgId WithFilePath:(NSString *)filePath{
    
    
    _currentPlayVoiceMsgId = msgId;
    
    
    
    if (_currentPlayVoiceMsgId) {
        
        // 开始播放
        
        if ([filePath qim_hasPrefixHttpHeader]) {
            
            [_remoteAudioPlayer prepareForURL:filePath playAfterReady:YES];
            
        } else {
            
            [_remoteAudioPlayer prepareForFilePath:filePath playAfterReady:YES];
            
        }
        
        
        
    } else {
        
        // 结束播放
        
        [_remoteAudioPlayer stop];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [self.tableView reloadData];
        
    }
    
}

- (void)playVoiceWithMsgId:(NSString *)msgId WithFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl {
    _currentPlayVoiceMsgId = msgId;
    
    if (_currentPlayVoiceMsgId) {
        [_remoteAudioPlayer prepareForFileName:fileName andVoiceUrl:voiceUrl playAfterReady:YES];
    } else {
        [_remoteAudioPlayer stop];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    [self.tableView reloadData];
}



- (void)remoteAudioPlayerReady:(QIMRemoteAudioPlayer *)player{
    
    
    
}



- (void)remoteAudioPlayerErrorOccured:(QIMRemoteAudioPlayer *)player withErrorCode:(QIMRemoteAudioPlayerErrorCode)errorCode{
    
    
    
}



- (void)remoteAudioPlayerDidStartPlaying:(QIMRemoteAudioPlayer *)player{
    
    [self updateCurrentPlayVoiceTime];
    
}



- (void)remoteAudioPlayerDidFinishPlaying:(QIMRemoteAudioPlayer *)player{
    
    _currentPlayVoiceMsgId = nil;
    
    [self.tableView reloadData];
    
}



- (void)updateCurrentPlayVoiceTime{
    
    if (_currentPlayVoiceMsgId) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyPlayVoiceTime object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:_remoteAudioPlayer.currentTime],kNotifyPlayVoiceTimeTime,_currentPlayVoiceMsgId,kNotifyPlayVoiceTimeMsgId, nil]];
        
        [self performSelector:@selector(updateCurrentPlayVoiceTime) withObject:nil afterDelay:1];
        
    }
    
}



- (int)playCurrentTime{
    
    return _remoteAudioPlayer.currentTime;
    
}



- (void)downloadProgress:(float)newProgress{
    
    if (_currentPlayVoiceMsgId) {
        
        _currentDownloadProcess = newProgress;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDownloadProgress object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:_currentDownloadProcess],kNotifyDownloadProgressProgress,_currentPlayVoiceMsgId,kNotifyDownloadProgressMsgId, nil]];
        
    } else {
        
        _currentDownloadProcess = 1;
        
    }
    
}



- (double)getCurrentDownloadProgress{
    
    return _currentDownloadProcess;
    
}

#endif

#pragma mark - notification

- (void)updateHistoryMessageList:(NSNotification *)notify {
    
}


//
// 二人消息 是在这里收到的

- (void)updateMessageList:(NSNotification *)notify{
    
    if ([self.chatId isEqualToString:notify.object]) {
        Message *msg = [notify.userInfo objectForKey:@"message"];
        
        if (msg) {
            [self.messageManager.dataSource addObject:msg];
            [self.tableView reloadData];
            [self addImageToImageList];
            [self scrollToBottomWithCheck:YES];
            [[QIMKit sharedInstance] clearSystemMsgNotReadWithJid:self.chatId];
        }
    }
}

- (void)scrollToBottom:(BOOL)animated {
    if (self.messageManager.dataSource.count == 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        CGFloat offsetY = self.tableView.contentSize.height + self.tableView.contentInset.bottom - CGRectGetHeight(self.tableView.frame);
        if (offsetY < -self.tableView.contentInset.top) {
            offsetY = -self.tableView.contentInset.top;
        }
        [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:animated];
    }else {
        if([self.tableView numberOfSections] > 0 ){
            NSInteger lastSectionIndex = [self.tableView numberOfSections]-1;
            NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex ]-1;
            if(lastRowIndex > 0){
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
                [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            }
        } else {
            CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:offset animated:NO];
        }
    }
}

- (BOOL)shouldScrollToBottomForNewMessage {
    CGFloat _h = self.tableView.contentSize.height - self.tableView.contentOffset.y - (CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.bottom);
    
    return _h <= 66 * 4;
}

- (void)scrollToBottomWithCheck:(BOOL)flag {
    [self scrollToBottom:flag];
}

#pragma mark - Cell Delegate

- (void)openWebUrl:(NSString *)url{
    QIMWebView *webVC = [[QIMWebView alloc] init];
    [webVC setUrl:url];
    [webVC setFromMsgList:YES];
    [self.navigationController pushViewController:webVC animated:YES];
}

static CGPoint tableOffsetPoint;

- (void)processEvent:(int)event withMessage:(id)message {
    
    if (event == MA_Repeater) {
        
        QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
        QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
        [controller setMessage:message];
        [[self navigationController] presentViewController:nav animated:YES completion:^{
            
        }];
    }else if (event == MA_Delete){
        for (Message * msg in self.messageManager.dataSource) {
            if ([msg.messageId isEqualToString:[(Message *)message messageId]]) {
                NSInteger index = [self.messageManager.dataSource indexOfObject:msg];
                [self.messageManager.dataSource removeObject:msg];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [[QIMKit sharedInstance] deleteMsg:message ByJid:self.chatId];
                break;
            }
        }
        
    } else if (event == MA_Favorite) {
        
        for (Message *msg in self.messageManager.dataSource) {
            
            if ([msg.messageId isEqualToString:[(Message *)message messageId]]) {
                
                
                [[QIMMyFavoitesManager sharedMyFavoritesManager] setMyFavoritesArrayWithMsg:message];
                
                break;
            }
        }
    }
}

#pragma mark - QIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser
{
    return _photos.count;
}

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index > _photos.count)
        return nil;
    
    NSString *imagePath;
    for (QIMDisplayImage *image in [_photos allValues]) {
        if (image.imageIndex == index) {
            imagePath = image.imagePath;
        }
    }
    if ([imagePath qim_hasPrefixHttpHeader]) {
        NSURL *url = [NSURL URLWithString:[imagePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        return url?[[QIMMWPhoto alloc] initWithURL:url]:nil;
    } else {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        if (image == nil) {
            image = [[UIImage alloc] initWithContentsOfFile:kImageDownloadFailImageFileName];
        }
        return image?[[QIMMWPhoto alloc] initWithImage:image]:nil;
    }
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser
{
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
        [self.tableView setContentOffset:tableOffsetPoint animated:YES];
    }];
}

#pragma mark -  MJRefresh的代理函数

- (void)loadNewSystemMsgList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
            [[QIMKit sharedInstance] getSystemMsgLisByUserId:self.chatId WithFromHost:[[QIMKit sharedInstance] getDomain] WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
                CGFloat offsetY = self.tableView.contentSize.height -  self.tableView.contentOffset.y;
                NSRange range = NSMakeRange(0, [list count]);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                [self.tableView reloadData];
                
                self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - offsetY - 30);
                //重新获取一次大图展示的数组
                [self addImageToImageList];
                [_tableView.mj_header endRefreshing];
            }];
        } else {
            [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:nil WihtLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WihtComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGFloat offsetY = self.tableView.contentSize.height -  self.tableView.contentOffset.y;
                    NSRange range = NSMakeRange(0, [list count]);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    [self.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                    [self.tableView reloadData];
                    
                    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - offsetY - 30);
                    //重新获取一次大图展示的数组
                    [self addImageToImageList];
                    [_tableView.mj_header endRefreshing];
                });
            }];
        }
    });
}

- (void)scrollToBottom_tableView {
    if (self.messageManager.dataSource.count == 0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageManager.dataSource.count - 1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self scrollToBottom:YES];
    }else {
        [self scrollToBottom:NO];
    }
}

-(void)refreshTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self.tableView
                                                 selector:@selector(reloadData)
                                                   object:nil];
        
        [self.tableView performSelector:@selector(reloadData)
                         withObject:nil
                         afterDelay:DEFAULT_DELAY_TIMES];
    });
}

- (void)moveViewToFoot {
    [self scrollToBottom_tableView];
}

//获取大图展示数组

- (void)addImageToImageList {
    /*
    [_photos removeAllObjects];
    
    NSInteger imageIndex = 0;
    NSInteger cellIndex  = 0;
    NSArray *tempDataSource = [NSArray arrayWithArray:self.messageManager.dataSource];
    for (Message *msg in tempDataSource) {
        if (![msg isKindOfClass:[NSString class]]) {
            TextCellCache *cache = [_cellSizeDic objectForKey:msg.messageId];
            if (cache) {
                if (cache.images.count > 0) {
                    NSString *imagePath = [cache.images firstObject][@"httpUrl"];
                    if (imagePath) {
                        QIMDisplayImage *displayImage = [[QIMDisplayImage alloc] init];
                        displayImage.imagePath       = imagePath;
                        displayImage.imageIndex      = imageIndex;
                        displayImage.cellIndex       = cellIndex;
                        [_photos setObject:displayImage forKey:@(cellIndex)];
                        imageIndex++;
                    }
                }
            }
        }
        cellIndex++;
    }
    */
}

#pragma mark - QTalkMessageTableScrollViewDelegate
- (void)QTalkMessageUpdateForwardBtnState:(BOOL)enable {
//    self.forwardBtn.enabled = enable;
//    QIMVerboseLog(@"%d", self.forwardBtn.enabled);
}

- (void)QTalkMessageScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

@end
