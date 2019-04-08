
#import <AVFoundation/AVFoundation.h>
#import "QIMPublicRedefineHeader.h"
#import "QIMRTCView.h"
#import "QIMRTCButton.h"
#import "QIMRTCHeaderView.h"
#import "QIMWebRTCClient.h"
#import "QIMWebRTCMeetingClient.h"
#import <WebRTC/WebRTC.h>
#import "QIMRTCViewController.h"
#import "UIView+QIMExtension.h"

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

@interface QIMRTCView () <QIMRTCHeaderViewDidClickDelegate>

@property (nonatomic, strong) NSMutableArray *adverseUser;

@property (nonatomic, copy) NSString *hasShowUserName;

@property (nonatomic, strong) QIMRTCViewController *rootRTCViewController;
/** 最小化 */
@property (strong, nonatomic)   UITapGestureRecognizer *toolsGenTap;
/** 工具栏是否隐藏了 */
@property (assign, nonatomic)   BOOL                    isToolsHidden;
/** 是否全屏 */
@property (strong, nonatomic)   UIImageView             *fullScreenImageView;

/** 是否交换了View */
@property (nonatomic, assign)   BOOL                    hasChangedView;
/** 是否是视频聊天 */
@property (assign, nonatomic)   BOOL                    isVideo;
/** 是否是被呼叫方 */
@property (assign, nonatomic)   BOOL                    callee;
/** 是否是后来加入的 */         
@property (assign, nonatomic)   BOOL                    isJoin;
/** 本地是否开启摄像头  */
@property (assign, nonatomic)   BOOL                    localCamera;
/** 是否是外放模式 */
@property (assign, nonatomic)   BOOL                    loudSpeaker;

/** 语音聊天背景视图 */
@property (strong, nonatomic)   UIImageView             *bgImageView;
/** 自己的视频画面 */
@property (strong, nonatomic)   UIImageView             *ownImageView;
/** 对方的视频画面 */
@property (strong, nonatomic)   UIImageView             *adverseImageView;
/** 对方的头像 */
@property (nonatomic, strong)   UIScrollView            *adverseHeaderImageStackView;

/** 更换view */
@property (nonatomic, strong)   UIButton                *changeViewBtn;

/** 顶部信息容器视图 */
@property (strong, nonatomic)   UIView                  *topContainerView;
/** 底部按钮容器视图 */
@property (strong, nonatomic)   UIView                  *btnContainerView;

/** 头像 */
@property (strong, nonatomic)   UIImageView             *portraitImageView;
/** 昵称 */
@property (strong, nonatomic)   UILabel                 *nickNameLabel;
/** 前置、后置摄像头切换按钮 */
@property (strong, nonatomic)   QIMRTCButton               *swichBtn;
/** 静音按钮 */
@property (strong, nonatomic)   QIMRTCButton               *muteBtn;
/** 摄像头按钮 */
@property (strong, nonatomic)   QIMRTCButton               *cameraBtn;
/** 扬声器按钮 */
@property (strong, nonatomic)   QIMRTCButton               *loudspeakerBtn;
/** 邀请成员按钮 */
@property (strong, nonatomic)   QIMRTCButton               *inviteBtn;
/** 消息回复按钮 */
@property (strong, nonatomic)   UIButton                *msgReplyBtn;
/** 收到视频通话时，语音接听按钮 */
@property (strong, nonatomic)   QIMRTCButton               *voiceAnswerBtn;
/** 挂断按钮 */
@property (strong, nonatomic)   QIMRTCButton               *hangupBtn;
/** 接听按钮 */
@property (strong, nonatomic)   QIMRTCButton               *answerBtn;
/** 收起按钮 */
@property (strong, nonatomic)   QIMRTCButton               *packupBtn;
/** 视频通话缩小后的按钮 */
@property (strong, nonatomic)   UIButton                *videoMicroBtn;
/** 音频通话缩小后的按钮 */
@property (strong, nonatomic)   QIMRTCButton               *microBtn;
/** 遮罩视图 */
@property (strong, nonatomic)   UIView                  *coverView;
/** 动画用的layer */
@property (strong, nonatomic)   CAShapeLayer            *shapeLayer;

@end

@implementation QIMRTCView{
    int _startHeaderX;
    int _startX;
    int _startY;
}

- (QIMRTCViewController *)rootRTCViewController {
    if (!_rootRTCViewController) {
        _rootRTCViewController = [[QIMRTCViewController alloc] init];
    }
    return _rootRTCViewController;
}

- (instancetype)initWithIsVideo:(BOOL)isVideo isCallee:(BOOL)isCallee
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        self.isVideo = isVideo;
        self.callee = isCallee;
        self.isHanged = YES;
        self.clipsToBounds = YES;
        [self setBackgroundColor:[UIColor blackColor]];
        [self setupUI];
    }
    
    return self;
}

- (instancetype)initWithRoomId:(NSString *)roomId WithRoomName:(NSString *)name isJoin:(BOOL)isJoin {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        self.isVideo = YES;
        self.callee = NO;
        self.isJoin = isJoin;
        _isRoom = YES;
        _roomId = roomId;
        self.isHanged = YES;
        self.clipsToBounds = YES;
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setupUI];
    }
    return self;
}

