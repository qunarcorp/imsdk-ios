//
//  GMGridViewController.m
//  GMPhotoPicker
//
//  Created by Guillermo Muntaner Perelló on 19/09/14.
//  Copyright (c) 2014 Guillermo Muntaner Perelló. All rights reserved.
//

#import "QTPHGridViewController.h"
#import "QTPHImagePickerController.h"
#import "QTPHAlbumsViewController.h"
#import "QTPHGridViewCell.h"
#import "QTPHImagePreviewController.h"
#import <Photos/Photos.h>
#import "QIMImageEditViewController.h"
#import "QTalkTipsView.h"
#import "QTalkVideoAssetViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MBProgressHUD.h"
#import "QTPHImagePickerManager.h"

//Helper methods
@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end

@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end



@interface QTPHImagePickerController ()

- (void)finishPickingAssets:(id)sender;
- (void)dismiss:(id)sender;
- (NSString *)toolbarTitle;
- (UIView *)noAssetsView;

@end


@interface QTPHGridViewController () <UIActionSheetDelegate,QIMImageEditViewControllerDelegate,PHPhotoLibraryChangeObserver>
{
    UIView   *_bottomView;
    UIButton *_previewButton;
    UIButton *_editButton;
    UIButton *_photoTypeButton;
    UIButton *_sendButton;
    
    NSThread    * checkShownThread;
    
    MBProgressHUD * _tipHUD;
}

@property (nonatomic, weak) QTPHImagePickerController *picker;
@property (strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;

@end

static CGSize AssetGridThumbnailSize;
NSString * const QTPHGridViewCellIdentifier = @"QTPHGridViewCellIdentifier";

@implementation QTPHGridViewController
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    UICollectionViewFlowLayout *portraitLayout;
    UICollectionViewFlowLayout *landscapeLayout;
}

-(id)initWithPicker:(QTPHImagePickerController *)picker
{
    //Custom init. The picker contains custom information to create the FlowLayout
    self.picker = picker;
    
    //Ipad popover is not affected by rotation!
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        screenWidth = CGRectGetWidth(picker.view.bounds);
        screenHeight = CGRectGetHeight(picker.view.bounds);
    }
    else
    {
        if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            screenHeight = CGRectGetWidth(picker.view.bounds);
            screenWidth = CGRectGetHeight(picker.view.bounds);
        }
        else
        {
            screenWidth = CGRectGetWidth(picker.view.bounds);
            screenHeight = CGRectGetHeight(picker.view.bounds);
        }
    }
    
    
    UICollectionViewFlowLayout *layout = [self collectionViewFlowLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    if (self = [super initWithCollectionViewLayout:layout])
    {
        //Compute the thumbnail pixel size:
        CGFloat scale = [UIScreen mainScreen].scale;
        //QIMVerboseLog(@"This is @%fx scale device", scale);
        AssetGridThumbnailSize = CGSizeMake(layout.itemSize.width * scale, layout.itemSize.height * scale);
        
        self.collectionView.allowsMultipleSelection = picker.allowsMultipleSelection;
        
        [self.collectionView registerClass:QTPHGridViewCell.class
                forCellWithReuseIdentifier:QTPHGridViewCellIdentifier];
        
        self.preferredContentSize = kPopoverContentSize;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.picker.isOriginal = [[QIMKit sharedInstance] pickerPixelOriginal];
    [self setupViews];
    [self initBottomView];
    // Navigation bar customization
    if (self.picker.customNavigationBarPrompt) {
        self.navigationItem.prompt = self.picker.customNavigationBarPrompt;
    }
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //初始时，collectionView 滑动到底部，貌似在did layout之后滑动才有效，暂时没想到别的好办法 --- chenjie
    checkShownThread = [[NSThread alloc] initWithTarget:self selector:@selector(checkIfViewIsShowing) object:nil];
    [checkShownThread start];
}

- (void)checkIfViewIsShowing {
    dispatch_async(dispatch_get_main_queue(), ^{
        while (1) {
            if (self.collectionView.window != nil) {
                break;
            }
        }
    
        [self.collectionView scrollRectToVisible:CGRectMake(0, self.collectionView.contentSize.height - 1, self.collectionView.width, 1) animated:NO];
    });
    
    [checkShownThread cancel];
    checkShownThread = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self setupButtons];
    [self setupToolbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)dealloc
{
    [self resetCachedAssets];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.picker.pickerStatusBarStyle;
}

- (void)refresh{
    [self.collectionView reloadData];
    [self setTitleWithSelectedIndexPaths:self.picker.selectedAssets];
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    
    UICollectionViewFlowLayout *layout = [self collectionViewFlowLayoutForOrientation:toInterfaceOrientation];
    
    //Update the AssetGridThumbnailSize:
    CGFloat scale = [UIScreen mainScreen].scale;
    AssetGridThumbnailSize = CGSizeMake(layout.itemSize.width * scale, layout.itemSize.height * scale);
    
    [self resetCachedAssets];
    //This is optional. Reload visible thumbnails:
    for (QTPHGridViewCell *cell in [self.collectionView visibleCells]) {
        NSInteger currentTag = cell.tag;
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = false;
        [self.imageManager requestImageForAsset:cell.asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage *result, NSDictionary *info)
                                    {
                                        // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                        if (cell.tag == currentTag) {
                                            [cell.imageView setImage:result];
                                        }
                                    }];
    }
    
    [self.collectionView setCollectionViewLayout:layout animated:YES];
}


