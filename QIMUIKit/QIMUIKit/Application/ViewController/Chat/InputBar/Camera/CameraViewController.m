//
//  ViewController.m
//  AVFoundationCamera
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

#import "CameraViewController.h"
#import "QIMImageUtil.h"
#import "UIImage+MultiFormat.h"

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

typedef enum {
    cameraTypeTakePhoto,
    cameraTypeRecording,
} CameraType;

@interface CameraViewController ()<AVCaptureFileOutputRecordingDelegate,UIAccelerometerDelegate>

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL navBarHidden;
@property (nonatomic, assign) CameraType cameraType;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic, strong) UILabel *timeDisplayLabel;

@property (nonatomic, strong) UIButton *videoBtn;
@property (nonatomic, strong) UIButton *photoBtn;

@property (nonatomic, assign) UIInterfaceOrientation deviceOrientation;

@property (nonatomic, strong) CMMotionManager *cmManager;

@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流流
@property (strong,nonatomic)     AVCaptureDeviceInput *audioCaptureDeviceInput;//音频
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@property (strong, nonatomic)  UIView *takePhotoViewContainer;//拍照
//@property (strong, nonatomic)  UIView *recordingViewContainer;//录像
@property (strong, nonatomic)  UIButton *takeButton;//拍照按钮
@property (strong, nonatomic)  UIButton *flashButton;//闪光灯按钮
@property (strong, nonatomic)  UIButton *flashAutoButton;//自动闪光灯按钮
@property (strong, nonatomic)  UIButton *flashOnButton;//打开闪光灯按钮
@property (strong, nonatomic)  UIButton *flashOffButton;//关闭闪光灯按钮
@property (strong, nonatomic)  UIImageView *focusCursor; //聚焦光标
@property (strong, nonatomic)  UIButton *changeDeviceBtn;//转换摄像头

@property (strong, nonatomic)  UIButton *recordingButton;//录音按钮
@property (assign,nonatomic) BOOL enableRotation;//是否允许旋转（注意在视频录制过程中禁止屏幕旋转）
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识

@property (nonatomic, strong) UIView *markViewTop;
@property (nonatomic, strong) UIView *markViewBottom;
@property (nonatomic, strong) UIView *point;

@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation CameraViewController

#pragma mark - setter and getter

- (CMMotionManager *)cmManager {
    
    if (!_cmManager) {
        
        _cmManager = [[CMMotionManager alloc] init];
        if (!_cmManager.accelerometerAvailable) {
            
                QIMVerboseLog(@"CMMotionManager unavailable");
        }
        _cmManager.accelerometerUpdateInterval = 0.1f;
    }
    return _cmManager;
}

- (UIView *)takePhotoViewContainer {
    
    if (!_takePhotoViewContainer) {
        
        _takePhotoViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.view.width, self.view.height - 60 - 110 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
    }
    return _takePhotoViewContainer;
}

- (UIView *)markViewTop {
    
    if (!_markViewTop) {
        
        _markViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
        _markViewTop.backgroundColor = [UIColor blackColor];
        _markViewTop.alpha = 0.5;
    }
    return _markViewTop;
}

- (UIView *)markViewBottom {
    
    if (!_markViewBottom) {
        
        _markViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 100 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], self.view.width, 100)];
        _markViewBottom.backgroundColor = [UIColor blackColor];
        _markViewBottom.alpha = 0.5;
    }
    return _markViewBottom;
}

- (UIView *)point {
    
    if (!_point) {
        
        _point = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 7)];
        _point.backgroundColor = [UIColor qim_colorWithHex:0xfcd109 alpha:1.0];
        _point.layer.cornerRadius = 3.5;
        _point.center = CGPointMake( self.view.width / 2, self.takePhotoViewContainer.bottom + 5);
    }
    return _point;
}

