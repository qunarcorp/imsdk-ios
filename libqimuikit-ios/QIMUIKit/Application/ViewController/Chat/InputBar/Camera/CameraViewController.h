//
//  ViewController.h
//  AVFoundationCamera
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

- (void)cameraViewCaontroller:(CameraViewController *)cameraVC didFinishPickingMediaWithInfo:(NSDictionary *)info;

- (void)cameraViewCaontrollerDidCancel:(CameraViewController *)cameraVC;

@end

@interface CameraViewController : UIViewController

@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递

@property (nonatomic,assign)id<CameraViewControllerDelegate> delegate;


@end

