//
//  QTImageAssetViewController.h
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QIMCommonUIFramework.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kColoumn    4
#define kImageCap   5 

extern CGFloat imageItemWidth;
@interface QTImageAssetViewController : QTalkViewController
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, assign) NSInteger number;     //新加的，选中的张数
- (NSMutableArray *)indexPathsForSelectedItems;
@end
