//
//  QIMFilePreviewVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "QIMFilePreviewVC.h"
#import "QIMFileIconTools.h"
#import "QIMJSONSerializer.h"
#import "QIMMoviePlayer.h"
#import "QIMAudioPlayer.h"
#import "QIMIconInfo.h"
#import "QIMContactSelectionViewController.h"

@interface QIMFilePreviewVC ()<UIWebViewDelegate,ASIProgressDelegate,ASIHTTPRequestDelegate>{
    dispatch_queue_t _writeDataQueue;
    UIWebView *_previewWebView;
    
    UIView *_downloadView;
    
    UIView *_bottomView;
    UIButton *_repeatButton;
    UIButton *_downLoadButton;
    UIButton *_deleteButton;
    UIView *_progressBgView;
    UIProgressView *_progressView;
    UIButton *_cancelDownButton;
    
    NSFileHandle *_fileHandle;
    NSString *_filePath;
    NSString *_fileName;
    NSString *_fileForwardTempPath;
    unsigned long long _fileOffset;
    long long _requestLength;
    long long _currentOffset;
    ASIHTTPRequest *_downloadRequest;
    QIMMoviePlayer *_videoPlayer;
    QIMAudioPlayer *_audioPlayer;
    
    BOOL _downloadComplate;
    
    BOOL _hasFile;
    
    UIDocumentInteractionController * _documentController;
    UIButton * _openOtherButton;
    UITapGestureRecognizer *_tap;
}

@end

@implementation QIMFilePreviewVC

- (NSString *) fileNamefromUrl:(NSString *) fileUrl {
    NSString *fileName = nil;

    NSURL *url = [NSURL URLWithString:fileUrl];
    NSDictionary *queryComponents = [url.query qim_dictionaryFromParamComponents];
    fileName = [queryComponents objectForKey:@"file"];
    fileName = [[fileName pathComponents] lastObject];
    if (!fileName)
        fileName = [[fileUrl pathComponents] lastObject];
    return fileName;
}

