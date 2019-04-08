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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

typedef enum : NSUInteger {
    QIMDateDayTypeMorning,
    QIMDateDayTypeNoon,
    QIMDateDayTypeAfternoon,
    QIMDateDayTypeNight,
} QIMDateDayType;

@interface NSDate (QIMCategory)

- (NSString *)qim_timeIntervalDescription;//距离当前的时间间隔描述
- (NSString *)qim_minuteDescription;/*精确到分钟的日期描述*/
- (NSString *)qim_MonthDescription; /*精确到月的日期描述*/
- (NSString *)qim_dayDescription;
- (NSString *)qim_formattedTime;
- (NSString *)qim_formattedDateDescription;//格式化日期描述
- (double)qim_timeIntervalSince1970InMilliSecond;
+ (NSDate *)qim_dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;
+ (NSString *)qim_formattedTimeFromTimeInterval:(long long)time;
// Relative dates from the current date
+ (NSDate *) qim_dateTomorrow;
+ (NSDate *) qim_dateYesterday;
+ (NSDate *) qim_dateWithDaysFromNow: (NSInteger) days;
+ (NSDate *) qim_dateWithDaysBeforeNow: (NSInteger) days;
+ (NSDate *) qim_dateWithHoursFromNow: (NSInteger) dHours;
+ (NSDate *) qim_dateWithHoursBeforeNow: (NSInteger) dHours;
+ (NSDate *) qim_dateWithMinutesFromNow: (NSInteger) dMinutes;
+ (NSDate *) qim_dateWithMinutesBeforeNow: (NSInteger) dMinutes;

// Comparing dates
- (BOOL) qim_isEqualToDateIgnoringTime: (NSDate *) aDate;
- (BOOL) qim_isToday;
- (BOOL) qim_isTomorrow;
- (BOOL) qim_isYesterday;
- (BOOL) qim_isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) qim_isThisWeek;
- (BOOL) qim_isNextWeek;
- (BOOL) qim_isLastWeek;
- (BOOL) qim_isSameMonthAsDate: (NSDate *) aDate;
- (BOOL) qim_isThisMonth;
- (BOOL) qim_isSameYearAsDate: (NSDate *) aDate;
- (BOOL) qim_isThisYear;
- (BOOL) qim_isNextYear;
- (BOOL) qim_isLastYear;
- (BOOL) qim_isEarlierThanDate: (NSDate *) aDate;
- (BOOL) qim_isLaterThanDate: (NSDate *) aDate;
- (BOOL) qim_isInFuture;
- (BOOL) qim_isInPast;

// Date roles
- (BOOL) qim_isTypicallyWorkday;
- (BOOL) qim_isTypicallyWeekend;

//获取时间段
+ (QIMDateDayType)qim_getTheTimeBucket;

// Adjusting dates
- (NSDate *) qim_dateByAddingDays: (NSInteger) dDays;
- (NSDate *) qim_dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) qim_dateByAddingHours: (NSInteger) dHours;
- (NSDate *) qim_dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) qim_dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) qim_dateBySubtractingMinutes: (NSInteger) dMinutes;
- (NSDate *) qim_dateAtStartOfDay;

// Retrieving intervals
- (NSInteger) qim_minutesAfterDate: (NSDate *) aDate;
- (NSInteger) qim_minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) qim_hoursAfterDate: (NSDate *) aDate;
- (NSInteger) qim_hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) qim_daysAfterDate: (NSDate *) aDate;
- (NSInteger) qim_daysBeforeDate: (NSDate *) aDate;
- (NSInteger)qim_distanceInDaysToDate:(NSDate *)anotherDate;

// Decomposing dates
@property (readonly) NSInteger qim_nearestHour;
@property (readonly) NSInteger qim_hour;
@property (readonly) NSInteger qim_minute;
@property (readonly) NSInteger qim_seconds;
@property (readonly) NSInteger qim_day;
@property (readonly) NSInteger qim_month;
@property (readonly) NSInteger qim_week;
@property (readonly) NSInteger qim_weekday;
@property (readonly) NSInteger qim_nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger qim_year;

@end
