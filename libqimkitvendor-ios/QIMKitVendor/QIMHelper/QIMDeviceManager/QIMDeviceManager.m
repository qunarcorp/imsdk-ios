//
//  QIMDeviceManager.m
//  QIMUIKit
//
//  Created by 李露 on 10/10/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMDeviceManager.h"
// 判断是否是iPhone X
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

// 状态栏高度
#define STATUS_BAR_HEIGHT (iPhoneX ? 44.f : 20.f)
// 导航栏高度
#define NAVIGATION_BAR_HEIGHT (iPhoneX ? 88.f : 64.f)
// tabBar高度
#define TAB_BAR_HEIGHT (iPhoneX ? (49.f+34.f) : 49.f)
// home indicator
#define HOME_INDICATOR_HEIGHT (iPhoneX ? 34.f : 0.f)

@implementation QIMDeviceManager

static QIMDeviceManager *_deviceManager = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceManager = [[QIMDeviceManager alloc] init];
    });
    return _deviceManager;
}

- (BOOL)isIphoneXSeries {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    
    return iPhoneXSeries;
}

- (CGFloat)getHOME_INDICATOR_HEIGHT {
    return [self isIphoneXSeries] ? 34.0f : 0.0f;
}

- (CGFloat)getTAB_BAR_HEIGHT {
    return [self isIphoneXSeries] ? (49.0f+34.0f) : 49.0f;
}

- (CGFloat)getNAVIGATION_BAR_HEIGHT {
    return [self isIphoneXSeries] ? 88.0f : 64.0f;
}

- (CGFloat)getSTATUS_BAR_HEIGHT {
    return [self isIphoneXSeries] ? 44.f : 20.f;
}

@end
