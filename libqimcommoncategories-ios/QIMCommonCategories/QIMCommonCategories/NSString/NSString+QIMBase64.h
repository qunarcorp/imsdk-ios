//
//  NSString+Base64.h
//  qunarChatCommon
//
//  Created by May on 14/12/29.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSString (QIMBase64)

+ (NSString *)qim_base64StringFromData:(NSData *)data length:(NSUInteger)length;
+ (NSString *)qim_stringWithBase64EncodedString:(NSString *)string;
- (NSString *)qim_base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)qim_base64EncodedString;
- (NSString *)qim_base64DecodedString;
- (NSData *)qim_base64DecodedData;

@end
