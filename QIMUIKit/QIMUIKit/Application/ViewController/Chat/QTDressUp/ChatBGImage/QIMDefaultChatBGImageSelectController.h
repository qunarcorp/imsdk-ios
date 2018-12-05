//
//  QIMDefaultChatBGImageSelectController.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//
#import "QIMCommonUIFramework.h"

@class QIMDefaultChatBGImageSelectController;
@protocol QIMDefaultChatBGImageSelectControllerDelegate <NSObject>

- (void)defaultQIMChatBGImageSelectController:(QIMDefaultChatBGImageSelectController *)imagePicker willPopWithImage:(UIImage *)image;

@end

@interface QIMDefaultChatBGImageSelectController : QTalkViewController
@property (nonatomic, assign) id<QIMDefaultChatBGImageSelectControllerDelegate> delegate;
@end
