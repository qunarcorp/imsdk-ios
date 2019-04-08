//
//  QIMRTCSingleView.m
//  QIMGeneralModule
//
//  Created by 李露 on 10/19/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMRTCSingleView.h"
#import <AVFoundation/AVFoundation.h>
#import "QIMRTCButton.h"
#import "QIMRTCHeaderView.h"
#import "QIMWebRTCClient.h"
#import "QIMWebRTCMeetingClient.h"
#import <WebRTC/WebRTC.h>
#import "QIMRTCViewController.h"
#import "UIView+QIMExtension.h"
#import "Masonry.h"
#import "QIMDeviceManager.h"
#import "UIColor+QIMUtility.h"
#import "QIMKitPublicHeader.h"
#import "QIMPublicRedefineHeader.h"

#define kRTCWidth       [UIScreen mainScreen].bounds.size.width
#define kRTCHeight      [UIScreen mainScreen].bounds.size.height

#define kRTCRate        ([UIScreen mainScreen].bounds.size.width / 320.0)
// 顶部信息容器的高度
#define kTopInfoH       (155 * kRTCRate)
// 底部按钮容器的高度
#define kContainerH     (162 * kRTCRate)
// 每个按钮的宽度
#define kBtnW           (60 * kRTCRate)
// 视频聊天时，小窗口的宽
#define kMicVideoW      (80 * kRTCRate)
// 视频聊天时，小窗口的高
#define kMicVideoH      (80 * kRTCRate)

@interface QIMRTCSingleView () <QIMRTCHeaderViewDidClickDelegate>

@property (nonatomic, strong) QIMRTCViewController *rootRTCViewController;

@property (nonatomic, strong) NSString *remoteJid;

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIView *topUserInfoView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) QIMRTCButton *convertAudioBtn;

@property (nonatomic, strong) QIMRTCButton *switchCameraBtn;

@property (strong, nonatomic) QIMRTCButton *hangupBtn;

/** 最小化 */
@property (strong, nonatomic)   UITapGestureRecognizer *toolsGenTap;
/** 工具栏是否隐藏了 */
@property (assign, nonatomic)   BOOL                    isToolsHidden;

/** 是否是视频聊天 */
@property (assign, nonatomic)   BOOL                    isVideo;
/** 是否是被呼叫方 */
@property (assign, nonatomic)   BOOL                    callee;
/** 本地是否开启摄像头  */
@property (assign, nonatomic)   BOOL                    localCamera;

/** 接听按钮 */
@property (strong, nonatomic)   QIMRTCButton             *answerBtn;

@end

@implementation QIMRTCSingleView

- (UIView *)topUserInfoView {
    if (!_topUserInfoView) {
        _topUserInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, self.width, 80)];
        _topUserInfoView.backgroundColor = [UIColor grayColor];
    }
    return _topUserInfoView;
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] init];
        _headerImageView.backgroundColor = [UIColor qtalkChatBgColor];
    }
    return _headerImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.text = @"正在连接中...";
    }
    return _stateLabel;
}

- (UIView *)masterView {
    if (!_masterView) {
        _masterView = [[UIView alloc] init];
    }
    return _masterView;
}

- (UIView *)otherView {
    if (!_otherView) {
        _otherView = [[UIView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changView:)];
        [_otherView addGestureRecognizer:tap];
    }
    return _otherView;
}

- (QIMRTCViewController *)rootRTCViewController {
    if (!_rootRTCViewController) {
        _rootRTCViewController = [[QIMRTCViewController alloc] init];
    }
    return _rootRTCViewController;
}

- (instancetype)initWithWithXmppId:(NSString *)remoteJid IsVideo:(BOOL)isVideo isCallee:(BOOL)isCallee
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        self.isVideo = isVideo;
        self.callee = isCallee;
        self.isHanged = YES;
        self.clipsToBounds = YES;
        self.remoteJid = remoteJid;
        [self setBackgroundColor:[UIColor blackColor]];
        [self setupUI];
    }
    
    return self;
}

- (void)hiddenHeaderView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect topFrame = self.topUserInfoView.frame;
        topFrame.origin.y = - topFrame.size.height - 20;
        self.topUserInfoView.frame = topFrame;
        self.topUserInfoView.hidden = YES;
    }];
}

