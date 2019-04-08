//
//  QIMQRCodeLoginManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/10/30.
//

#import "QIMCommonUIFramework.h"

typedef enum {
    QIMQRCodeLoginStateNone = 0,
    QIMQRCodeLoginStateSuccess = 1,
    QIMQRCodeLoginStateFailed,
} QIMQRCodeLoginState;

#define QIMQRCodeLoginStateNotification @"QIMQRCodeLoginStateNotification"

@interface QIMQRCodeLoginManager : NSObject

+ (instancetype)shareQIMQRCodeLoginManager;

+ (instancetype)shareQIMQRCodeLoginManagerWithKey:(NSString *)loginKey WithType:(NSString *)type;

+ (instancetype)shareQIMQRCodeLoginManagerWithKey:(NSString *)loginKey;

/**
 取消登陆
 */
- (void)cancelQRCodeLogin;


/**
 确认登陆
 */
- (void)confirmQRCodeLogin;


/**
 已经确认扫码
 */
- (void)confirmQRCodeAction;

@end
