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

#import "NSDate+QIMCategory.h"
#import "NSDateFormatter+QIMCategory.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation NSDate (QIMCategory)

/*距离当前的时间间隔描述*/
- (NSString *)qim_timeIntervalDescription
{
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];
	if (timeInterval < 60) {
        return @"1分钟内";
	} else if (timeInterval < 3600) {
        return [NSString stringWithFormat:@"%.f分钟前", timeInterval / 60];
	} else if (timeInterval < 86400) {
        return [NSString stringWithFormat:@"%.f小时前", timeInterval / 3600];
	} else if (timeInterval < 2592000) {//30天内
        return [NSString stringWithFormat:@"%.f天前", timeInterval / 86400];
    } else if (timeInterval < 31536000) {//30天至1年内
        NSDateFormatter *dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"M月d日"];
        return [dateFormatter stringFromDate:self];
    } else {
        return [NSString stringWithFormat:@"%.f年前", timeInterval / 31536000];
    }
}

/*精确到分钟的日期描述*/
- (NSString *)qim_minuteDescription
{
    NSDateFormatter *dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"yyyy-MM-dd"];
    
	NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
	NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    if ([theDay isEqualToString:currentDay]) {//当天
		[dateFormatter setDateFormat:@"ah:mm"];
        return [dateFormatter stringFromDate:self];
	} else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] < 86400 * 7) {//间隔一周内
        [dateFormatter setDateFormat:@"EEEE ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else {//以前
		[dateFormatter setDateFormat:@"yyyy-MM-dd ah:mm"];
        return [dateFormatter stringFromDate:self];
	}
}

- (NSString *)qim_MonthDescription {
    NSDateFormatter *dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"yyyy年-MM月"];
    
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月
    return theDay;
}

/*标准时间日期描述*/
-(NSString *)qim_formattedTime{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSString * dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(6,2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(4,2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间
 
    
    NSInteger hour = [self qim_hoursAfterDate:date];
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";
    
    //hasAMPM==TURE为12小时制，否则为24小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    
    if (!hasAMPM) { //24小时制
        if (hour <= 24 && hour >= 0) {
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"HH:mm"];
        }else if (hour < 0 && hour >= -24) {
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"昨天HH:mm"];
        }else {
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"yyyy-MM-dd"];
        }
    }else {
        if (hour >= 0 && hour <= 6) {
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"凌晨hh:mm"];
        }else if (hour > 6 && hour <=11 ) {
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"上午hh:mm"];
        }else if (hour > 11 && hour <= 17) {
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"下午hh:mm"];
        }else if (hour > 17 && hour <= 24) {
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"晚上hh:mm"];
        }else if (hour < 0 && hour >= -24){
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"昨天HH:mm"];
        }else  {
            dateFormatter = [NSDateFormatter qim_dateFormatterWithFormat:@"yyyy-MM-dd"];
        }
        
    }
    
    ret = [dateFormatter stringFromDate:self];
    return ret;
}

/*格式化日期描述*/
- (NSString *)qim_dayDescription
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    if ([theDay isEqualToString:currentDay]) {//当天
        return [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"common_today", nil),[dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        return [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"common_yesterday", nil),[dateFormatter stringFromDate:self]];
    } else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        return [dateFormatter stringFromDate:self];
    }
}

/*格式化日期描述*/
- (NSString *)qim_formattedDateDescription
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
	NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    
//    NSInteger timeInterval = -[self timeIntervalSinceNow];
//    if (timeInterval < 60) {
//        return @"1分钟内";
//	} else if (timeInterval < 3600) {//1小时内
//        return [NSString stringWithFormat:@"%d分钟前", timeInterval / 60];
//	} else if (timeInterval < 21600) {//6小时内
//        return [NSString stringWithFormat:@"%d小时前", timeInterval / 3600];
//	} else
    if ([theDay isEqualToString:currentDay]) {//当天
		[dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"%@ %@",@"今天",[dateFormatter stringFromDate:self]];
	} else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"%@ %@",@"昨天",[dateFormatter stringFromDate:self]];
    } else {//以前
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateFormatter stringFromDate:self];
	}
}

- (double)qim_timeIntervalSince1970InMilliSecond {
    double ret;
    ret = [self timeIntervalSince1970] * 1000;
    
    return ret;
}

+ (NSDate *)qim_dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond {
    NSDate *ret = nil;
    double timeInterval = timeIntervalInMilliSecond;
    // judge if the argument is in secconds(for former data structure).
    if(timeIntervalInMilliSecond > 140000000000) {
        timeInterval = timeIntervalInMilliSecond / 1000;
    }
    ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return ret;
}

+ (NSString *)qim_formattedTimeFromTimeInterval:(long long)time{
    return [[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:time] qim_formattedTime];
}

#pragma mark Relative Dates

+ (NSDate *) qim_dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
	return [[NSDate date] qim_dateByAddingDays:days];
}

+ (NSDate *) qim_dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
	return [[NSDate date] qim_dateBySubtractingDays:days];
}

+ (NSDate *) qim_dateTomorrow
{
	return [NSDate qim_dateWithDaysFromNow:1];
}

+ (NSDate *) qim_dateYesterday
{
	return [NSDate qim_dateWithDaysBeforeNow:1];
}

