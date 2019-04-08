//
//  QIMVideoCacheManager.h
//  QTalkVideoPlayerDemo
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.
//

#import "QIMCommonUIFramework.h"

typedef void(^QTalkCacheQueryCompletedBlock)(unsigned long long);

@interface QIMVideoCacheManager : NSObject

/**
 * 清除指定URL的缓存视频文件(异步).
 */
+(void)clearVideoCacheForUrl:(NSURL *)url;

/**
 * 清除所有的缓存(异步)
 */
+(void)clearAllVideoCache;

/**
 * 获取缓存总大小(异步)
 */
+(void)getSize:(QTalkCacheQueryCompletedBlock)completedOperation;

@end