- (void) showUI {
    if (_audioPlayer == nil) {
        [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:self.navigationController.navigationBarHidden];
        if (self.navigationController.navigationBarHidden) {
            [UIView animateWithDuration:0.3 animations:^{
                [_bottomView setFrame:CGRectMake(0, self.view.height, self.view.width, _bottomView.height)];
                [_previewWebView setFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
                [_videoPlayer setFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [_bottomView setFrame:CGRectMake(0, self.view.height - _bottomView.height, self.view.width, _bottomView.height)];
                [_previewWebView setFrame:CGRectMake(0, 0, self.view.width, self.view.height - _bottomView.height)];
                [_videoPlayer setFrame:CGRectMake(0, 0, self.view.width, self.view.height - _bottomView.height)];
            }];
        }
    } 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _writeDataQueue = dispatch_queue_create("Write File Queue", 0);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUI)];
    [self.view addGestureRecognizer:tap];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setTitle:@"文件预览"];
    
    _openOtherButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 7, 30, 30)];
    [_openOtherButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_openOtherButton setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f1cd" size:24 color:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1/1.0]]] forState:UIControlStateNormal];
    [_openOtherButton addTarget:self action:@selector(openWithOthers:) forControlEvents:UIControlEventTouchUpInside];
    _openOtherButton.enabled = NO;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_openOtherButton];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    [self initBottomView];
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    _fileName = [infoDic objectForKey:@"FileName"];
    
    NSString *downLoad = [[QIMKit sharedInstance] getDownloadFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downLoad] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:downLoad withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileUrl = [infoDic objectForKey:@"HttpUrl"];
    if (![fileUrl qim_hasPrefixHttpHeader]) {
        fileUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_HttpHost], fileUrl];
    }
    _fileForwardTempPath = [downLoad stringByAppendingPathComponent:[NSString stringWithFormat:@"FileForwardTemp"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_fileForwardTempPath] == YES) {
        [[NSFileManager defaultManager] removeItemAtPath:_fileForwardTempPath error:nil];
    }
    NSString *fileMd5 = [[QIMKit sharedInstance] getFileNameFromUrl:fileUrl];
    if (!fileMd5.length) {
        fileMd5 = [infoDic objectForKey:@"FileMd5"];
    }
    NSString *fileExt = [[QIMKit sharedInstance] getFileExtFromUrl:fileUrl];
    if (!fileExt.length) {
        fileExt = [_fileName pathExtension];
        fileMd5 = [NSString stringWithFormat:@"%@.%@", fileMd5, fileExt];
    }
    _filePath = [downLoad stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileMd5 ? fileMd5 : @""]];
    {
        _downloadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-_bottomView.top)];
        [_downloadView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [self.view addSubview:_downloadView];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - 60)/2.0, 100, 60, 60)];
        [iconView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [iconView setImage:[QIMFileIconTools getFileIconWihtExtension:_fileName.pathExtension]];
        [_downloadView addSubview:iconView];
        
        UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.bottom + 10, self.view.width, 40)];
        [fileNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleWidth];
        [fileNameLabel setBackgroundColor:[UIColor clearColor]];
        [fileNameLabel setTextColor:[UIColor blackColor]];
        [fileNameLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [fileNameLabel setTextAlignment:NSTextAlignmentCenter];
        [fileNameLabel setNumberOfLines:2];
        [fileNameLabel setText:_fileName];
        [_downloadView addSubview:fileNameLabel];
        
        UILabel *fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, fileNameLabel.bottom + 10, self.view.width, 20)];
        [fileSizeLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleWidth];
        [fileSizeLabel setBackgroundColor:[UIColor clearColor]];
        [fileSizeLabel setTextColor:[UIColor lightGrayColor]];
        [fileSizeLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [fileSizeLabel setTextAlignment:NSTextAlignmentCenter];
        [fileSizeLabel setText:[infoDic objectForKey:@"FileSize"]];
        [_downloadView addSubview:fileSizeLabel];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, fileSizeLabel.bottom+20, self.view.width, 20)];
        [infoLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
        [infoLabel setBackgroundColor:[UIColor clearColor]];
        [infoLabel setTextColor:[UIColor blackColor]];
        [infoLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [infoLabel setTextAlignment:NSTextAlignmentCenter];
        [infoLabel setText:@"当前文件不支持在线浏览，请先下载文件。"];
        [_downloadView addSubview:infoLabel];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:nil]) {

        _downloadComplate = NO;
        [_deleteButton setHidden:YES];
        [_downLoadButton setHidden:NO];
    } else {
        _downloadComplate = YES;
        [_downloadView setHidden:YES];
        [_deleteButton setHidden:NO];
        [_downLoadButton setHidden:YES];
        
        [self showFile];
    }
}

- (void)dealloc {
    
    [_downloadRequest clearDelegatesAndCancel];
    if (!_downloadComplate)
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
}

- (void)showFile {
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    
    if ([QIMFileIconTools getFileTypeByFileExtension:_fileName.pathExtension] == FileType_Video) {
        _hasFile = YES;
        _openOtherButton.enabled = YES;
        _videoPlayer = [[QIMMoviePlayer alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _bottomView.top)];
        [_videoPlayer setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_videoPlayer setVideoPath:_filePath];
        [_videoPlayer setVideoUrl:_filePath];
        [self.view addSubview:_videoPlayer];
    } else if ([QIMFileIconTools getFileTypeByFileExtension:_fileName.pathExtension] == FileType_Audio){
        _hasFile = NO;
        _audioPlayer = [[QIMAudioPlayer alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _bottomView.top)];
        [_audioPlayer setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_audioPlayer setAudioPath:_filePath];
        [_audioPlayer setAudioName:_fileName];
        [_audioPlayer play];
        [self.view addSubview:_audioPlayer];
    } else {
        _hasFile = YES;
        _openOtherButton.enabled = YES;
        [self initWebView];
        [self loadFilePath:_filePath inView:_previewWebView];
    }
}