+ (NSDate *) qim_dateWithHoursFromNow: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) qim_dateWithHoursBeforeNow: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) qim_dateWithMinutesFromNow: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) qim_dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

#pragma mark Comparing Dates

- (BOOL) qim_isEqualToDateIgnoringTime: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) &&
			(components1.day == components2.day));
}

- (BOOL) qim_isToday
{
	return [self qim_isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) qim_isTomorrow
{
	return [self qim_isEqualToDateIgnoringTime:[NSDate qim_dateTomorrow]];
}

- (BOOL) qim_isYesterday
{
	return [self qim_isEqualToDateIgnoringTime:[NSDate qim_dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) qim_isSameWeekAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	
	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if (components1.week != components2.week) return NO;
	
	// Must have a time interval under 1 week. Thanks @aclark
	return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) qim_isThisWeek
{
	return [self qim_isSameWeekAsDate:[NSDate date]];
}

- (BOOL) qim_isNextWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self qim_isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self qim_isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL) qim_isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) qim_isThisMonth
{
    return [self qim_isSameMonthAsDate:[NSDate date]];
}

- (BOOL) qim_isSameYearAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
	return (components1.year == components2.year);
}

- (BOOL) qim_isThisYear
{
    // Thanks, baspellis
	return [self qim_isSameYearAsDate:[NSDate date]];
}

- (BOOL) qim_isNextYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return (components1.year == (components2.year + 1));
}

- (BOOL) qim_isLastYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return (components1.year == (components2.year - 1));
}

- (BOOL) qim_isEarlierThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) qim_isLaterThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL) qim_isInFuture
{
    return ([self qim_isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL) qim_isInPast
{
    return ([self qim_isEarlierThanDate:[NSDate date]]);
}


#pragma mark Roles
- (BOOL) qim_isTypicallyWeekend
{
    NSDateComponents *components = [CURRENT_CALENDAR components:NSWeekdayCalendarUnit fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) qim_isTypicallyWorkday
{
    return ![self qim_isTypicallyWeekend];
}

#pragma mark Adjusting Dates

//将时间点转化成日历形式
+ (NSDate *)getCustomDateWithHour:(NSInteger)hour {
    
    //获取当前时间
    NSDate * destinationDateNow = [NSDate date];

    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *currentComps = [[NSDateComponents alloc] init];

    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;

    currentComps = [currentCalendar components:unitFlags fromDate:destinationDateNow];

    //设置当前的时间点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];

    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

//获取时间段
+ (QIMDateDayType)qim_getTheTimeBucket {

    NSDate * currentDate = [NSDate date];
    if ([currentDate compare:[NSDate getCustomDateWithHour:0]] == NSOrderedDescending && [currentDate compare:[NSDate getCustomDateWithHour:9]] == NSOrderedAscending) {
        return QIMDateDayTypeMorning;
    } else if ([currentDate compare:[NSDate getCustomDateWithHour:9]] == NSOrderedDescending && [currentDate compare:[NSDate getCustomDateWithHour:11]] == NSOrderedAscending) {
    
        return QIMDateDayTypeMorning;
    } else if ([currentDate compare:[NSDate getCustomDateWithHour:11]] == NSOrderedDescending && [currentDate compare:[NSDate getCustomDateWithHour:13]] == NSOrderedAscending) {
        
        return QIMDateDayTypeAfternoon;
   } else if ([currentDate compare:[NSDate getCustomDateWithHour:13]] == NSOrderedDescending && [currentDate compare:[NSDate getCustomDateWithHour:18]] == NSOrderedAscending) {
    
        return QIMDateDayTypeAfternoon;
    } else {
        return QIMDateDayTypeNight;
    }
}

- (NSDate *) qim_dateByAddingDays: (NSInteger) dDays
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) qim_dateBySubtractingDays: (NSInteger) dDays
{
	return [self qim_dateByAddingDays: (dDays * -1)];
}

- (NSDate *) qim_dateByAddingHours: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) qim_dateBySubtractingHours: (NSInteger) dHours
{
	return [self qim_dateByAddingHours: (dHours * -1)];
}

- (NSDate *) qim_dateByAddingMinutes: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) qim_dateBySubtractingMinutes: (NSInteger) dMinutes
{
	return [self qim_dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *) qim_dateAtStartOfDay
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *) qim_componentsWithOffsetFromDate: (NSDate *) aDate
{
	NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
	return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger) qim_minutesAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) qim_minutesBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) qim_hoursAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) qim_hoursBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) qim_daysAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_DAY);
}

- (NSInteger) qim_daysBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)qim_distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}

#pragma mark Decomposing Dates

- (NSInteger) qim_nearestHour
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
	return components.hour;
}

- (NSInteger) qim_hour
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.hour;
}

- (NSInteger) qim_minute
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.minute;
}

- (NSInteger) qim_seconds
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.second;
}

- (NSInteger) qim_day
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.day;
}

- (NSInteger) qim_month
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.month;
}

- (NSInteger) qim_week
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.week;
}

- (NSInteger) qim_weekday
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.weekday;
}

- (NSInteger) qim_nthWeekday // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.weekdayOrdinal;
}

- (NSInteger) qim_year
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.year;
}

@end
