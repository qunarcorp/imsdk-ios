//
// Created by may on 2017/10/23.
// Copyright (c) 2017 May. All rights reserved.
//

#import "QIMAES256.h"
#import "AESTools.h"
#import "NSString+QIMBase64.h"
#import "NSData+QIMBase64.h"

@implementation QIMAES256 {
    
}

+ (NSData *)encryptForData:(NSString *)message password:(NSString *)password {
    
    uint8_t *output = NULL;
    if (message && password) {
        int length = AES_CBC_Encode_auto_bytes_int(
                                               (const uint8_t *) [message UTF8String],
                                               strlen([message UTF8String]),
                                               [password UTF8String],
                                               &output);
        
        if (length > 0) {
            NSData *resultData = [[NSData alloc] initWithBytes:output length:length];
            free(output);
            return [resultData autorelease];
        } else {
            return nil;
        }
    }
    return nil;
}

+ (NSString *)encryptForBase64:(NSString *)message password:(NSString *)password {
    
    NSData *data = [QIMAES256 encryptForData:message password:password];
    if (data) {
        NSString *base64EncodedString = [NSString qim_base64StringFromData:data length:[data length]];
        return base64EncodedString;
    }
    return nil;
}

+ (NSString *)decryptForBase64:(NSString *)base64EncodedString password:(NSString *)password {
    NSData *data = [NSData qim_base64DataFromString:base64EncodedString];
    if (password) {
        return [QIMAES256 decryptForData:data password:password];
    }
    return nil;
}

+ (NSString *)decryptForData:(NSData *)data password:(NSString *)password {
    
    if (data != nil) {
        char *output = NULL;
        
        int length = AES_CBC_Decode_auto_bytes_int(
                                               (const uint8_t *) [data bytes],
                                               [data length],
                                               [password UTF8String],
                                               &output);
        
        if (length > 0) {
            
            NSString *result = [[NSString alloc] initWithBytes:output length:length encoding:NSUTF8StringEncoding];
            free(output);
            return [result autorelease];
        }
    }
    return nil;
    
}

@end
