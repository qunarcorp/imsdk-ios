//
//  NSData+HookContentsOfFile.h
//  qunarChatIphone
//
//  Created by QIM on 2018/2/6.
//

#import <Foundation/Foundation.h>

@interface NSData (QIMHookContentsOfFile)

+(instancetype)dataWithContentsOfFile:(NSString *)path;

@end
