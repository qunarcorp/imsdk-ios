//
//  QIMVideoURLAssetResourceLoader.m
//  QTalkVideoPlayer
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.



#import "QIMVideoURLAssetResourceLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "QIMVideoDownloadManager.h"
#import "QIMVideoCachePathTool.h"

@interface QIMVideoURLAssetResourceLoader()<QIMVideoDownloadManagerDelegate>

/** 下载器 */
@property (nonatomic, strong)QIMVideoDownloadManager *manager;

/** 请求队列 */
@property (nonatomic, strong)NSMutableArray *pendingRequests;

@property (nonatomic, strong)NSString *videoPath;

/** 文件名 */
@property(nonatomic, strong)NSString *suggestFileName;

@end


@implementation QIMVideoURLAssetResourceLoader

- (instancetype)init{
    self = [super init];
    if (self) {
        _pendingRequests = [NSMutableArray array];
    }
    return self;
}


#pragma mark -----------------------------------------
#pragma mark Public

- (NSURL *)getSchemeVideoURL:(NSURL *)url{
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"systemCannotRecognition";
    
    NSString *path = QTalk_tempPath;
    NSString *suggestFileName = [QIMVideoCachePathTool suggestFileNameWithURL:url];
    path = [path stringByAppendingPathComponent:suggestFileName];
    _videoPath = path;
    
    return [components URL];
}

-(void)invalidDownload{
    [self.manager invalidateAndCancel];
    self.manager = nil;
}


#pragma mark -----------------------------------------
#pragma mark AVAssetResourceLoaderDelegate

/**
  必须返回Yes，如果返回NO，则resourceLoader将会加载出现故障的数据
  @param resourceLoader 资源管理器
  @param loadingRequest 每一小块数据的请求
 */
-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    if (resourceLoader && loadingRequest) {
        [self.pendingRequests addObject:loadingRequest];
        [self dealLoadingRequest:loadingRequest];
    }
   
    return YES;
}

-(void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self.pendingRequests removeObject:loadingRequest];
}


#pragma mark -----------------------------------------
#pragma mark Private

- (void)dealLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
  
    NSURL *interceptedURL = [loadingRequest.request URL];
    
    if (self.manager) {
        if (self.manager.downLoadingOffset > 0)
            [self processPendingRequests];
    }
    else{
        self.manager = [QIMVideoDownloadManager new];
        self.manager.delegate = self;
        [self.manager setUrl:interceptedURL offset:0];
    }
}

- (void)processPendingRequests{
    
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests) {
        
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
        
        if (didRespondCompletely) {
            [requestsCompleted addObject:loadingRequest];
            [loadingRequest finishLoading];
        }
    }
    [self.pendingRequests removeObjectsInArray:[requestsCompleted copy]];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest{
    
    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    NSData *fileData = [NSData dataWithContentsOfFile:_videoPath options:NSDataReadingMappedIfSafe error:nil];
    NSInteger unreadBytes = self.manager.downLoadingOffset - self.manager.offset - (NSInteger)startOffset;
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    NSUInteger totalLength = startOffset - self.manager.offset + numberOfBytesToRespondWith;
    if (fileData.length >= totalLength) {
        [dataRequest respondWithData:[fileData subdataWithRange:NSMakeRange((NSUInteger)startOffset- self.manager.offset, (NSUInteger)numberOfBytesToRespondWith)]];
        
        long long endOffset = startOffset + dataRequest.requestedLength;
        BOOL didRespondFully = (self.manager.offset + self.manager.downLoadingOffset) >= endOffset;
        return didRespondFully;
    }
    return NO;
}

-(void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest{
    NSString *mimetype = self.manager.mimeType;
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(mimetype), NULL);
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = self.manager.fileLength;
}


#pragma mark -----------------------------------------
#pragma mark QIMVideoDownloadManagerDelegate

-(void)manager:(QIMVideoDownloadManager *)manager didReceiveData:(NSData *)data downloadOffset:(NSInteger)offset tempFilePath:(NSString *)filePath{
    [self processPendingRequests];
}

-(void)didFinishLoadingWithManager:(QIMVideoDownloadManager *)manager fileSavePath:(NSString *)filePath{
    
    _videoPath = filePath;
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingWithManager:fileSavePath:)]) {
        [self.delegate didFinishLoadingWithManager:manager fileSavePath:filePath];
    }
}

-(void)didFailLoadingWithManager:(QIMVideoDownloadManager *)manager WithError:(NSError *)errorCode{
    if ([self.delegate respondsToSelector:@selector(didFailLoadingWithManager:WithError:)]) {
        [self.delegate didFailLoadingWithManager:manager WithError:errorCode];
    }
}

@end
