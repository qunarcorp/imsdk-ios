/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "NSDateFormatter+QIMCategory.h"

@implementation NSDateFormatter (QIMCategory)

+ (id)qim_dateFormatter
{
    return [[self alloc] init];
}

+ (id)qim_dateFormatterWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[self alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (id)qim_defaultDateFormatter
{
    return [self qim_dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

@end
