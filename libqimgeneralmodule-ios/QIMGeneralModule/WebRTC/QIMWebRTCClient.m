//
//  QIMWebRTCClient.m
//  ChatDemo
//
//  Created by Harvey on 16/5/30.
//  Copyright © 2016年 Mac. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "QIMRTCNSNotification.h"
#import "QIMWebRTCClient.h"

#import "QIMUUIDTools.h"
#import "QIMKitPublicHeader.h"
#import "QIMJSONSerializer.h"
#import "UIView+QIMExtension.h"
#import "NSBundle+QIMLibrary.h"
#import "ASIHTTPRequest.h"
#import "QIMPublicRedefineHeader.h"
#import <WebRTC/WebRTC.h>
#import "Masonry.h"

@interface QIMWebRTCClient ()<RTCPeerConnectionDelegate, RTCVideoViewDelegate>

@property (strong, nonatomic)   RTCPeerConnectionFactory            *peerConnectionFactory;
@property (nonatomic, strong)   RTCMediaConstraints                 *pcConstraints;
@property (nonatomic, strong)   RTCMediaConstraints                 *sdpConstraints;
@property (nonatomic, strong)   RTCMediaConstraints                 *videoConstraints;
@property (nonatomic, strong)   RTCPeerConnection                   *peerConnection;

@property (nonatomic, strong)   RTCCameraPreviewView                *localVideoView;
@property (nonatomic, strong)   RTCEAGLVideoView                    *remoteVideoView;
@property (nonatomic, strong)   RTCVideoTrack                       *localVideoTrack;
@property (nonatomic, strong)   RTCVideoTrack                       *remoteVideoTrack;
@property (nonatomic, strong)   RTCAudioTrack                       *localAudioTrack;

@property (nonatomic, assign)   BOOL usingFrontCamera;

@property (nonatomic, strong)   RTCCameraVideoCapturer *capturer;

@property (strong, nonatomic)   AVAudioPlayer               *audioPlayer;  /**< 音频播放器 */
@property (nonatomic, strong)   CTCallCenter                *callCenter;

@property (strong, nonatomic)   NSMutableArray              *ICEServers;

@property (assign, nonatomic)   BOOL                        HaveSentCandidate;  /**< 已发送候选 */

@property (nonatomic, strong) RTCFileLogger *fileLogger;

@end

@implementation QIMWebRTCClient{
    int _webRTCType;
}

static QIMWebRTCClient *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QIMWebRTCClient alloc] init];
        instance.ICEServers = [NSMutableArray array];
        RTCFileLogger *fileLogger = [[RTCFileLogger alloc] init];
        instance.fileLogger = fileLogger;
        [instance.fileLogger start];
        instance.usingFrontCamera = YES;
        [instance addNotifications];
        [instance startEngine];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)getRemoteFullJid{
    NSString *remoteJid = [NSString stringWithFormat:@"%@%@",self
                           .remoteJID,self.remoteResource.length > 0?[NSString stringWithFormat:@"/%@",self.remoteResource]:@""];
    return remoteJid;
}

- (NSArray *)getICEServicesWithService:(NSDictionary *)service{
    NSArray *uris = [service objectForKey:@"uris"];
    NSString *userName = [service objectForKey:@"username"];
    NSString *credential = [service objectForKey:@"password"];
    NSMutableArray *ices = [NSMutableArray array];
    for (NSString *uri in uris) {
        NSURL *url = [NSURL URLWithString:uri];
        RTCIceServer *ice = [[RTCIceServer alloc] initWithURLStrings:@[uri] username:userName credential:credential];
        [ices addObject:ice];
    }
    return ices;
}

