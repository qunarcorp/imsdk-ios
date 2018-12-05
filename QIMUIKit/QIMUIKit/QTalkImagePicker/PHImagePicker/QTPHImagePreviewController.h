//
//  QTImagePreviewController.h
//  qunarChatIphone
//
//  Created by admin on 15/8/19.
//
//

//#import "QIMCommonUIFramework.h"
#import "QIMCommonUIFramework.h"

@class QTPHImagePickerController;
@class QTPHGridViewController;
@interface QTPHImagePreviewController : QTalkViewController
@property (nonatomic,assign) QTPHImagePickerController * picker;
@property (nonatomic,assign) QTPHGridViewController * gridVC;
@property (nonatomic, strong) NSArray *photoArray;
@end
