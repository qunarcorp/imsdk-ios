//
//  QIMVideoCacheManager.m
//  QTalkVideoPlayerDemo
//
//  Created by qitmac000495 on 17/1/9.
//  Copyright © 2017年 lilu. All rights reserved.
//

#import "QIMVideoCacheManager.h"
#import "QIMVideoCachePathTool.h"
#import "QIMVideoURLAssetResourceLoader.h"
#include <sys/param.h>
#include <sys/mount.h>

@implementation QIMVideoCacheManager

+ (void)clearVideoCacheForUrl:(NSURL *)url{
    
    if ([url isKindOfClass:[NSURL class]]) {
        if (url.absoluteString.length==0) {
            return;
        }
    }
    else if ([url isKindOfClass:[NSString class]]) {
        NSString *s = (NSString *)url;
        if (s.length==0) {
            return;
        }
        url = [NSURL URLWithString:s];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *savePa = [QIMVideoCachePathTool fileSavePath];
    NSString *suggestFileName = [QIMVideoCachePathTool suggestFileNameWithURL:url];
    savePa = [savePa stringByAppendingPathComponent:suggestFileName];
    if ([fileManager fileExistsAtPath:savePa]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [fileManager removeItemAtPath:savePa error:nil];
        });
    }
}

+ (void)clearAllVideoCache{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *savePa = [QIMVideoCachePathTool fileSavePath];
    NSString *tempPa = [QIMVideoCachePathTool fileCachePath];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [fileManager removeItemAtPath:savePa error:nil];
        [fileManager removeItemAtPath:tempPa error:nil];
    });
}

+ (void)getSize:(QTalkCacheQueryCompletedBlock)completedOperation{
    NSString *savePa = [QIMVideoCachePathTool fileSavePath];
    NSString *tempPa = [QIMVideoCachePathTool fileCachePath];
    NSArray *directoryPathArr = @[
                                  savePa,
                                  tempPa
                                  ];
    [self getSizeWithDirectoryPath:directoryPathArr completion:^(NSInteger totalSize) {
        if (completedOperation) {
            completedOperation(totalSize);
        }
    }];
}

+ (void)getSizeWithDirectoryPath:(NSArray *)directoryPathArr completion:(void(^)(NSInteger))completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSInteger totalSize = 0;
        for (NSString *directoryPath in directoryPathArr) {
            BOOL isDir;
            BOOL isFile = [manager fileExistsAtPath:directoryPath isDirectory:&isDir];
            if (!isDir || !isFile) {
                NSException *exc = [NSException exceptionWithName:@"FilePathError" reason:@"File not exist." userInfo:nil];
                [exc raise];
            }
            
            NSArray *subPaths = [manager subpathsAtPath:directoryPath];
            for (NSString *subPath in subPaths) {
                NSString *fullPath = [directoryPath stringByAppendingPathComponent:subPath];
                if ([fullPath containsString:@".DS"]) continue;
                BOOL isDirectory;
                BOOL isFile = [manager fileExistsAtPath:fullPath isDirectory:&isDirectory];
                if (!isFile || isDirectory) continue;
                NSDictionary *attr = [manager attributesOfItemAtPath:fullPath error:nil];
                totalSize += [attr fileSize];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(totalSize);
            }
        });
    });
}

@end