#pragma mark - Setup

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 46);
}

- (void)setupButtons
{
    NSString *cancelTitle = @"取消";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cancelTitle
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self.picker
                                                                             action:@selector(dismiss:)];
}

- (void)setupToolbar
{
    self.toolbarItems = self.picker.toolbarItems;
}

- (void)initBottomView{
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64 - [[QIMDeviceManager sharedInstance] getTAB_BAR_HEIGHT], [UIScreen mainScreen].bounds.size.width, 49)];
    [_bottomView setBackgroundColor:[UIColor qim_colorWithHex:0xf1f1f1 alpha:1]];
    [self.view addSubview:_bottomView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, 0.5)];
    [lineView setBackgroundColor:[UIColor qim_colorWithHex:0x999999 alpha:1]];
    [_bottomView addSubview:lineView];
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_previewButton setFrame:CGRectMake(10, 8, 60, 30)];
    [_previewButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1] forState:UIControlStateDisabled];
    [_previewButton addTarget:self action:@selector(onPreviewClick) forControlEvents:UIControlEventTouchUpInside];
    [_previewButton setEnabled:NO];
    [_bottomView addSubview:_previewButton];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_editButton setFrame:CGRectMake(_previewButton.right, 8, 60, 30)];
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
    
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 90, 8, 80, 30)];
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
        [_previewButton setEnabled:YES];
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
        [_previewButton setEnabled:NO];
        [_editButton setEnabled:NO];
        [_photoTypeButton setEnabled:NO];
        [_sendButton setEnabled:NO];
        [_sendButton setTitle:@"确定" forState:UIControlStateNormal];
    }
}