- (void)onToolsViewHidenClick:(UITapGestureRecognizer *)tapGesture{
    
    if (self.isToolsHidden) {
        
        //退出全屏
        [UIView animateWithDuration:0.5 animations:^{
            CGRect topFrame = self.topContainerView.frame;
            topFrame.origin.y = 0;
            self.topContainerView.frame = topFrame;
            CGRect buttonFrame = self.btnContainerView.frame;
            buttonFrame.origin.y = kRTCHeight - buttonFrame.size.height;
            self.btnContainerView.frame = buttonFrame;
            [self updateFrameOfRemoteView:CGRectMake(0, self.btnContainerView.top - kMicVideoH - 10, kRTCWidth, kMicVideoH)];

        } completion:^(BOOL finished) {
            self.isToolsHidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }];
    } else {
        //进入全屏
        [UIView animateWithDuration:0.5 animations:^{
            CGRect topFrame = self.topContainerView.frame;
            topFrame.origin.y = - topFrame.size.height - 20;
            self.topContainerView.frame = topFrame;
            CGRect buttonFrame = self.btnContainerView.frame;
            buttonFrame.origin.y = kRTCHeight;
            self.btnContainerView.frame = buttonFrame;
            [self updateFrameOfRemoteView:CGRectMake(0, self.btnContainerView.top - kMicVideoH - 10, kRTCWidth, kMicVideoH)];
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
    _startHeaderX = 10;
    _startX = 10;
    _startY = 100;
    
//    self.adverseImageView.backgroundColor = [UIColor blackColor];
    self.ownImageView.backgroundColor = [UIColor blackColor];
    self.portraitImageView.backgroundColor = [UIColor clearColor];
    if (!_isRoom) {
        if (self.isVideo && !self.callee) {
            // 视频通话时，呼叫方的UI初始化
            [self initUIForVideoCaller];
            
            //        // 模拟对方点击通话后的动画效果
            //        [self performSelector:@selector(connected) withObject:nil afterDelay:3.0];
            //        _answered = YES;
            //        _oppositeCamera = YES;
            //        _localCamera = YES;
            
        } else if (!self.isVideo && !self.callee) {
            // 语音通话时，呼叫方UI初始化
            [self initUIForAudioCaller];
            
            //        [self performSelector:@selector(connected) withObject:nil afterDelay:3.0];
            //        _answered = YES;
            //        _oppositeCamera = NO;
            //        _localCamera = NO;
            
        } else if (!self.isVideo && self.callee) {
            // 语音通话时，被呼叫方UI初始化
            [self initUIForAudioCallee];
        } else {
            // 视频通话时，被呼叫方UI初始化
            [self initUIForVideoCallee];
        }
    } else {
        if (!self.isVideo && !self.callee && self.isJoin) {
            [self initUIForAudioCallee];
        } else if (self.isVideo && !self.callee && self.isJoin) {
            [self initUIForVideoCallee];
        }else if (self.isVideo && !self.callee && !self.isJoin) {
            [self initUIForVideoCaller];
        }
    }
}

/**
 *  视频通话时，呼叫方的UI设置
 */
- (void)initUIForVideoCaller
{
    _localCamera = YES;
    _oppositeCamera = YES;
    
    [self setUserInteractionEnabled:YES];
    
    self.toolsGenTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onToolsViewHidenClick:)];
    [self addGestureRecognizer:self.toolsGenTap];
    
   // 自己视频View
    self.ownImageView.frame = self.frame;
    [self addSubview:_ownImageView];
    
    // 对方视频View
    self.adverseStackView.frame = self.frame;
    [self addSubview:self.adverseStackView];
    
    // 顶部InfoView
    self.topContainerView.frame = CGRectMake(0, 0, kRTCWidth, kTopInfoH);
    self.topContainerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:_topContainerView];
    
    
    CGFloat switchBtnW = 45 * kRTCRate;
    CGFloat topOffset = 30 * kRTCRate;
    self.swichBtn.frame = CGRectMake(kRTCWidth - switchBtnW - 10, topOffset, switchBtnW, switchBtnW);
    [self.topContainerView addSubview:_swichBtn];
    
    
    self.portraitImageView.frame = CGRectMake(10, topOffset, 45, 45);
    [self.portraitImageView setImage:self.headerImage];
    self.portraitImageView.layer.cornerRadius = 5;
    [self.topContainerView addSubview:self.portraitImageView];
    
    self.nickNameLabel.frame = CGRectMake(self.portraitImageView.right + 10, topOffset, kRTCWidth - 20 * 3 - switchBtnW - self.portraitImageView.right, 30);
    self.nickNameLabel.textColor = [UIColor whiteColor];
    self.nickNameLabel.textAlignment = NSTextAlignmentLeft;
    self.nickNameLabel.text = self.nickName ? :@"飞翔的昵称";
    [self.topContainerView addSubview:_nickNameLabel];
    
    if (_isRoom) {
        self.adverseHeaderImageStackView.frame = CGRectMake(10, self.portraitImageView.bottom + 20, kRTCWidth, 65);
        [self.topContainerView addSubview:self.adverseHeaderImageStackView];
    }
    
    self.connectLabel.frame = CGRectMake(self.nickNameLabel.left, CGRectGetMaxY(self.nickNameLabel.frame), CGRectGetWidth(self.nickNameLabel.frame), 20);
    self.connectLabel.textColor = [UIColor whiteColor];
    self.connectLabel.textAlignment = NSTextAlignmentLeft;
    self.connectLabel.text = self.connectText;
    [self.topContainerView addSubview:_connectLabel];
    
    self.netTipLabel.frame = CGRectMake(0, 0, kRTCWidth, 30);
    self.netTipLabel.textColor = [UIColor whiteColor];
    self.netTipLabel.center = self.center;
    [self addSubview:_netTipLabel];
    
    self.btnContainerView.frame = CGRectMake(0, kRTCHeight - kContainerH, kRTCWidth, kContainerH);
    self.btnContainerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:_btnContainerView];
    
    // 下面底部 6按钮视图
    [self initUIForBottomBtns];
    self.cameraBtn.enabled = NO;
    self.inviteBtn.enabled = NO;
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
    
//    [self loudspeakerClick];
}

/**
 *  视频通话，被呼叫方UI初始化
 */
- (void)initUIForVideoCallee
{
    // 上面 通用部分
    [self initUIForTopCommonViews];
    
    CGFloat btnW = kBtnW;
    CGFloat btnH = kBtnW + 20;
    CGFloat paddingX = (kRTCWidth - btnW * 2) / 3;
    self.hangupBtn.frame = CGRectMake(paddingX, kContainerH - btnH - 5, btnW, btnH);
    [self.btnContainerView addSubview:_hangupBtn];
    
    self.answerBtn.frame = CGRectMake(paddingX * 2 + btnW, kContainerH - btnH - 5, btnW, btnH);
    [self.btnContainerView addSubview:_answerBtn];
    
    // 这里还需要添加两个按钮
    self.msgReplyBtn.frame = CGRectMake(paddingX, 5, btnW, btnW);
    if (!_isRoom) {
        [self.btnContainerView addSubview:_msgReplyBtn];
    }
    
    if (!_isRoom) {
        self.voiceAnswerBtn.frame = CGRectMake(paddingX * 2 + btnW, 5, btnW, btnW);
        [self.btnContainerView addSubview:_voiceAnswerBtn];
    }
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
}

/**
 *  语音通话，呼叫方UI初始化
 */
