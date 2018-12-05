//
//  QIMUtility.m
//  QunarUGC
//
//  Created by zhao yan on 12-8-8.
//  Copyright (c) 2012年 qunar. All rights reserved.
//

#import "QIMUtility.h"
#import "zlib.h"

#include <sys/stat.h>
#include <dirent.h>

@implementation QIMUtility

+ (NSData *)uncompress:(NSData *)data withUncompressedDataLength:(NSUInteger)length
{
    if([data length] == 0)
	{
		return data;
	}
	else
	{
		// 分配解压空间
		NSMutableData *decompressedData = [NSMutableData dataWithLength:length];  
		
		// 设置解压参数
		z_stream stream;  
		stream.next_in = (Bytef *)[data bytes];  
		stream.avail_in = (uInt)[data length];
		stream.total_in = 0;
		stream.next_out = (Bytef *)[decompressedData mutableBytes];  
		stream.avail_out = (uInt)[decompressedData length];
		stream.total_out = 0;  
		stream.zalloc = Z_NULL;  
		stream.zfree = Z_NULL;  
		stream.opaque = Z_NULL;
		
		// 初始化
		if(inflateInit(&stream) == Z_OK)
		{
			// 解压缩
			int status = inflate(&stream, Z_SYNC_FLUSH);
			if(status == Z_STREAM_END)
			{
				// 清除
				if(inflateEnd(&stream) == Z_OK)
				{
					return decompressedData;
				}
			}
		}
	}
	
	return nil;
}

