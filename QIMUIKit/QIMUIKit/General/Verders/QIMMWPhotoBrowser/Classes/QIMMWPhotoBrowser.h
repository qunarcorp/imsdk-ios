//
//  QIMMWPhotoBrowser.h
//  QIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMMWPhoto.h"
#import "QIMMWPhotoProtocol.h"
#import "QIMMWCaptionView.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define QIMMWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define QIMMWLog(x, ...)
#endif

@class QIMMWPhotoBrowser;

@protocol QIMMWPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser;
- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (QIMMWCaptionView *)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser currentDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser;

@end

@interface QIMMWPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>
@property (nonatomic, assign) BOOL notAutoHidenControls;
@property (nonatomic, weak) IBOutlet id<QIMMWPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL enableGrid;
@property (nonatomic) BOOL enableSwipeToDismiss;
@property (nonatomic) BOOL startOnGrid;
@property (nonatomic) BOOL autoPlayOnAppear;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, strong) UILabel   * indexLabel;//显示图片位置 如1/4
@property (nonatomic, strong) UIActivity *customActivity;

// Customise image selection icons as they are the only icons with a colour tint
// Icon should be located in the app's main bundle
@property (nonatomic, strong) NSString *customImageSelectedIconName;
@property (nonatomic, strong) NSString *customImageSelectedSmallIconName;

// Init
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithDelegate:(id <QIMMWPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end