- (void)initUIForAudioCaller
{
    // 上面 通用部分
    [self initUIForTopCommonViews];
    
    // 下面底部 6按钮视图
    [self initUIForBottomBtns];

    self.cameraBtn.enabled = NO;
    self.inviteBtn.enabled = NO;
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
}

/**
 *  语音通话时，被呼叫方的UI初始化
 */
- (void)initUIForAudioCallee
{
    // 上面 通用部分
    [self initUIForTopCommonViews];
    
    CGFloat btnW = kBtnW;
    CGFloat btnH = kBtnW + 20;
    CGFloat paddingX = (kRTCWidth - btnW * 2) / 3;
    self.hangupBtn.frame = CGRectMake(paddingX, kContainerH - btnH - 5, btnW, btnH);
    [self.btnContainerView addSubview:_hangupBtn];
    
    self.answerBtn.frame = CGRectMake(paddingX * 2 + btnW, kContainerH - btnH - 5, btnW, btnH);
    [self.btnContainerView addSubview:_answerBtn];
    
    CGFloat replyW = 110 * kRTCRate;
    CGFloat replyH = 45 * kRTCRate;
    
    CGFloat centerX = self.center.x;
    if (!_isRoom) {
        self.msgReplyBtn.frame = CGRectMake(centerX - replyW * 0.5, 20, replyW, replyH);
        [self.btnContainerView addSubview:_msgReplyBtn];
    }
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
}

/**
 *  上半部分通用视图
 *  语音通话呼叫方、语音通话接收方、视频通话接收方上半部分视图布局都一样
 */
- (void)initUIForTopCommonViews
{
    CGFloat centerX = self.center.x;
    
    self.bgImageView.frame = self.frame;
    [self addSubview:_bgImageView];
    
    CGFloat portraitW = 130 * kRTCRate;
    self.portraitImageView.frame = CGRectMake(0, 0, portraitW, portraitW);
    self.portraitImageView.center = CGPointMake(centerX, portraitW);
    self.portraitImageView.layer.cornerRadius = portraitW * 0.5;
    self.portraitImageView.layer.masksToBounds = YES;
    [self.portraitImageView setImage:self.headerImage];
    [self addSubview:_portraitImageView];
    
    self.nickNameLabel.frame = CGRectMake(0, 0, kRTCWidth, 30);
    self.nickNameLabel.center = CGPointMake(centerX, CGRectGetMaxY(self.portraitImageView.frame) + 40);
    self.nickNameLabel.text = self.nickName ? :@"飞翔的昵称";
    [self addSubview:_nickNameLabel];
    
    self.connectLabel.frame = CGRectMake(0, 0, kRTCWidth, 30);
    self.connectLabel.center = CGPointMake(centerX, CGRectGetMaxY(self.nickNameLabel.frame) + 10);
    self.connectLabel.text = self.connectText;
    [self addSubview:_connectLabel];
    
    self.netTipLabel.frame = CGRectMake(0, 0, kRTCWidth, 30);
    self.netTipLabel.center = CGPointMake(centerX, CGRectGetMaxY(self.connectLabel.frame) + 40);
    [self addSubview:_netTipLabel];
    
    self.btnContainerView.frame = CGRectMake(0, kRTCHeight - kContainerH, kRTCWidth, kContainerH);
    [self addSubview:_btnContainerView];
}

/**
 *  添加底部6个按钮
 */
- (void)initUIForBottomBtns
{
    CGFloat btnW = kBtnW;
    CGFloat paddingX = (self.frame.size.width - btnW*3) / 4;
    CGFloat paddingY = (kContainerH - btnW *2) / 3;
    self.muteBtn.frame = CGRectMake(paddingX, paddingY, btnW, btnW);
    [self.btnContainerView addSubview:_muteBtn];
    
    self.cameraBtn.frame = CGRectMake(paddingX * 2 + btnW, paddingY, btnW, btnW);
    [self.btnContainerView addSubview:_cameraBtn];
    
    self.loudspeakerBtn.frame = CGRectMake(paddingX * 3 + btnW * 2, paddingY, btnW, btnW);
    self.loudspeakerBtn.selected = self.loudSpeaker;
    [self.btnContainerView addSubview:_loudspeakerBtn];
    
    self.inviteBtn.frame = CGRectMake(paddingX, paddingY * 2 + btnW, btnW, btnW);
    [self.btnContainerView addSubview:_inviteBtn];
    
    self.hangupBtn.frame = CGRectMake(paddingX * 2 + btnW, paddingY * 2 + btnW, btnW, btnW);
    [self.btnContainerView addSubview:_hangupBtn];
    
    self.packupBtn.frame = CGRectMake(paddingX * 3 + btnW * 2, paddingY * 2 + btnW, btnW, btnW);
    [self.btnContainerView addSubview:_packupBtn];
}

- (void)show
{
    if (self.isVideo && self.callee) {
        self.connectLabel.text = @"视频通话";
    } else if (!self.isVideo && self.callee) {
        self.connectLabel.text = @"语音通话";
    }
    
    _topContainerView.transform = CGAffineTransformMakeTranslation(0, -kTopInfoH);
    _btnContainerView.transform = CGAffineTransformMakeTranslation(0, kContainerH);
    
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
        [UIView animateWithDuration:1 animations:^{
//            _portraitImageView.transform = CGAffineTransformIdentity;
//            _nickNameLabel.transform = CGAffineTransformIdentity;
//            _connectLabel.transform = CGAffineTransformIdentity;
//            _swichBtn.transform = CGAffineTransformIdentity;
            _topContainerView.transform = CGAffineTransformIdentity;
            _btnContainerView.transform = CGAffineTransformIdentity;

        }];
    }];
    
    [self updateFrameOfLocalView:CGRectMake(0, 0, kRTCWidth, kRTCHeight)];
    
}

- (void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
//        _portraitImageView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_portraitImageView.frame));
//        _nickNameLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_nickNameLabel.frame));
//        _connectLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_connectLabel.frame));
//        _swichBtn.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_swichBtn.frame));
        _topContainerView.transform = CGAffineTransformMakeTranslation(0, -kTopInfoH);
        _btnContainerView.transform = CGAffineTransformMakeTranslation(0, kContainerH);
        
    } completion:^(BOOL finished) {
        [self clearAllSubViews];
        [self removeFromSuperview];
        [self.rootRTCViewController dismiss];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
}

