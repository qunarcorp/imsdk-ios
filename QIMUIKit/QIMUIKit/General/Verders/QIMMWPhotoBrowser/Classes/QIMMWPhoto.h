//
//  QIMMWPhoto.h
//  QIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <Photos/Photos.h>
#import "QIMMWPhotoProtocol.h"

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to QIMMWPhotoProtocol
@interface QIMMWPhoto : NSObject <QIMMWPhoto>

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSData *photoData;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;
@property (nonatomic, strong) NSDictionary *extendInfo;
@property (nonatomic, strong) id photoMsg;

+ (QIMMWPhoto *)photoWithImage:(UIImage *)image;
+ (QIMMWPhoto *)photoWithURL:(NSURL *)url;
+ (QIMMWPhoto *)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (QIMMWPhoto *)videoWithURL:(NSURL *)url; // Initialise video with no poster image

- (id)init;
- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;
- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
- (id)initWithVideoURL:(NSURL *)url;

@end