+(NSString *) decrypt:(NSString *) text withKey:(NSString *) key {
    //
    // 先把字符串变成byte数组
    int len = (int)[text length] / 2;
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    for (int i = 0; i < len; i++) {
        byte_chars[0] = [text characterAtIndex:i * 2];
        byte_chars[1] = [text characterAtIndex:i * 2 + 1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    NSData *data = [NSData dataWithBytes:buf length:len];
    free(buf);
    
    const void *pData = [data bytes];
    uint8_t *pItem = (uint8_t *)pData;
    long crc = 
    crc = (long) (pItem[0] & 0xff) + ((long) (pItem[1] & 0xff) << 24) + (((long) (pItem[2] & 0xff)) << 16) + ((long) (pItem[3] & 0xff) << 8);
    
    uLong crc32Value = crc32(0L, Z_NULL, 0);
    crc32Value = crc32(crc32Value, (pItem + sizeof(uLong)), sizeof(uLong) * ([data length] - sizeof(uLong)));
    
    if (crc32Value == crc) {
        
        //
        // 说明可以搞
        // 加密字
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger keyLength = [keyData length];
        Byte *keyBytes = (Byte *)[keyData bytes];
        
        NSMutableData *resultData = [[NSMutableData alloc] initWithCapacity:100];
        
        Byte theData = (Byte)calloc(1, sizeof(Byte));
        for (int i = sizeof(uLong); i < [data length] - sizeof(uLong); i++) {
            theData = (int)(*(pItem + i)) -  keyLength;
            theData = (int)(*(pItem + i)) - keyBytes[i % keyLength];
            theData ^= 91;
            [resultData appendBytes:&theData length:sizeof(Byte)];
        }
        free(&theData);
        NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        return result;
    }
    return nil;
    
}

+ (NSString *)encrypt:(NSString *)text withKey:(NSString *)key
{
	// 加密字
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
	NSUInteger keyLength = [keyData length];
	Byte *keyBytes = (Byte *)[keyData bytes];
	
	// 旧的数据
	NSData *srcData = [text dataUsingEncoding:NSUTF8StringEncoding];
	NSUInteger srcLength = [srcData length];
	Byte* srcBytes = (Byte *)[srcData bytes];
	
	// 新的数据
	NSUInteger destLength = sizeof(uLong) + srcLength;
	Byte* destBytes = (Byte *)malloc(sizeof(Byte) * destLength);
	memcpy(destBytes + sizeof(uLong), srcBytes, sizeof(Byte) * srcLength);
	
	// 加密
	for(NSUInteger i = 0; i < srcLength; i++)
	{
		destBytes[i + sizeof(uLong)] ^= 91;
		destBytes[i + sizeof(uLong)] += keyBytes[i % keyLength];
	}
	
	// 计算CRC32
	uLong crc32Value = crc32(0L, Z_NULL, 0);
    crc32Value = crc32(crc32Value, destBytes + sizeof(uLong), sizeof(Byte) * srcLength);
	
	// 加密CRC32
	destBytes[0] = (Byte)crc32Value;
	destBytes[1] = (Byte)(crc32Value >> 24);
	destBytes[2] = (Byte)(crc32Value >> 8);
	destBytes[3] = (Byte)(crc32Value >> 16);
	
	// 通过字节数组得到字符串
	NSMutableString *destString = [[NSMutableString alloc] initWithString:@""];
	for(NSUInteger i = 0; i < destLength; i++)
	{
		Byte destByte = destBytes[i] & 0xFF;
		Byte destHexFirst = destByte / 16;
		Byte destHexSecond = destByte % 16;
		
		[destString appendFormat:@"%x%x", destHexFirst, destHexSecond];
	}
	free(destBytes);
	
	return destString;
}

+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize
{
	CGFloat scale;
	CGSize newsize;
	
	if(thisSize.width <= aSize.width && thisSize.height <= aSize.height)
	{
		newsize = thisSize;
	}
	else 
	{
		if(thisSize.width >= thisSize.height)
		{
			scale = aSize.width/thisSize.width;
			newsize.width = aSize.width;
			newsize.height = ceilf(thisSize.height*scale);
		}
		else 
		{
			scale = aSize.height/thisSize.height;
			newsize.height = aSize.height;
			newsize.width = ceilf(thisSize.width*scale);
		}
	}
    
	return newsize;
}

// Proportionately resize, completely fit in view, no cropping
+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewsize
{
	CGSize size = [QIMUtility fitSize:image.size inSize:viewsize];
    
    UIGraphicsBeginImageContext(size);
    
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationLow);
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	[image drawInRect:rect];
	
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return newimg;
}

+ (UIImage *)squareImage:(UIImage *)image width:(CGFloat)width
{
    if (image == nil)
        return nil;
    
    CGSize drawSize = image.size;
    
    if (drawSize.width >= drawSize.height && drawSize.height >= width)
    {
        drawSize.width = ceilf(drawSize.width * width / drawSize.height);
        drawSize.height = width;
    }
    else if (drawSize.height >= drawSize.width && drawSize.width >= width)
    {
        drawSize.height = ceilf(drawSize.height * width / drawSize.width);
        drawSize.width = width;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    
	CGRect rect = CGRectMake(floorf((width - drawSize.width)/2.0), floorf((width - drawSize.height)/2.0), drawSize.width, drawSize.height);
	[image drawInRect:rect];
	
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return newimg;

}



+ (NSString *)date2Interval:(NSString *)dateString
{
    NSString *retInterval = nil;
    
    // 转换的字符串是否有效
    if (dateString != nil && [dateString length] != 0)
    {
        // 当前日期
        NSDate *curDate = [NSDate date];
        
        // 获取日期字符串
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        
        // 是否是日期类型
        if (date != nil)
        {
            // 时间间隔
            int interval = [curDate timeIntervalSinceDate:date];
            
            if (interval < 0)
            {
                interval = 0;
            }
            
            // 转成分钟
            interval /= 60;
            
            // 判断是否是分钟
            if (interval < 60)
            {
                if (interval > 0)
                {
                    retInterval = [NSString stringWithFormat:@"%d分钟前", interval];
                }
                else
                {
                    retInterval = @"刚刚";
                }
            }
            else
            {
                // 转成小时
                interval /= 60;
                
                // 5小时内(含)
                if (interval <= 5)
                {
                    retInterval = [NSString stringWithFormat:@"%d小时前", interval];
                }
                else
                {
                    
                    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    
                    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
                    NSDateComponents *curDateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:curDate];
                    
                    if ([curDateComponents year] > [dateComponents year])
                    {
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        retInterval = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
                    }
                    else if ([curDateComponents year] == [dateComponents year])
                    {
                        
                        if ([curDateComponents month] > [dateComponents month])
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            retInterval = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
                        }
                        else if ([curDateComponents month] == [dateComponents month])
                        {
                            if ([curDateComponents day] == [dateComponents day])
                            {
                                [dateFormatter setDateFormat:@"HH:mm"];
                                retInterval = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"common_today", nil),[dateFormatter stringFromDate:date]];
                            }
                            else if ([curDateComponents day] - [dateComponents day] == 1)
                            {
                                [dateFormatter setDateFormat:@"HH:mm"];
                                retInterval = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"common_yesterday", nil),[dateFormatter stringFromDate:date]];
                            }
                            else if ([curDateComponents day] - [dateComponents day] == 2)
                            {
                                [dateFormatter setDateFormat:@"HH:mm"];
                                retInterval = [NSString stringWithFormat:@"前天 %@", [dateFormatter stringFromDate:date]];
                            }
                            else
                            {
                                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                retInterval = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
                            }
                        }
                        else
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            retInterval = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
                        }
                    }
                }
            }
        }
    }
    
    return retInterval;
}

