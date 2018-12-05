//
//  QIMChatBGImageSelectController.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//
#import "QIMCommonUIFramework.h"

@class QIMChatBGImageSelectController;

@protocol QIMChatBGImageSelectControllerDelegate <NSObject>

- (void)ChatBGImageDidSelected:(QIMChatBGImageSelectController *)chatBGImageSelectVC;

@end

@interface QIMChatBGImageSelectController : QTalkViewController

@property (nonatomic ,assign) id<QIMChatBGImageSelectControllerDelegate> delegate;
@property (nonatomic,assign) NSString       * userID;
@property (nonatomic,assign) BOOL             isFromChat;

- (instancetype)initWithCurrentBGImage:(UIImage *)image;

@end
