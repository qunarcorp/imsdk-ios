//
//  GMAlbumsViewController.m
//  GMPhotoPicker
//
//  Created by Guillermo Muntaner Perelló on 19/09/14.
//  Copyright (c) 2014 Guillermo Muntaner Perelló. All rights reserved.
//

#import "QTPHImagePickerController.h"
#import "QTPHAlbumsViewController.h"
#import "QTPHGridViewCell.h"
#import "QTPHGridViewController.h"
#import "QTPHAlbumsViewCell.h"

@interface QTPHAlbumsViewController() <PHPhotoLibraryChangeObserver>

@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;
@property (strong) NSArray *collectionsFetchResultsAssets;
@property (strong) NSArray *collectionsFetchResultsTitles;
@property (nonatomic, weak) QTPHImagePickerController *picker;
@property (strong) PHCachingImageManager *imageManager;

@end


@implementation QTPHAlbumsViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.preferredContentSize = kPopoverContentSize;
    }
    
    return self;
}

static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    // Navigation bar customization
    if (self.picker.customNavigationBarPrompt) {
        self.navigationItem.prompt = self.picker.customNavigationBarPrompt;
    }
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    // Table view aspect
    self.tableView.rowHeight = kAlbumRowHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Buttons
    NSDictionary* barButtonItemAttributes = @{NSFontAttributeName: [UIFont fontWithName:self.picker.pickerFontName size:self.picker.pickerFontHeaderSize]};

    NSString *cancelTitle = @"取消";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cancelTitle
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.picker
                                                                            action:@selector(dismiss:)];
    if (self.picker.useCustomFontForNavigationBar) {
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateSelected];
    }

    if (self.picker.allowsMultipleSelection) {
        NSString *doneTitle = @"";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:doneTitle
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self.picker
                                                                                 action:@selector(finishPickingAssets:)];
        if (self.picker.useCustomFontForNavigationBar) {
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateSelected];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = (self.picker.autoDisableDoneButton ? self.picker.selectedAssets.count > 0 : TRUE);
    }
    
    // Bottom toolbar
    self.toolbarItems = self.picker.toolbarItems;
    
    // Title
    if (!self.picker.title) {
        self.title = @"照片";
    } else {
        self.title = self.picker.title;
    }
    
    // Fetch PHAssetCollections:
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:1];
    if (topLevelUserCollections) {
        [tempArr addObject:topLevelUserCollections];
    }
    
    if (smartAlbums) {
        [tempArr addObject:smartAlbums];
    }
    
    self.collectionsFetchResults = tempArr;
    self.collectionsLocalizedTitles = @[@"所有照片",@"自定义相册",@"智能相册"];
    
    [self updateFetchResults];
    
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Register for changes
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)dealloc
{
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.picker.pickerStatusBarStyle;
}

- (void)selectAllAlbumsCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

-(void)updateFetchResults
{
    //What I do here is fetch both the albums list and the assets of each album.
    //This way I have acces to the number of items in each album, I can load the 3
    //thumbnails directly and I can pass the fetched result to the gridViewController.
    
    self.collectionsFetchResultsAssets=nil;
    self.collectionsFetchResultsTitles=nil;
    
    //Fetch PHAssetCollections:
    PHFetchResult *topLevelUserCollections = [self.collectionsFetchResults objectAtIndex:0];
    PHFetchResult *smartAlbums = [self.collectionsFetchResults objectAtIndex:1];
    
    //All album: Sorted by descending creation date.
    NSMutableArray *allFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *allFetchResultLabel = [[NSMutableArray alloc] init];
    {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
        [allFetchResultArray addObject:assetsFetchResult];
        [allFetchResultLabel addObject:@"所有照片"];
    }
    
    //User albums:
    NSMutableArray *userFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *userFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in topLevelUserCollections)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            //Albums collections are allways PHAssetCollectionType=1 & PHAssetCollectionSubtype=2
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if(assetsFetchResult.count>0){
                [userFetchResultArray addObject:assetsFetchResult];
                [userFetchResultLabel addObject:collection.localizedTitle];
            }
        }
    }
    
                                  
    //Smart albums: Sorted by descending creation date.
    NSMutableArray *smartFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *smartFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in smartAlbums)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            //Smart collections are PHAssetCollectionType=2;
            if(self.picker.customSmartCollections && [self.picker.customSmartCollections containsObject:@(assetCollection.assetCollectionSubtype)])
            {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if(assetsFetchResult.count>0)
                {
                    [smartFetchResultArray addObject:assetsFetchResult];
                    [smartFetchResultLabel addObject:collection.localizedTitle];
                }
            }
        }
    }
    
    self.collectionsFetchResultsAssets= @[allFetchResultArray,smartFetchResultArray,userFetchResultArray];
    self.collectionsFetchResultsTitles= @[allFetchResultLabel,smartFetchResultLabel,userFetchResultLabel];
}


#pragma mark - Accessors

- (QTPHImagePickerController *)picker
{
    return (QTPHImagePickerController *)self.navigationController.parentViewController;
}


