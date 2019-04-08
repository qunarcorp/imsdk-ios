//
//  QIMJumpURLHandle.h
//  qunarChatIphone
//
//  Created by admin on 15/8/13.
//
//

#import <Foundation/Foundation.h>

@interface QIMJumpURLHandle : NSObject

+ (BOOL)parseURL:(NSURL *)url;
+ (void)decodeQCodeStr:(NSString *)qCodeStr;

@end
