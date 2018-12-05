//
//  NSString+URLEncoding.m
//  QunarIphone
//
//  Created by Qunar.com on 12-7-9.
//
//

#import "zlib.h"
#import "NSString+QIMUtility.h"
#import <CommonCrypto/CommonHMAC.h>
#import "QIMUtility.h"
#import "NSMutableDictionary+QIMSafe.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation NSString (QIMUtility)

#pragma mark URLEncoding
- (NSString *)qim_URLEncodedString
{
    NSString *result = (__bridge_transfer NSString *)
	CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
											(CFStringRef)self,
											NULL,
											CFSTR("!*'();:@&;=+$,/?%#[] "),
											kCFStringEncodingUTF8);
    return result;
}

- (NSString*)qim_URLDecodedString
{
    NSString *result = (__bridge_transfer NSString *)
	CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
															(CFStringRef)self,
															CFSTR(""),
															kCFStringEncodingUTF8);
    return result;
}

- (BOOL)qim_hasPrefixHttpHeader {
    if ([self hasPrefix:@"http"]) {
        return YES;
    }
    return NO;
}

#pragma mark XQueryComponents
- (NSString *)qim_stringByDecodingURLFormat
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return result;
}

- (NSString *)qim_stringByEncodingURLFormat
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return result;
}

- (NSDictionary *)qim_dictionaryFromQueryComponents
{
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    
    for(NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) continue; // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        NSString *key = [[keyValuePairArray objectAtIndex:0] qim_stringByDecodingURLFormat];
        NSString *value = [[keyValuePairArray objectAtIndex:1] qim_stringByDecodingURLFormat];
        NSMutableArray *results = [queryComponents objectForKey:key]; // URL spec says that multiple values are allowed per key
        
        if(!results) // First object
        {
            [queryComponents setObject:value forKey:key];
        }
    }
	
    return queryComponents;
}

- (NSDictionary *)qim_dictionaryFromParamComponents
{
    NSMutableDictionary *paramComponents = [NSMutableDictionary dictionary];
    
    for(NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSString *value = nil;
        NSString *key = nil;
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        NSInteger pairCount = [keyValuePairArray count];
        if(pairCount == 2)
        {
            key = [[keyValuePairArray objectAtIndex:0] qim_stringByDecodingURLFormat];
            value = [[keyValuePairArray objectAtIndex:1] qim_stringByDecodingURLFormat];
        }
        else if(pairCount == 1)
        {
            key = [[keyValuePairArray objectAtIndex:0] qim_stringByDecodingURLFormat];
            value = @"";
        }
        
        NSMutableArray *results = [paramComponents objectForKey:key];
        
        if(!results) // First object
        {
            //TODO: no such method
            [paramComponents setQIMSafeObject:value forKey:key];
        }
    }
	
    return paramComponents;
}

#pragma mark Encoding
- (NSString *)qim_getSHA1
{
	// 分配hash结果空间
	uint8_t *hashBytes = malloc(CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t));
	if(hashBytes)
	{
		memset(hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
        
		// 计算hash值
		NSData *srcData = [self dataUsingEncoding:NSUTF8StringEncoding];
		CC_SHA1((void *)[srcData bytes], (CC_LONG)[srcData length], hashBytes);
        
		// 组建String
		NSMutableString* destString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
		for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		{
			[destString appendFormat:@"%02X", hashBytes[i]];
		}
		
		// 释放空间
		free(hashBytes);
		
		return destString;
	}
	
	return nil;
}

- (NSString *)qim_getMD5
{
	// 分配MD5结果空间
	uint8_t *md5Bytes = malloc(CC_MD5_DIGEST_LENGTH * sizeof(uint8_t));
	if(md5Bytes)
	{
		memset(md5Bytes, 0x0, CC_MD5_DIGEST_LENGTH);
		
		// 计算hash值
		NSData *srcData = [self dataUsingEncoding:NSUTF8StringEncoding];
		CC_MD5((void *)[srcData bytes], (CC_LONG)[srcData length], md5Bytes);
		
		// 组建String
		NSMutableString* destString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
		for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		{
			[destString appendFormat:@"%02X", md5Bytes[i]];
		}
		
		// 释放空间
		free(md5Bytes);
		
		return destString;
	}
	
	return nil;
}

