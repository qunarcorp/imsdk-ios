//
//  QIMVideoURLAssetResourceLoader.h
//  QTalkVideoPlayer
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.



/**
 * 这个类的功能是把缓存到本地的临时数据根据播放器需要的 offset 和 length 去取出数据, 并返回给播放器
 */


#import "QIMCommonUIFramework.h"
#import <AVFoundation/AVFoundation.h>

@class QIMVideoDownloadManager;

@protocol QIMVideoURLAssetResourceLoaderDelegate <NSObject>

@optional

/**
 视频文件下载完成

 @param manager manager
 @param filePath 保存路径
 */
- (void)didFinishLoadingWithManager:(QIMVideoDownloadManager *)manager fileSavePath:(NSString *)filePath;

/**
 视频文件下载失败

 @param manager manager
 @param errorCode 错误码
 */
- (void)didFailLoadingWithManager:(QIMVideoDownloadManager *)manager WithError:(NSError *)errorCode;

@end


@interface QIMVideoURLAssetResourceLoader : NSObject<AVAssetResourceLoaderDelegate>

@property (nonatomic, weak) id<QIMVideoURLAssetResourceLoaderDelegate> delegate;

/**
  NSURLComponents用来替代NSMutableURL，可以readwrite修改URL，这里通过更改请求策略，将容量巨大的连续媒体数据进行分段，分割为数量众多的小文件进行传递。采用了一个不断更新的轻量级索引文件来控制分割后小媒体文件的下载和播放，可同时支持直播和点播
  @param url   Request url
  @return      Fixed url
 */
- (NSURL *)getSchemeVideoURL:(NSURL *)url;

-(void)invalidDownload;

@end
