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
        _imageView = [[YLImageView alloc] init];
        [_imageView sd_setImageWithURL:_imageURL placeholderImage:[UIImage imageNamed:@"PhotoDownloadfailedSmall"] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//            NSString *progress = [NSString stringWithFormat:@"%lld%%", receivedSize / expectedSize];
//            [self.progressLabel setText:progress];
//            NSLog(@"下载图片进度 : %ld", progress);
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
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
        }];
    }
}

- (CGRect)rectFitOriginSize:(CGSize)size byRect:(CGRect)byRect{
    if (_imageAlignment == QCImageAlignmentFill) {
        return byRect;
    }
    CGRect scaleRect = byRect;
    CGFloat originTargetWidth = size.width;
    CGFloat originTargetHeight = size.height;
    CGFloat targetWidth = byRect.size.width <= 0 ? size.width : byRect.size.width;
    CGFloat targetHeight = byRect.size.height <= 0 ? size.height : byRect.size.height;
    CGFloat widthFactor = targetWidth / size.width;
    CGFloat heightFactor = targetHeight / size.height;
    CGFloat scaleFactor = MIN(widthFactor, heightFactor);
    CGFloat scaledWidth  = size.width * scaleFactor;
    CGFloat scaledHeight = size.height * scaleFactor;
    // center the image
    if (originTargetHeight > SCREEN_HEIGHT * 3 && originTargetHeight / originTargetWidth >= 5) {
        scaleRect.size = CGSizeMake(50, 100);
        scaleRect.origin = CGPointMake(0, 0);
    } else {
        scaleRect.size = CGSizeMake(scaledWidth, scaledHeight);
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
    }
    return scaleRect;
}

// override
- (void)didNotDrawRun
{
    
}

@end
