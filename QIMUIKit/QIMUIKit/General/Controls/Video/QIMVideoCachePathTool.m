//
//  QIMVideoCachePathTool.m
//  QTalkVideoPlayerDemo
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.


#import "QIMVideoCachePathTool.h"

@implementation QIMVideoCachePathTool

// 拼接临时文件缓存存储路径
+ (NSString *)fileCachePath{
    return [QIMVideoCachePathTool getFilePathWithNewPath:QTalk_tempPath];
}

// 拼接完整文件存储路径
+ (NSString *)fileSavePath{
    return [QIMVideoCachePathTool getFilePathWithNewPath:QTalk_savePath];
}

+ (NSString *)getFilePathWithNewPath:(NSString *)newPath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 创建文件夹
    if (![fileManager fileExistsAtPath:newPath]) {
        [fileManager createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return newPath;
}

+ (NSString *)suggestFileNameWithURL:(NSURL*)url{
    NSString *md5 = [[QIMKit sharedInstance] getFileNameFromKey:[url absoluteString]];
    return [md5 stringByAppendingString:@".mp4"];
}

@end
