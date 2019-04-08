
#import <UIKit/UIKit.h>
#import "QIMRTCNSNotification.h"
#import "QIMWebRTCSocketClient.h"

@class RTCEAGLVideoView;
@interface QIMRTCView : UIView

@property (nonatomic, assign) CGSize localVideoViewSize;
@property (nonatomic, assign) CGSize removeVideoViewSize;

#pragma mark - properties

@property (nonatomic, readonly, assign) BOOL isRoom;
@property (nonatomic, readonly, strong) NSString *roomId;
@property (nonatomic, readonly, strong) NSString *roomName;
@property (nonatomic, strong) QIMWebRTCSocketClient *socketClient;

/** 对方的头像 */
@property (copy, nonatomic) UIImage             *headerImage;
/** 对方的昵称 */
@property (copy, nonatomic) NSString            *nickName;
/** 连接信息，如等待对方接听...、对方已拒绝、语音通话、视频通话 */
@property (copy, nonatomic) NSString            *connectText;
/** 网络提示信息，如网络状态良好、 */
@property (copy, nonatomic) NSString            *netTipText;
/** 是否是被挂断 */
@property (assign, nonatomic)   BOOL            isHanged;
/** 是否已接听 */
@property (assign, nonatomic)   BOOL            answered;
/** 对方是否开启了摄像头 */
@property (assign, nonatomic)   BOOL            oppositeCamera;

/** 头像 */
@property (strong, nonatomic, readonly)   UIImageView             *portraitImageView;
/** 自己的视频画面 */
@property (strong, nonatomic, readonly)   UIImageView             *ownImageView;
/** 对方的视频画面 */
@property (strong, nonatomic, readonly)   UIImageView             *adverseImageView;

@property (nonatomic, strong)   UIView            *adverseStackView;

/** 连接状态，如等待对方接听...、对方已拒绝、语音电话、视频电话 */
@property (strong, nonatomic)   UILabel                 *connectLabel;
/** 网络状态提示，如对方网络良好、网络不稳定等 */
@property (strong, nonatomic)   UILabel                 *netTipLabel;

@property (strong, nonatomic) RTCEAGLVideoView *localVideoView;

#pragma mark - method
- (instancetype)initWithIsVideo:(BOOL)isVideo isCallee:(BOOL)isCallee;

- (instancetype)initWithRoomId:(NSString *)roomId WithRoomName:(NSString *)name isJoin:(BOOL)isJoin;

- (void)show;

- (void)dismiss;

- (void)updateFrameOfLocalView:(CGRect)newFrame;

- (void)updateFrameOfRemoteView:(CGRect)newFrame;

- (void)updateVideoView;

- (void)showAlertMessage:(NSString *)message;

- (void)setContectText:(NSString *)text;
- (void)showRoomInfo:(NSString *)info;

- (RTCEAGLVideoView *)chooseRemoteVideoViewWithUserName:(NSString *)userName;
- (RTCEAGLVideoView *)addRemoteVideoViewWithUserName:(NSString *)userName WithUserHeader:(BOOL)showUserHeader;

- (void)removeAllSubviewsWithParentView:(UIView *)parentView;
- (void)removeRemoteVideoViewWithUserName:(NSString *)userName;

@end
