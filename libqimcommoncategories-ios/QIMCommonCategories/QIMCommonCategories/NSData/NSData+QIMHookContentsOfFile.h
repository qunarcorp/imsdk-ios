//
//  NSData+HookContentsOfFile.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/6.
//

#import <Foundation/Foundation.h>

@interface NSData (QIMHookContentsOfFile)

+(instancetype)dataWithContentsOfFile:(NSString *)path;

@end
