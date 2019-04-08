//
//  QIMRTCSingleView.h
//  QIMGeneralModule
//
//  Created by 李露 on 10/19/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QIMRTCNSNotification.h"

@class RTCEAGLVideoView;
@class RTCCameraPreviewView;
NS_ASSUME_NONNULL_BEGIN

@interface QIMRTCSingleView : UIView

@property (nonatomic, assign) CGSize localVideoViewSize;
@property (nonatomic, assign) CGSize removeVideoViewSize;

#pragma mark - properties

/** 是否是被挂断 */
@property (assign, nonatomic)   BOOL            isHanged;
/** 是否已接听 */
@property (assign, nonatomic)   BOOL            answered;

@property (nonatomic, strong) UIView *masterView;

@property (nonatomic, strong) UIView *otherView;

/** 连接状态，如等待对方接听...、对方已拒绝、语音电话、视频电话 */
@property (strong, nonatomic)   UILabel                 *connectLabel;
/** 网络状态提示，如对方网络良好、网络不稳定等 */
@property (strong, nonatomic)   UILabel                 *netTipLabel;

@property (assign, nonatomic)   BOOL                    isRemoteVideoFront;

#pragma mark - method

- (instancetype)initWithWithXmppId:(NSString *)remoteJid IsVideo:(BOOL)isVideo isCallee:(BOOL)isCallee;

- (void)updateRemoteUserInfoWithXmppId:(NSString *)xmppId;

- (void)updateConnectionStateText:(NSString *)stateText;

- (void)show;

- (void)dismiss;

- (void)hiddenHeaderView;

- (void)hiddenBottomView;

- (void)showAlertMessage:(NSString *)message;

- (RTCCameraPreviewView *)getMineCameraPreview;
- (RTCEAGLVideoView *)getOtherVideoView;

- (void)removeAllSubviewsWithParentView:(UIView *)parentView;


@end

NS_ASSUME_NONNULL_END
