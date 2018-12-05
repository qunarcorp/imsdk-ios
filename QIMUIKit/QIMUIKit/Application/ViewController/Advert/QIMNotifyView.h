//
//  QIMNotifyView.h
//  qunarChatIphone
//
//  Created by QIM on 2018/2/24.
//

#import "QIMCommonUIFramework.h"

#define kNotifyViewCloseNotification @"kNotifyViewCloseNotification"

@interface QIMNotifyView : UIView

- (instancetype)initWithNotifyMessage:(NSDictionary *)message;

+ (instancetype)sharedNotifyViewWithMessage:(NSDictionary *)message;

@property (nonatomic, strong) NSDictionary *message;

@end