// 根据版本使用不同的参数
+ (UIImage *)adjustImageFillSize:(NSString *)imageNamed capInsets:(UIEdgeInsets)capInsets
{
    if (imageNamed != nil && [imageNamed length] != 0)
    {
        UIImage *image = [UIImage imageNamed:imageNamed];
        if (image != nil)
        {
            if ([image respondsToSelector:@selector(resizableImageWithCapInsets:)] == YES)
            {
                return [image resizableImageWithCapInsets:capInsets];
            }
            else if ([image respondsToSelector:@selector(stretchableImageWithLeftCapWidth:topCapHeight:)] == YES)
            {
                return [image stretchableImageWithLeftCapWidth:capInsets.left topCapHeight:capInsets.top];
            }
        }
    }
    
    return nil;
}

+ (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location
{
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
    
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
    
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setValue:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setValue:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    
    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    
    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    
    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
    
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setValue:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
    
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setValue:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
    
    return gps;
}

+ (NSString *)getFullWeekend:(NSInteger)index
{
    switch (index)
	{
		case 1:
			return @"星期日";
		case 2:
			return @"星期一";
		case 3:
			return @"星期二";
		case 4:
			return @"星期三";
		case 5:
			return @"星期四";
		case 6:
			return @"星期五";
		case 7:
			return @"星期六";
	}
	
	return nil;
}

+ (void)performInBackground:(dispatch_block_t)block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

+ (BOOL)isPureNumandCharacters:(NSString *)string {
    NSString *result = [string stringByTrimmingCharactersInSet: [NSCharacterSet decimalDigitCharacterSet]];
    return ![result length];
}

+ (BOOL)isTelphoneNo:(NSString *)str {
    
    if ([str length] > 0) {
        //1[0-9]{10}
        
        //^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$
        
        //    NSString *regex = @"[0-9]{11}";
        
        NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        BOOL isMatch = [pred evaluateWithObject:str];
        
        return isMatch;
        
    }
    
    return NO;
}

+ (long long) sizeofPath:(NSString *) filePath {
    
    if ([filePath length] <= 0)
        return 0;
    
    long long folderSize = 0;
    
    const char* folderPath = [filePath UTF8String];
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        long long folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            NSString *strPath = [NSString stringWithUTF8String:childPath];
            folderSize += [QIMUtility sizeofPath:strPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }
    }
    return folderSize;
}

@end