#pragma mark Valid
- (BOOL)qim_isRangeValidFromIndex:(NSInteger)index withSize:(NSInteger)rangeSize
{
	NSUInteger stringLength = [self length];
    
    if ((stringLength - index) < rangeSize)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark String2Date
- (NSString *)qim_getYYMMDDFWW
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale * gregorianLocale = [[NSLocale alloc] initWithLocaleIdentifier:NSGregorianCalendar];
    [dateFormatter setLocale:gregorianLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *searchDate = [dateFormatter dateFromString:self];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger weekday = [gregorianCalendar ordinalityOfUnit:
                          NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:searchDate];
    NSString *defaultDateText  = [NSString stringWithFormat:@"%@ %@", self, [QIMUtility getFullWeekend:weekday]];
    return defaultDateText;
}

//隐藏替换部分
- (NSString *)qim_getHidenPartString
{
    NSRange range = NSMakeRange(3, 4);
    if ([self length] < (range.location+range.length))
    {
        return self;
    }
    else
    {
        return  [self stringByReplacingCharactersInRange:range withString:@"****"];
    }
}

+ (NSString *)qim_hashString:(NSString *)data withSalt:(NSString *)salt
{
    if (![data qim_isStringSafe] || ![salt qim_isStringSafe])
    {
        return nil;
    }
    
    {
        //
        // 做个转换，目的是尽可能让图片映射在一个文件上，减少下载的次数
        NSURL *tempUrl = [NSURL URLWithString:data];
        NSMutableString *tempKey = nil;
        
        {
            BOOL newQtalkFileservice = NO;
            
            NSArray *pathComponents = [[tempUrl path] pathComponents];
            if ([pathComponents containsObject:@"file"] &&
                [pathComponents containsObject:@"v2"] &&
                [pathComponents containsObject:@"download"]) {
                newQtalkFileservice = YES;
            }
            
            if (newQtalkFileservice) {
                tempKey = [NSMutableString stringWithString:[[[tempUrl path] lastPathComponent] stringByDeletingPathExtension]];
            } else {
                if (![tempUrl host] || !tempUrl)
                    tempKey = [NSMutableString stringWithString:data];
                else {
                    tempKey = [NSMutableString stringWithFormat:@"%@%@",
                               [tempUrl host],
                               [tempUrl relativePath]];
                }
            }
            
            NSString *query = [tempUrl query];
            if (query) {
                NSArray *parameters = [query componentsSeparatedByString:@"&"];
                for (NSString *item in parameters) {
                    NSArray *value = [item componentsSeparatedByString:@"="];
                    if ([value count] == 2) {
                        NSString *key = [value objectAtIndex:0];
                        
                        if ([[tempUrl relativePath] isEqualToString:@"/cgi-bin/get_file.pl"]) {
                            if ([key isEqualToString:@"file"] ||
                                 [key isEqualToString:@"fileurl"] ||
                                 [key isEqualToString:@"md5"]) {
                                [tempKey appendString:[NSString stringWithFormat:@"?file=%@",
                                                       [value objectAtIndex:1]]];
                            }
                        }
                        
                        if ([[key lowercaseString] isEqualToString:@"w"] || [[key lowercaseString] isEqualToString:@"h"]) {
                            [tempKey appendString:item];
                        }
                    }
                }
            }
        }
        data = tempKey ? tempKey : data;
    }
    

    
    const char *cKey  = [salt cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    
    return hash;
}

- (BOOL)qim_isStringSafe
{
    return [self length] > 0;
}

#pragma mark Trim Space
- (NSString *)qim_trimSpaceString
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark 适配函数
- (CGSize)qim_sizeWithFontCompatible:(UIFont *)font
{
    if([self respondsToSelector:@selector(sizeWithAttributes:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font};
        CGSize stringSize = [self sizeWithAttributes:dictionaryAttributes];
        return CGSizeMake(ceil(stringSize.width), ceil(stringSize.height));
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		return [self sizeWithFont:font];
#pragma clang diagnostic pop
    }
}

- (CGSize)qim_sizeWithFontCompatible:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font,};
		
        CGRect stringRect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                               options:NSStringDrawingTruncatesLastVisibleLine
                                            attributes:dictionaryAttributes
                                               context:nil];
        
        CGFloat widthResult = stringRect.size.width;
        if(widthResult - width >= 0.0000001)
        {
            widthResult = width;
        }
        
        return CGSizeMake(widthResult, ceil(stringRect.size.height));
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		return [self sizeWithFont:font forWidth:width lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
}

- (CGSize)qim_sizeWithFontCompatible:(UIFont *)font constrainedToSize:(CGSize)size
{
    if([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font};
        CGRect stringRect = [self boundingRectWithSize:size
											   options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:dictionaryAttributes
                                               context:nil];
        
        return CGSizeMake(ceil(stringRect.size.width), ceil(stringRect.size.height));
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		return [self sizeWithFont:font constrainedToSize:size];
#pragma clang diagnostic pop
    }
}

- (CGSize)qim_sizeWithFontCompatible:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font,};
        CGRect stringRect = [self boundingRectWithSize:size
											   options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:dictionaryAttributes
                                               context:nil];
        
        return CGSizeMake(ceil(stringRect.size.width), ceil(stringRect.size.height));
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		return [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
}