- (void)connected
{
    if (self.isVideo && !_isRoom) {
        // 视频通话，对方接听以后
        self.cameraBtn.enabled = NO;
        self.loudspeakerBtn.selected = NO;
        self.cameraBtn.selected = NO;
        self.inviteBtn.enabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            [self updateFrameOfLocalView:self.frame];
            [self updateFrameOfRemoteView:CGRectMake(0, self.btnContainerView.top - 10 - kMicVideoH, kRTCWidth, kMicVideoH)];

        } completion:^(BOOL finished) {
//            [[QIMWebRTCClient sharedInstance] resizeViews];
        }];
    } else if (self.isVideo && _isRoom) {
        //会议视频
        self.cameraBtn.enabled = NO;
        self.loudspeakerBtn.selected = NO;
        self.cameraBtn.selected = NO;
        self.inviteBtn.enabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            [self updateFrameOfLocalView:self.frame];
            [self updateFrameOfRemoteView:CGRectMake(0, self.btnContainerView.top - 10 - kMicVideoH, kRTCWidth, kMicVideoH)];
            
        } completion:^(BOOL finished) {
//            [[QIMWebRTCClient sharedInstance] resizeViews];
//            [[QIMWebRTCMeetingClient sharedInstance] answerJoinRoom];
        }];
    } else {
        self.cameraBtn.enabled = YES;
        self.inviteBtn.enabled = YES;
        self.btnContainerView.alpha = 1.0;
    }
}

- (void)updateVideoView{
    
    if (!self.hasChangedView) {
        [UIView animateWithDuration:0.5 animations:^{
            [self updateFrameOfRemoteView:CGRectMake(0, self.btnContainerView.top - 10 - kMicVideoH, kRTCWidth, kMicVideoH)];
            [self updateFrameOfLocalView:CGRectMake(0, 0, kRTCWidth , kRTCHeight)];
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            
            [self updateFrameOfRemoteView:CGRectMake(0, self.btnContainerView.top - 10 - kMicVideoH, kRTCWidth, kMicVideoH)];
            [self updateFrameOfLocalView:CGRectMake(0, kTopInfoH, kRTCWidth , kRTCHeight - kTopInfoH - kContainerH - 7)];

        }];
    }
}

- (void)updateFrameOfLocalView:(CGRect)newFrame
{
    self.ownImageView.frame = newFrame;
    self.ownImageView.center = self.center;
    for (UIView *subView in self.ownImageView.subviews) {
        Class class = NSClassFromString(@"RTCEAGLVideoView");
        if ([subView isKindOfClass:class]) { 
            if (self.localVideoViewSize.width > 0 && self.localVideoViewSize.height > 0) {
                CGFloat scale = MIN(newFrame.size.width / self.localVideoViewSize.width , newFrame.size.height / self.localVideoViewSize.height);
                CGRect frame;
                frame.size.width = scale * self.localVideoViewSize.width;
                frame.size.height = scale * self.localVideoViewSize.height;
                frame.origin.x = (newFrame.size.width - frame
                                  .size.width) / 2.0;
                frame.origin.y = (newFrame.size.height - frame.size.height) / 2.0;
                subView.frame = frame;
            } else {
                subView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
            }
            subView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
            for (UIView *sView in subView.subviews) {
                class = NSClassFromString(@"GLKView");
                if ([sView isKindOfClass:class]) {
                    sView.frame = CGRectMake(0, 0, subView.size.width, subView.size.height);
                }
            }
        }
    }
}

- (void)updateFrameOfRemoteView:(CGRect)newFrame
{
    self.adverseStackView.frame = newFrame;
    for (UIView *subView in self.adverseStackView.subviews) {
        Class class = NSClassFromString(@"RTCEAGLVideoView");
        if ([subView isKindOfClass:class]) {
            if (self.removeVideoViewSize.width > 0 && self.removeVideoViewSize.height > 0) {
                CGFloat scale = MIN(newFrame.size.width / self.removeVideoViewSize.width , newFrame.size.height / self.removeVideoViewSize.height);
                CGRect frame;
                frame.size.width = scale * self.removeVideoViewSize.width;
                frame.size.height = scale * self.removeVideoViewSize.height;
                frame.origin.x = (newFrame.size.width - frame
                                  .size.width) / 2.0;
                frame.origin.y = (newFrame.size.height - frame.size.height) / 2.0;
                subView.frame = frame;
            } else {
                subView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
            }
            for (UIView *sView in subView.subviews) {
                class = NSClassFromString(@"GLKView");
                if ([sView isKindOfClass:class]) {
                    sView.frame = CGRectMake(0, 0, subView.width, subView.height);
                }
            }
        }
    }
}

- (void)clearAllSubViews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _bgImageView = nil;
//    _ownImageView = nil;
//    _adverseImageView = nil;
//    _portraitImageView = nil;
    _nickNameLabel = nil;
    _connectLabel = nil;
    _netTipLabel = nil;
    _swichBtn = nil;
    _topContainerView = nil;
    [self clearBottomViews];
    
    _coverView = nil;
}

- (void)clearBottomViews
{
    _btnContainerView = nil;
    _muteBtn = nil;
    _cameraBtn = nil;
    _loudspeakerBtn = nil;
    _inviteBtn = nil;
    _hangupBtn = nil;
    _packupBtn = nil;
    _msgReplyBtn = nil;
    _voiceAnswerBtn = nil;
    _answerBtn = nil;
}

- (void)dealloc
{
     QIMVerboseLog(@"%s",__func__);
    [self clearAllSubViews];
}

#pragma mark - 按钮点击事件

- (void)switchClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchCameraNotification object:nil];
}

- (void)muteClick
{
    QIMVerboseLog(@"静音%s",__func__);
    if (!self.muteBtn.selected) {
        self.muteBtn.selected = YES;
    } else {
        self.muteBtn.selected = NO;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kMuteNotification object:@{@"isMute":@(self.muteBtn.selected)}];
}

