//
//  QIMPushProductViewController.h
//  qunarChatIphone
//
//  Created by chenjie on 16/1/26.
//
//

#import "QIMCommonUIFramework.h"

@class QIMPushProductViewController;

@protocol QIMPushProductViewControllerDelegate <NSObject>

- (void)sendProductInfoStr:(NSString *)infoStr productDetailUrl:(NSString *)detlUrl;

@end

@interface QIMPushProductViewController : UIViewController

@property(nonatomic,assign) id<QIMPushProductViewControllerDelegate> delegate;

@end