- (void)qim_drawAtPointCompatible:(CGPoint)point withFont:(UIFont *)font
{
    if([self respondsToSelector:@selector(drawAtPoint:withAttributes:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font};
        [self drawAtPoint:point withAttributes:dictionaryAttributes];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		[self drawAtPoint:point withFont:font];
#pragma clang diagnostic pop
    }
}

- (void)qim_drawInRectCompatible:(CGRect)rect withFont:(UIFont *)font
{
    if([self respondsToSelector:@selector(drawWithRect:options:attributes:context:)] == YES)
    {
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font};
        [self drawWithRect:rect
                   options:NSStringDrawingUsesLineFragmentOrigin
                attributes:dictionaryAttributes
                   context:nil];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		[self drawInRect:rect withFont:font];
#pragma clang diagnostic pop
    }
}

- (void)qim_drawInRectCompatible:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment
{
    if([self respondsToSelector:@selector(drawWithRect:options:attributes:context:)] == YES)
    {
		NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[paragraphStyle setAlignment:alignment];
        NSDictionary *dictionaryAttributes = @{NSFontAttributeName:font,
											   NSParagraphStyleAttributeName:paragraphStyle};
        [self drawWithRect:rect
                   options:NSStringDrawingUsesLineFragmentOrigin
                attributes:dictionaryAttributes
                   context:nil];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		[self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
#pragma clang diagnostic pop
    }
}

- (NSString *)qim_stringByEscapingXMLEntities
{
    return ((__bridge  NSString *)CFXMLCreateStringByEscapingEntities(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL));
}

- (NSString *)qim_stringByUnescapingEscapingXMLEntities
{
    return ((__bridge  NSString *)CFXMLCreateStringByUnescapingEntities(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL));
}

/*
 At the very least we need to do <, >, &, ", and '. In addition, we'll have to do everything else in the string.
 We should also be handling items that are up over certain values correctly.
 */
CFStringRef CFXMLCreateStringByEscapingEntities(CFAllocatorRef allocator, CFStringRef string, CFDictionaryRef entitiesDictionary) {
    //    CFAssert1(string != NULL, __kCFLogAssertion, "%s(): NULL string not permitted.", __PRETTY_FUNCTION__);
    CFMutableStringRef newString = CFStringCreateMutable(allocator, 0); // unbounded mutable string
    CFMutableCharacterSetRef startChars = CFCharacterSetCreateMutable(allocator);
    
    CFStringInlineBuffer inlineBuf;
    CFIndex idx = 0;
    CFIndex mark = idx;
    CFIndex stringLength = CFStringGetLength(string);
    UniChar uc;
    
    CFCharacterSetAddCharactersInString(startChars, CFSTR("&<>'\""));
    
    CFStringInitInlineBuffer(string, &inlineBuf, CFRangeMake(0, stringLength));
    for(idx = 0; idx < stringLength; idx++) {
        uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, idx);
        if(CFCharacterSetIsCharacterMember(startChars, uc)) {
            CFStringRef previousSubstring = CFStringCreateWithSubstring(allocator, string, CFRangeMake(mark, idx - mark));
            CFStringAppend(newString, previousSubstring);
            CFRelease(previousSubstring);
            switch(uc) {
                case '&':
                    CFStringAppend(newString, CFSTR("&amp;"));
                    break;
                case '<':
                    CFStringAppend(newString, CFSTR("&lt;"));
                    break;
                case '>':
                    CFStringAppend(newString, CFSTR("&gt;"));
                    break;
                case '\'':
                    CFStringAppend(newString, CFSTR("&apos;"));
                    break;
                case '"':
                    CFStringAppend(newString, CFSTR("&quot;"));
                    break;
            }
            mark = idx + 1;
        }
    }
    // Copy the remainder to the output string before returning.
    CFStringRef remainder = CFStringCreateWithSubstring(allocator, string, CFRangeMake(mark, idx - mark));
    if (NULL != remainder) {
        CFStringAppend(newString, remainder);
        CFRelease(remainder);
    }
    
    CFRelease(startChars);
    return newString;
}