- (UIButton *)videoBtn {
    
    if (!_videoBtn) {
        
        _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoBtn.frame = CGRectMake(0, 5, 30, 20);
        [_videoBtn setTitle:@"视频" forState:UIControlStateNormal];
        [_videoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_videoBtn setTitleColor:[UIColor qim_colorWithHex:0xfcd109 alpha:1.0] forState:UIControlStateSelected];
        _videoBtn.backgroundColor = [UIColor clearColor];
        _videoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_videoBtn addTarget:self action:@selector(videoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoBtn;
}

- (UIButton *)photoBtn {
    
    if (!_photoBtn) {
        
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoBtn.frame = CGRectMake(0, 5, 30, 20);
        [_photoBtn setTitle:@"照片" forState:UIControlStateNormal];
        [_photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_photoBtn setTitleColor:[UIColor qim_colorWithHex:0xfcd109 alpha:1.0] forState:UIControlStateSelected];
        _photoBtn.backgroundColor = [UIColor clearColor];
        _photoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_photoBtn addTarget:self action:@selector(photoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _photoBtn.center = CGPointMake(_point.center.x, _point.center.y + _point.height / 2 + 15);
    }
    return _photoBtn;
}

- (UIImageView *)focusCursor {
    
    if (!_focusCursor) {
        
        _focusCursor = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_focus"]];
        _focusCursor.frame = CGRectMake(0, 0, 50, 50);
        _focusCursor.alpha = 0;
        
    }
    return _focusCursor;
}

- (UIButton *)flashButton {
    
    if (!_flashButton) {
        
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.frame = CGRectMake(10, 5, 50, 50);
        [_flashButton setImage:[UIImage imageNamed:@"camera_flash_auto_a"] forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}

- (UIButton *)changeDeviceBtn {
    
    if (!_changeDeviceBtn) {
        
        _changeDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeDeviceBtn.frame = CGRectMake(self.view.width - 60, 5, 50, 50);
        [_changeDeviceBtn setImage:[UIImage imageNamed:@"icon_camera_flip_a"] forState:UIControlStateNormal];
        [_changeDeviceBtn addTarget:self action:@selector(toggleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeDeviceBtn;
}

- (UIButton *)takeButton {
    
    if (!_takeButton) {
        
        _takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takeButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        _takeButton.frame = CGRectMake((self.view.width - 65) / 2, self.view.height - 70 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], 65, 65);
        [_takeButton setBackgroundImage:[UIImage imageNamed:@"btn_camera_takephoto"] forState:UIControlStateNormal];
        [_takeButton setImage:[UIImage imageNamed:@"icon_camera_photo"] forState:UIControlStateNormal];
        [_takeButton addTarget:self action:@selector(takeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takeButton;
}

- (UIButton *)recordingButton {
    
    if (!_recordingButton) {
        
        _recordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordingButton.frame = CGRectMake((self.view.width - 65) / 2, self.view.height - 70 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], 65, 65);
        [_recordingButton setBackgroundImage:[UIImage imageNamed:@"mqz_v_record_start"] forState:UIControlStateNormal];
        [_recordingButton setBackgroundImage:[UIImage imageNamed:@"mqz_v_record_stop"] forState:UIControlStateSelected];
        [_recordingButton addTarget:self action:@selector(recordingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _recordingButton.hidden = YES;
    }
    return _recordingButton;
}

- (UIButton *)cancelBtn {
    
    if (!_cancelBtn) {
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(15, self.view.height - 70 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], 70, 70);
        [_cancelBtn setImage:[UIImage imageNamed:@"icon_cancel_white"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UILabel *)timeDisplayLabel {
    
    if (!_timeDisplayLabel) {
        
        _timeDisplayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [[QIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT] - 20, self.view.width, 40)];
        _timeDisplayLabel.textColor = [UIColor whiteColor];
        _timeDisplayLabel.textAlignment = NSTextAlignmentCenter;
        _timeDisplayLabel.backgroundColor = [UIColor clearColor];
        _timeDisplayLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _timeDisplayLabel;
}


#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cameraType = cameraTypeTakePhoto;
    
    [self initUI];
    [self initCamera];
    
    _cmManager = [[CMMotionManager alloc]init];
    if (!_cmManager.accelerometerAvailable) {
        QIMVerboseLog(@"CMMotionManager unavailable");
    }
    _cmManager.accelerometerUpdateInterval =0.1f;
    [_cmManager startAccelerometerUpdates];
}

- (void)initUI {
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.takePhotoViewContainer];
    
    [self.view addSubview:self.markViewTop];
    [self.view addSubview:self.markViewBottom];
    [self.view addSubview:self.point];
    [self.view addSubview:self.videoBtn];
    [self.view addSubview:self.photoBtn];
    self.videoBtn.center = CGPointMake(self.photoBtn.center.x - self.photoBtn.frame.size.width - 10, self.photoBtn.center.y);
    self.photoBtn.selected = YES;
    [self.takePhotoViewContainer addSubview:self.focusCursor];
    [self.view addSubview:self.flashButton];
    _flashMode = AVCaptureFlashModeAuto;
    [self.view addSubview:self.changeDeviceBtn];
    [self.view addSubview:self.takeButton];
    [self.view addSubview:self.recordingButton];
    [self.view addSubview:self.cancelBtn];
}

- (void)initCamera
{
    //初始化会话
    _captureSession=[[AVCaptureSession alloc]init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//设置分辨率
        _captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
    }
    //获得输入设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!captureDevice) {
        QIMVerboseLog(@"取得后置摄像头时出现问题.");
        captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];//取得前置摄像头
    }
    if (!captureDevice) {
        QIMVerboseLog(@"取得后置摄像头时出现问题.");
        return;
    }
    
    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        QIMVerboseLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    //初始化设备输出对象，用于获得输出数据
    _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    
    
    CALayer *layer=self.takePhotoViewContainer.layer;
    layer.masksToBounds=YES;
    
    _captureVideoPreviewLayer.frame=layer.bounds;
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
    //    [layer addSublayer:_captureVideoPreviewLayer];
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
    [self setFlashModeButtonStatus];
}

- (void)setToTakePhoto
{
    _cameraType = cameraTypeTakePhoto;
    self.takeButton.hidden = NO;
    self.recordingButton.hidden = YES;
    _timeDisplayLabel.hidden = YES;
    
    float cap = _photoBtn.center.x - _videoBtn.center.x;
    _photoBtn.selected = YES;
    _videoBtn.selected = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _photoBtn.center = CGPointMake(_photoBtn.center.x - cap, _photoBtn.center.y);
        _videoBtn.center = CGPointMake(_videoBtn.center.x - cap, _videoBtn.center.y);
        
    } completion:^(BOOL finished) {
    }];
    
    [self.captureSession beginConfiguration];
    [_captureSession removeInput:_audioCaptureDeviceInput];
    [_captureSession removeOutput:_captureMovieFileOutput];
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    [_captureSession commitConfiguration];
    
//    //创建视频预览层，用于实时展示摄像头状态
//    layer.masksToBounds=YES;
//    
    
    self.takePhotoViewContainer.frame = CGRectMake(0, 60, self.view.width, self.view.height - 64 - 100 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]);
    CALayer *layer=self.takePhotoViewContainer.layer;
    _captureVideoPreviewLayer.frame=layer.bounds;
//    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
//    [layer addSublayer:_captureVideoPreviewLayer];
    
    _enableRotation=NO;
    
}

- (void)setToRecording
{
    _cameraType = cameraTypeRecording;
    self.takeButton.hidden = YES;
    self.recordingButton.hidden = NO;
    
    float cap = _photoBtn.center.x - _videoBtn.center.x;
    _photoBtn.selected = NO;
    _videoBtn.selected = YES;
    [UIView animateWithDuration:0.5 animations:^{
        _photoBtn.center = CGPointMake(_photoBtn.center.x + cap, _photoBtn.center.y);
        _videoBtn.center = CGPointMake(_videoBtn.center.x + cap, _videoBtn.center.y);

    } completion:^(BOOL finished) {
    }];
    
    [self setTimeDisplayLabelText];
    
    NSError * error = nil;
    
    //添加一个音频输入设备
    if (!_audioCaptureDeviceInput) {
        AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        _audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
        if (error) {
            QIMVerboseLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
            return;
        }
    }
    //初始化设备输出对象，用于获得输出数据
    if (!_captureMovieFileOutput) {
        _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    }
    
    [self.captureSession beginConfiguration];
    [_captureSession removeOutput:_captureStillImageOutput];
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_audioCaptureDeviceInput]) {
        [_captureSession addInput:_audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
    
    [_captureSession commitConfiguration];
    
//    //创建视频预览层，用于实时展示摄像头状态
//    CALayer *layer=self.takePhotoViewContainer.layer;
//    layer.masksToBounds=YES;
//
    self.takePhotoViewContainer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.view.height - self.markViewBottom.height);

//    self.takePhotoViewContainer.frame = self.view.bounds;
    _captureVideoPreviewLayer.frame=CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.view.height - self.markViewBottom.height);
//    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
//    [layer addSublayer:_captureVideoPreviewLayer];
    
    _enableRotation=YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    _navBarHidden = self.navigationController.navigationBarHidden;
    //隐藏状态栏 导航条
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [self.captureSession startRunning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //恢复状态栏 导航条
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden];
    self.navigationController.navigationBarHidden = _navBarHidden;
    
    [self.captureSession stopRunning];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)dealloc{
    [self removeNotification];
    [_cmManager stopAccelerometerUpdates];
    _cmManager = nil;
}


-(BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationPortrait == toInterfaceOrientation;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

//-(BOOL)shouldAutorotate{
//    return NO;//self.enableRotation;
//}
//
////屏幕旋转时调整视频预览图层的方向
//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    AVCaptureConnection *captureConnection=[self.captureVideoPreviewLayer connection];
//    captureConnection.videoOrientation=(AVCaptureVideoOrientation)toInterfaceOrientation;
//}
////旋转后重新设置大小
//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    _captureVideoPreviewLayer.frame=self.takePhotoViewContainer.bounds;
//}


-(void)updateDeviceOrientation
{
    CMAccelerometerData *accelData = _cmManager.accelerometerData;
    double xx = accelData.acceleration.x;
    double yy = accelData.acceleration.y;
//    double zz = accelData.acceleration.z;
    
    float angle = atan2(yy, xx);
    // Read my blog for more details on the angles. It should be obvious that you
    // could fire a custom shouldAutorotateToInterfaceOrientation-event here.
    _deviceOrientation = UIInterfaceOrientationPortrait;
    if(angle >= -2.25 && angle <= -0.25)
    {
        if(_deviceOrientation != UIInterfaceOrientationPortrait)
        {
            _deviceOrientation = UIInterfaceOrientationPortrait;
        }
    }
    else if(angle >= -1.75 && angle <= 0.75)
    {
        if(_deviceOrientation != UIInterfaceOrientationLandscapeRight)
        {
            _deviceOrientation = UIInterfaceOrientationLandscapeRight;
        }
    }
    else if(angle >= 0.75 && angle <= 2.25)
    {
        if(_deviceOrientation != UIInterfaceOrientationPortraitUpsideDown)
        {
            _deviceOrientation = UIInterfaceOrientationPortraitUpsideDown;
        }
    }
    else if(angle <= -2.25 || angle >= 2.25)
    {
        if(_deviceOrientation != UIInterfaceOrientationLandscapeLeft)
        {
            _deviceOrientation = UIInterfaceOrientationLandscapeLeft;
        }
    }else{
        if(_deviceOrientation != UIInterfaceOrientationPortrait)
        {
            _deviceOrientation = UIInterfaceOrientationPortrait;
        }
    }
    [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = (AVCaptureVideoOrientation) self.deviceOrientation;
}

#pragma mark - UIAccelerometerDelegate
//被削弱，随时可能不能用。。。，CoreMotion 替代


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // Get the current device angle
    float xx = -[acceleration x];
    float yy = [acceleration y];
    float angle = atan2(yy, xx);
    // Read my blog for more details on the angles. It should be obvious that you
    // could fire a custom shouldAutorotateToInterfaceOrientation-event here.
    if(angle >= -2.25 && angle <= -0.25)
    {
        if(_deviceOrientation != UIInterfaceOrientationPortrait)
        {
            _deviceOrientation = UIInterfaceOrientationPortrait;
        }
    }
    else if(angle >= -1.75 && angle <= 0.75)
    {
        if(_deviceOrientation != UIInterfaceOrientationLandscapeRight)
        {
            _deviceOrientation = UIInterfaceOrientationLandscapeRight;
        }
    }
    else if(angle >= 0.75 && angle <= 2.25)
    {
        if(_deviceOrientation != UIInterfaceOrientationPortraitUpsideDown)
        {
            _deviceOrientation = UIInterfaceOrientationPortraitUpsideDown;
        }
    }
    else if(angle <= -2.25 || angle >= 2.25)
    {
        if(_deviceOrientation != UIInterfaceOrientationLandscapeLeft)
        {
            _deviceOrientation = UIInterfaceOrientationLandscapeLeft; 
        }
    }else{
        if(_deviceOrientation != UIInterfaceOrientationPortrait)
        {
            _deviceOrientation = UIInterfaceOrientationPortrait;
        }
    }
    [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = (AVCaptureVideoOrientation) self.deviceOrientation;
}

//设置图片附加信息

-(NSData *) setImageInfoWithImageData:(NSData *)data Properties:(NSDictionary *)properties {
    
    //设置properties属性
    
    CGImageSourceRef imageRef =CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    CFStringRef uti=CGImageSourceGetType(imageRef);
    
    NSMutableData *data1=[NSMutableData data];
    
    CGImageDestinationRef destination=CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data1, uti, 1, NULL);
    
    if (!destination) {
        
        QIMVerboseLog(@"error");
        
        return data;
        
    }
    
    
    
    CGImageDestinationAddImageFromSource(destination, imageRef, 0, (__bridge CFDictionaryRef)properties);
    
    BOOL check=CGImageDestinationFinalize(destination);
    
    if (!check) {
        
        QIMVerboseLog(@"error");
        
        return data;
        
    }
    return data1;
}

#pragma mark - UI方法

- (void)cancelHandle:(UIButton *)sender
{
    _seconds = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraViewCaontrollerDidCancel:)]) {
        [self.delegate cameraViewCaontrollerDidCancel:self];
    }
    self.delegate = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoButtonClick:(UIButton *)sender
{
    if (_cameraType == cameraTypeTakePhoto) {
        return;
    }
    [self setToTakePhoto];
}

- (void)videoButtonClick:(UIButton *)sender
{
    if (_cameraType == cameraTypeRecording) {
        return;
    }
    [self setToRecording];
}

#pragma mark 拍照
- (void)takeButtonClick:(UIButton *)sender {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
            AVCaptureDevicePosition currentPosition=[currentDevice position];
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image=[UIImage imageWithData:imageData];
            UIImage * resImage = nil;
            
            [self updateDeviceOrientation];
            
            switch (_deviceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                {
                    if (currentPosition == AVCaptureDevicePositionFront) {
                        resImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationDown];
                    }else{
                        resImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
                    }
                    
                }
                    break;
                case UIInterfaceOrientationLandscapeRight:
                {
                    if (currentPosition == AVCaptureDevicePositionFront) {
                        resImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
                    }else{
                        resImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationDown];
                    }
                    
                }
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                {
                    resImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationLeft];
                    
                }
                    break;
                    
                default:
                    resImage = image;
                    break;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraViewCaontroller:didFinishPickingMediaWithInfo:)]) {
                    [self.delegate cameraViewCaontroller:self didFinishPickingMediaWithInfo:@{UIImagePickerControllerMediaType:(NSString *)kUTTypeImage,UIImagePickerControllerOriginalImage:resImage}];
            }
        }
        
    }];
}

