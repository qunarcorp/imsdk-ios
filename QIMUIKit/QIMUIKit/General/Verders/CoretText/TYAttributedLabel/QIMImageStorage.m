//
//  QCDrawImageStorage.m
//  QIMAttributedLabelDemo
//
//  Created by chenjie on 16/7/7.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//

#import "QIMImageStorage.h"
#import "QIMImageCache.h"
#import "YLImageView.h"
#import "YLGIFImage.h"

@interface QIMImageStorage () {
    YLImageView * _imageView;
    CGRect        _rect;
}
@property (nonatomic, weak) UIView *ownerView;
@property (nonatomic, strong) UIView *propressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) BOOL isNeedUpdateFrame;
@end

@implementation QIMImageStorage

- (instancetype)init
{
    if (self = [super init]) {
        _cacheImageOnMemory = NO;
        NSString *placeholdImagePath = [[NSBundle mainBundle] pathForResource:@"PhotoDownload@2x" ofType:@"png"];
        _placeholdImageName = placeholdImagePath;
    }
    return self;
}

- (UIView *)propressView {
    if (!_propressView) {
        _propressView = [[UIView alloc] initWithFrame:CGRectMake(_imageView.left, _imageView.top, _imageView.width, _imageView.height)];
        _propressView.backgroundColor = [UIColor lightGrayColor];
        _propressView.alpha = 0.5;
        _propressView.hidden = YES;
        [_imageView addSubview:_propressView];
    }
    return _propressView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _propressView.width, _propressView.height)];
        [_progressLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setText:@""];
        [_progressLabel setTextAlignment:NSTextAlignmentCenter];
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [self.propressView addSubview:_progressLabel];
    }
    return _progressLabel;
}

#pragma mark - protocol

- (void)setOwnerView:(UIView *)ownerView
{
    _ownerView = ownerView;
    if (!ownerView || !_imageURL) {
        return;
    }
//    if (!ownerView || !_ownerView) {
//        _ownerView = ownerView;
//    }
    /*
    if ([_imageURL isKindOfClass:[NSURL class]]) {
        CGSize size = [[QIMKit sharedInstance] getImageSizeFromUrl:_imageURL.absoluteString];
        CGFloat width = size.width;
        CGFloat height = size.height;
        if (self.size.width >= ([UIScreen mainScreen].bounds.size.width / 2.0f) || self.size.height >= ([UIScreen mainScreen].bounds.size.height / 2.0f)) {
            width = self.size.width / 2.0f;
            height = self.size.height / 2.0f;
        }
        BOOL isExist = [[QIMKit sharedInstance] isFileExistForUrl:_imageURL.absoluteString width:width height:height forCacheType:QIMFileCacheTypeColoction];
        if (!isExist) {
            NSData *data = [[QIMKit sharedInstance] getFileDataFromUrl:_imageURL.absoluteString width:width height:height forCacheType:QIMFileCacheTypeColoction];
            if (data.length > 0) {
                NSData *data = [[QIMKit sharedInstance] getFileDataFromUrl:_imageURL.absoluteString
                                                                            width:width
                                                                           height:height
                                                                     forCacheType:QIMFileCacheTypeColoction];
                if (data) {
                    if (_isNeedUpdateFrame) {
                        if (ownerView) {
                            [ownerView setNeedsDisplay];
                        }
                        _isNeedUpdateFrame = NO;
                    }
                }
            }
        }
     }*/
/*
    if ([_imageURL isKindOfClass:[NSURL class]] && ![[QIMImageCache cache] imageIsCacheForURL:_imageURL.absoluteString]) {
        
        [[QIMImageCache cache]saveAsyncImageFromURL:_imageURL.absoluteString thumbImageSize:self.size completion:^(BOOL isCache) {
            
            if (_isNeedUpdateFrame) {
                if (ownerView && isCache) {
                    [ownerView setNeedsDisplay];
                }
                _isNeedUpdateFrame = NO;
            }
        }];
    }
     */
}

- (void)drawStorageWithRect:(CGRect)rect
{
    if (rect.size.width == 0 || rect.size.height == 0) {
        return;
    }
    _rect = rect;
    __block YLGIFImage *image = nil;
    NSData *placeHoldImageData = [NSData dataWithContentsOfFile:_placeholdImageName];
    image = placeHoldImageData.length ? [YLGIFImage imageWithData:placeHoldImageData scale:1.0] : nil;
    _isNeedUpdateFrame = YES;
    if (_image) {
        // 本地图片名
        image = _image;
        if (image.images.count <= 1) {
            CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextDrawImage(context, fitRect, image.CGImage);
        } else {
            CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
            //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
            fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    [_imageView removeFromSuperview];
                    _imageView = [[YLImageView alloc] initWithFrame:fitRect];
                    _imageView.image = image;
                    [self.ownerView addSubview:_imageView];
                }
            });
        }
    }else if (_imageName){
        // 图片网址
        image = (YLGIFImage *)[UIImage imageNamed:_imageName];
        if (_cacheImageOnMemory) {
            _image = image;
        }
        if (image.images.count <= 1) {
            CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextDrawImage(context, fitRect, image.CGImage);
        } else {
            CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
            //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
            fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    [_imageView removeFromSuperview];
                    _imageView = [[YLImageView alloc] initWithFrame:fitRect];
                    _imageView.image = image;
                    [self.ownerView addSubview:_imageView];
                }
            });
        }
    } else if (_imageURL){
        // 图片数据
        
        BOOL isGif = [[[_imageURL pathExtension] lowercaseString] isEqualToString:@"gif"];
        CGFloat width = self.size.width;
        CGFloat height = self.size.height;
        if (self.size.width >= ([UIScreen mainScreen].bounds.size.width / 2.0f) || self.size.height >= ([UIScreen mainScreen].bounds.size.height / 2.0f)) {
            width = self.size.width / 2.0f;
            height = self.size.height / 2.0f;
        }
        
//        [_imageView removeFromSuperview];
//        CGRect fitRect = [self rectFitOriginSize:CGSizeMake(width, height) byRect:rect];
//        _imageView = [[YLImageView alloc] initWithFrame:fitRect];
//        _imageView.image = image;
//        [self.ownerView addSubview:_imageView];
//
        _imageView = [[YLImageView alloc] init];
        [_imageView sd_setImageWithURL:_imageURL placeholderImage:[UIImage imageNamed:@"PhotoDownloadfailedSmall"] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            NSString *progress = [NSString stringWithFormat:@"%lld%%", receivedSize / expectedSize];
//            [self.progressLabel setText:progress];
//            NSLog(@"下载图片进度 : %ld", progress);
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
            //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
            fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    [_imageView removeFromSuperview];
                    _imageView = [[YLImageView alloc] initWithFrame:fitRect];
                    _imageView.image = image;
                    [self.ownerView addSubview:_imageView];
                } else {
                    QIMVerboseLog(@"加载图片失败 : %@", error);
                }
            });
            return;
            
