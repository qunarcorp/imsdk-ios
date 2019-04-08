//
//  QIMVideoDownloadManager.h
//  QTalkVideoPlayer
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.


#import "QIMCommonUIFramework.h"
#import <AVFoundation/AVFoundation.h>

@class QIMVideoDownloadManager;

@protocol QIMVideoDownloadManagerDelegate <NSObject>

@optional


/**
 视频文件开始下载

 @param manager manager
 @param videoLength 视频文件长度
 @param mimeType 视频文件类型
 */
- (void)manager:(QIMVideoDownloadManager *)manager didReceiveVideoLength:(NSUInteger)videoLength mimeType:(NSString *)mimeType;

/**
 视频文件下载成功

 @param manager manager
 @param filePath 保存的路径
 */
- (void)didFinishLoadingWithManager:(QIMVideoDownloadManager *)manager fileSavePath:(NSString *)filePath;

/**
 视频文件下载失败

 @param manager manager
 @param errorCode 错误码
 */
- (void)didFailLoadingWithManager:(QIMVideoDownloadManager *)manager WithError:(NSError *)errorCode;

/**
 视频文件下载中。。。

 @param manager manager
 @param data 已下载的视频文件data
 @param offset 已下载视频的偏移量
 @param filePath 视频文件临时存储路径
 */
-(void)manager:(QIMVideoDownloadManager *)manager didReceiveData:(NSData *)data downloadOffset:(NSInteger)offset tempFilePath:(NSString *)filePath;

@end


@interface QIMVideoDownloadManager : NSObject

/**
 视频文件URL
 */
@property (nonatomic, strong, readonly) NSURL *url;

/**
 已下载视频文件的偏移量
 */
@property (nonatomic, readonly) NSUInteger offset;

/**
 视频文件总长度
 */
@property (nonatomic, readonly) NSUInteger fileLength;

/**
  当前下载了的文件的位置
 */
@property (nonatomic, readonly) NSUInteger downLoadingOffset;

/**
  视频文件mineType 类型
 */
@property (nonatomic, strong, readonly) NSString *mimeType;

/**
  视频文件是否已经下载完成
 */
@property (nonatomic, assign)BOOL isFinishLoad;

@property(nonatomic, weak)id<QIMVideoDownloadManagerDelegate> delegate;

- (void)setUrl:(NSURL *)url offset:(long long)offset;

/**
 取消当前下载queue
 */
- (void)invalidateAndCancel;

@end
