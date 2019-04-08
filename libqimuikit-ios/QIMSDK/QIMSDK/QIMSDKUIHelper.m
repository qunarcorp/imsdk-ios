//
//  QIMSDKUIHelper.m
//  QIMSDK
//
//  Created by 李露 on 2018/9/29.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMSDKUIHelper.h"
#import "QIMFastEntrance.h"
#import "QIMNotificationManager.h"
//#import "QIMBusinessModleUpdate.h"
#import "QIMRemoteNotificationManager.h"

@interface QIMSDKUIHelper ()

@property (nonatomic, strong) UINavigationController *rootNav;

@property (nonatomic, strong) UIViewController *rootVc;

@end

@implementation QIMSDKUIHelper

+ (void)load {
    
    [QIMNotificationManager sharedInstance];
}

static QIMSDKUIHelper *_uiHelper = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _uiHelper = [[QIMSDKUIHelper alloc] init];
        [QIMKit sharedInstance];
    });
    return _uiHelper;
}

+ (instancetype)sharedInstanceWithRootNav:(UINavigationController *)rootNav rootVc:(UIViewController *)rootVc {
    QIMSDKUIHelper *helper = [QIMSDKUIHelper shareInstance];
    if (rootNav && rootVc) {
        helper.rootNav = rootNav;
        helper.rootVc = rootVc;
        [QIMFastEntrance sharedInstanceWithRootNav:rootNav rootVc:rootVc];
    } else {
        NSAssert(rootNav, @"RootNav shuold not be nil, Please check the rootNav");
        NSAssert(rootVc, @"RootVc should not be nil, Please check the rootVC");
    }
    return helper;
}

- (void)checkUpNotifacationHandle {
    [QIMRemoteNotificationManager checkUpNotifacationHandle];
}

- (void)updateMicroTourModel {
//    [QIMBusinessModleUpdate updateMicroTourModel];
}

@end
