//
//  QTImagePreviewController.m
//  qunarChatIphone
//
//  Created by admin on 15/8/19.
//
//

#import "QTPHImagePreviewController.h"
#import "QTPHImagePickerController.h"
#import "QIMImageEditViewController.h"
#import "QTImageAssetTools.h"
#import "QTPHGridViewController.h"
#import "QIMImageUtil.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MBProgressHUD.h"
#import "QTPHImagePickerManager.h"
#import "QIMStringTransformTools.h"

#define kImageViewTag   1000
#define kImageViewBGScrollViewTagFrom   2000

@interface QTPHImagePreviewController ()<UIScrollViewDelegate,UIAlertViewDelegate,QIMImageEditViewControllerDelegate,UIActionSheetDelegate>{
    UIScrollView * _scrollView;
    UIView   *_bottomView;
    UIButton *_editButton;
    UIButton *_photoTypeButton;
    UIButton *_sendButton;
    NSInteger _lastPageNum;
    UIButton *_rightButton;
    
    PHCachingImageManager   * _imageManager;
    UIScrollView    * _lastScrollView;
    MBProgressHUD * _tipHUD;
    
}

@end

@implementation QTPHImagePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:@"预览"];
    self.view.backgroundColor = [UIColor spectralColorBlueColor];
    self.picker.isOriginal = [[QIMKit sharedInstance] pickerPixelOriginal];
    
    _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_rightButton setImage:[UIImage imageNamed:@"photo_browser_header_icon_unchecked"] forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@"photo_browser_header_icon_checked"] forState:UIControlStateSelected];
    [_rightButton addTarget:self action:@selector(onRightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    _imageManager = [[PHCachingImageManager alloc] init];
    [self initPhotoScroll];
    [self initBottomView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES
        ;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init UI

- (void)initPhotoScroll{
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    CGRect StatusRect = [[UIApplication sharedApplication] statusBarFrame];
    //标题栏
    CGRect NavRect = self.navigationController.navigationBar.frame;
    CGFloat bottomMargin = 0;
    if (NavRect.size.height + StatusRect.size.height > 20) {
        bottomMargin = StatusRect.size.height + NavRect.size.height - 20;
    }
    QIMVerboseLog(@"%f", StatusRect.size.height + NavRect.size.height);
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [UIScreen mainScreen].bounds.size.height - 46)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(_scrollView.width * self.photoArray.count, _scrollView.height);
    _scrollView.bounces = NO;
    _scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_scrollView];
    [self setUpPhotos];
    _lastPageNum = -1;
    [self scrollViewDidEndDragging:_scrollView willDecelerate:NO];
}

- (void)setUpPhotos{
    NSInteger i = 0;
    for (PHAsset * asset in self.photoArray) {
        [_imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            //gif 图片
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downloadFinined) {
                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                    if (downloadFinined && imageData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIScrollView * bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_scrollView.width * i, 0, _scrollView.width, _scrollView.height)];
                            bgScrollView.minimumZoomScale = 1.0;
                            bgScrollView.maximumZoomScale = 10.0;
                            bgScrollView.tag = kImageViewBGScrollViewTagFrom + i;
                            bgScrollView.delegate = self;
                            bgScrollView.backgroundColor = [UIColor whiteColor];
                            bgScrollView.showsHorizontalScrollIndicator = NO;
                            bgScrollView.showsVerticalScrollIndicator = NO;
                            
                            YLImageView * imageView = [[YLImageView alloc] initWithFrame:bgScrollView.bounds];
                            YLGIFImage *result = [YLGIFImage imageWithData:imageData];
                            imageView.image = result;
                            imageView.tag = kImageViewTag;
                            imageView.backgroundColor = [UIColor whiteColor];
                            if (result.size.width < bgScrollView.width && result.size.height < bgScrollView.height) {
                                imageView.contentMode = UIViewContentModeCenter;
                            }else{
                                imageView.contentMode = UIViewContentModeScaleAspectFit;
                            }
                            [bgScrollView addSubview:imageView];
                            [_scrollView addSubview:bgScrollView];
                        });
                    }
                } else {
                    UIScrollView * bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_scrollView.width * i, 0, _scrollView.width, _scrollView.height)];
                    bgScrollView.minimumZoomScale = 1.0;
                    bgScrollView.maximumZoomScale = 10.0;
                    bgScrollView.tag = kImageViewBGScrollViewTagFrom + i;
                    bgScrollView.delegate = self;
                    bgScrollView.backgroundColor = [UIColor whiteColor];
                    bgScrollView.showsHorizontalScrollIndicator = NO;
                    bgScrollView.showsVerticalScrollIndicator = NO;
                    
                    UIImageView * imageView = [[UIImageView alloc] initWithFrame:bgScrollView.bounds];
                    UIImage *result = [UIImage imageWithData:imageData];
                    UIImage * imageFix = [QIMImageUtil fixOrientation:result];
                    imageView.image = imageFix;
                    imageView.tag = kImageViewTag;
                    imageView.backgroundColor = [UIColor whiteColor];
                    if (result.size.width < bgScrollView.width && result.size.height < bgScrollView.height) {
                        imageView.contentMode = UIViewContentModeCenter;
                    }else{
                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                    }
                    [bgScrollView addSubview:imageView];
                    [_scrollView addSubview:bgScrollView];
                }
            }
        }];
        /*
        [_imageManager requestImageForAsset:asset targetSize:_scrollView.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downloadFinined) {
                UIScrollView * bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_scrollView.width * i, 0, _scrollView.width, _scrollView.height)];
                bgScrollView.minimumZoomScale = 1.0;
                bgScrollView.maximumZoomScale = 10.0;
                bgScrollView.tag = kImageViewBGScrollViewTagFrom + i;
                bgScrollView.delegate = self;
                bgScrollView.backgroundColor = [UIColor whiteColor];
                bgScrollView.showsHorizontalScrollIndicator = NO;
                bgScrollView.showsVerticalScrollIndicator = NO;
                
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:bgScrollView.bounds];
                UIImage * imageFix = [QIMImageUtil fixOrientation:result];
                imageView.image = imageFix;
                imageView.tag = kImageViewTag;
                imageView.backgroundColor = [UIColor whiteColor];
                if (result.size.width < bgScrollView.width && result.size.height < bgScrollView.height) {
                    imageView.contentMode = UIViewContentModeCenter;
                }else{
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                }
                [bgScrollView addSubview:imageView];
                [_scrollView addSubview:bgScrollView];
            }
        }]; */
        i ++;
    }
}

