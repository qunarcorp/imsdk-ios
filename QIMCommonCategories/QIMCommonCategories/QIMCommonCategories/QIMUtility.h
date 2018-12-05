//
//  QIMUtility.h
//  QunarUGC
//
//  Created by zhao yan on 12-8-8.
//  Copyright (c) 2012年 qunar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

@interface QIMUtility : NSObject

+ (NSString *)getFullWeekend:(NSInteger)index;

+ (NSData *)uncompress:(NSData *)data withUncompressedDataLength:(NSUInteger)length;

+ (NSString *)encrypt:(NSString *)text withKey:(NSString *)key;

// 改变图片大小
+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize;

+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewsize;

+ (UIImage *)squareImage:(UIImage *)image width:(CGFloat)width;

+ (NSString *)date2Interval:(NSString *)dateString;

// 根据版本使用不同的参数
+ (UIImage *)adjustImageFillSize:(NSString *)imageWithName capInsets:(UIEdgeInsets)capInsets;

// 相册图片经纬度
+ (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location;

+ (void)performInBackground:(dispatch_block_t)block;

// 判断字符串

+ (BOOL)isPureNumandCharacters:(NSString *)string;

+ (BOOL)isTelphoneNo:(NSString *)str;

//
// 获取目录内文件大小

+ (long long) sizeofPath:(NSString *) filePath;

@end