- (void)updateICEServers{
    NSString *httpUrl = [NSString stringWithFormat:@"https://qt.qunar.com/rtc/index.php?username=%@",[[[QIMKit sharedInstance] thirdpartKeywithValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:httpUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request startSynchronous];
    if(request.responseStatusCode == 200) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        int errorCode = [[infoDic objectForKey:@"error"] intValue];
        if (errorCode == 0) {
            NSArray *services = [infoDic objectForKey:@"serverses"];
            for (NSDictionary *service in services) {
                NSArray *ices = [self getICEServicesWithService:service];
                [self.ICEServers addObjectsFromArray:ices];
            } 
        }
    }
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hangupEvent) name:kHangUpNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSignalingMessage:) name:@"kNotifyAudioVideoMsgNotify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptAction) name:kAcceptNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchCamera) name:kSwitchCameraNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(muteButton:) name:kMuteNotification object:nil];
}

- (void)muteButton:(NSNotification *)notify{
    BOOL isMute = [[notify.object objectForKey:@"isMute"] boolValue];
    [(RTCMediaStreamTrack *)self.localAudioTrack setIsEnabled:!isMute];
}

- (void)switchCamera {
    _usingFrontCamera = !_usingFrontCamera;
    [self startCapture];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    NSString *value = @"true";
    NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : value };
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:nil
     optionalConstraints:optionalConstraints];
    return constraints;
}

- (RTCMediaConstraints *)defaultAnswerConstraints {
    return [self defaultOfferConstraints];
}

- (RTCMediaConstraints *)defaultOfferConstraints {
    NSDictionary *mandatoryConstraints = @{
                                           @"OfferToReceiveAudio" : @"true",
                                           @"OfferToReceiveVideo" : @"true"
                                           };
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatoryConstraints
     optionalConstraints:nil];
    return constraints;
}

- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats =
    [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth = [UIScreen mainScreen].bounds.size.width;
    int targetHeight = [UIScreen mainScreen].bounds.size.height;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (diff == currentDiff && pixelFormat == [_capturer preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }
    
    return selectedFormat;
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxFramerate = fmax(maxFramerate, fpsRange.maxFrameRate);
    }
    return maxFramerate;
}

- (void)startCapture {
    AVCaptureDevicePosition position = self.usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    
    if (format == nil) {
        RTCLogError(@"No valid formats for device %@", device);
        NSAssert(NO, @"");
        
        return;
    }
    
    NSInteger fps = [self selectFpsForFormat:format];
    [self.capturer startCaptureWithDevice:device format:format fps:fps];
}

/**
 解决前置摄像头录制视频左右颠倒问题
 */
- (void)videoMirored {
    AVCaptureSession * session = (AVCaptureSession *)self.localVideoView.captureSession;
    for (AVCaptureVideoDataOutput* output in session.outputs) {
        for (AVCaptureConnection * av in output.connections) {
            //判断是否是前置摄像头状态
            if (_usingFrontCamera) {
                if (av.supportsVideoMirroring) {
                    //镜像设置
                    av.videoMirrored = YES;
                }
            }
        }
    }
}

- (RTCVideoTrack *)createLocalVideoTrack {
    
    RTCVideoSource *source = [self.peerConnectionFactory videoSource];
    
#if !TARGET_IPHONE_SIMULATOR
    QIMVerboseLog(@"sss");
    RTCCameraVideoCapturer *capturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:source];
    self.capturer = capturer;
    self.localVideoView.captureSession = capturer.captureSession;
    [self startCapture];
    [self videoMirored];
#else
#if defined(__IPHONE_11_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0)
    if (@available(iOS 10, *)) {
        RTCFileVideoCapturer *fileCapturer = [[RTCFileVideoCapturer alloc] initWithDelegate:source];
//        [fileCapturer startCapturingFromFileNamed:@"Screenrecorde.mp4" onError:^(NSError * _Nonnull error) {
//            QIMVerboseLog(@"error : %@", error);
//        }];
    }
#endif
#endif
    
    return [self.peerConnectionFactory videoTrackWithSource:source trackId:kARDVideoTrackId];
}

