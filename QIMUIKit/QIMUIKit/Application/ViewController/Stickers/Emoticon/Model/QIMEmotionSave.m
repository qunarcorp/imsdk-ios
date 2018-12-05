//
//  QIMEmotionSave.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#import "QIMEmotionSave.h"

static QIMEmotionSave *__EmotionSave = nil;

@implementation QIMEmotionSave

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        __EmotionSave = [[QIMEmotionSave alloc] init];
    });
    
    return __EmotionSave;
}

- (NSString *)getEmotionInfoDataPath {
    
    // 判断cache文件夹
    
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kEmotionPathResource];
    
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:@"EmotionPackageIdList.info"];

    return resourcePath;
}

- (void)saveEmotionDownloadData:(id)data {
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kEmotionPathResource];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:@"EmotionPackageIdList.info"];
    [data writeToFile:resourcePath atomically:YES];
}

//字典转data
- (NSData *)returnDataWithDictionary:(NSDictionary *)dict
{
    NSMutableData * data = [[NSMutableData alloc] init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:@"talkData"];
    [archiver finishEncoding];
    
    return data;
}

@end