- (void)openWithOthers:(id)sender {
    NSString *downLoad = [[QIMKit sharedInstance] getDownloadFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downLoad] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:downLoad withIntermediateDirectories:YES attributes:nil error:nil];
    }
    _fileForwardTempPath = [downLoad stringByAppendingPathComponent:[NSString stringWithFormat:@"FileForwardTemp"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_fileForwardTempPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_fileForwardTempPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    _fileForwardTempPath = [_fileForwardTempPath stringByAppendingPathComponent:_fileName];
    [[NSFileManager defaultManager] copyItemAtPath:_filePath toPath:_fileForwardTempPath error:nil];
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:_fileForwardTempPath]];
    _documentController.name = _fileName;
//    _documentController.delegate = self;
//    _documentController.UTI = @"com.microsoft.word.xlsx";
     [_documentController presentOptionsMenuFromRect:CGRectZero inView:self.view  animated:YES];

}

#pragma mark - asi http request delegate

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    QIMVerboseLog(@"didReceiveResponseHeaders %@",responseHeaders);
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    if (request.responseStatusCode == 200) {
        if (_writeDataQueue == nil) {
            _writeDataQueue = dispatch_queue_create("Write File Queue", 0);
        }
        dispatch_async(_writeDataQueue, ^{
            if (_fileHandle == nil) {
                [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
                _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
            }
            [_fileHandle truncateFileAtOffset:_fileOffset];
            [_fileHandle writeData:data];
            _fileOffset += data.length;
        });
        float value = _fileOffset * 1.0 / request.contentLength;
        [_progressView setProgress:value animated:YES];
    } else {
        QIMVerboseLog(@"FilePreViewVc didReceiveData : %@, StatusCode : %d", request, request.responseStatusCode);
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    if (request.responseStatusCode == 200) {
        QIMVerboseLog(@"finished");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_fileHandle synchronizeFile];
            _downloadComplate = YES;
            [_deleteButton setHidden:NO];
            [_downLoadButton setHidden:YES];
            [_downloadView setHidden:YES];
            [_progressBgView setHidden:YES];
            [_bottomView setHidden:NO];
            [self showFile];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDownloadFileComplete
                                                                object:self.message.messageId];
            [_downloadRequest setDelegate:nil];
            [_downloadRequest setDownloadProgressDelegate:nil];
            _downloadRequest = nil;
            [_fileHandle closeFile];
            _fileHandle = nil;
        });
    } else {
        QIMVerboseLog(@"FilePreViewVc requestFinished : %@, StatusCode : %d", request, request.responseStatusCode);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    QIMVerboseLog(@"requestFailed");
    [_downloadRequest setDelegate:nil];
    [_downloadRequest setDownloadProgressDelegate:nil];
    _downloadRequest = nil;
    [_fileHandle closeFile];
    _fileHandle = nil;
}

#pragma mark - asi http request progress delegate

- (void)setProgress:(float)newProgress {
    QIMVerboseLog(@"Down File %f",newProgress);
}

// Called when the request receives some data - bytes is the length of that data
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
//    QIMVerboseLog(@"didReceiveBytes %lld", bytes);
    
//    if (bytes > _currentOffset) {
    _currentOffset = bytes;
        
//        float value = _currentOffset*1.0/_requestLength;
//    
//    if ([_progressView progress] <= value){
//        [_progressView setProgress:value];
//    }
//    }
}

// Called when the request sends some data
// The first 32KB (128KB on older platforms) of data sent is not included in this amount because of limitations with the CFNetwork API
// bytes may be less than zero if a request needs to remove upload progress (probably because the request needs to run again)
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
    QIMVerboseLog(@"didSendBytes %lld", bytes);
//    _currentOffset = bytes;
}

// Called when a request needs to change the length of the content to download
- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength{
    QIMVerboseLog(@"incrementDownloadSizeBy %lld", newLength);
    _requestLength += newLength;
}

// Called when a request needs to change the length of the content to upload
// newLength may be less than zero when a request needs to remove the size of the internal buffer from progress tracking
- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength{
    QIMVerboseLog(@"incrementUploadSizeBy %lld", newLength);
    _requestLength += newLength;
}
#pragma mark - init ui

- (void)onRepeatButton:(UIButton *)sender{
    QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
    [controller setMessage:self.message];
    if ([[QIMKit sharedInstance] getIsIpad]){
        [[[[UIApplication sharedApplication].delegate window] rootViewController] presentViewController:nav animated:YES completion:nil];
    }else{
        [[self navigationController] presentViewController:nav animated:YES completion:^{
        }];
    }
}