- (void)initBottomView{

    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.bottom, [UIScreen mainScreen].bounds.size.width, 46)];
    [_bottomView setBackgroundColor:[UIColor qim_colorWithHex:0xf1f1f1 alpha:1]];
    [self.view addSubview:_bottomView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5)];
    [lineView setBackgroundColor:[UIColor qim_colorWithHex:0x999999 alpha:1]];
    [_bottomView addSubview:lineView];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_editButton setFrame:CGRectMake(10, 8, 60, 30)];
    [_editButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1] forState:UIControlStateDisabled];
    [_editButton addTarget:self action:@selector(onEditClick) forControlEvents:UIControlEventTouchUpInside];
    [_editButton setEnabled:NO];
    [_bottomView addSubview:_editButton];
    
    _photoTypeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_photoTypeButton.titleLabel setNumberOfLines:0];
    [_photoTypeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_photoTypeButton setFrame:CGRectMake(_editButton.right + 15, 8, 100, 30)];
    [_photoTypeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_photoTypeButton setImage:[UIImage imageNamed:@"photo_browser_button_arrow_normal"] forState:UIControlStateNormal];
    [_photoTypeButton setImage:[UIImage imageNamed:@"photo_browser_button_arrow_pressed"] forState:UIControlStateHighlighted];
    [_photoTypeButton setTitle:self.picker.isOriginal ? @" 原图" : @" 标清" forState:UIControlStateNormal];
    [_photoTypeButton setTitleColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1] forState:UIControlStateDisabled];
    [_photoTypeButton setEnabled:NO];
    [_photoTypeButton addTarget:self action:@selector(onPhotoTypeClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_photoTypeButton];
    
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 90, 8, 80, 30)];
    [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_sendButton setBackgroundImage:[[UIImage imageNamed:@"common_button_focus_nor"] stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateNormal];
    [_sendButton setBackgroundImage:[[UIImage imageNamed:@"common_button_focus_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateHighlighted];
    [_sendButton setBackgroundImage:[[UIImage imageNamed:@"common_button_disabled"] stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateDisabled];
    [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1] forState:UIControlStateDisabled];
    [_sendButton setTitle:@"确定" forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(onSendClick) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setEnabled:NO];
    [_bottomView addSubview:_sendButton];
    
    [self setTitleWithSelectedIndexPaths:self.picker.selectedAssets];
}


- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count > 0) {
        if (indexPaths.count == 1) {
            [_editButton setEnabled:YES];
        } else {
            [_editButton setEnabled:NO];
        }
        [_photoTypeButton setEnabled:YES];
        [_sendButton setEnabled:YES];
        NSInteger maxNumber = [[QTPHImagePickerManager sharedInstance] maximumNumberOfSelection];
        if (maxNumber > 0) {
            [_sendButton setTitle:[NSString stringWithFormat:@"确定(%ld/%@)",(long)indexPaths.count,@(maxNumber)] forState:UIControlStateNormal];
        } else {
            [_sendButton setTitle:[NSString stringWithFormat:@"确定(%ld/%@)",(long)indexPaths.count,@(kMaximumNumberOfSelection)] forState:UIControlStateNormal];
        }
    } else {
        [_editButton setEnabled:NO];
        [_photoTypeButton setEnabled:NO];
        [_sendButton setEnabled:NO];
        [_sendButton setTitle:@"确定" forState:UIControlStateNormal];
    }
//    if (picker.isOriginalImage == NO) {
//        [_photoTypeButton setTitle:[NSString stringWithFormat:@"   标清\r(%@)",[QIMStringTransformTools CapacityTransformStrWithSize:picker.compressDataLength]] forState:UIControlStateNormal];
//    } else {
//        [_photoTypeButton setTitle:[NSString stringWithFormat:@"   原图\r(%@)",[QIMStringTransformTools CapacityTransformStrWithSize:picker.originalDataLength]] forState:UIControlStateNormal];
//    }
}

#pragma mark - action

- (void)onRightButtonClick{
    PHAsset *asset = [self.photoArray objectAtIndex:(NSInteger)((_scrollView.contentOffset.x) / _scrollView.width)];
    if ([self.picker.selectedAssets containsObject:asset]) {
        _rightButton.selected = NO;
        [self.picker deselectAsset:asset];
        if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)]) {
            [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
        }
    } else {
        _rightButton.selected = YES;
        [self.picker selectAsset:asset];
        [self setTitleWithSelectedIndexPaths:self.picker.selectedAssets];
        if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSelectAsset:)]) {
            [self.picker.delegate assetsPickerController:self.picker didSelectAsset:asset];
        }
    }
    [self setTitleWithSelectedIndexPaths:self.picker.selectedAssets];
    [self.gridVC refresh];
}

