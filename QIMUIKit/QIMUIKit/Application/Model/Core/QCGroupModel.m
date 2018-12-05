//
//  QCGroupModel.m
//  qunarChatIphone
//
//  Created by c on 15/5/12.
//  Copyright (c) 2015年 c. All rights reserved.
//

#import "QCGroupModel.h"

@implementation QCGroupModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.groupId           = nil;
        self.groupName         = nil;
        self.groupAnnouncement = nil;
        self.groupAdmin        = nil;
        self.groupPermission   = QCGroupPermissionNone;
        self.members           = [NSMutableArray array];
    }
    return self;
}
@end
