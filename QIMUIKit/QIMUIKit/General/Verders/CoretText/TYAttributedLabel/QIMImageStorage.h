//
//  QCDrawImageStorage.h
//  QIMAttributedLabelDemo
//
//  Created by chenjie on 16/7/7.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMDrawStorage.h"

typedef enum {
    QCImageAlignmentCenter,  // 图片居中
    QCImageAlignmentLeft,    // 图片左对齐
    QCImageAlignmentRight,   // 图片右对齐
    QCImageAlignmentFill     // 图片拉伸填充
} QCImageAlignment;

typedef enum {
    QIMImageStorageTypeImage,
    QIMImageStorageTypeGif,
    QIMImageStorageTypeEmotion,
} QIMImageStorageType;

@interface QIMImageStorage : QIMDrawStorage <QIMViewStorageProtocol>

@property (nonatomic, strong) YLGIFImage   *image;

@property (nonatomic, strong) NSString  *imageName;

@property (nonatomic, strong) NSURL     *imageURL;

@property (nonatomic, strong) NSString  *placeholdImageName;

@property (nonatomic, assign) QCImageAlignment imageAlignment; // default center

@property (nonatomic, assign) QIMImageStorageType storageType; // default center

@property (nonatomic, assign) BOOL cacheImageOnMemory; // default NO ,if YES can improve performance，but increase memory

@property (nonatomic, strong) NSDictionary        * infoDic;

@end
