//
//  QIMPublicNumberRobotVC.h
//  qunarChatIphone
//
//  Created by admin on 15/8/26.
//
//

#import "QIMCommonUIFramework.h"
 
@interface QIMPublicNumberRobotVC : QTalkViewController

@property (nonatomic, strong) NSString *robotJId;
@property (nonatomic, strong) NSString *publicNumberId;
@property (nonatomic, strong) NSString *stype;
@property (nonatomic, strong) NSString *name;

- (void)refreshCellForMsg : (Message *)msg;

- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType;

- (void)sendMessage:(NSString *)message ForMsgType:(int)msgType;

- (void)sendImageData:(NSData *)imageData;

- (void)sendText:(NSString *)text;
@end