- (void)createMediaSenders {
    RTCMediaConstraints *constraints = [self defaultMediaAudioConstraints];
    RTCAudioSource *source = [_peerConnectionFactory audioSourceWithConstraints:constraints];
    RTCAudioTrack *track = [_peerConnectionFactory audioTrackWithSource:source
                                                                trackId:kARDAudioTrackId];
    [_peerConnection addTrack:track streamIds:@[ kARDMediaStreamId ]];
    _localVideoTrack = [self createLocalVideoTrack];
    if (_localVideoTrack) {
        [_peerConnection addTrack:_localVideoTrack streamIds:@[ kARDMediaStreamId ]];
        // We can set up rendering for the remote track right away since the transceiver already has an
        // RTCRtpReceiver with a track. The track will automatically get unmuted and produce frames
        // once RTP is received.
//        RTCVideoTrack *track = (RTCVideoTrack *)([self videoTransceiver].receiver.track);
        //        [_delegate appClient:self didReceiveRemoteVideoTrack:track];
//        [self didReceiveRemoteVideoTrack:track];
    }
}

- (void)startEngine
{
    RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
    RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory decoderFactory:decoderFactory];
    

    
    self.pcConstraints = [self defaultAnswerConstraints];
    self.sdpConstraints = [self defaultOfferConstraints];
    //set RTCVideoSource's(localVideoSource) constraints
    self.videoConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
}

- (void)createPeerConnection {
    // 更新ICE Servers
    [self updateICEServers];
    
    //创建PeerConnection
    RTCMediaConstraints *optionalConstraints = [self defaultPeerConnectionConstraints];
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    config.iceServers = _ICEServers;
    self.peerConnection = [self.peerConnectionFactory peerConnectionWithConfiguration:config constraints:optionalConstraints delegate:self];
}

- (void)stopEngine
{
    RTCCleanupSSL();
    [self.peerConnectionFactory stopAecDump];
    
    _peerConnectionFactory = nil;
}

- (BOOL)calling{
    return self.rtcView != nil;
}

- (void)showRTCViewByXmppId:(NSString *)remoteJid isVideo:(BOOL)isVideo isCaller:(BOOL)isCaller
{
    
    // 1.显示视图
    self.rtcView = [[QIMRTCSingleView alloc] initWithWithXmppId:remoteJid IsVideo:isVideo isCallee:!isCaller];
    [self.rtcView show];
    [self.rtcView updateRemoteUserInfoWithXmppId:remoteJid];
    // 2.播放声音
    NSURL *audioURL;
    if (isCaller) {
        audioURL = [NSURL URLWithString:[NSBundle qim_myLibraryResourcePathWithClassName:@"QIMGeneralModule" BundleName:@"QIMWebRTCIcons" pathForResource:@"AVChat_waitingForAnswer" ofType:@"mp3"]];
    } else {
        audioURL = [NSURL URLWithString:[NSBundle qim_myLibraryResourcePathWithClassName:@"QIMGeneralModule" BundleName:@"QIMWebRTCIcons" pathForResource:@"AVChat_incoming" ofType:@"mp3"]];
    }
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    _audioPlayer.numberOfLoops = -1;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
    // 3.拨打时，禁止黑屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // 4.监听系统电话
    [self listenSystemCall];
    
    // 5.做RTC必要设置
    if (isCaller) {
        [self initRTCSetting];
        // 如果是发起者，创建一个offer信令
        Message *msg = [[QIMKit sharedInstance] sendMessage:@"[当前客户端不支持音视频]" WithInfo:nil ToUserId:self.remoteJID WihtMsgType:QIMWebRTC_MsgType_Video];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:self.remoteJID userInfo:@{@"message":msg}];
        });
    } else {
        // 如果是接收者，就要处理信令信息，创建一个answer
        QIMVerboseLog(@"如果是接收者，就要处理信令信息");
//        self.rtcView.connectText = isVideo ? @"视频通话":@"语音通话";
    }
}

- (RTCMediaConstraints *)defaultMediaAudioConstraints {
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constraints =
    [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                          optionalConstraints:nil];
    return constraints;
}

/**
 *  关于RTC 的设置
 */
- (void)initRTCSetting
{
    [self initLocalVideoView];
    [self initRemoteVideoView];
    
    [self createPeerConnection];
    [self createMediaSenders];
}

