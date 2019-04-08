//
//  QTImageAssetCell.h
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QIMCommonUIFramework.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol QTImageAssetCellDelegate <NSObject>
@optional
- (BOOL)shouldSelectAsset:(ALAsset*)asset;
- (void)didSelectAsset:(ALAsset*)asset;
- (void)didDeselectAsset:(ALAsset*)asset;
@end

@interface QTImageAssetCell : UITableViewCell
@property (nonatomic, weak) id<QTImageAssetCellDelegate> delegate;
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, strong) NSPredicate *selectionFilter;
+ (CGFloat)getCellHeight;
- (void)refreshUI; 

@end