- (void)cameraClick
{
    self.localCamera = !self.localCamera;
    if (self.localCamera) {
        self.isVideo = YES;
        [self clearAllSubViews];
        
        [self initUIForVideoCaller];
        // 在这里添加 开启本地视频采集 的代码
        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoCaptureNotification object:@{@"videoCapture":@(YES)}];
        // 对方和本地都开了摄像头
        if (self.oppositeCamera) {
            [self updateFrameOfLocalView:self.frame];
            [self addSubview:self.ownImageView];
            self.cameraBtn.enabled = YES;
            self.inviteBtn.enabled = YES;
            self.cameraBtn.selected = YES;
        } else {
            // 本地开启，对方未开摄像头
            [self.adverseStackView removeFromSuperview];
            self.cameraBtn.enabled = YES;
            self.inviteBtn.enabled = YES;
            self.cameraBtn.selected = YES;
        }
        
    } else {
        // 在这里添加 关闭本地视频采集 的代码
        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoCaptureNotification object:@{@"videoCapture":@(NO)}];
        if (self.oppositeCamera) {
            // 本地未开，对方开了摄像头
            [self clearAllSubViews];
            
            [self initUIForVideoCaller];
            
            [self.ownImageView removeFromSuperview];
            self.cameraBtn.enabled = YES;
            self.inviteBtn.enabled = YES;
            
        } else {
            // 本地和对方都未开始摄像头
            self.isVideo = NO;
            [self clearAllSubViews];
            
            [self initUIForAudioCaller];
            
            [self connected];
        }
    }
}

- (void)loudspeakerClick
{
    QIMVerboseLog(@"外放声音%s",__func__);
    if (!self.loudspeakerBtn.selected) {
        self.loudspeakerBtn.selected = YES;
        self.loudSpeaker = YES;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        self.loudspeakerBtn.selected = NO;
        self.loudSpeaker = NO;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
}

- (void)inviteClick
{
    QIMVerboseLog(@"邀请成员%s",__func__);
    #warning 这里需要发送邀请成员的通知
}

- (void)hangupClick
{
    if (self.isHanged) {
        self.coverView.hidden = NO;
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:2.0];
    } else {
        [self dismiss];
    }
    
    NSDictionary *dict = @{@"isVideo":@(self.isVideo),@"isCaller":@(!self.callee),@"answered":@(self.answered)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kHangUpNotification object:dict];
}

- (void)packupClick
{
    // 如果是语音通话的收起
    if (!self.isVideo) {
        // 1.获取动画缩放结束时的圆形
        UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:self.portraitImageView.frame];
        
        // 2.获取动画缩放开始时的圆形
        CGSize startSize = CGSizeMake(self.frame.size.width * 0.5, self.frame.size.height - self.portraitImageView.center.y);
        CGFloat radius = sqrt(startSize.width * startSize.width + startSize.height * startSize.height);
        CGRect startRect = CGRectInset(self.portraitImageView.frame, -radius, -radius);
        UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:startRect];
        
        // 3.创建shapeLayer作为视图的遮罩
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = endPath.CGPath;
        self.layer.mask = shapeLayer;
        self.shapeLayer = shapeLayer;
        
        // 添加动画
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (id)startPath.CGPath;
        pathAnimation.toValue = (id)endPath.CGPath;
        pathAnimation.duration = 0.5;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.delegate = self;
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.fillMode = kCAFillModeForwards;
        
        [shapeLayer addAnimation:pathAnimation forKey:@"packupAnimation"];
    } else {
        [self removeGestureRecognizer:self.toolsGenTap];
        // 视频通话的收起动画
//        _nickNameLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_nickNameLabel.frame));
//        _connectLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_connectLabel.frame));
        //        _swichBtn.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_swichBtn.frame));
        _btnContainerView.transform = CGAffineTransformMakeTranslation(0, 0);
        _btnContainerView.transform = CGAffineTransformMakeTranslation(0, kContainerH);
        
        if (self.answered) {
            [UIView animateWithDuration:1.0 animations:^{
                self.frame = CGRectMake(kRTCWidth - kMicVideoW - 10 , 74, kMicVideoW, kMicVideoH);
                [self.topContainerView setHidden:YES];
                if (self.oppositeCamera && self.localCamera) {
                    _ownImageView.hidden = YES;
                    [self updateFrameOfRemoteView:CGRectMake(0, 0, kRTCWidth, kMicVideoH)];
                } else if (!self.oppositeCamera && self.localCamera) {
                    [self updateFrameOfLocalView:CGRectMake(0, 0, kRTCWidth, kMicVideoH)];
                } else {
                    [self updateFrameOfRemoteView:CGRectMake(0, 0, kRTCWidth, kMicVideoH)];
                }
            } completion:^(BOOL finished) {
                self.videoMicroBtn.frame = self.adverseStackView.frame;
                [self addSubview:_videoMicroBtn];
            }];
        } else {
            [UIView animateWithDuration:1.0 animations:^{
                self.frame = CGRectMake(kRTCWidth - kMicVideoW - 10 , 74, kMicVideoW, kMicVideoH);
                [self.topContainerView setHidden:YES];
                [self updateFrameOfRemoteView:CGRectMake(0, 0, kRTCWidth, kMicVideoH)];
            } completion:^(BOOL finished) {
                self.videoMicroBtn.frame = self.adverseStackView.frame;

                [self addSubview:_videoMicroBtn];
            }];
        }
        
//        [[QIMWebRTCClient sharedInstance] resizeViews];
    }
}

- (void)msgReplyClick
{
    QIMVerboseLog(@"%s",__func__);

    NSArray *messages = @[@"现在不方便接听，稍后给你回复。",@"现在不方便接听，有什么事吗",@"马上到"];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle: nil otherButtonTitles:nil];
    for (NSString *message  in messages) {
        [sheet addButtonWithTitle:message];
    }
    [sheet showInView:self];
}

/**
 *  接听按钮操作
 */
- (void)answerClick
{
    self.answered = YES;
    NSDictionary *dict = nil;
    // 接听按钮只在接收方出现，分语音接听和视频接听两种情况
    if (self.isVideo && !_isRoom) {
        _localCamera = YES;
        _oppositeCamera = YES;

        [self clearAllSubViews];
        // 视频通话接听之后，UI布局与呼叫方一样
        [self initUIForVideoCaller];
        // 执行一个小动画
        [self connected];
        dict = @{@"isVideo":@(YES),@"audioAccept":@(NO)};
    } else if (self.isVideo && _isRoom) {
        _localCamera = YES;
        _oppositeCamera = YES;
        
        [self clearAllSubViews];
        // 视频通话接听之后，UI布局与呼叫方一样
        [self initUIForVideoCaller];
        [self connected];
        [[QIMWebRTCMeetingClient sharedInstance] answerJoinRoom];
        self.answered = YES;
    } else {
        _localCamera = NO;
        _oppositeCamera = NO;
        
        [UIView animateWithDuration:1 animations:^{
            self.btnContainerView.alpha = 0;
        } completion:^(BOOL finished) {
            [self clearAllSubViews];
            
            [self initUIForAudioCaller];
            self.connectLabel.text = @"正在通话中...";
            
            [self connected];
        }];
        dict = @{@"isVideo":@(NO),@"audioAccept":@(YES)};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcceptNotification object:dict];
}

