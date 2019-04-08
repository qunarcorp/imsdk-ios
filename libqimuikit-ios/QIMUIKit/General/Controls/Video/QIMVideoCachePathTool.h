//
//  QIMVideoCachePathTool.h
//  QTalkVideoPlayerDemo
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.


#import "QIMCommonUIFramework.h"

#define QTalk_tempPath [UserCachesPath stringByAppendingString:@"/QTalkVideoPlayer_temp"]
#define QTalk_savePath [UserCachesPath stringByAppendingString:@"/QTalkVideoPlayer_Save"]

@interface QIMVideoCachePathTool : NSObject

/**
  临时文件存储路径
 */
+(NSString *)fileCachePath;

/**
  完整文件存储路径
 */
+(NSString *)fileSavePath;

/**
  缓存的文件名字
 */
+(NSString *)suggestFileNameWithURL:(NSURL*)url;

@end
