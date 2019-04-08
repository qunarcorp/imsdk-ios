//
//  QIMZipArchive.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/10/11.
//

#import "QIMZipArchive.h"
#import "ZipArchive.h"
#import "QIMPublicRedefineHeader.h"

@implementation QIMZipArchive

+ (instancetype)sharedInstance {
    static QIMZipArchive *_zipArchive = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zipArchive = [[QIMZipArchive alloc] init];
    });
    return _zipArchive;
}

- (NSString *)zipFiles:(NSArray *)paramFiles ToFile:(NSString *)toFilePath ToZipFileName:(NSString *)zipFileName WithZipPassword:(NSString *)password
{
    //取得zip文件全路径
    NSString * zipPath = [toFilePath stringByAppendingPathComponent:zipFileName];
    //判断文件是否存在，如果存在则删除文件
    NSFileManager * fileManager = [NSFileManager defaultManager];
    @try
    {
        if([fileManager fileExistsAtPath:zipPath])
        {
            if(![fileManager removeItemAtPath:zipPath error:nil])
            {
                QIMVerboseLog(@"Delete zip file failure.");
            }
        }
    }
    @catch (NSException * exception) {
        QIMVerboseLog(@"%@",exception);
    }
    
    //判断需要压缩的文件是否为空
    if(paramFiles == nil || [paramFiles count] == 0)
    {
        QIMVerboseLog(@"The files want zip is nil.");
        return nil;
    }
    
    //实例化并创建zip文件
    ZipArchive * zipArchive = [[ZipArchive alloc] init];
    zipArchive.compression = ZipArchiveCompressionBest;
    if (password.length > 0) {
        [zipArchive CreateZipFile2:zipPath Password:password];
    } else {
        [zipArchive CreateZipFile2:zipPath];
    }
    
    //遍历文件
    for(NSString * filePath in paramFiles)
    {
        NSArray *fileComponentes = filePath.pathComponents;
        NSString * fileName = [fileComponentes lastObject];
        if([fileManager fileExistsAtPath:filePath])
        {   //添加文件到压缩文件
            [zipArchive addFileToZip:filePath newname:fileName];
        }
    }
    //关闭文件
    if([zipArchive CloseZipFile2])
    {
        QIMVerboseLog(@"Create zip file success.");
        return zipPath;
    }
    return nil;
}

@end
