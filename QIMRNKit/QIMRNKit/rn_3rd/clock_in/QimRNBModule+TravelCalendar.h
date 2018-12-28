//
//  QimRNBModule+TravelCalendar.h
//  QIMRNKit
//
//  Created by 李露 on 2018/9/7.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QimRNBModule.h"
#import "QIMCommonUIFramework.h"

@interface QimRNBModule (TravelCalendar)

- (NSDictionary *)qimrn_grtRNDataByTrip:(NSDictionary *)tripItem;

- (void)qimrn_selectUserTripByDate:(NSDictionary *)params;

- (NSArray *)qimrn_getTripArea;

@end
