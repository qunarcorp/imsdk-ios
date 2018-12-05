//
//  QCDepartmentModel.m
//  qunarChatIphone
//
//  Created by c on 15/5/12.
//  Copyright (c) 2015年 c. All rights reserved.
//

#import "QCDepartmentModel.h"

@implementation QCDepartmentModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.departmentId           = nil;
        self.departmentName         = nil;
        self.departmentLevel        = -1;
        self.departmentMembersCount = 0;
        self.members                = [NSMutableArray array];
    }
    return self;
}

@end
