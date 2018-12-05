//
//  QCDepartmentModel.h
//  qunarChatIphone
//
//  Created by c on 15/5/12.
//  Copyright (c) 2015年 c. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QCDepartmentModel : NSObject

@property (nonatomic, strong) NSString       * departmentId;            //部门id
@property (nonatomic, strong) NSString       * departmentName;          //部门名称
@property (nonatomic, assign) int              departmentLevel;         //部门level
@property (nonatomic, assign) int              departmentMembersCount;  //部门人数

@property (nonatomic, strong) NSMutableArray * members;                 //部门成员

@end
