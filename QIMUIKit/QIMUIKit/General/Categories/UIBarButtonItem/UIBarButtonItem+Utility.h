//
//  UIBarButtonItem+Utility.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/14.
//
//

#import "QIMCommonUIFramework.h"

@interface UIBarButtonItem (Utility)

+ (UIBarButtonItem *)createBarButtonItemWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target action:(SEL)action;

@end