- (void)initLocalVideoView {
    
    self.localVideoView = [self.rtcView getMineCameraPreview];
    [self.rtcView.masterView addSubview:self.localVideoView];
    [self.localVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
}

- (void)initRemoteVideoView {
    
    self.remoteVideoView = [self.rtcView getOtherVideoView];
    self.remoteVideoView.delegate = self;
    self.remoteVideoView.hidden = YES;
}

- (void)cleanCache
{
    // 1.将试图置为nil
    self.rtcView = nil;
    
    // 2.将音乐停止
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
    _audioPlayer = nil;
    
    // 3.取消手机常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // 4.取消系统电话监听
    self.callCenter = nil;
    
    _peerConnection = nil;
    _localVideoTrack = nil;
    _remoteVideoTrack = nil;
    _localVideoView = nil;
    _remoteVideoView = nil;
    _HaveSentCandidate = NO;
}

- (void)listenSystemCall
{
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            QIMVerboseLog(@"Call has been disconnected");
        }
        else if ([call.callState isEqualToString:CTCallStateConnected])
        {
            QIMVerboseLog(@"Call has just been connected");
        }
        else if([call.callState isEqualToString:CTCallStateIncoming])
        {
            QIMVerboseLog(@"Call is incoming");
        }
        else if ([call.callState isEqualToString:CTCallStateDialing])
        {
            QIMVerboseLog(@"call is dialing");
        }
        else
        {
            QIMVerboseLog(@"Nothing is done");
        }
    };
}

- (void)switchVideoView {
    if (self.rtcView.isRemoteVideoFront) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.rtcView.masterView removeAllSubviews];
            [self.rtcView.otherView removeAllSubviews];
            
            [self.rtcView.masterView addSubview:self.localVideoView];
            [self.rtcView.otherView addSubview:self.remoteVideoView];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.rtcView.masterView removeAllSubviews];
            [self.rtcView.otherView removeAllSubviews];
            
            [self.rtcView.masterView addSubview:self.remoteVideoView];
            [self.rtcView.otherView addSubview:self.localVideoView];
        });
    }
}

- (void)changeViews {
    
    if (self.rtcView.isRemoteVideoFront) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.rtcView.masterView removeAllSubviews];
            [self.rtcView.otherView removeAllSubviews];
            [self.rtcView.masterView addSubview:self.localVideoView];
            [self.rtcView.otherView addSubview:self.remoteVideoView];
            [self updateMakeConstraints];
            self.rtcView.isRemoteVideoFront = NO;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.rtcView.masterView removeAllSubviews];
            [self.rtcView.otherView removeAllSubviews];

            [self.rtcView.masterView addSubview:self.remoteVideoView];
            [self.rtcView.otherView addSubview:self.localVideoView];
            [self updateMakeConstraints];
            self.rtcView.isRemoteVideoFront = YES;
        });
    }
}

#pragma mark - private method