- (void)hiddenBottomView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect buttonFrame = self.bottomView.frame;
        buttonFrame.origin.y = kRTCHeight;
        self.bottomView.frame = buttonFrame;
        self.isToolsHidden = YES;
    }];
}

- (void)onToolsViewHidenClick:(UITapGestureRecognizer *)tapGesture{
    
    if (self.isToolsHidden) {
        
        //退出全屏
        [UIView animateWithDuration:0.5 animations:^{
   
            CGRect buttonFrame = self.bottomView.frame;
            buttonFrame.origin.y = kRTCHeight - buttonFrame.size.height;
            self.bottomView.frame = buttonFrame;
        } completion:^(BOOL finished) {
            self.isToolsHidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }];
    } else {
        //进入全屏
        [UIView animateWithDuration:0.5 animations:^{
            
            CGRect buttonFrame = self.bottomView.frame;
            buttonFrame.origin.y = kRTCHeight;
            self.bottomView.frame = buttonFrame;
        } completion:^(BOOL finished) {
            self.isToolsHidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }];
    }
}

/**
 *  初始化UI
 */
- (void)setupUI
{
    if (self.isVideo && !self.callee) {
        // 视频通话时，呼叫方的UI初始化
        [self initUIForVideoCaller];
        
    } else if (!self.isVideo && !self.callee) {
        // 语音通话时，呼叫方UI初始化
        
    } else if (!self.isVideo && self.callee) {
        // 语音通话时，被呼叫方UI初始化
        
    } else {
        // 视频通话时，被呼叫方UI初始化
        [self initUIForVideoCallee];
    }
}

- (void)setUpHeaderView {
    [self addSubview:self.topUserInfoView];
    [self.topUserInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([[QIMDeviceManager sharedInstance] getNAVIGATION_BAR_HEIGHT]);
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(80);
    }];
    
    [self.topUserInfoView addSubview:self.headerImageView];
    [self.topUserInfoView addSubview:self.nameLabel];
    [self.topUserInfoView addSubview:self.stateLabel];
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.top.left.mas_equalTo(12);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(30);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(10);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(30);
    }];
}

- (void)setupBottomView {
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(100);
    }];
    
    [self.bottomView addSubview:self.convertAudioBtn];
    [self.bottomView addSubview:self.hangupBtn];
    [self.bottomView addSubview:self.switchCameraBtn];
    [self.convertAudioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(64);
        make.top.left.mas_equalTo(8);
    }];
    
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomView);
        make.width.height.mas_equalTo(64);
        make.top.mas_equalTo(8);
    }];
    
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(64);
        make.top.mas_equalTo(8);
        make.right.mas_equalTo(-10);
    }];
}

/**
 *  视频通话时，呼叫方的UI设置
 */
- (void)initUIForVideoCaller
{
    _localCamera = YES;
    
    [self setUserInteractionEnabled:YES];
    
    self.toolsGenTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onToolsViewHidenClick:)];
    [self addGestureRecognizer:self.toolsGenTap];
    
    //主视频窗口
    self.masterView.frame = self.frame;
    self.masterView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.masterView];
    
    //副视频窗口
    self.otherView.frame = CGRectMake(kRTCWidth - 110, 10, 100, 150);
    self.otherView.backgroundColor = [UIColor clearColor];
    self.otherView.hidden = YES;
    [self addSubview:self.otherView];
    
    [self setUpHeaderView];
    
    [self setupBottomView];
}

/**
 *  视频通话，被呼叫方UI初始化
 */
- (void)initUIForVideoCallee
{
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview:self.answerBtn];
    [view addSubview:self.hangupBtn];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
    [view addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    NSString *text = [NSString stringWithFormat:@"%@邀请你视频通话", [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.remoteJid]];
    [nameLabel setText:text];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:nameLabel];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(view.centerY).offset(-120);
        make.left.mas_equalTo(width/2.0-32);
        make.width.height.mas_equalTo(64);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(20);
        make.left.mas_equalTo(width/2.0-150);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(40);
    }];
    
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(view.mas_bottom).offset(-50);
        make.left.mas_equalTo(width/2.0-32);
        make.width.height.mas_equalTo(64);
    }];
    [self.answerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(width/2.0-32);
        make.bottom.mas_equalTo(self.hangupBtn.mas_top).offset(-50);
        make.width.height.mas_equalTo(64);
    }];
    [self addSubview:view];
}