- (void)onDownloadButton:(UIButton *)sender{
    [_progressBgView setHidden:NO];
    [_bottomView setHidden:YES];
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    NSString *fileUrl = [infoDic objectForKey:@"HttpUrl"];
    if (![fileUrl qim_hasPrefixHttpHeader]) {
        fileUrl =  [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", fileUrl];
    }
    NSURL *url = [NSURL URLWithString:fileUrl];
    
    _downloadRequest = [[ASIHTTPRequest alloc] initWithURL:url];
    _downloadRequest.showAccurateProgress = YES;
    [_downloadRequest setDelegate:self];
    [_downloadRequest setDownloadProgressDelegate:self];
    [_downloadRequest startAsynchronous];
}

- (void)onDeleteButton:(UIButton *)sender{
    [_videoPlayer stop];
    _fileOffset = 0;
    _currentOffset = 0;
    _requestLength = 0;
    [_progressView setProgress:0.0];
    [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDownloadFileComplete
                                                        object:self.message.messageId];
    _openOtherButton.enabled = NO;
    [_downLoadButton setHidden:NO];
    [_deleteButton setHidden:YES];
    [_videoPlayer removeFromSuperview];
    [_audioPlayer removeFromSuperview];
    [_downloadView setHidden:NO];
    _downloadComplate = NO;
}

- (void)onCancelButton:(UIButton *)sender{
    
    [_downloadRequest clearDelegatesAndCancel];
    _downloadRequest = nil;
    _fileOffset = 0;
    _currentOffset = 0;
    _requestLength = 0;
    [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDownloadFileComplete
                                                        object:self.message.messageId];
    [_deleteButton setHidden:YES];
    [_downLoadButton setHidden:NO];
    [_downloadView setHidden:NO];
    [_progressBgView setHidden:YES];
    [_bottomView setHidden:NO];
    _downloadComplate = NO;
    [_progressView setProgress:0.0];
}

- (void)initBottomView{
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 40, self.view.width, 40)];
    [_bottomView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.view addSubview:_bottomView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5)];
    [lineView setBackgroundColor:[UIColor grayColor]];
    [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_bottomView addSubview:lineView];
    
    CGFloat width = self.view.width / 2.0;
    
    _repeatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_repeatButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [_repeatButton setFrame:CGRectMake(0, 0, width, _bottomView.height)];
    [_repeatButton setTitle:@"转发" forState:UIControlStateNormal];
    [_repeatButton addTarget:self action:@selector(onRepeatButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_repeatButton];
    
    _downLoadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_downLoadButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [_downLoadButton setFrame:CGRectMake(width, 0, width, _bottomView.height)];
    [_downLoadButton setTitle:@"下载到本机" forState:UIControlStateNormal];
    [_downLoadButton addTarget:self action:@selector(onDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_downLoadButton];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_deleteButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [_deleteButton setFrame:CGRectMake(width, 0, width, _bottomView.height)];
    [_deleteButton setTitle:@"从本机删除" forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(onDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_deleteButton];
    
    _progressBgView = [[UIView alloc] initWithFrame:_bottomView.frame];
    [_progressBgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_progressBgView setHidden:YES];
    [_progressBgView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_progressBgView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5)];
    [lineView setBackgroundColor:[UIColor grayColor]];
    [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_progressBgView addSubview:lineView];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, (_progressBgView.height - 2)/2.0, _progressBgView.width - 60, 2)];
    [_progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [_progressBgView addSubview:_progressView];
    
    _cancelDownButton = [[UIButton alloc] initWithFrame:CGRectMake(_progressView.right + 10, 0, 40, 40)];
    [_cancelDownButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [_cancelDownButton setImage:[UIImage imageNamed:@"cancel_down"] forState:UIControlStateNormal];
    [_cancelDownButton setImage:[UIImage imageNamed:@"cancel_down_pressed"] forState:UIControlStateHighlighted];
    [_cancelDownButton addTarget:self action:@selector(onCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [_progressBgView addSubview:_cancelDownButton];
}

- (void)tempClick {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (void)initWebView{
    
    _previewWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _bottomView.top)];
    [_previewWebView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_previewWebView setDelegate:self];
    [_previewWebView setScalesPageToFit:YES];
    [_previewWebView setMultipleTouchEnabled:YES]; 
    [self.view addSubview:_previewWebView];
}

- (void)loadFileError {
    _hasFile = NO;
    [_previewWebView removeFromSuperview];
    _previewWebView = nil;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    
    _downloadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-_bottomView.height)];
    [_downloadView setBackgroundColor:[UIColor whiteColor]];
    [_downloadView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.view addSubview:_downloadView];
    
    NSString *fileName = [infoDic objectForKey:@"FileName"];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - 60)/2.0, 100, 60, 60)];
    [iconView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [iconView setImage:[QIMFileIconTools getFileIconWihtExtension:fileName.pathExtension]];
    [_downloadView addSubview:iconView];
    
    UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.bottom + 10, self.view.width, 40)];
    [fileNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth];
    [fileNameLabel setBackgroundColor:[UIColor clearColor]];
    [fileNameLabel setTextColor:[UIColor blackColor]];
    [fileNameLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [fileNameLabel setTextAlignment:NSTextAlignmentCenter];
    [fileNameLabel setNumberOfLines:2];
    [fileNameLabel setText:fileName];
    [_downloadView addSubview:fileNameLabel];
    
    UILabel *fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, fileNameLabel.bottom + 10, self.view.width, 20)];
    [fileSizeLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth];
    [fileSizeLabel setBackgroundColor:[UIColor clearColor]];
    [fileSizeLabel setTextColor:[UIColor lightGrayColor]];
    [fileSizeLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [fileSizeLabel setTextAlignment:NSTextAlignmentCenter];
    [fileSizeLabel setText:[infoDic objectForKey:@"FileSize"]];
    [_downloadView addSubview:fileSizeLabel];
    
    UIButton *otherAppOpenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    otherAppOpenBtn.frame = CGRectMake(20, fileSizeLabel.bottom + 20, self.view.width - 40, 60);
    otherAppOpenBtn.backgroundColor = [UIColor qtalkIconSelectColor];
    [otherAppOpenBtn addTarget:self action:@selector(openWithOthers:) forControlEvents:UIControlEventTouchUpInside];
    [otherAppOpenBtn setTitle:@"用其他应用打开" forState:UIControlStateNormal];
    [_downloadView addSubview:otherAppOpenBtn];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, otherAppOpenBtn.bottom+20, self.view.width, 40)];
    [infoLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextColor:[UIColor qunarTextGrayColor]];
    [infoLabel setFont:[UIFont systemFontOfSize:12]];
    [infoLabel setNumberOfLines:0];
    [infoLabel setTextAlignment:NSTextAlignmentCenter];
    [infoLabel setText:[NSString stringWithFormat:@"%@%@", [QIMKit getQIMProjectTitleName], @"暂不支持打开此类文件 \n 可使用前其他应用打开并预览"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUI)];
    [_downloadView addGestureRecognizer:tap];
    [_downloadView addSubview:infoLabel];
}

- (void)loadFilePath:(NSString*)filePath inView:(UIWebView*)webView {
    if (filePath.length >= 0) {
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        NSString *MIMEType = [response MIMEType];
        QIMVerboseLog(@"WebView 预览文件: %@, MiMEType : %@", filePath, MIMEType);
        NSData *tempData = [NSData dataWithContentsOfFile:filePath];
        //将数据传给webView显示，并且告知文档类型、编码格式
        [webView loadData:tempData MIMEType:MIMEType textEncodingName:@"UTF-8" baseURL:nil];
    } else {
        [self loadFileError];
    }
}

#pragma mark - webview delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self loadFileError];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (_hasFile) {
        return YES;
    } else {
        return UIInterfaceOrientationPortrait == toInterfaceOrientation;
    }
}

- (BOOL)shouldAutorotate
{
    return _hasFile;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    UIInterfaceOrientation orientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
        {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            orientation = UIInterfaceOrientationLandscapeLeft;
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
            break;
        default:
        {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
    }
    return orientation;
}

@end
