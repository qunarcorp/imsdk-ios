//
//  QIMRSACoder.h
//  qunarChatCommon
//
//  Created by May on 14/12/29.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMRSACoder : NSObject

+ (SecKeyRef)publicKey:(NSString *) certPath;

+ (NSString *)RSAEncrypotoTheData:(NSString *)plainText withPublicKey:(SecKeyRef) publicKey;

+ (NSData *) RSAEncrypotoText:(NSString *)plainText withPublicKey:(SecKeyRef) publicKey;

+ (NSData *) RSAYourText:(NSString *) text withPublicKeyFile:(NSString *) fileName;

+ (NSString *) encryptByRsa:(NSString*)content;

+ (NSString *) encryptByRsa:(NSString*)content publicKeyFileName:(NSString *) fileName;

+ (NSString *) rsaYourText:(NSString *) text;
+ (NSString *) writeRSAFile:(NSString *) publicKey;

+ (NSString *) RSAForPassword:(NSString *)password;

@end