- (void)updateRemoteUserInfoWithXmppId:(NSString *)xmppId {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.headerImageView.image = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
        self.nameLabel.text = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:xmppId];
    });
}

- (void)updateConnectionStateText:(NSString *)stateText {
    dispatch_async(dispatch_get_main_queue(), ^{
       self.stateLabel.text = stateText;
    });
}

- (void)show
{
    if (self.isVideo && self.callee) {
        self.connectLabel.text = @"视频通话";
    } else if (!self.isVideo && self.callee) {
        self.connectLabel.text = @"语音通话";
    }
    
    self.alpha = 0;
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.6;
    [self.rootRTCViewController.view addSubview:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.rootRTCViewController];
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:animation forKey:@"animation"];
    [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:nav animated:NO completion:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.rootRTCViewController dismiss];

    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
}

- (void)dealloc
{
    QIMVerboseLog(@"%s",__func__);
}

#pragma mark - 按钮点击事件

- (void)switchClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchCameraNotification object:nil];
}

- (void)hangupClick
{
    if (self.isHanged) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:2.0];
    } else {
        [self dismiss];
    }
    
    NSDictionary *dict = @{@"isVideo":@(self.isVideo),@"isCaller":@(!self.callee),@"answered":@(self.answered)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kHangUpNotification object:dict];
}

/**
 *  接听按钮操作
 */
- (void)answerClick
{
    self.answered = YES;
    NSDictionary *dict = nil;
    // 接听按钮只在接收方出现，分语音接听和视频接听两种情况
    if (self.isVideo) {
        _localCamera = YES;
        [self removeAllSubviews];
        // 视频通话接听之后，UI布局与呼叫方一样
        [self initUIForVideoCaller];
        dict = @{@"isVideo":@(YES),@"audioAccept":@(NO)};
    } else {
        _localCamera = NO;
        dict = @{@"isVideo":@(NO),@"audioAccept":@(YES)};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcceptNotification object:dict];
}

#pragma mark - 懒加载

- (QIMRTCButton *)convertAudioBtn {
    if (!_convertAudioBtn) {
        _convertAudioBtn = [[QIMRTCButton alloc] initWithTitle:@"切换语音" noHandleImageName:@"voip_convert_icons_130x130_"];
    }
    return _convertAudioBtn;
}

- (QIMRTCButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[QIMRTCButton alloc] initWithTitle:@"切换摄像头" noHandleImageName:@"voip_camera_icons_66x66_"];
        [_switchCameraBtn addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor grayColor];
    }
    return _bottomView;
}

- (QIMRTCButton *)hangupBtn
{
    if (!_hangupBtn) {
        if (_callee && !_answered) {
            _hangupBtn = [[QIMRTCButton alloc] initWithTitle:@"拒绝"  noHandleImageName:@"icon_call_reject_normal"];
        } else if (!_callee && !_answered) {
            _hangupBtn = [[QIMRTCButton alloc] initWithTitle:@"拒绝"  noHandleImageName:@"icon_call_reject_normal"];
        }else {
            _hangupBtn = [[QIMRTCButton alloc] initWithTitle:nil noHandleImageName:@"icon_call_reject_normal"];
        }
        
        [_hangupBtn addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangupBtn;
}

- (QIMRTCButton *)answerBtn
{
    if (!_answerBtn) {
        _answerBtn = [[QIMRTCButton alloc] initWithTitle:@"接听" noHandleImageName:@"icon_audio_receive_normal"];
        [_answerBtn addTarget:self action:@selector(answerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerBtn;
}

#pragma mark - property setter

- (RTCCameraPreviewView *)getMineCameraPreview {
    RTCCameraPreviewView *cameraPreview = [[RTCCameraPreviewView alloc] init];
    return cameraPreview;
}

- (RTCEAGLVideoView *)getOtherVideoView {
    RTCEAGLVideoView *otherVideoView = [[RTCEAGLVideoView alloc] init];
    
    return otherVideoView;
}

- (void)changView:(UIButton *)btn {
    
    [[QIMWebRTCClient sharedInstance] changeViews];
}

- (void)showAlertMessage:(NSString *)message {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismiss];
    }];
    [alertVc addAction:cancelAction];
    [alertVc addAction:okAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];
}

@end

