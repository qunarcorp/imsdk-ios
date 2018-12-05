//
//  QIMProgressHUD.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/1/14.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMProgressHUD : NSObject

+ (QIMProgressHUD *)sharedInstance;

- (void)showProgressHUDWithTest:(NSString *)text;

- (void)closeHUD;

@end
