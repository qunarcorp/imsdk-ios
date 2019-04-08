//
//  QIMJSONSerializer.m
//  ObjcJSON
//
//  Created by 李露 on 2017/10/30.
//  Copyright © 2017年 李露. All rights reserved.
//

#import "QIMJSONSerializer.h"
#import "NSJSONSerialization+QIMRemovingNulls.h"
#import "QIMPublicRedefineHeader.h"

@implementation QIMJSONSerializer

+ (instancetype)sharedInstance {
    static QIMJSONSerializer *__jsonSeri = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __jsonSeri = [[QIMJSONSerializer alloc] init];
    });
    return __jsonSeri;
}

- (NSData *)serializeObject:(id)inObject error:(NSError **)outError {
    NSData *jsonData = nil;
    if ([NSJSONSerialization isValidJSONObject:inObject]) {
        
        @try {
            jsonData = [NSJSONSerialization dataWithJSONObject:inObject
                                                       options:0
                                                         error:outError];
        }
        @catch (NSException * exception) {
            QIMVerboseLog(@"serializeObject [ %@ ] Exception %@", inObject, exception);
        }
        @finally {
            
        }
    }
    return jsonData;
}

- (NSString *)serializeObject:(id)inObject {
    NSError *error = nil;
    NSString *result = [[NSString alloc] initWithData:[self serializeObject:inObject error:&error] encoding:NSUTF8StringEncoding];
    return result;
}

- (id)deserializeObject:(id)inObject error:(NSError **)outError {
    if (!inObject) {
        return nil;
    }
    NSData *data = inObject;
    if ([inObject isKindOfClass:[NSString class]]) {

        data = [inObject dataUsingEncoding:NSUTF8StringEncoding];
    }
    id outObject = nil;
    NSError *error = nil;
    @try {
        outObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    }
    @catch (NSException *exception) {
        QIMVerboseLog(@"deserializeObject [ %@ ] Exception%@", inObject, exception);
        outObject = @{};
    }
    @finally {
        
    }
    if (error == nil) {
        
    } else {
        QIMVerboseLog(@"deserializeObject [ %@ ] Error : %@", inObject, error);
    }
    
    return outObject;
}

- (NSString *)serializeString:(NSString *)inString
{
    NSMutableString *theMutableCopy = [inString mutableCopy];
    [theMutableCopy replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [theMutableCopy length])];
    [theMutableCopy replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [theMutableCopy length])];
    [theMutableCopy replaceOccurrencesOfString:@"/" withString:@"\\/" options:0 range:NSMakeRange(0, [theMutableCopy length])];
    [theMutableCopy replaceOccurrencesOfString:@"\b" withString:@"\\b" options:0 range:NSMakeRange(0, [theMutableCopy length])];
    [theMutableCopy replaceOccurrencesOfString:@"\f" withString:@"\\f" options:0 range:NSMakeRange(0, [theMutableCopy length])];
    [theMutableCopy replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, [theMutableCopy length])];
    [theMutableCopy stringByReplacingOccurrencesOfString:@"(\n)" withString:@"\\\\n" options:NSRegularExpressionSearch range:NSMakeRange(0, [theMutableCopy length])];
     [theMutableCopy stringByReplacingOccurrencesOfString:@"(\r)" withString:@"\\\\r" options:NSRegularExpressionSearch range:NSMakeRange(0, [theMutableCopy length])];
    [theMutableCopy replaceOccurrencesOfString:@"\t" withString:@"\\t" options:0 range:NSMakeRange(0, [theMutableCopy length])];
    /*
     case 'u':
     {
     theCharacter = 0;
     
     int theShift;
     for (theShift = 12; theShift >= 0; theShift -= 4)
     {
     int theDigit = HexToInt([self scanCharacter]);
     if (theDigit == -1)
     {
     [self setScanLocation:theScanLocation];
     return(NO);
     }
     theCharacter |= (theDigit << theShift);
     }
     }
     */
    return theMutableCopy;
}

@end
