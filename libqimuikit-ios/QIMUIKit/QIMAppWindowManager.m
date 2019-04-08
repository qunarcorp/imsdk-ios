//
//  QIMAppWindowManager.m
//  QIMUIKit
//
//  Created by 李露 on 2018/6/13.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMAppWindowManager.h"
#import "QIMCommonUIFramework.h"

@implementation QIMAppWindowManager

static QIMAppWindowManager *_windowManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _windowManager = [[QIMAppWindowManager alloc] init];
    });
    return _windowManager;
}

@end