#pragma mark - actions
- (void)onPreviewClick{
    QTPHImagePreviewController *previewVC = [[QTPHImagePreviewController alloc] init];
    [previewVC setPhotoArray:[NSArray arrayWithArray:self.picker.selectedAssets]];
    previewVC.picker = self.picker;
    previewVC.gridVC = self;
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (void)onEditClick{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    screenSize.width *= [UIScreen mainScreen].scale;
    screenSize.height *= [UIScreen mainScreen].scale;
    CGSize targetSize = self.picker.isOriginal ? PHImageManagerMaximumSize : screenSize ;
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    [[self tipHUDWithText:@"正在获取图片..."] show:YES];
    __weak typeof(self) weakSelf = self;
    [_imageManager requestImageForAsset:[self.picker.selectedAssets firstObject] targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片尺寸" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"标清"],[NSString stringWithFormat:@"原图"],nil];
    [sheet showInView:self.view];
}

- (void)onSendClick{
    [self.picker finishPickingAssets:nil];
}


#pragma mark - Collection View Layout

- (UICollectionViewFlowLayout *)collectionViewFlowLayoutForOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(!portraitLayout)
        {
            portraitLayout = [[UICollectionViewFlowLayout alloc] init];
            portraitLayout.minimumInteritemSpacing = self.picker.minimumInteritemSpacing;
            int cellTotalUsableWidth = screenWidth - (self.picker.colsInPortrait-1)*self.picker.minimumInteritemSpacing;
            portraitLayout.itemSize = CGSizeMake(cellTotalUsableWidth/self.picker.colsInPortrait, cellTotalUsableWidth/self.picker.colsInPortrait);
            double cellTotalUsedWidth = (double)portraitLayout.itemSize.width*self.picker.colsInPortrait;
            double spaceTotalWidth = (double)screenWidth-cellTotalUsedWidth;
            double spaceWidth = spaceTotalWidth/(double)(self.picker.colsInPortrait-1);
            portraitLayout.minimumLineSpacing = spaceWidth;
        }
        return portraitLayout;
    }
    else
    {
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            if(!landscapeLayout)
            {
                landscapeLayout = [[UICollectionViewFlowLayout alloc] init];
                landscapeLayout.minimumInteritemSpacing = self.picker.minimumInteritemSpacing;
                int cellTotalUsableWidth = screenHeight - (self.picker.colsInLandscape-1)*self.picker.minimumInteritemSpacing;
                landscapeLayout.itemSize = CGSizeMake(cellTotalUsableWidth/self.picker.colsInLandscape, cellTotalUsableWidth/self.picker.colsInLandscape);
                double cellTotalUsedWidth = (double)landscapeLayout.itemSize.width*self.picker.colsInLandscape;
                double spaceTotalWidth = (double)screenHeight-cellTotalUsedWidth;
                double spaceWidth = spaceTotalWidth/(double)(self.picker.colsInLandscape-1);
                landscapeLayout.minimumLineSpacing = spaceWidth;
            }
            return landscapeLayout;
        }
        else
        {
            if(!portraitLayout)
            {
                portraitLayout = [[UICollectionViewFlowLayout alloc] init];
                portraitLayout.minimumInteritemSpacing = self.picker.minimumInteritemSpacing;
                int cellTotalUsableWidth = screenWidth - (self.picker.colsInPortrait-1)*self.picker.minimumInteritemSpacing;
                portraitLayout.itemSize = CGSizeMake(cellTotalUsableWidth/self.picker.colsInPortrait, cellTotalUsableWidth/self.picker.colsInPortrait);
                double cellTotalUsedWidth = (double)portraitLayout.itemSize.width*self.picker.colsInPortrait;
                double spaceTotalWidth = (double)screenWidth-cellTotalUsedWidth;
                double spaceWidth = spaceTotalWidth/(double)(self.picker.colsInPortrait-1);
                portraitLayout.minimumLineSpacing = spaceWidth;
            }
            return portraitLayout;
        }
    }
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QTPHGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QTPHGridViewCellIdentifier
                                                             forIndexPath:indexPath];
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    /*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        QIMVerboseLog(@"Image manager: Requesting FIT image for iPad");
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFit
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                      if (cell.tag == currentTag) {
                                          [cell.imageView setImage:result];
                                      }
                                  }];
    }
    else*/
    {
        //QIMVerboseLog(@"Image manager: Requesting FILL image for iPhone");
        @autoreleasepool {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            options.synchronous = YES;
            
            [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(92, 92) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [cell.imageView setImage:result];
            }];
            
            [self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                //gif 图片
                //这里不要直接用NSData赋值，相册图片过多时会导致OOM
                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    //这里获取gif图片的NSData数据
                    if (cell.tag == currentTag) {
                        [cell.gifLabel setHidden:NO];
                    }
                } else {
                    //其他格式的图片
                    if (cell.tag == currentTag) {
                        [cell.gifLabel setHidden:YES];
                    }
                }
            }];
        }
    }
    
    [cell bind:asset];
    
    cell.shouldShowSelection = self.picker.allowsMultipleSelection;
    
    // Optional protocol to determine if some kind of assets can't be selected (pej long videos, etc...)
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldEnableAsset:)]) {
        cell.enabled = [self.picker.delegate assetsPickerController:self.picker shouldEnableAsset:asset];
    } else {
        cell.enabled = YES;
    }
    
    if ([self.picker.selectedAssets containsObject:asset]) {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        cell.selected = NO;
    }
    
    return cell;
}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    if (self.picker.selectedAssets.count && [(PHAsset *)self.picker.selectedAssets.firstObject mediaType] != asset.mediaType) {
        [QTalkTipsView showTips:@"不能同时选择照片和视频" InView:self.view];
        return NO;
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        BOOL notAllowSelectVideo = [[QTPHImagePickerManager sharedInstance] notAllowSelectVideo];
        if (notAllowSelectVideo == YES) {
            //不允许选择视频
            [QTalkTipsView showTips:[NSString stringWithFormat:@"当前不支持上传视频到驼圈"] InView:self.view];
        } else {
            [self.picker.selectedAssets insertObject:asset atIndex:self.picker.selectedAssets.count];
            int duration = (int)asset.duration;
            [_imageManager requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    QTalkVideoAssetViewController *vc = [[QTalkVideoAssetViewController alloc]  init];
                    [vc setVideoAsset:asset];
                    vc.picker = self.picker;
                    vc.videoDuration = duration;
                    [self.navigationController pushViewController:vc animated:YES];
                });
            }];
        }
        return NO;
    }
    
    NSInteger maxNumber = [[QTPHImagePickerManager sharedInstance] maximumNumberOfSelection];
    if (maxNumber > 0) {
        if (self.picker.selectedAssets.count >= maxNumber) {
            [QTalkTipsView showTips:[NSString stringWithFormat:@"最多只能选择%d张照片",maxNumber] InView:self.view];
            return NO;
        }
    } else {
        if (self.picker.selectedAssets.count >= kMaximumNumberOfSelection) {
            [QTalkTipsView showTips:[NSString stringWithFormat:@"最多只能选择%d张照片",kMaximumNumberOfSelection] InView:self.view];
            return NO;
        }
    }
    
    QTPHGridViewCell *cell = (QTPHGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell.isEnabled) {
        return NO;
    } else if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)]) {
        return [self.picker.delegate assetsPickerController:self.picker shouldSelectAsset:asset];
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    [self.picker selectAsset:asset];
    [self setTitleWithSelectedIndexPaths:self.picker.selectedAssets];
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSelectAsset:)]) {
        [self.picker.delegate assetsPickerController:self.picker didSelectAsset:asset];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeselectAsset:)]) {
        return [self.picker.delegate assetsPickerController:self.picker shouldDeselectAsset:asset];
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    [self.picker deselectAsset:asset];
    [self setTitleWithSelectedIndexPaths:self.picker.selectedAssets];
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)]) {
        [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)]) {
        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)]) {
        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)]) {
        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
    }
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.assetsFetchResults.count;
    return count;
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        if (collectionChanges) {
            
            // get the new fetch result
            self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.collectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
                
            } else {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                        if (self.picker.showCameraButton && self.picker.autoSelectCameraImages) {
                            for (NSIndexPath *path in [insertedIndexes aapl_indexPathsFromIndexesWithSection:0]) {
                                [self collectionView:collectionView didSelectItemAtIndexPath:path];
                            }
                        }
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}


#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        [self.imageManager stopCachingImagesForAllAssets];
        self.previousPreheatRect = CGRectZero;
    }
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

#pragma mark - QIMImageEditViewControllerDelegate

- (void)imageEditVC:(QIMImageEditViewController *)imageEditVC didEditWithProductImage:(UIImage *)productImage
{
    if (productImage) {
        [self.picker finishEditWithImage:productImage];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    }else{
        return YES;
    }
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft;
    }else{
        UIInterfaceOrientation orientation;
        switch ([[UIDevice currentDevice] orientation]) {
            case UIDeviceOrientationPortrait:
            {
                orientation = UIInterfaceOrientationPortrait;
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
            {
                orientation = UIInterfaceOrientationPortraitUpsideDown;
            }
                break;
            case UIDeviceOrientationLandscapeLeft:
            {
                orientation = UIInterfaceOrientationLandscapeLeft;
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                orientation = UIInterfaceOrientationLandscapeRight;
            }
                break;
            default:
            {
                orientation = UIInterfaceOrientationPortrait;
            }
                break;
        }
        return orientation;
        
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
