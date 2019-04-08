//
//  QIMKit+QIMFileManager.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@class Message;
typedef void(^QIMFileManagerUploadCompletionBlock)(UIImage *image, NSError *error, QIMFileCacheType cacheType, NSString *imageURL);

@interface QIMKit (QIMFileManager)


/**
 根据文件URL获取文件后缀

 @param url 文件URL
 @return 文件后缀
 */
+ (NSString *) urlpathExtension:(NSString *) url;

+ (NSString *) documentsofPath:(QIMFileCacheType) type;

/**
 文件上传
 
 @param filePath 文件路径
 @param message 消息
 @param jid user id
 @param flag 是文件还是图片
 @return 文件url
 */
- (NSString *)uploadFileForPath:(NSString *)filePath forMessage:(Message *)message withJid:(NSString *)jid isFile:(BOOL)flag;

/**
 文件上传

 @param fileData 文件二进制
 @param message 消息
 @param jid 用户Id
 @param flag 是文件还是图片
 @return 文件URL
 */
- (NSString *)uploadFileForData:(NSData *)fileData forMessage:(Message *)message withJid:(NSString *)jid isFile:(BOOL)flag;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag fileExt:(NSString *)fileExt completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock;

- (void )downloadFileWithUrl:(NSString *)url isFile:(BOOL)flag forCacheType:(QIMFileCacheType)type;


/**
 下载图片

 @param url 图片URL
 @param width 图片width
 @param height 图片height
 @param type 图片缓存类型
 */
-(void)downloadImage:(NSString *)url width:(CGFloat) width height:(CGFloat) height  forCacheType:(QIMFileCacheType)type;


/**
 下载图片

 @param url 图片URL
 @param width 图片width
 @param height 图片height
 @param type 图片缓存类型
 @param complation 下载成功的回调
 */
-(void)downloadImage:(NSString *)url
               width:(CGFloat) width
              height:(CGFloat) height
        forCacheType:(QIMFileCacheType)type
          complation:(void(^)(NSData *)) complation;

-(void)downloadCollectionEmoji:(NSString *)url
                         width:(CGFloat) width
                        height:(CGFloat) height
                  forCacheType:(QIMFileCacheType)type
                    complation:(void(^)(NSData *)) complation;

//- (NSData *) getSmallFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type;

/**
 缓存文件
 
 @param data 文件data
 @param fileName 文件名称
 @param type 缓存类型
 @return 返回path
 */
- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl forCacheType:(QIMFileCacheType)type;

/**
 缓存文件
 
 @param data 文件data
 @param httpUrl 远程链接
 @param width 宽
 @param height 高
 @param type 缓存类型
 @return 返回path
 */
- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl  width:(CGFloat) width height:(CGFloat) height forCacheType:(QIMFileCacheType)type;

/**
 获取文件path
 
 @param fileName 文件名
 @param type 缓存类型
 @return 返回path
 */
- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type;

/**
 获取文件path

 @param fileName 文件名
 @param type 缓存类型
 @param careExist 是否关心文件已存在
 @return 返回Path
 */
- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type careExist:(BOOL) careExist;

/**
 *  临时文件URL调明星接口换取持久化URL
 *
 *  @param tempUrl 临时URL
 */
- (void )getPermUrlWithTempUrl:(NSString *)tempUrl PermHttpUrl:(void(^)(NSString *))callBackPermUrl;

/**
 文件是否存在
 
 @param url 文件url
 @param width 宽
 @param height 高
 @param type 缓存类型
 @return 返回是否存在
 */
- (BOOL)isFileExistForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type;

- (NSString *)fileExistLocalPathForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type;

- (NSString *)getNewMd5ForMd5:(NSString *)oldMd5 withWidth:(float)width height:(float)height;

/**
 获取file data
 
 @param fileName file名称
 @param type file缓存类型
 @return 返回file data
 */
- (NSData *) getFileDataForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type;

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type;

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type needUpdate:(BOOL)update;

- (NSData *) getFileDataFromUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type;

- (CGSize)getImageSizeFromUrl:(NSString *)url;

- (NSString *) getFileNameFromKey:(NSString *)url;

/**
 *  根据URL获得文件名
 *
 *  @param url URL
 */
- (NSString *) getFileNameFromUrl:(NSString *)url;

- (NSString *) getFileExtFromUrl:(NSString *) url;

- (NSString *) md5fromUrl:(NSString *) url;

/**
 根据URL获得文件名

 @param url 图片URL
 @param width 图片width
 @param height 图片height
 @return 图片文件名
 */
- (NSString *) getFileNameFromUrl:(NSString *)url width:(CGFloat) width height:(CGFloat) height;

/**
 获取图片后缀
 
 @param data data
 @return 返回图片后缀
 */
- (NSString *)getImageFileExt:(NSData *)data;

- (NSString *)getMD5FromFileData:(NSData *)fileData;

/**
 获取图片size
 
 @param imgSize 原图片size
 @return 缩略图size
 */
- (CGSize)getFitSizeForImgSize:(CGSize)imgSize;

@end
