//
//  QTalkPermissionManager.m
//  Noob2017
//
//  Created by lihuaqi on 2017/9/11.
//  Copyright © 2017年 lihuaqi. All rights reserved.
//

#import "QIMAuthorizationManager.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

static NSString* const kAuthorizationPhotoPromot = @"无法使用相册";
static NSString* const kAuthorizationPhotosMessage = @"请在iPhone的\"设置-隐私-相册\"中允许访问相册。";
static NSString* const kAuthorizationPhotosOpenURL = @"";

static NSString* const kAuthorizationCameraPromot = @"无法使用相机";
static NSString* const kAuthorizationCameraMessage = @"请在iPhone的\"设置-隐私-相机\"中允许访问相机。";
static NSString* const kAuthorizationCameraOpenURL = @"";

static NSString* const kAuthorizationLocationPromot = @"无法使用定位";
static NSString* const kAuthorizationLocationMessage = @"请在iPhone的\"设置-隐私-定位服务\"中允许访问相册。";
static NSString* const kAuthorizationLocationOpenURL = @"";

static QIMAuthorizationManager *instance = nil;

@implementation QIMAuthorizationManager
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return instance;
}

- (void)requestAuthorizationWithType:(ENUM_QAM_AuthorizationType )authorizationType {
    if (authorizationType == ENUM_QAM_AuthorizationTypePhotos) {
        [self requestAuthorizationForPhotos];
    }else if (authorizationType == ENUM_QAM_AuthorizationTypeCamera) {
        [self requestAuthorizationForCamera];
    }else if (authorizationType == ENUM_QAM_AuthorizationTypeLocation) {
        [self requestAuthorizationForLocation];
    }
}

#pragma --以后新增权限只要增加类似下面的一个方法即可
- (void)requestAuthorizationForPhotos {
    //这里的写法原因是项目中的照片控制器有问题：进入相册后再判断权限，点击不允许，再取消就崩了
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        [self settingAuthorizationsTitle:kAuthorizationPhotoPromot Message:kAuthorizationPhotosMessage openUrl:kAuthorizationPhotosOpenURL];
    }else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                if (self.authorizedBlock) {
                    self.authorizedBlock();
                }
            }else{
                //不允许就不让进入相册
                return ;
            }
        }];
        
    }else if (status == PHAuthorizationStatusAuthorized ){
        //QIMVerboseLog(@"允许当前应用访问相册");
        if (self.authorizedBlock) {
            self.authorizedBlock();
        }
    }
}

- (void)requestAuthorizationForCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self settingAuthorizationsTitle:kAuthorizationCameraPromot Message:kAuthorizationCameraMessage openUrl:kAuthorizationCameraOpenURL];
    }else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                //QIMVerboseLog(@"允许当前应用访问相机");
                if (self.authorizedBlock) {
                    self.authorizedBlock();
                }
            }else {
                //不允许就不让进入相册
                return ;
            }
        }];
        
    }else if (status == AVAuthorizationStatusAuthorized){
        if (self.authorizedBlock) {
            self.authorizedBlock();
        }
    }
}

- (void)requestAuthorizationForLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted ) {
        [self settingAuthorizationsTitle:kAuthorizationLocationPromot Message:kAuthorizationLocationMessage openUrl:kAuthorizationLocationOpenURL];
    }else {
        //QIMVerboseLog(@"允许当前应用开启定位");
        if (self.authorizedBlock) {
            self.authorizedBlock();
        }
    }
}

- (void)settingAuthorizationsTitle:(NSString *)title Message:(NSString *)message openUrl:(NSString *)openUrl {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: title
                                                                              message: message
                                                                       preferredStyle: UIAlertControllerStyleAlert];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"好的"
                                                         style: UIAlertActionStyleDefault
                                                       handler: ^(UIAlertAction *action) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
    }]];
    
//    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
//                                                         style: UIAlertActionStyleCancel
//                                                       handler: nil]];
    
    UIViewController *vc = [self getCurrentVC];
    
    if (vc) {

      [vc presentViewController:alertController animated:YES completion: nil];
    }
}


#pragma --查询用户授权状态，以后可能用通知的方式提醒用户开启某项权限
- (NSMutableDictionary *)authorizationStatus {
    NSMutableDictionary *authorizationDic = [NSMutableDictionary dictionaryWithCapacity:10];
    PHAuthorizationStatus statusPhotos = [PHPhotoLibrary authorizationStatus];
    if (statusPhotos == PHAuthorizationStatusDenied || statusPhotos == PHAuthorizationStatusRestricted) {
        //1 该权限是被拒绝状态
        [authorizationDic setValue:@(1) forKey:@"statusPhotos"];
    }else if (statusPhotos == PHAuthorizationStatusNotDetermined){
        //3 该权限是为确定状态，没有使用过该权限
        [authorizationDic setValue:@(3) forKey:@"statusPhotos"];
    }else {
        //0 该权限是允许状态
        [authorizationDic setValue:@(0) forKey:@"statusPhotos"];
    }
    
    AVAuthorizationStatus statusCamera = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusCamera == PHAuthorizationStatusDenied || statusPhotos == PHAuthorizationStatusRestricted) {
        [authorizationDic setValue:@(1) forKey:@"statusCamera"];
    }else if (statusCamera == PHAuthorizationStatusNotDetermined){
        [authorizationDic setValue:@(3) forKey:@"statusCamera"];
    }else {
        [authorizationDic setValue:@(0) forKey:@"statusCamera"];
    }
    
    CLAuthorizationStatus statusLocation = [CLLocationManager authorizationStatus];
    if (statusLocation == kCLAuthorizationStatusDenied || statusLocation == kCLAuthorizationStatusRestricted) {
        [authorizationDic setValue:@(1) forKey:@"statusLocation"];
    }else if (statusLocation == kCLAuthorizationStatusNotDetermined){
        [authorizationDic setValue:@(3) forKey:@"statusLocation"];
    }else {
        [authorizationDic setValue:@(0) forKey:@"statusLocation"];
    }
    return authorizationDic;
}


//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
@end