#pragma mark 视频录制
- (void)recordingButtonClick:(UIButton *)sender {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
        self.enableRotation=NO;
        //如果支持多任务则则开始多任务
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            self.backgroundTaskIdentifier=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
        NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
        QIMVerboseLog(@"save path is :%@",outputFielPath);
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
        QIMVerboseLog(@"fileUrl:%@",fileUrl);
        [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
    else{
        [self.captureMovieFileOutput stopRecording];//停止录制
    }
    _seconds = 0;
    
    [self setTimeDisplayLabelText];
}


#pragma mark 切换前后摄像头
- (void)toggleButtonClick:(UIButton *)sender {
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput=toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    
    [self setFlashModeButtonStatus];
}

- (void)flashButtonClick : (UIButton *)sender
{
    _flashMode = (_flashMode + 1) % 3;
    [self setFlashMode:_flashMode];
    switch (_flashMode) {
        case AVCaptureFlashModeAuto:
        {
            [_flashButton setImage:[UIImage imageNamed:@"camera_flash_auto_a"] forState:UIControlStateNormal];
        }
            break;
        case AVCaptureFlashModeOn:
        {
            [_flashButton setImage:[UIImage imageNamed:@"camera_flash_on_a"] forState:UIControlStateNormal];
        }
            break;
        case AVCaptureFlashModeOff:
        {
            [_flashButton setImage:[UIImage imageNamed:@"camera_flash_off_a"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 自动闪光灯开启
- (void)flashAutoClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
}
#pragma mark 打开闪光灯
- (void)flashOnClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOn];
    [self setFlashModeButtonStatus];
}
#pragma mark 关闭闪光灯
- (void)flashOffClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOff];
    [self setFlashModeButtonStatus];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    QIMVerboseLog(@"开始录制...");
    _recordingButton.selected = YES;
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
    }
    [_timer fire];
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    QIMVerboseLog(@"视频录制完成.");
    _recordingButton.selected = NO;
    //视频录入完成之后在后台将视频存储到相簿
    self.enableRotation=YES;
    [_timer invalidate];
    self.timer = nil;
    self.timeDisplayLabel.hidden = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraViewCaontroller:didFinishPickingMediaWithInfo:)]) {
        [self.delegate cameraViewCaontroller:self didFinishPickingMediaWithInfo:@{UIImagePickerControllerMediaType:(NSString *)kUTTypeMovie,UIImagePickerControllerMediaURL:outputFileURL}];
    }
    