- (RTCSessionDescription *)descriptionWithDescription:(RTCSessionDescription *)description videoFormat:(NSString *)videoFormat
{
    NSString *sdpString = description.sdp;
    NSString *lineChar = @"\n";
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[sdpString componentsSeparatedByString:lineChar]];
    NSInteger mLineIndex = -1;
    NSString *videoFormatRtpMap = nil;
    NSString *pattern = [NSString stringWithFormat:@"^a=rtpmap:(\\d+) %@(/\\d+)+[\r]?$", videoFormat];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    for (int i = 0; (i < lines.count) && (mLineIndex == -1 || !videoFormatRtpMap); ++i) {
        // mLineIndex 和 videoFromatRtpMap 都更新了之后跳出循环
        NSString *line = lines[i];
        if ([line hasPrefix:@"m=video"]) {
            mLineIndex = i;
            continue;
        }
        
        NSTextCheckingResult *result = [regex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
        if (result) {
            videoFormatRtpMap = [line substringWithRange:[result rangeAtIndex:1]];
            continue;
        }
    }
    
    if (mLineIndex == -1) {
        // 没有m = video line, 所以不能转格式,所以返回原来的description
        QIMVerboseLog(@"No m=video line, so can't prefer %@", videoFormat);
        return description;
    }
    
    if (!videoFormatRtpMap) {
        // 没有videoFormat 类型的rtpmap。
        return description;
    }
    
    NSString *spaceChar = @" ";
    NSArray *origSpaceLineParts = [lines[mLineIndex] componentsSeparatedByString:spaceChar];
    if (origSpaceLineParts.count > 3) {
        NSMutableArray *newMLineParts = [NSMutableArray arrayWithCapacity:origSpaceLineParts.count];
        NSInteger origPartIndex = 0;
        
        [newMLineParts addObject:origSpaceLineParts[origPartIndex++]];
        [newMLineParts addObject:origSpaceLineParts[origPartIndex++]];
        [newMLineParts addObject:origSpaceLineParts[origPartIndex++]];
        [newMLineParts addObject:videoFormatRtpMap];
        for (; origPartIndex < origSpaceLineParts.count; ++origPartIndex) {
            if (![videoFormatRtpMap isEqualToString:origSpaceLineParts[origPartIndex]]) {
                [newMLineParts addObject:origSpaceLineParts[origPartIndex]];
            }
        }
        
        NSString *newMLine = [newMLineParts componentsJoinedByString:spaceChar];
        [lines replaceObjectAtIndex:mLineIndex withObject:newMLine];
    } else {
        QIMVerboseLog(@"SDP Media description 格式 错误");
    }
    NSString *mangledSDPString = [lines componentsJoinedByString:lineChar];
    
    return [[RTCSessionDescription alloc] initWithType:description.type sdp:mangledSDPString];
}

#pragma mark - SDP

- (NSString *)getLocalSDPByRemoteSDP:(NSString *)sdp{
    sdp = [sdp stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
    sdp = [sdp stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    QIMVerboseLog(@"&*******& Remote SDP %@",sdp);
    return sdp;
}

- (NSString *)getRemoteSDPByLocalSDP:(NSString *)sdp{
    QIMVerboseLog(@"&*******& Local SDP %@",sdp);
    sdp = [sdp stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    sdp = [sdp stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    return sdp;
}

- (void)hangupEvent
{
    NSDictionary *dict = @{@"type":@"close"};
    NSString *extentInfo = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
    [[QIMKit sharedInstance] sendAudioVideoWithType:_webRTCType WithBody:@"close" WithExtentInfo:extentInfo WithMsgId:[QIMUUIDTools UUID] ToJid:[self getRemoteFullJid]];
    [self processMessageDict:dict];
}

- (void)receiveSignalingMessage:(NSNotification *)notification{
    NSString *userID = [notification object];
    if ([userID isEqualToString:self.remoteJID]) {
        NSDictionary *dict = [notification userInfo];
        NSString *extendInfo = [dict objectForKey:@"extendInfo"];
        NSString *resource = [dict objectForKey:@"resource"];
        if (self.remoteResource.length <= 0) {
            self.remoteResource = resource;
        }
        QIMVerboseLog(@"===========音视频信息=========\r receiveAudioVideoMsgNotify extendInfo %@",extendInfo);
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
        [self processMessageDict:infoDic];
    }
}

- (void)acceptAction
{
    [self.audioPlayer stop];
    
    [self initRTCSetting];
    
    __weak QIMWebRTCClient *weakSelf = self;
    [self.peerConnection offerForConstraints:self.sdpConstraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        QIMWebRTCClient *strongSelf = weakSelf;
        [self peerConnection:strongSelf.peerConnection didCreateSessionDescription:sdp error:error];
    }];
}

- (void)processMessageDict:(NSDictionary *)dict
{
    NSString *type = dict[@"type"];
    dict = dict[@"payload"];
    if ([type isEqualToString:@"offer"]) {
        NSString *sdpStr = dict[@"sdp"];
        sdpStr = [self getLocalSDPByRemoteSDP:sdpStr];
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:sdpStr];
        __weak __typeof(self)weakSelf = self;
        [self.peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
            RTCLogError(@"processMessageDict setRemoteDescription Error : %@", error);
            [weakSelf peerConnection:[weakSelf peerConnection] didSetSessionDescriptionWithError:error];
        }];
        
        // 2.将音乐停止
        if ([_audioPlayer isPlaying]) {
            [_audioPlayer stop];
        }
        
    } else if ([type isEqualToString:@"answer"]) {
        NSString *sdpStr = dict[@"sdp"];
        sdpStr = [self getLocalSDPByRemoteSDP:sdpStr];
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdpStr];
        __weak id mySelf = self;
        [self.peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
            QIMVerboseLog(@"setRemoteSDP : %@", remoteSdp);
            [mySelf peerConnection:[mySelf peerConnection] didSetSessionDescriptionWithError:error];
        }];
    } else if ([type isEqualToString:@"candidate"]) {
        NSString *mid = [dict objectForKey:@"id"];
        NSNumber *sdpLineIndex = [dict objectForKey:@"label"];
        NSString *sdp = [dict objectForKey:@"candidate"];
        RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpLineIndex.intValue sdpMid:mid];
        if (self.peerConnection.remoteDescription) {
            [self.peerConnection addIceCandidate:candidate];
            QIMVerboseLog(@"Add ICE %@",candidate);
        } else {
            QIMVerboseLog(@"");
        }
    } else if ([type isEqualToString:@"close"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.rtcView) {
                [self.rtcView dismiss];
                [self cleanCache];
            }
        });
    } else if ([type isEqualToString:@"busy"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.rtcView) {
                [self.rtcView dismiss];
                [self cleanCache];
            }
        });
    } else if ([type isEqualToString:@"deny"]) { 
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.rtcView) {
                [self.rtcView dismiss];
                [self cleanCache];
            }
        });
    }
}

