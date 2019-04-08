//
//  QIMKit+QIMCalendar.h
//  QIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMCalendar)

- (NSArray *)selectTripByYearMonth:(NSString *)date;

- (void)createTrip:(NSDictionary *)param callBack:(QIMKitCreateTripBlock)callback;

- (void)getTripAreaAvailableRoom:(NSDictionary *)dateDic callBack:(QIMKitGetTripAreaAvailableRoomBlock)callback;

- (void)tripMemberCheck:(NSDictionary *)params callback:(QIMKitGetTripMemberCheckBlock)callback;

- (NSArray *)getLocalAreaList;

- (void)getRemoteAreaList;

@end