//    UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier=self.backgroundTaskIdentifier;
//    self.backgroundTaskIdentifier=UIBackgroundTaskInvalid;
//    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
//    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (error) {
//            QIMVerboseLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
//        }
//        QIMVerboseLog(@"outputUrl:%@",outputFileURL);
//        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
//        if (lastBackgroundTaskIdentifier!=UIBackgroundTaskInvalid) {
//            [[UIApplication sharedApplication] endBackgroundTask:lastBackgroundTaskIdentifier];
//        }
//        QIMVerboseLog(@"成功保存视频到相簿.");
//    }];
    
}

- (void)timerHandle:(NSTimer *)timer
{
    _seconds ++;
    [self setTimeDisplayLabelText];
    
}

- (void)setTimeDisplayLabelText
{
    [self.view addSubview:self.timeDisplayLabel];
    _timeDisplayLabel.hidden = NO;
    NSInteger hours = _seconds / (60 * 60);
    NSInteger minutes = (_seconds % (60 * 60)) / 60;
    NSInteger seconds = _seconds % 60;
    _timeDisplayLabel.text = [NSString stringWithFormat:@"%@%@:%@%@:%@%@",hours > 9 ? @"" : @"0",@(hours),minutes > 9 ? @"" : @"0",@(minutes),seconds > 9 ? @"" : @"0",@(seconds)];

}

