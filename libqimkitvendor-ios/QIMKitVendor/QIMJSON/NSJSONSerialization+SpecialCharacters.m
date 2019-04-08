//
//  NSJSONSerialization+SpecialCharacters.m
//  QIMKitVendor
//
//  Created by 李露 on 11/13/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "NSJSONSerialization+SpecialCharacters.h"
#import <objc/message.h>

@interface NSJSONSerialization (SpecialCharacters)

@end

@implementation NSJSONSerialization (SpecialCharacters)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getClassMethod(self, @selector(JSONObjectWithData:options:error:));
        Method swizlledMethod = class_getClassMethod(self, @selector(sc_JSONObjectWithData:options:error:));
        method_exchangeImplementations(originalMethod, swizlledMethod);
    });
}

+ (id)sc_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError * _Nullable __autoreleasing *)error {
    if (!data.length) return nil;
    NSError *serializationError = nil;
    id responseObject = [self sc_JSONObjectWithData:data options:opt error:&serializationError];
    if (!responseObject) {
        if (error) {
            *error = serializationError;
        }
        
        if (serializationError && serializationError.code == 3840) {
            NSString *serializationString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (!serializationString) {
                return nil;
            }
            serializationString = [serializationString stringByReplacingOccurrencesOfString:@"(\\r\\n|\\r|\\n)" withString:@"\\\\r" options:NSRegularExpressionSearch range:NSMakeRange(0, serializationString.length)];
            
            NSData *serializationData = [serializationString dataUsingEncoding:NSUTF8StringEncoding];
            responseObject = [self sc_JSONObjectWithData:serializationData options:opt error:nil];
#ifndef DEBUG
            if (responseObject && error) {
                *error = nil;
            }
#endif
        }
    }
    
    return responseObject;
}

@end