//            CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (image) {
//                    [self.propressView removeFromSuperview];
//                    [_imageView removeFromSuperview];
//                    _imageView = [[YLImageView alloc] initWithFrame:fitRect];
//                    _imageView.image = image;
//                    [self.ownerView addSubview:_imageView];
//                }
//            });
        }];
        /*
        BOOL isExist = [[QIMKit sharedInstance] isFileExistForUrl:_imageURL.absoluteString width:width height:height forCacheType:QIMFileCacheTypeColoction];
        if (isExist) {
            NSString *localFile = [[QIMKit sharedInstance] fileExistLocalPathForUrl:_imageURL.absoluteString width:width height:height forCacheType:QIMFileCacheTypeColoction];
            NSData *data = [NSData dataWithContentsOfFile:localFile];
            if (data.length > 0) {
                image = [YLGIFImage imageWithData:data scale:1.0];
                CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
                //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
                fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        [_imageView removeFromSuperview];
                        _imageView = [[YLImageView alloc] initWithFrame:fitRect];
                        _imageView.image = image;
                        [self.ownerView addSubview:_imageView];
                    }
                });
                return;
            } else{
                image = placeHoldImageData.length ? [YLGIFImage imageWithData:placeHoldImageData scale:1.0] : nil;
                
                _isNeedUpdateFrame = YES;
            }
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [[QIMKit sharedInstance] getFileDataFromUrl:_imageURL.absoluteString
                                                                            width:isGif?0:width
                                                                           height:isGif?0:height
                                                                     forCacheType:QIMFileCacheTypeColoction];
                if (data) {
                    image = [YLGIFImage imageWithData:data scale:1.0];
                    CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
                    //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
                    fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (image) {
                            [_imageView removeFromSuperview];
                            _imageView = [[YLImageView alloc] initWithFrame:fitRect];
                            _imageView.image = image;
                            [self.ownerView addSubview:_imageView];
                        }
                    });
                    return;
                } else{
                    image = placeHoldImageData.length ? [YLGIFImage imageWithData:placeHoldImageData scale:1.0] : nil;
                    
                    _isNeedUpdateFrame = YES;
                }
            });
        }
        */
    }
    
    /*
    if (image.images.count <= 1) {
        CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, fitRect, image.CGImage);
    } else {
        CGRect fitRect = [self rectFitOriginSize:image.size byRect:rect];
        //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
        fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                [_imageView removeFromSuperview];
                _imageView = [[YLImageView alloc] initWithFrame:fitRect];
                _imageView.image = image;
                [self.ownerView addSubview:_imageView];
            }
        });
    }
    */
    /*
    if (image) {
        CGRect fitRect = [self rectFitOriginSize:self.size byRect:rect];
        [_imageView removeFromSuperview];
        //坐标系变换，函数绘制图片，但坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。要达到预想的效果必须变换坐标系。
        fitRect.origin.y = self.ownerView.height - fitRect.size.height - fitRect.origin.y;
        _imageView = [[YLImageView alloc] initWithFrame:fitRect];
        _imageView.image = image;
        [self.ownerView addSubview:_imageView];
    } */
}

- (CGRect)rectFitOriginSize:(CGSize)size byRect:(CGRect)byRect{
    if (_imageAlignment == QCImageAlignmentFill) {
        return byRect;
    }
    CGRect scaleRect = byRect;
    CGFloat targetWidth = byRect.size.width <= 0 ? size.width : byRect.size.width;
    CGFloat targetHeight = byRect.size.height <= 0 ? size.height : byRect.size.height;
    CGFloat widthFactor = targetWidth / size.width;
    CGFloat heightFactor = targetHeight / size.height;
    CGFloat scaleFactor = MIN(widthFactor, heightFactor);
    CGFloat scaledWidth  = size.width * scaleFactor;
    CGFloat scaledHeight = size.height * scaleFactor;
    scaleRect.size = CGSizeMake(scaledWidth, scaledHeight);
    // center the image
    if (widthFactor < heightFactor) {
        scaleRect.origin.y += (targetHeight - scaledHeight) * 0.5;
    } else if (widthFactor > heightFactor) {
        switch (_imageAlignment) {
            case QCImageAlignmentCenter:
                scaleRect.origin.x += (targetWidth - scaledWidth) * 0.5;
                break;
            case QCImageAlignmentRight:
                scaleRect.origin.x += (targetWidth - scaledWidth);
            default:
                break;
        }
    }
    return scaleRect;
}

// override
- (void)didNotDrawRun
{
    
}

@end
