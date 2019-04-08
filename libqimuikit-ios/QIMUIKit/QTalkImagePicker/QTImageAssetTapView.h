//
//  QTImageAssetTipView.h
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

//#import "QIMCommonUIFramework.h"
#import "QIMCommonUIFramework.h"

@protocol QTImageAssetTapViewDelegate <NSObject>
@optional
-(void)touchSelect:(BOOL)select;
-(BOOL)shouldTap;
@end
@interface QTImageAssetTapView : UIView
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, weak) id<QTImageAssetTapViewDelegate> delegate;
@end
