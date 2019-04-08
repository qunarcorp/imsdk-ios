//
//  QCUserModel.m
//  qunarChatIphone
//
//  Created by c on 15/5/12.
//  Copyright (c) 2015年 c. All rights reserved.
//

#import "QCUserModel.h"

@implementation QCUserModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userId         = nil;
        self.rtxId          = nil;
        self.username       = nil;
        self.nickname       = nil;
        self.password       = nil;
        self.avatar         = nil;
        self.email          = nil;
        self.gender         = QCUserGenderNone;
        self.isOnline       = NO;
        self.lastOnlineTime = 0;
    }
    return self;
}

#pragma mark - setter
-(void)setGender:(QCUserGender)gender
{
    if (gender == QCUserGenderFemale) {
        self.genderToString = @"女";
    }else {
        self.genderToString = @"男";
    }
    self.gender = gender;
}

-(void)setIsOnline:(BOOL)isOnline
{
    if (isOnline == YES) {
        self.lastOnlineTime = [[NSDate alloc] timeIntervalSince1970];
    }
    self.isOnline = isOnline;
}

@end
