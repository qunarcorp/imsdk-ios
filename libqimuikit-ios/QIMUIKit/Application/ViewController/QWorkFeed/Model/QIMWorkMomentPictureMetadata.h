//
//  QIMWorkMomentPictureMetadata.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

/// 图片标记
typedef NS_ENUM(NSUInteger, MHPictureBadgeType) {
    MHPictureBadgeTypeNone = 0, ///< 正常图片
    MHPictureBadgeTypeLong,     ///< 长图
    MHPictureBadgeTypeGIF,      ///< GIF
};

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentPictureMetadata : NSObject

/// < Full image url
@property (nonatomic, readwrite, strong) NSURL *url;
/// < pixel width
@property (nonatomic, readwrite, assign) int width;
/// < pixel height
@property (nonatomic, readwrite, assign) int height;
/// < "WEBP" "JPEG" "GIF"
@property (nonatomic, readwrite, copy) NSString *type;
/// < Default:1
@property (nonatomic, readwrite, assign) int cutType;
/// 图片标记 （正常 GIF 长图）
@property (nonatomic, readwrite, assign) MHPictureBadgeType badgeType;

@end

NS_ASSUME_NONNULL_END
