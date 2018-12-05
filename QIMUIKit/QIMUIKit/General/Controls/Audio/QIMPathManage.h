//
//  QIMPathManage.h
//  AudioTempForQT
//
//  Created by danzheng on 15/4/21.
//  Copyright (c) 2015年 fresh. All rights reserved.
//
//  用于管理文件路径，将vedio文件统一存储，Document目录下Voices保存发送出去的文件，VoicesReceived保存接收到的数据

#import "QIMCommonUIFramework.h"

@interface QIMPathManage : NSObject

+ (NSString*)getCurrentTimeString;
+ (NSString*)getCacheDirectory;
//+ (NSString*)getReceiveCacheDirectory;
+ (BOOL)fileExistsAtPath:(NSString*)_path;
+ (BOOL)deleteFileAtPath:(NSString*)_path;
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;
+ (NSString*)getPathByFileName:(NSString *)_fileName;

+ (NSString *)getPathToSaveWithSaveData:(NSData *)dataToSave ToFileName:(NSString *)fileName ofType:(NSString *)type;
//+ (NSString*)getReceivePathByFileName:(NSString *)_fileName ofType:(NSString *)_type;

@end
