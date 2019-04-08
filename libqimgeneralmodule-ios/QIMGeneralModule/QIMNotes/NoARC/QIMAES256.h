//
// Created by may on 2017/10/23.
// Copyright (c) 2017 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMAES256 : NSObject

+ (NSData *)encryptForData:(NSString *)message password:(NSString *)password;

+ (NSString *)encryptForBase64:(NSString *)message password:(NSString *)password;

+ (NSString *)decryptForBase64:(NSString *)base64EncodedString password:(NSString *)password;

+ (NSString *)decryptForData:(NSData *)base64EncodedString password:(NSString *)password;

@end