CFStringRef CFXMLCreateStringByUnescapingEntities(CFAllocatorRef allocator, CFStringRef string, CFDictionaryRef entitiesDictionary) {
    //    CFAssert1(string != NULL, __kCFLogAssertion, "%s(): NULL string not permitted.", __PRETTY_FUNCTION__);
    
    CFStringInlineBuffer inlineBuf; /* use this for fast traversal of the string in question */
    CFStringRef sub;
    CFIndex lastChunkStart, length = CFStringGetLength(string);
    CFIndex i, entityStart;
    UniChar uc;
    UInt32 entity;
    int base;
    CFMutableDictionaryRef fullReplDict = entitiesDictionary ? CFDictionaryCreateMutableCopy(allocator, 0, entitiesDictionary) : CFDictionaryCreateMutable(allocator, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("amp"), (const void *)CFSTR("&"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("quot"), (const void *)CFSTR("\""));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("lt"), (const void *)CFSTR("<"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("gt"), (const void *)CFSTR(">"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("apos"), (const void *)CFSTR("'"));
    
    CFStringInitInlineBuffer(string, &inlineBuf, CFRangeMake(0, length - 1));
    CFMutableStringRef newString = CFStringCreateMutable(allocator, 0);
    
    lastChunkStart = 0;
    // Scan through the string in its entirety
    for(i = 0; i < length; ) {
        uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;    // grab the next character and move i.
        
        if(uc == '&') {
            entityStart = i - 1;
            entity = 0xFFFF;    // set this to a not-Unicode character as sentinel
            // we've hit the beginning of an entity. Copy everything from lastChunkStart to this point.
            if(lastChunkStart < i - 1) {
                sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(lastChunkStart, (i - 1) - lastChunkStart));
                CFStringAppend(newString, sub);
                CFRelease(sub);
            }
            
            uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;    // grab the next character and move i.
            // Now we can process the entity reference itself
            if(uc == '#') {    // this is a numeric entity.
                base = 10;
                entity = 0;
                uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
                
                if(uc == 'x') {    // only lowercase x allowed. Translating numeric entity as hexadecimal.
                    base = 16;
                    uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
                }
                
                // process the provided digits 'til we're finished
                while(true) {
                    if (uc >= '0' && uc <= '9')
                        entity = entity * base + (uc-'0');
                    else if (uc >= 'a' && uc <= 'f' && base == 16)
                        entity = entity * base + (uc-'a'+10);
                    else if (uc >= 'A' && uc <= 'F' && base == 16)
                        entity = entity * base + (uc-'A'+10);
                    else break;
                    
                    if (i < length) {
                        uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
                    }
                    else
                        break;
                }
            }
            
            // Scan to the end of the entity
            while(uc != ';' && i < length) {
                uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
            }
            
            if(0xFFFF != entity) { // it was numeric, and translated.
                // Now, output the result fo the entity
                if(entity >= 0x10000) {
                    UniChar characters[2] = { ((entity - 0x10000) >> 10) + 0xD800, ((entity - 0x10000) & 0x3ff) + 0xDC00 };
                    CFStringAppendCharacters(newString, characters, 2);
                } else {
                    UniChar character = entity;
                    CFStringAppendCharacters(newString, &character, 1);
                }
            } else {    // it wasn't numeric.
                sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(entityStart + 1, (i - entityStart - 2))); // This trims off the & and ; from the string, so we can use it against the dictionary itself.
                CFStringRef replacementString = (CFStringRef)CFDictionaryGetValue(fullReplDict, sub);
                if(replacementString) {
                    CFStringAppend(newString, replacementString);
                } else {
                    CFRelease(sub); // let the old substring go, since we didn't find it in the dictionary
                    sub =  CFStringCreateWithSubstring(allocator, string, CFRangeMake(entityStart, (i - entityStart))); // create a new one, including the & and ;
                    CFStringAppend(newString, sub); // ...and append that.
                }
                CFRelease(sub); // in either case, release the most-recent "sub"
            }
            
            // move the lastChunkStart to the beginning of the next chunk.
            lastChunkStart = i;
        }
    }
    if(lastChunkStart < length) { // we've come out of the loop, let's get the rest of the string and tack it on.
        sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(lastChunkStart, i - lastChunkStart));
        CFStringAppend(newString, sub);
        CFRelease(sub);
    }
    
    CFRelease(fullReplDict);
    
    return newString;
}

@end
