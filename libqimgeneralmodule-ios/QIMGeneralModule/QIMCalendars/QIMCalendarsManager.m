//
//  QIMCalendarsManager.m
//  QIMGeneralModule
//
//  Created by 李露 on 2018/9/10.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMCalendarsManager.h"
#import <EventKit/EventKit.h>
#import "QIMPublicRedefineHeader.h"

@interface QIMCalendarsManager ()

@property (nonatomic ,copy) completion  completion;

@property (nonatomic, strong) EKEventStore *eventStore;

@property (nonatomic, strong) EKCalendar *enevtCalendar;

@end

@implementation QIMCalendarsManager

+ (instancetype)sharedEventCalendar{
    static QIMCalendarsManager *eventCalendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventCalendar = [[QIMCalendarsManager alloc] init];
        eventCalendar.eventStore = [[EKEventStore alloc] init];
        eventCalendar.enevtCalendar = [eventCalendar.eventStore defaultCalendarForNewEvents];
        eventCalendar.enevtCalendar.title = @"QTalk";
        eventCalendar.enevtCalendar.CGColor = [UIColor greenColor].CGColor;
    });
    return eventCalendar;
}

// 检测日历功能是否可以使用
- (void)checkCalendarCanUsedCompletion:(completion)completion{
    //    EKEntityTypeEvent日历事件
    //    EKEntityTypeReminder提醒事项
    self.completion = completion;
    EKAuthorizationStatus eventStatus = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
    if (eventStatus == EKAuthorizationStatusAuthorized) {
        if (self.completion) {
            self.completion(YES, nil);
        }
    }else if(eventStatus == EKAuthorizationStatusNotDetermined){
        __block  BOOL isGranted = NO;
        __block  NSError *isError;
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            isGranted = granted;
            isError = error;
            if (granted) {
                QIMVerboseLog(@"用户点击了允许访问日历");
            }else{
                QIMVerboseLog(@"用户没有点允许访问日历");
            }
        }];
        if(self.completion){
            self.completion(isGranted, isError);
        }
    }
}

// 查日历事件：startDate/endDate : 开始/结束时间 modifytitle:标题，为空则都要查询
- (NSArray *)checkToStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addModifytitle:(NSString *)modifytitle{
    
    // 查询到所有的日历
    NSArray *tempA = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *only3D = [NSMutableArray array];
    
    for (int i = 0 ; i < tempA.count; i ++) {
        
        EKCalendar *temCalendar = tempA[i];
        EKCalendarType type = temCalendar.type;
        // 工作、家庭和本地日历
        if (type == EKCalendarTypeLocal || type == EKCalendarTypeCalDAV) {
            
            [only3D addObject:temCalendar];
        }
    }
    
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:only3D];
    
    // 获取到范围内的所有事件
    NSArray *request = [self.eventStore eventsMatchingPredicate:predicate];
    // 按开始事件进行排序
    request = [request sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    
    if (!modifytitle || [modifytitle isEqualToString:@""]) {
        return request;
    }else{
        NSMutableArray *onlyRequest = [NSMutableArray array];
        for (int i = 0; i < request.count; i++) {
            EKEvent *event = request[i];
            if (event.title && [event.title isEqualToString:modifytitle]) {
                [onlyRequest addObject:event];
            }
        }
        return onlyRequest;
    }
}

// 写入日历
- (void)createEventCalendarTitle:(NSString *)title addLocation:(NSString *)location addStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addAllDay:(BOOL)allDay addAlarmArray:(NSArray *)alarmArray addCompletion:(completion)completion{
    
    self.completion = completion;
    
    if ([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error){
                    
                }else if (!granted){
                    
                }else{
                    EKEvent *event  = [EKEvent eventWithEventStore:self.eventStore];
                    event.title = title;
                    event.location = location;
                    
                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                    
                    event.startDate = startDate;
                    event.endDate   = endDate;
                    // 是否设置全天
                    event.allDay = allDay;
                    //添加提醒
                    if (alarmArray && alarmArray.count > 0) {
                        for (NSString *timeString in alarmArray) {
                            [event addAlarm:[EKAlarm alarmWithRelativeOffset:[timeString integerValue]]];
                            
                        }
                    }
                    //默认日历类型
                    [event setCalendar:[self.eventStore defaultCalendarForNewEvents]];
                    // 保存日历
                    NSError *err;
                    
                    [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                    QIMVerboseLog(@"eventId : %@", event.eventIdentifier);
                    if (self.completion) {
                        
                        self.completion(granted,error);
                    }
                }
            });
        }];
    }
}

// 删除日历事件
- (BOOL)deleteCalendarStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addModifytitle:(NSString *)modifytitle{
    // 获取到此事件
    NSArray *request = [self checkToStartDate:startDate addEndDate:endDate addModifytitle:modifytitle];
    
    for (int i = 0; i < request.count; i ++) {
        // 删除这一条事件
        EKEvent *event = request[i];
        [event setCalendar:[self.eventStore defaultCalendarForNewEvents]];
        NSError*error =nil;
        
        // commit:NO：最后再一次性提交
        [self.eventStore removeEvent:event span:EKSpanThisEvent commit:NO error:&error];
    }
    //一次提交所有操作到事件库
    NSError *errored = nil;
    BOOL commitSuccess= [self.eventStore commit:&errored];
    return commitSuccess;
}

// 修改日历
- (void)modifyCalendarCalendarTitle:(NSString *)title addLocation:(NSString *)location addModifytitle:(NSString *)modifytitle addStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addAllDay:(BOOL)allDay addAlarmArray:(NSArray *)alarmArray addCompletion:(completion)completion{
    // 获取到此事件
    EKEvent *event = [self.eventStore eventWithIdentifier:@"A192C190-C2BB-43A4-8F30-DF458241B5FE:0A63C85C736D47EDBD63F"];
    QIMVerboseLog(@"event : %@", event);
    return;
    NSArray *request = [self checkToStartDate:startDate addEndDate:endDate addModifytitle:modifytitle];
    if (request.count > 0 ) {
        for (int i = 0; i < request.count; i++) {
            [self deleteCalendarStartDate:startDate addEndDate:endDate addModifytitle:modifytitle];
            
            [self createEventCalendarTitle:title addLocation:location addStartDate:startDate addEndDate:endDate addAllDay:allDay addAlarmArray:alarmArray addCompletion:completion];
        }
    } else{
        // 没有此条日历
        [self createEventCalendarTitle:title addLocation:location addStartDate:startDate addEndDate:endDate addAllDay:allDay addAlarmArray:alarmArray addCompletion:completion];
    }
}

- (void)modifyCalendarWithEventId:(NSString *)identi CalendarTitle:(NSString *)title addLocation:(NSString *)location addModifytitle:(NSString *)modifytitle addStartDate:(NSDate *)startDate addEndDate:(NSDate *)endDate addAllDay:(BOOL)allDay addAlarmArray:(NSArray *)alarmArray addCompletion:(completion)completion {
    EKEvent *event = [self.eventStore eventWithIdentifier:@"A192C190-C2BB-43A4-8F30-DF458241B5FE:0A63C85C736D47EDBD63FC37514C18F80"];
    QIMVerboseLog(@"event : %@", event);
}

@end
