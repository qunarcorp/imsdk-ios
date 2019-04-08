//
//  QIMWorkMomentPicture.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMWorkMomentPictureMetadata.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentPicture : NSObject

//图片地址
@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, assign) long long addTime;

@property (nonatomic, assign) NSInteger imageWidth;

@property (nonatomic, assign) NSInteger imageHeight;

///// 图片模型id
//@property (nonatomic, readwrite, copy) NSString *picID;
//@property (nonatomic, readwrite, copy) NSString *objectID;
//@property (nonatomic, readwrite, assign) int photoTag;
///// < YES:固定为方形 NO:原始宽高比
//@property (nonatomic, readwrite, assign) BOOL keepSize;
///// < w:180
//@property (nonatomic, readwrite, strong) QIMWorkMomentPictureMetadata *thumbnail;
///// < w:360 (列表中的缩略图)
//@property (nonatomic, readwrite, strong) QIMWorkMomentPictureMetadata *bmiddle;
///// < w:480
//@property (nonatomic, readwrite, strong) QIMWorkMomentPictureMetadata *middlePlus;
///// < w:720 (放大查看)
//@property (nonatomic, readwrite, strong) QIMWorkMomentPictureMetadata *large;
///// < (查看原图)
//@property (nonatomic, readwrite, strong) QIMWorkMomentPictureMetadata *largest;
///// < 原图
//@property (nonatomic, readwrite, strong) QIMWorkMomentPictureMetadata *original;
///// 图片标记类型
//@property (nonatomic, readwrite, assign) MHPictureBadgeType badgeType;

@end

NS_ASSUME_NONNULL_END