#pragma mark - 通知
/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    QIMVerboseLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    QIMVerboseLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    QIMVerboseLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    QIMVerboseLog(@"会话发生错误.");
}

#pragma mark - 私有方法

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        QIMVerboseLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.takePhotoViewContainer addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer * leftSwipeGexture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
    leftSwipeGexture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.takePhotoViewContainer addGestureRecognizer:leftSwipeGexture];
    
    UISwipeGestureRecognizer * rightSwipeGexture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
    rightSwipeGexture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.takePhotoViewContainer addGestureRecognizer:rightSwipeGexture];
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.takePhotoViewContainer];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

- (void)swipeHandle:(UISwipeGestureRecognizer *)swipeGesture
{
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        QIMVerboseLog(@"left");
        if (_cameraType == cameraTypeTakePhoto) {
            return;
        }
        [self setToTakePhoto];
    }else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        QIMVerboseLog(@"right");
        if (_cameraType == cameraTypeRecording) {
            return;
        }
        [self setToRecording];
    }
}

/**
 *  设置闪光灯按钮状态
 */
-(void)setFlashModeButtonStatus{
    AVCaptureDevice *captureDevice=[self.captureDeviceInput device];
    AVCaptureFlashMode flashMode=captureDevice.flashMode;
    if([captureDevice isFlashAvailable]){
        self.flashAutoButton.hidden=NO;
        self.flashOnButton.hidden=NO;
        self.flashOffButton.hidden=NO;
        self.flashAutoButton.enabled=YES;
        self.flashOnButton.enabled=YES;
        self.flashOffButton.enabled=YES;
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
                self.flashAutoButton.enabled=NO;
                break;
            case AVCaptureFlashModeOn:
                self.flashOnButton.enabled=NO;
                break;
            case AVCaptureFlashModeOff:
                self.flashOffButton.enabled=NO;
                break;
            default:
                break;
        }
    }else{
        self.flashAutoButton.hidden=YES;
        self.flashOnButton.hidden=YES;
        self.flashOffButton.hidden=YES;
    }
}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
        
    }];
}
@end