#pragma mark - Rotation

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
    UIInterfaceOrientation statusOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return statusOrientation;
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


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.collectionsFetchResultsAssets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
    return fetchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row];
    
    QTPHAlbumsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[QTPHAlbumsViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;

    // Set the label
    cell.titleLabel.font = [UIFont fontWithName:self.picker.pickerFontName size:self.picker.pickerFontHeaderSize];
    cell.titleLabel.text = (self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row];
    cell.titleLabel.textColor = self.picker.pickerTextColor;
    
    // Retrieve the pre-fetched assets for this album:
    PHFetchResult *assetsFetchResult = (self.collectionsFetchResultsAssets[indexPath.section])[indexPath.row];
    
    // Display the number of assets
    if (self.picker.displayAlbumsNumberOfAssets) {
        cell.infoLabel.font = [UIFont fontWithName:self.picker.pickerFontName size:self.picker.pickerFontNormalSize];
        cell.infoLabel.text = [self tableCellSubtitle:assetsFetchResult];
        cell.infoLabel.textColor = self.picker.pickerTextColor;
    }
    
    // Set the 3 images (if exists):
    if ([assetsFetchResult count] > 0) {
        CGFloat scale = [UIScreen mainScreen].scale;
        
        //Compute the thumbnail pixel size:
        CGSize tableCellThumbnailSize1 = CGSizeMake(kAlbumThumbnailSize1.width*scale, kAlbumThumbnailSize1.height*scale);
        PHAsset *asset = [assetsFetchResult lastObject];
        [cell setVideoLayout:(asset.mediaType==PHAssetMediaTypeVideo)];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = false;
        [self.imageManager requestImageForAsset:asset
                                     targetSize:tableCellThumbnailSize1
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
             if (cell.tag == currentTag) {
                 cell.imageView1.image = result;
             }
         }];
        
        // Second & third images:
        // TODO: Only preload the 3pixels height visible frame!
        if ([assetsFetchResult count] > 1) {
            //Compute the thumbnail pixel size:
            CGSize tableCellThumbnailSize2 = CGSizeMake(kAlbumThumbnailSize2.width*scale, kAlbumThumbnailSize2.height*scale);
            PHAsset *asset = assetsFetchResult[assetsFetchResult.count - 2];
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.synchronous = false;
            [self.imageManager requestImageForAsset:asset
                                         targetSize:tableCellThumbnailSize2
                                        contentMode:PHImageContentModeAspectFill
                                            options:options
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                 if (cell.tag == currentTag) {
                     cell.imageView2.image = result;
                 }
             }];
        } else {
            cell.imageView2.image = nil;
        }
        
        if ([assetsFetchResult count] > 2) {
            CGSize tableCellThumbnailSize3 = CGSizeMake(kAlbumThumbnailSize3.width*scale, kAlbumThumbnailSize3.height*scale);
            PHAsset *asset = assetsFetchResult[assetsFetchResult.count - 3];
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.synchronous = false;
            [self.imageManager requestImageForAsset:asset
                                         targetSize:tableCellThumbnailSize3
                                        contentMode:PHImageContentModeAspectFill
                                            options:options
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                 if (cell.tag == currentTag) {
                     cell.imageView3.image = result;
                 }
             }];
        } else {
            cell.imageView3.image = nil;
        }
    } else {
        [cell setVideoLayout:NO];
        cell.imageView3.image = [UIImage imageNamed:@"QTPHEmptyFolder"];
        cell.imageView2.image = [UIImage imageNamed:@"QTPHEmptyFolder"];
        cell.imageView1.image = [UIImage imageNamed:@"QTPHEmptyFolder"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QTPHAlbumsViewCell *cell = (QTPHAlbumsViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    // Init the GMGridViewController
    QTPHGridViewController *gridViewController = [[QTPHGridViewController alloc] initWithPicker:[self picker]];
    // Set the title
    gridViewController.title = cell.titleLabel.text;
    // Use the prefetched assets!
    gridViewController.assetsFetchResults = [[_collectionsFetchResultsAssets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // Remove selection so it looks better on slide in
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    // Push GMGridViewController
    [self.navigationController pushViewController:gridViewController animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor clearColor];
    header.backgroundView.backgroundColor = [UIColor clearColor];

    // Default is a bold font, but keep this styled as a normal font
    header.textLabel.font = [UIFont fontWithName:self.picker.pickerFontName size:self.picker.pickerFontNormalSize];
    header.textLabel.textColor = self.picker.pickerTextColor;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //Tip: Returning nil hides the section header!
    
    return nil;
    
    NSString *title = nil;
//    if (section > 0) {
        // Only show title for non-empty sections:
        PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
        if (fetchResult.count > 0) {
            title = self.collectionsLocalizedTitles[section];
        }
//    }
    return title;
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        // This only affects to changes in albums level (add/remove/edit album)
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
        }
        
        // However, we want to update if photos are added, so the counts of items & thumbnails are updated too.
        // Maybe some checks could be done here , but for now is OKey.
        [self updateFetchResults];
        [self.tableView reloadData];
        
    });
}



#pragma mark - Cell Subtitle

- (NSString *)tableCellSubtitle:(PHFetchResult*)assetsFetchResult
{
    // Just return the number of assets. Album app does this:
    return [NSString stringWithFormat:@"%ld", (long)[assetsFetchResult count]];
}



@end
