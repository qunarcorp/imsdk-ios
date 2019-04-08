//
//  ZoomingScrollView.h
//  QIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMMWPhotoProtocol.h"
#import "QIMMWTapDetectingImageView.h"
#import "QIMMWTapDetectingView.h"

@class QIMMWPhotoBrowser, QIMMWPhoto, QIMMWCaptionView;

@interface QIMMWZoomingScrollView : UIScrollView <UIScrollViewDelegate, QIMMWTapDetectingImageViewDelegate, QIMMWTapDetectingViewDelegate> {

}

@property () NSUInteger index;
@property (nonatomic) id <QIMMWPhoto> photo;
@property (nonatomic, weak) QIMMWCaptionView *captionView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;

- (id)initWithPhotoBrowser:(QIMMWPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

@end
