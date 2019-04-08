//
//  NSData+Base64.h
//  qunarChatCommon
//
//  Created by May on 14/12/29.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSData (QIMBase64)

+ (NSData *)qim_dataWithBase64EncodedString:(NSString *)string;
- (NSString *)qim_base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)qim_base64EncodedString;
+ (NSData *)qim_base64DataFromString:(NSString *)string;

@end
