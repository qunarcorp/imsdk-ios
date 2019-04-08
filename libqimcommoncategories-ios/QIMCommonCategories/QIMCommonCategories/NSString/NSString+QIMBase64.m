//
//  NSString+Base64.m
//  qunarChatCommon
//
//  Created by May on 14/12/29.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "NSString+QIMBase64.h"
#import "NSData+QIMBase64.h"

static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

@implementation NSString (QIMBase64)

+ (NSString *)qim_base64StringFromData:(NSData *)data length:(NSUInteger)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1) {
        return @"";
    }
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0) {
            break;
        }
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext) {
                input[i] = raw[ix];
            }
            else {
                input[i] = 0;
            }
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++) {
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        }
        
        for (i = ctcopy; i < 4; i++) {
            [result appendString: @"="];
        }
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length)) {
            charsonline = 0;
        }
    }
    return result;
}

+ (NSString *)qim_stringWithBase64EncodedString:(NSString *)string
{
    NSData *data = [NSData qim_dataWithBase64EncodedString:string];
    if (data)
    {
        NSString *result = [[self alloc]
                            initWithData:data encoding:NSUTF8StringEncoding];
        
#if !__has_feature(objc_arc)
        [result autorelease];
#endif
        return result;
    }
    return nil;
}
- (NSString *)qim_base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data qim_base64EncodedStringWithWrapWidth:wrapWidth];
}
- (NSString *)qim_base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data qim_base64EncodedString];
}
- (NSString *)qim_base64DecodedString
{
    return [NSString qim_stringWithBase64EncodedString:self];
}
- (NSData *)qim_base64DecodedData
{
    return [NSData qim_dataWithBase64EncodedString:self];
}
@end
