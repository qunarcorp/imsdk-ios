//
//  NSString+QIMUtility.h
//  QunariPhone
//
//  Created by Neo on 11/12/12.
//  Copyright (c) 2012 姜琢. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface NSString (QIMUtility)

// URLEncoding
- (NSString *)qim_URLEncodedString;
- (NSString *)qim_URLDecodedString;
- (BOOL)qim_hasPrefixHttpHeader;

// XQueryComponents
- (NSString *)qim_stringByDecodingURLFormat;
- (NSString *)qim_stringByEncodingURLFormat;
- (NSDictionary *)qim_dictionaryFromQueryComponents;
- (NSDictionary *)qim_dictionaryFromParamComponents;    // 对于参数中不带＝的，用@“”作为参数值

// Encoding
- (NSString *)qim_getSHA1;
- (NSString *)qim_getMD5;

// Valid
- (BOOL)qim_isRangeValidFromIndex:(NSInteger)index withSize:(NSInteger)rangeSize;

// String2Date
- (NSString *)qim_getYYMMDDFWW;

//用 ****替换部分字符
- (NSString *)qim_getHidenPartString;

// 产生 hash code
+ (NSString *)qim_hashString:(NSString *)data withSalt:(NSString *)salt;

- (BOOL)qim_isStringSafe;

// Trim
- (NSString *)qim_trimSpaceString;

// 适配函数
- (CGSize)qim_sizeWithFontCompatible:(UIFont *)font;
- (CGSize)qim_sizeWithFontCompatible:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)qim_sizeWithFontCompatible:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)qim_sizeWithFontCompatible:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (void)qim_drawAtPointCompatible:(CGPoint)point withFont:(UIFont *)font;
- (void)qim_drawInRectCompatible:(CGRect)rect withFont:(UIFont *)font;
- (void)qim_drawInRectCompatible:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

- (NSString *)qim_stringByEscapingXMLEntities;
- (NSString *)qim_stringByUnescapingEscapingXMLEntities;

@end
