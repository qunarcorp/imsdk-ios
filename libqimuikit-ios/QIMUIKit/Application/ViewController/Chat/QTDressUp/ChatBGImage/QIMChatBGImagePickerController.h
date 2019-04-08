//
//  QIMChatBGImagePickerController.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@class QIMChatBGImagePickerController;
@protocol QIMChatBGImagePickerControllerDelegate <NSObject>

- (void)imagePicker:(QIMChatBGImagePickerController *)imagePicker willDismissWithImage:(UIImage *)image;

@end

@interface QIMChatBGImagePickerController : QTalkViewController

@property (nonatomic, assign) id<QIMChatBGImagePickerControllerDelegate> delegate;

-(instancetype)initWithImage:(UIImage *)image;

@end