- (void)onEditClick{
    NSInteger index = (NSInteger)(_scrollView.contentOffset.x / _scrollView.width);
    CGSize screenSize = _scrollView.size;
    screenSize.width *= [UIScreen mainScreen].scale;
    screenSize.height *= [UIScreen mainScreen].scale;
    CGSize targetSize = self.picker.isOriginal ? PHImageManagerMaximumSize : screenSize ;
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    [[self tipHUDWithText:@"正在获取图片..."] show:YES];
    __weak typeof(self) weakSelf = self;
    [_imageManager requestImageForAsset:[self.photoArray objectAtIndex:index] targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self closeHUD];
                QIMImageEditViewController * imageEditVC = [[QIMImageEditViewController alloc] initWithImage:result];
                imageEditVC.delegate = self;
                [weakSelf.navigationController pushViewController:imageEditVC animated:YES];
            });
        }
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [_photoTypeButton setTitle:[NSString stringWithFormat:@" 标清"] forState:UIControlStateNormal];
        self.picker.isOriginal = NO;
        [[QIMKit sharedInstance] setPickerPixelOriginal:NO];
    } else if (buttonIndex == 1) {
        
        [_photoTypeButton setTitle:[NSString stringWithFormat:@" 原图"] forState:UIControlStateNormal];
        self.picker.isOriginal = YES;
        [[QIMKit sharedInstance] setPickerPixelOriginal:YES];
    }
}

- (void)onPhotoTypeClick{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片尺寸" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"标清"],
                            [NSString stringWithFormat:@"原图"],nil];
    [sheet showInView:self.view];
}

- (void)onSendClick{
    [self.picker finishPickingAssets:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == _scrollView) {
        if (decelerate == NO) {
            [self refreshRightBtnState];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == _scrollView) {
        [self refreshRightBtnState];
    }
}

- (void)refreshRightBtnState{
    NSInteger pageNum = (NSInteger)((_scrollView.contentOffset.x) / _scrollView.width);
    if (pageNum == _lastPageNum) {
        return;
    }else{
        _lastPageNum = pageNum;
    }
    PHAsset *asset = [self.photoArray objectAtIndex:pageNum];
    if ([self.picker.selectedAssets containsObject:asset]) {
        _rightButton.selected = YES;
    } else {
        _rightButton.selected = NO;
    }
    [_lastScrollView setZoomScale:1.0 animated:NO];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (scrollView != _scrollView) {
        return [scrollView viewWithTag:kImageViewTag];
    }
    return nil;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (scrollView != _scrollView) {
        _lastScrollView = scrollView;
    }
    
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
//    if (scrollView != _scrollView) {
//        UIView * view = [scrollView viewWithTag:kImageViewTag];
//        if (view.width < scrollView.width && view.height < scrollView.height) {
//            view.center = scrollView.center;
//        }
//    }
}

#pragma mark - QIMImageEditViewControllerDelegate

- (void)imageEditVC:(QIMImageEditViewController *)imageEditVC didEditWithProductImage:(UIImage *)productImage
{
    if (productImage) {
        [self.picker finishEditWithImage:productImage];
    }
}

#pragma mark - HUD
- (MBProgressHUD *)tipHUDWithText:(NSString *)text {
    if (!_tipHUD) {
        _tipHUD = [[MBProgressHUD alloc] initWithView:[self view]];
        _tipHUD.minSize = CGSizeMake(120, 120);
        _tipHUD.minShowTime = 1;
        [_tipHUD setLabelText:@""];
        [[self view] addSubview:_tipHUD];
    }
    [_tipHUD setDetailsLabelText:text];
    return _tipHUD;
}

- (void)closeHUD{
    if (_tipHUD) {
        [_tipHUD hide:YES];
    }
}

@end
