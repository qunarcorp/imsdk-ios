//
//  QTImageAssetView.h
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QIMCommonUIFramework.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol QTImageAssetViewDelegate <NSObject>
@optional
-(BOOL)shouldSelectAsset:(ALAsset*)asset;
-(void)tapSelectHandle:(BOOL)select asset:(ALAsset*)asset;
@end
@interface QTImageAssetView : UIView
@property (nonatomic, weak) id<QTImageAssetViewDelegate> delegate;

- (void)bind:(ALAsset *)asset selectionFilter:(NSPredicate*)selectionFilter isSeleced:(BOOL)isSeleced;

@end
