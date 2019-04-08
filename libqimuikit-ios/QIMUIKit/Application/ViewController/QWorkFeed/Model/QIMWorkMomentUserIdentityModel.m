//
//  QIMWorkMomentUserIdentityModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentUserIdentityModel.h"

@implementation QIMWorkMomentUserIdentityModel

@end

@implementation QIMWorkMomentUserIdentityManager

static QIMWorkMomentUserIdentityManager *_manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[QIMWorkMomentUserIdentityManager alloc] init];
        _manager.isAnonymous = NO;
    });
    return _manager;
}

@end
