//
//  QIMCalendarsManager.h
//  QIMGeneralModule
//
//  Created by 李露 on 2018/9/10.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completion)(BOOL granted, NSError *error);

@interface QIMCalendarsManager : NSObject

+ (instancetype)sharedEventCalendar;

// 检测日历功能是否可以使用
- (void)checkCalendarCanUsedCompletion:(completion)completion;

/**
 *  添加日历提醒事项
 *
 *  @param title      事件标题
 *  @param location   事件位置
 *  @param startDate  开始时间
 *  @param endDate    结束时间
 *  @param allDay     是否全天
 *  @param alarmArray 闹钟集合
 *  @param completion 回调方法
 */
- (void)createEventCalendarTitle:(NSString *)title addLocation:(NSString *)location addStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addAllDay:(BOOL)allDay addAlarmArray:(NSArray *)alarmArray addCompletion:(completion)completion;


/**
 *  查日历事件
 *
 *  @param startDate  开始时间
 *  @param endDate    结束时间
 *  @param modifytitle    标识符-标题，为空则都要查询
 */
- (NSArray *)checkToStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addModifytitle:(NSString *)modifytitle;

/**
 *  删除日历事件
 *
 *  @param startDate  开始时间
 *  @param endDate    结束时间
 *  @param modifytitle    标识符-标题，为空则都要删除
 */
- (BOOL)deleteCalendarStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addModifytitle:(NSString *)modifytitle;

/**
 *  修改日历
 *
 *  @param title      事件标题
 *  @param location   事件位置
 *  @param modifytitle  标识符
 *  @param startDate  开始时间
 *  @param endDate    结束时间
 *  @param allDay     是否全天
 *  @param alarmArray 闹钟集合
 *  @param completion 回调方法
 */
- (void)modifyCalendarCalendarTitle:(NSString *)title addLocation:(NSString *)location addModifytitle:(NSString *)modifytitle addStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addAllDay:(BOOL)allDay addAlarmArray:(NSArray *)alarmArray addCompletion:(completion)completion;

@end