#pragma mark - RTCPeerConnectionDelegate
// Triggered when the SignalingState changed.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {
    QIMVerboseLog(@"信令状态改变 Signaling state changed: %ld", (long)stateChanged);
    switch (stateChanged) {
        case RTCSignalingStateStable:
        {
            QIMVerboseLog(@"stateChanged = RTCSignalingStable");
        }
            break;
        case RTCSignalingStateClosed:
        {
            QIMVerboseLog(@"stateChanged = RTCSignalingClosed");
        }
            break;
        case RTCSignalingStateHaveLocalOffer:
        {
            QIMVerboseLog(@"stateChanged = RTCSignalingHaveLocalOffer");
        }
            break;
        case RTCSignalingStateHaveRemoteOffer:
        {
            QIMVerboseLog(@"stateChanged = RTCSignalingHaveRemoteOffer");
            [self setConnectLabelText:@"对方已接受，正在连接..."];
        }
            break;
        case RTCSignalingStateHaveRemotePrAnswer:
        {
            QIMVerboseLog(@"stateChanged = RTCSignalingHaveRemotePrAnswer");
        }
            break;
        case RTCSignalingStateHaveLocalPrAnswer:
        {
            QIMVerboseLog(@"stateChanged = RTCSignalingHaveLocalPrAnswer");
        }
            break;
    }
}

- (void)setConnectLabelText:(NSString *)text {
    __weak QIMWebRTCClient *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMWebRTCClient *strongSelf = weakSelf;
        [strongSelf.rtcView updateConnectionStateText:text];
    });
}

// Triggered when a remote peer close a stream.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream {
    QIMVerboseLog(@"Stream was removed.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didStartReceivingOnTransceiver:(RTCRtpTransceiver *)transceiver {
    RTCMediaStreamTrack *track = transceiver.receiver.track;
    QIMVerboseLog(@"Now receiving %@ on track %@.", track.kind, track.trackId);
}