// 视频通话时的语音接听按钮
- (void)voiceAnswerClick
{
    self.answered = YES;
    self.isVideo = YES;
    _localCamera = NO;
    _oppositeCamera = YES;
    
    [self clearAllSubViews];
    
    [self initUIForVideoCaller];
    
    [self.ownImageView removeFromSuperview];
    self.cameraBtn.enabled = YES;
    self.inviteBtn.enabled = NO;
    
    NSDictionary *dict = @{@"isVideo":@(YES),@"audioAccept":@(YES)};
    // 只有视频通话的语音接听，传一个参数NO。
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcceptNotification object:dict];
}

// 语音通话，缩小后的按钮点击事件
- (void)microClick
{
    [self.microBtn removeFromSuperview];
    self.microBtn = nil;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.center = self.portraitImageView.center;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.bounds = [UIScreen mainScreen].bounds;
        self.frame = self.bounds;
        
        CAShapeLayer *shapeLayer = self.shapeLayer;
        
        // 1.获取动画缩放开始时的圆形
        UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:self.portraitImageView.frame];
        
        // 2.获取动画缩放结束时的圆形
        CGSize endSize = CGSizeMake(self.frame.size.width * 0.5, self.frame.size.height - self.portraitImageView.center.y);
        CGFloat radius = sqrt(endSize.width * endSize.width + endSize.height * endSize.height);
        CGRect endRect = CGRectInset(self.portraitImageView.frame, -radius, -radius);
        UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:endRect];
        
        // 3.创建shapeLayer作为视图的遮罩
        shapeLayer.path = endPath.CGPath;
        
        // 添加动画
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (id)startPath.CGPath;
        pathAnimation.toValue = (id)endPath.CGPath;
        pathAnimation.duration = 0.5;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.delegate = self;
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.fillMode = kCAFillModeForwards;
        
        [shapeLayer addAnimation:pathAnimation forKey:@"showAnimation"];
    }];
}

- (void)videoMicroClick
{
    [self.videoMicroBtn removeFromSuperview];
    _ownImageView.hidden = NO;
    
    [self.topContainerView setHidden:NO];
    
    if (self.answered) {
        [UIView animateWithDuration:1.0 animations:^{
            self.frame = [UIScreen mainScreen].bounds;
            [self updateFrameOfLocalView:CGRectMake(0, 0, kRTCWidth, kRTCHeight)];
            [self updateFrameOfRemoteView:CGRectMake(0, self.btnContainerView.top - 10 - kMicVideoH, kRTCWidth, kMicVideoH)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^{
                self.topContainerView.transform = CGAffineTransformIdentity;
                self.btnContainerView.transform = CGAffineTransformIdentity;
                
//                [[QIMWebRTCClient sharedInstance] resizeViews];
            }];
        }];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            self.frame = [UIScreen mainScreen].bounds;
            [self updateVideoView];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^{
                self.topContainerView.transform = CGAffineTransformIdentity;
                self.btnContainerView.transform = CGAffineTransformIdentity;
                
//                [[QIMWebRTCClient sharedInstance] resizeViews];
            }];
        }];
    }
    
    [self addGestureRecognizer:self.toolsGenTap];
    
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isEqual:[self.shapeLayer animationForKey:@"packupAnimation"]]) {
        CGRect rect = self.frame;
        rect.origin = self.portraitImageView.frame.origin;
        self.bounds = rect;
        rect.size = self.portraitImageView.frame.size;
        self.frame = rect;
        
        [UIView animateWithDuration:1.0 animations:^{
            self.center = CGPointMake(kRTCWidth - 60, kRTCHeight - 80);
            self.transform = CGAffineTransformMakeScale(0.5, 0.5);
            
        } completion:^(BOOL finished) {
            self.microBtn.frame = self.frame;
            self.microBtn.layer.cornerRadius = self.microBtn.bounds.size.width * 0.5;
            self.microBtn.layer.masksToBounds = YES;
            [self.superview addSubview:_microBtn];
        }];
    } else if ([anim isEqual:[self.shapeLayer animationForKey:@"showAnimation"]]) {
        self.layer.mask = nil;
        self.shapeLayer = nil;
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)adverseUser {
    if (!_adverseUser) {
        _adverseUser = [NSMutableArray arrayWithCapacity:4];
    }
    return _adverseUser;
}

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"im_skin_icon_audiocall_bg.jpg"]];
    }
    
    return _bgImageView;
}

- (UIView *)adverseStackView {
    
    if (!_adverseStackView) {
        _adverseStackView = [[UIView alloc] init];
    }
    return _adverseStackView;
}

- (UIImageView *)adverseImageView
{
    if (!_adverseImageView) {
        _adverseImageView = [[UIImageView alloc] init];
        [_adverseImageView setBackgroundColor:[UIColor redColor]];
        [_adverseImageView setUserInteractionEnabled:YES];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
        label.textColor = [UIColor whiteColor];
        label.text = @"对方";
        [_adverseImageView addSubview:label];
    }
    
    return _adverseImageView;
}

- (UIImageView *)ownImageView
{
    if (!_ownImageView) {
        _ownImageView = [[UIImageView alloc] init];
        [_ownImageView setBackgroundColor:[UIColor blackColor]];
        [_ownImageView setUserInteractionEnabled:YES];
        _ownImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _ownImageView;
}

- (UIScrollView *)adverseHeaderImageStackView {
    if (!_adverseHeaderImageStackView) {
        _adverseHeaderImageStackView = [[UIScrollView alloc] init];
        _adverseHeaderImageStackView.showsHorizontalScrollIndicator = YES;
    }
    return _adverseHeaderImageStackView;
}

- (UIImageView *)portraitImageView
{
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"portrait"]];
    }
    
    return _portraitImageView;
}

