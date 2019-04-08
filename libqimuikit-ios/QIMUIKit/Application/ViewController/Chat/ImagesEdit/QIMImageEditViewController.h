//
//  QIMImageEditViewController.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/3.
//
//

#import "QIMCommonUIFramework.h"

@class QIMImageEditViewController;

@protocol QIMImageEditViewControllerDelegate <NSObject>

- (void)imageEditVC:(QIMImageEditViewController *)imageEditVC didEditWithProductImage:(UIImage *)productImage;

@end

@interface QIMImageEditViewController : QTalkViewController

@property (nonatomic, assign) id<QIMImageEditViewControllerDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image;

@end