/** Called when a receiver and its track are created. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
        didAddReceiver:(RTCRtpReceiver *)rtpReceiver
               streams:(NSArray<RTCMediaStream *> *)mediaStreams {
    QIMVerboseLog(@"didAddReceiver :");
}

/** Called when the receiver and its track are removed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
     didRemoveReceiver:(RTCRtpReceiver *)rtpReceiver {
    QIMVerboseLog(@"didRemoveReceiver :");
}

// Called any time the ICEConnectionState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeIceConnectionState:(RTCIceConnectionState)newState {
    QIMVerboseLog(@"ICE state changed: %ld", (long)newState);
    switch (newState) {
        case RTCIceConnectionStateNew:
        {
            QIMVerboseLog(@"newState = RTCICEConnectionNew");
            [self setConnectLabelText:@"连接中..."];
        }
            break;
        case RTCIceConnectionStateChecking:
        {
            QIMVerboseLog(@"newState = RTCICEConnectionChecking");
        }
            break;
        case RTCIceConnectionStateConnected:
        {
            QIMVerboseLog(@"newState = RTCICEConnectionConnected");//15:56:56.698 15:56:57.570
            [self setConnectLabelText:@"已连接"];
        }
            break;
        case RTCIceConnectionStateCompleted:
        {
            QIMVerboseLog(@"newState = RTCICEConnectionCompleted");//5:56:57.573
        }
            break;
        case RTCIceConnectionStateFailed:
        {
            QIMVerboseLog(@"newState = RTCICEConnectionFailed");
            [self setConnectLabelText:@"连接失败..."];
            [self hangupEvent];
        }
            break;
        case RTCIceConnectionStateDisconnected:
        {
            QIMVerboseLog(@"newState = RTCICEConnectionDisconnected");
            [self setConnectLabelText:@"连接断开..."];
            [self hangupEvent];
        }
            break;
        case RTCIceConnectionStateClosed:
        {
            QIMVerboseLog(@"newState = RTCICEConnectionClosed");
            [self setConnectLabelText:@"关闭..."];
            [self hangupEvent];
        }
            break;
        case RTCIceConnectionStateCount:
        {
            QIMVerboseLog(@"newState = RTCICEConnectionMax");
            [self setConnectLabelText:@"连接最大数..."];
        }
            break;
    }
}

// Called any time the ICEGatheringState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceGatheringState:(RTCIceGatheringState)newState {
    QIMVerboseLog(@"peerConnection iceGatheringChanged %s",__func__);
    switch (newState) {
        case RTCIceGatheringStateNew:
        {
            QIMVerboseLog(@"newState = RTCICEGatheringNew");
        }
            break;
        case RTCIceGatheringStateGathering:
        {
            QIMVerboseLog(@"newState = RTCICEGatheringGathering");
        }
            break;
        case RTCIceGatheringStateComplete:
        {
            QIMVerboseLog(@"newState = RTCICEGatheringComplete");
        }
            break;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    QIMVerboseLog(@"Stream with %lu video tracks and %lu audio tracks was added.",
           (unsigned long)stream.videoTracks.count,
           (unsigned long)stream.audioTracks.count);
    QIMVerboseLog(@"Received %lu video tracks and %lu audio tracks",
           (unsigned long)stream.videoTracks.count,
           (unsigned long)stream.audioTracks.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.remoteVideoView.hidden = NO;
        self.rtcView.otherView.hidden = NO;
        [self.rtcView.masterView addSubview:self.remoteVideoView];
        [self.rtcView.otherView addSubview:self.localVideoView];
        [self updateMakeConstraints];
        self.rtcView.isRemoteVideoFront = YES;
        [self.rtcView hiddenHeaderView];
        [self.rtcView hiddenBottomView];
    });
    if ([stream.videoTracks count]) {
        self.remoteVideoTrack = nil;
        [self.remoteVideoView renderFrame:nil];
        self.remoteVideoTrack = stream.videoTracks[0];
        [self.remoteVideoTrack addRenderer:self.remoteVideoView];
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self videoView:self.remoteVideoView didChangeVideoSize:self.rtcView.adverseImageView.bounds.size];
//        [self videoView:self.localVideoView didChangeVideoSize:self.rtcView.masterView.bounds.size];
//    });
}

// New Ice candidate have been found.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    if (self.HaveSentCandidate) {
        return;
    }
    // 发送ICE Candidate
    NSDictionary *dic = @{@"type": @"candidate", @"payload": @{@"label": [NSNumber numberWithInteger:candidate.sdpMLineIndex], @"candidate": candidate.sdp,@"id":candidate.sdpMid}};
    NSString *content = [[QIMJSONSerializer sharedInstance] serializeObject:dic];
    [[QIMKit sharedInstance] sendAudioVideoWithType:_webRTCType WithBody:@"candidate" WithExtentInfo:content WithMsgId:[QIMUUIDTools UUID] ToJid:[self getRemoteFullJid]];
    
    self.HaveSentCandidate = YES;
    QIMVerboseLog(@"新的 Ice candidate 被发现. %@",content);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates {
    QIMVerboseLog(@"移除Ice candidate");
}

// New data channel has been opened.
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel{
    QIMVerboseLog(@"New data channel has been opened.");
}

#pragma mark - RTCSessionDescriptionDelegate
// Called when creating a session.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didCreateSessionDescription:(RTCSessionDescription *)sdp
                 error:(NSError *)error{
    if (error) {
        QIMVerboseLog(@"创建SessionDescription 失败 : %@", error);
    } else {
        QIMVerboseLog(@"创建SessionDescription 成功");
        RTCSessionDescription *sdpH264 = [self descriptionWithDescription:sdp videoFormat:@"VP8"];
        __weak QIMWebRTCClient *weakSelf = self;
        [self.peerConnection setLocalDescription:sdpH264 completionHandler:^(NSError * _Nullable error) {
            QIMWebRTCClient *strongSelf = weakSelf;
            [strongSelf peerConnection:strongSelf.peerConnection didSetSessionDescriptionWithError:error];
        }];
        NSString *sdpString = sdp.sdp;
        sdpString = [self getRemoteSDPByLocalSDP:sdpString];
        NSString *type = sdp.type == RTCSdpTypeOffer ? @"offer" : @"answer";
        NSDictionary *dic = @{@"type":type, @"payload":@{@"type":type,@"sdp":sdpString}};
        NSString *content = [[QIMJSONSerializer sharedInstance] serializeObject:dic];
        [[QIMKit sharedInstance] sendAudioVideoWithType:_webRTCType WithBody:type WithExtentInfo:content WithMsgId:[QIMUUIDTools UUID] ToJid:[self getRemoteFullJid]];
    }
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
    QIMVerboseLog(@"WARNING: Renegotiation needed but unimplemented.");
}

// Called when setting a local or remote description.

- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error
{
    QIMVerboseLog(@"%s",__func__);
    
    if (error) {
        if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer) {
            // 发送offer 信令其实更应该在这里发
            RTCLogError(@"Failed to set session description. Error: %@", error);
        }
        return;
    } else {
        if (peerConnection.signalingState == RTCSignalingStateHaveRemoteOffer && !peerConnection.localDescription) {
            RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
            __weak QIMWebRTCClient *weakSelf = self;
            [self.peerConnection answerForConstraints:constraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
                QIMWebRTCClient *strongSelf = weakSelf;
                [strongSelf peerConnection:strongSelf.peerConnection didCreateSessionDescription:sdp error:error];
            }];
        }
    }
}

#pragma mark - RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size
{
    if (videoView == self.localVideoView) {
        QIMVerboseLog(@"local size === %@",NSStringFromCGSize(size));
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    } else if (videoView == self.remoteVideoView){
        QIMVerboseLog(@"remote size === %@",NSStringFromCGSize(size));
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    }
}

- (void)updateMakeConstraints {
    [self.remoteVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    [self.localVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    [self.remoteVideoTrack addRenderer:self.remoteVideoView];
    self.localVideoView.captureSession = self.capturer.captureSession;
}

@end