- (UILabel*)nickNameLabel
{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.text = @"飞翔的昵称";
        _nickNameLabel.font = [UIFont systemFontOfSize:17.0f];
        _nickNameLabel.textColor = [UIColor darkGrayColor];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _nickNameLabel;
}

- (UILabel*)connectLabel
{
    if (!_connectLabel) {
        _connectLabel = [[UILabel alloc] init];
        _connectLabel.text = @"等待对方接听...";
        _connectLabel.font = [UIFont systemFontOfSize:15.0f];
        _connectLabel.textColor = [UIColor grayColor];
        _connectLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _connectLabel;
}

- (QIMRTCButton *)swichBtn
{
    if (!_swichBtn) {
        _swichBtn = [[QIMRTCButton alloc] initWithTitle:nil noHandleImageName:@"icon_avp_camera_white"];
        [_swichBtn addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _swichBtn;
}

- (UILabel*)netTipLabel
{
    if (!_netTipLabel) {
        _netTipLabel = [[UILabel alloc] init];
        _netTipLabel.text = @"";
        _netTipLabel.font = [UIFont systemFontOfSize:13.0f];
        _netTipLabel.textColor = [UIColor grayColor];
        _netTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _netTipLabel;
}

- (UIView *)topContainerView{
    if (!_topContainerView) {
        _topContainerView = [[UIView alloc] init];
    }
    return _topContainerView;
}

- (UIView *)btnContainerView
{
    if (!_btnContainerView) {
        _btnContainerView = [[UIView alloc] init];
    }
    return _btnContainerView;
}

- (QIMRTCButton *)muteBtn
{
    if (!_muteBtn) {
        _muteBtn = [[QIMRTCButton alloc] initWithTitle:@"静音" imageName:@"icon_avp_mute" isVideo:_isVideo];
        [_muteBtn addTarget:self action:@selector(muteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _muteBtn;
}

- (QIMRTCButton *)cameraBtn
{
    if (!_cameraBtn) {
        _cameraBtn = [[QIMRTCButton alloc] initWithTitle:@"摄像头" imageName:@"icon_avp_video" isVideo:_isVideo];
        [_cameraBtn addTarget:self action:@selector(cameraClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cameraBtn;
}

- (QIMRTCButton *)loudspeakerBtn
{
    if (!_loudspeakerBtn) {
        _loudspeakerBtn = [[QIMRTCButton alloc] initWithTitle:@"扬声器" imageName:@"icon_avp_loudspeaker" isVideo:_isVideo];
        [_loudspeakerBtn addTarget:self action:@selector(loudspeakerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loudspeakerBtn;
}

- (QIMRTCButton *)inviteBtn
{
    if (!_inviteBtn) {
        _inviteBtn = [[QIMRTCButton alloc] initWithTitle:@"邀请成员" imageName:@"icon_avp_invite" isVideo:_isVideo];
        [_inviteBtn addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _inviteBtn;
}

- (QIMRTCButton *)hangupBtn
{
    if (!_hangupBtn) {
        if (_callee && !_answered) {
            _hangupBtn = [[QIMRTCButton alloc] initWithTitle:@"拒绝"  noHandleImageName:@"icon_call_reject_normal"];
        } else if (!_callee && !_answered && _isJoin) {
            _hangupBtn = [[QIMRTCButton alloc] initWithTitle:@"拒绝"  noHandleImageName:@"icon_call_reject_normal"];
        }else {
            _hangupBtn = [[QIMRTCButton alloc] initWithTitle:nil noHandleImageName:@"icon_call_reject_normal"];
        }
        
        [_hangupBtn addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangupBtn;
}

- (QIMRTCButton *)packupBtn
{
    if (!_packupBtn) {
        _packupBtn = [[QIMRTCButton alloc] initWithTitle:@"收起" imageName:@"icon_avp_reduce" isVideo:_isVideo];
        [_packupBtn setEnabled:NO];
        [_packupBtn addTarget:self action:@selector(packupClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _packupBtn;
}

- (UIButton *)msgReplyBtn
{
    if (!_msgReplyBtn) {
        if (self.isVideo) {
            _msgReplyBtn = [[QIMRTCButton alloc] initWithTitle:@"消息回复" noHandleImageName:@"icon_av_reply_message_normal"];
        } else {
            _msgReplyBtn = [[UIButton alloc] init];
            [_msgReplyBtn setTitle:@"消息回复" forState:UIControlStateNormal];
            _msgReplyBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [_msgReplyBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_msgReplyBtn setImage:[UIImage imageNamed:@"icon_av_reply_message_normal"] forState:UIControlStateNormal];
            [_msgReplyBtn setBackgroundImage:[UIImage imageNamed:@"view_audio_reply_message_bg"] forState:UIControlStateNormal];
        }
        
        [_msgReplyBtn addTarget:self action:@selector(msgReplyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _msgReplyBtn;
}

- (QIMRTCButton *)voiceAnswerBtn
{
    if (!_voiceAnswerBtn) {
        _voiceAnswerBtn = [[QIMRTCButton alloc] initWithTitle:@"语音接听" noHandleImageName:@"icon_av_audio_receive_normal"];
        [_voiceAnswerBtn addTarget:self action:@selector(voiceAnswerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceAnswerBtn;
}

- (QIMRTCButton *)answerBtn
{
    if (!_answerBtn) {
        _answerBtn = [[QIMRTCButton alloc] initWithTitle:@"接听" noHandleImageName:@"icon_audio_receive_normal"];
        [_answerBtn addTarget:self action:@selector(answerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerBtn;
}

- (QIMRTCButton *)microBtn
{
    if (!_microBtn) {
        _microBtn = [[QIMRTCButton alloc] initWithTitle:@"等待中" noHandleImageName:@"icon_av_audio_micro_normal"];
        [_microBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _microBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _microBtn.backgroundColor = [UIColor orangeColor];
        [_microBtn addTarget:self action:@selector(microClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _microBtn;
}

- (UIButton *)videoMicroBtn
{
    if (!_videoMicroBtn) {
        _videoMicroBtn = [[UIButton alloc] init];
        [_videoMicroBtn setExclusiveTouch:YES];
        [_videoMicroBtn addTarget:self action:@selector(videoMicroClick) forControlEvents:UIControlEventTouchDown];
    }
    
    return _videoMicroBtn;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    
    return _coverView;
}

#pragma mark - property setter
- (void)setHeaderImage:(UIImage *)headerImage{
    
    _headerImage = headerImage;
    self.portraitImageView.image = headerImage;
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    self.nickNameLabel.text = _nickName;
}

- (void)setConnectText:(NSString *)connectText
{
    _connectText = connectText;
    self.connectLabel.text = connectText;
    
    [self.microBtn setTitle:connectText forState:UIControlStateNormal];
}

- (void)setNetTipText:(NSString *)netTipText
{
    _netTipText = netTipText;
    self.netTipLabel.text = _netTipText;
}

- (void)setAnswered:(BOOL)answered
{
    _answered = answered;
    if (!self.callee) {
        [self connected];
    }
}

- (void)setOppositeCamera:(BOOL)oppositeCamera
{
    _oppositeCamera = oppositeCamera;
    
//    [self cameraClick];
    self.isVideo = YES;
    // 如果对方开启摄像头
    if (oppositeCamera) {
        [self clearAllSubViews];
        
        [self initUIForVideoCaller];
        
        if (self.localCamera) {
            [self connected];
        } else {
            [self.ownImageView removeFromSuperview];
        }
    } else { // 对方关闭
        if (self.localCamera) {

            [self.adverseStackView removeFromSuperview];
            
            [UIView animateWithDuration:1.0 animations:^{
//                self.ownImageView.frame = self.frame;
                [self updateFrameOfLocalView:self.frame];
            }];
        } else {
            // 本地和对方都未开始摄像头
            self.isVideo = NO;
            [self clearAllSubViews];
            
            [self initUIForAudioCaller];
            
            [self connected];
        }
    }
}

- (void)addRemoteUserHeaderImageViewWithUserName:(NSString *)userName {
    
    NSString *userId = [userName copy];
    QIMRTCHeaderView *headerView = [[QIMRTCHeaderView alloc] initWithinitWithFrame:CGRectMake(_startHeaderX, 0, 65, 65) userId:userId];
    headerView.userInteractionEnabled = YES;
    headerView.rtcHeaderViewDidClickDelegate = self;
    headerView.tag = self.adverseUser.count - 1;
    if (_isRoom) {
        [self.adverseHeaderImageStackView addSubview:headerView];
    }
    _startHeaderX += (45 + 10);
}

- (void)didClickUserQIMRTCHeaderViewWithTag:(NSInteger)tag {
    if (tag >= 0) {
        NSString *userId = [self.adverseUser objectAtIndex:tag];
        if (![userId isEqualToString:self.hasShowUserName]) {
            [[QIMWebRTCMeetingClient sharedInstance] addedStreamWithClickUserId:userId];
        }
    }
}

- (RTCEAGLVideoView *)addRemoteVideoViewWithUserName:(NSString *)userName WithUserHeader:(BOOL)showUserHeader{
    
    [self.adverseUser addObject:userName];
    if (showUserHeader) {
        [self addRemoteUserHeaderImageViewWithUserName:userName];
    }
    
    RTCEAGLVideoView *remoteView = [self chooseRemoteVideoViewWithUserName:userName];
    return remoteView;
}

- (UIButton *)changeViewBtn {
    if (!_changeViewBtn) {
        _changeViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeViewBtn addTarget:self action:@selector(changView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeViewBtn;
}

- (RTCEAGLVideoView *)chooseRemoteVideoViewWithUserName:(NSString *)userName {
    
    if (_startX > kRTCWidth) {
        return nil;
    }
    CGRect frame = CGRectMake(kRTCWidth - _startX - kMicVideoW, 0, kMicVideoW, kMicVideoH);
    RTCEAGLVideoView *remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:frame];
    remoteVideoView.contentMode = UIViewContentModeScaleAspectFit;
    remoteVideoView.tag = kRTCWidth;
    if (CGRectEqualToRect(CGRectZero, self.changeViewBtn.frame)) {
        self.changeViewBtn.frame = frame;
    }
    UIView *imageView = [[UIView alloc] init];
    imageView.backgroundColor = [UIColor grayColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView addSubview:remoteVideoView];
    //    [self removeAllSubviewsWithParentView:self.adverseStackView];
    [self.adverseStackView removeAllSubviews];
    self.hasShowUserName = userName;
    [self.adverseStackView addSubview:self.changeViewBtn];
    [self.adverseStackView addSubview:imageView];
    [UIView animateWithDuration:0.25 animations:^{
        [self.changeViewBtn layoutIfNeeded];
        [imageView layoutIfNeeded];
        [self.adverseStackView layoutIfNeeded];
    }];
    
    return remoteVideoView;
}

- (void)changView:(UIButton *)btn {

    if (self.isToolsHidden) {
        if (self.hasChangedView == NO) {
            [UIView animateWithDuration:0.1 animations:^{
                
//                [[QIMWebRTCClient sharedInstance] changeViews];
                self.hasChangedView = YES;
            }];
        } else {
            [UIView animateWithDuration:0.1 animations:^{
//                [[QIMWebRTCClient sharedInstance] resizeViews];
                self.hasChangedView = NO;
            }];
        }
    } else {
        [self onToolsViewHidenClick:nil];
    }
}

- (void)removeRemoteVideoViewWithUserName:(NSString *)userName{
    [self.adverseUser removeObject:userName];
    [self resetRemoteVideoView];
}

- (void)removeAllSubviewsWithParentView:(UIView *)parentView {
    while (parentView.subviews.count) {
        UIView* child = parentView.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (void)resetRemoteVideoView {
    _startHeaderX = 0;
    [self.adverseHeaderImageStackView removeAllSubviews];
    for (NSInteger i = 0; i < self.adverseUser.count; i++) {
        NSString *name = [self.adverseUser objectAtIndex:i];
        [self addRemoteUserHeaderImageViewWithUserName:name];
    }
    if (self.adverseUser.count) {
        [[QIMWebRTCMeetingClient sharedInstance] addedStreamWithClickUserId:[self.adverseUser objectAtIndex:0]];
    } else {
        [self.adverseStackView removeAllSubviews];
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self.adverseHeaderImageStackView layoutIfNeeded];
        [self.adverseStackView layoutIfNeeded];
    }];
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

- (void)setContectText:(NSString *)text{
    
}

- (void)showRoomInfo:(NSString *)info{
    
}

@end
