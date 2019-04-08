//
//  QIMZipArchive.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/10/11.
//

#import <Foundation/Foundation.h>

@interface QIMZipArchive : NSObject

+ (instancetype)sharedInstance;

/**
 压缩文件
 
 @param paramFiles 待压缩的文件Path(数组)
 @param toFilePath 压缩后的路径
 @param zipFileName 压缩后文件名
 @param password    压缩密码
 @return 压缩后文件路径
 */
- (NSString *)zipFiles:(NSArray *)paramFiles ToFile:(NSString *)toFilePath ToZipFileName:(NSString *)zipFileName WithZipPassword:(NSString *)password;

@end
