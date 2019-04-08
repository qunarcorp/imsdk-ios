//
//  QTImagePickerController.h
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QIMCommonUIFramework.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class QTImagePickerController;

@protocol QTImagePickerControllerDelegate <NSObject>
@optional

-(void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets ToOriginal:(BOOL)flag;
-(void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingImage:(UIImage *)image;
- (void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingVideo:(NSDictionary *)videoDic;

-(void)qtImagePickerControllerDidCancel:(QTImagePickerController *)picker;
-(void)qtImagePickerController:(QTImagePickerController *)picker didSelectAsset:(ALAsset*)asset;
-(void)qtImagePickerController:(QTImagePickerController *)picker didDeselectAsset:(ALAsset*)asset;
-(void)qtImagePickerControllerDidMaximum:(QTImagePickerController *)picker;
-(void)qtImagePickerControllerDidMinimum:(QTImagePickerController *)picker;
@end

@interface QTImagePickerController : UINavigationController

@property (nonatomic, weak) id <QTImagePickerControllerDelegate> imageDelegate;
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;
@property (nonatomic, strong) NSMutableArray *indexPathsForSelectedItems;
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;
@property (nonatomic, assign) NSInteger minimumNumberOfSelection;
@property (nonatomic, strong) NSPredicate *selectionFilter;
@property (nonatomic, assign) BOOL showCancelButton;
@property (nonatomic, assign) BOOL showEmptyGroups;
@property (nonatomic, assign) BOOL isFinishDismissViewController;

@property (nonatomic, assign) long long originalDataLength;
@property (nonatomic, assign) long long compressDataLength;
@property (nonatomic, assign) BOOL isOriginalImage;
@property (nonatomic, strong) NSMutableDictionary *compressDataLengthDic;
@property (nonatomic, assign) BOOL selectedPhoto;

@end

