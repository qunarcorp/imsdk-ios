//
//  QIMWebRTCMeetingClient.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/15.
//
//

#import "QIMWebRTCMeetingClient.h"
#import "QIMWebRTCSocketClient.h"
#import "QIMRTCNSNotification.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "QIMRTCView.h"
#import "QIMPublicRedefineHeader.h"
#import "QIMKitPublicHeader.h"
#import "QIMUUIDTools.h"
#import "QIMJSONSerializer.h"
#import "UIView+QIMExtension.h"
#import "QIMNetwork.h"

#import <WebRTC/WebRTC.h>
#import "Masonry.h"
 
@interface QIMWebRTCMeetingClient()<QIMWebRTCSocketClientDelegate,RTCPeerConnectionDelegate /*,RTCSessionDescriptionDelegate*/, RTCVideoViewDelegate>{
    RTCConfiguration *_configuration;
    NSMutableArray *_addIceCandidate;
    NSMutableArray *_localIceCandidate;
    BOOL _createRoom;
}

@property (nonatomic, copy) NSString *navServer;
@property (nonatomic, copy) NSString *httpServer;

@property (strong, nonatomic)   RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong)   RTCMediaConstraints *localPCConstraints;
@property (nonatomic, strong)   RTCMediaConstraints *pcConstraints;
@property (nonatomic, strong)   RTCMediaConstraints *sdpConstraints;
@property (nonatomic, strong)   RTCPeerConnection *localPeerConnection;

@property (nonatomic, strong)   RTCVideoTrack *localVideoTrack;
@property (nonatomic, strong)   RTCAudioTrack *localAudioTrack;
@property (strong, nonatomic)   NSMutableArray *ICEServers;
@property (strong, nonatomic)   NSMutableDictionary *peerConnectionDic;
@property (strong, nonatomic)   NSMutableArray *roomMembers;
@property (strong, nonatomic)   NSMutableDictionary *roomMemberStreams;
@property (strong, nonatomic)   NSMutableDictionary *peerConnectionCanDic;
@property (strong, nonatomic)   NSMutableDictionary *willSendCanDic;

@property (nonatomic, strong)   NSMutableDictionary *remoteVideoTrackDic;

@property (nonatomic, assign)   BOOL usingFrontCamera;
@property (nonatomic, strong)   RTCCameraVideoCapturer *capturer;
@property (nonatomic, strong)   RTCCameraPreviewView   *localVideoView;

@end

@implementation QIMWebRTCMeetingClient
static QIMWebRTCMeetingClient *instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QIMWebRTCMeetingClient alloc] init];
        [instance startEngine];
        instance.usingFrontCamera = YES;
        instance.ICEServers = [NSMutableArray array];
        [instance addNotifications];
    });
    return instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (RTCMediaConstraints *)defaultPCConstraints {

    NSDictionary *mandatoryConstraints = @{@"OfferToReceiveAudio":@"true",@"OfferToReceiveVideo":@"true"};
    NSDictionary *optionalConstraints = @{@"DtlsSrtpKeyAgreement":@"true",@"googIPv6": @"false"};
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:optionalConstraints];
    return constraints;
}

- (RTCMediaConstraints *)defaultLocalPeerConnectionConstraints {
    NSString *value = @"true";
    NSDictionary *mandatoryConstraints = @{@"OfferToReceiveAudio":@"false",@"OfferToReceiveVideo":@"false"};
    NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : value, @"googIPv6" : @"false"};
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                                             optionalConstraints:optionalConstraints];
    return constraints;
}

- (RTCMediaConstraints *)defaultSDPConstraints {
    NSDictionary *sdpMandatoryConstraints = @{@"OfferToReceiveAudio":@"true",@"OfferToReceiveVideo":@"true"};
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:sdpMandatoryConstraints optionalConstraints:nil];
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
    NSArray<AVCaptureDeviceFormat *> *formats = [RTCCameraVideoCapturer supportedFormatsForDevice:device];
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
    [self.localPeerConnection addTrack:track streamIds:@[ kARDMediaStreamId ]];
    _localVideoTrack = [self createLocalVideoTrack];
    if (_localVideoTrack) {
        [self.localPeerConnection addTrack:_localVideoTrack streamIds:@[ kARDMediaStreamId ]];
    }
}

- (RTCMediaConstraints *)defaultMediaAudioConstraints {
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                                             optionalConstraints:nil];
    return constraints;
}

- (void)startEngine
{
    RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
    RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory      decoderFactory:decoderFactory];
    self.localPCConstraints = [self defaultLocalPeerConnectionConstraints];
    self.pcConstraints = [self defaultPCConstraints];
    self.sdpConstraints = [self defaultSDPConstraints];
}

- (void)stopEngine
{
    [self.peerConnectionFactory stopAecDump];
    _peerConnectionFactory = nil;
}

- (BOOL)calling {
    return self.rtcMeetingView != nil;
}

- (RTCMediaConstraints *)defaultPCMe {
    return nil;
}

- (NSArray *)getICEServicesWithService:(NSDictionary *)service{
    NSString *url = [service objectForKey:@"urls"];
    NSString *userName = [service objectForKey:@"username"];
    NSString *credential = [service objectForKey:@"credential"];
    NSMutableArray *ices = [NSMutableArray array];
    
    RTCIceServer *iceServer = [[RTCIceServer alloc] initWithURLStrings:@[url] username:userName credential:credential];
    [ices addObject:iceServer];
    return ices;
}

- (void)updateICEServers{
    if (self.httpServer.length <= 0) {
        self.httpServer = @"https://qtalktv5.vc.cn6.qunar.com:8443";
    }
    if (self.httpServer.length > 0) {
        NSString *httpUrl = [NSString stringWithFormat:@"%@/getTurnServers?username=%@", self.httpServer, [[[QIMKit sharedInstance] thirdpartKeywithValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:httpUrl];
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if(response.code == 200) {
                NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
                int errorCode = [[infoDic objectForKey:@"error"] intValue];
                if (errorCode == 0) {
                    NSArray *services = [infoDic objectForKey:@"servers"];
                    for (NSDictionary *service in services) {
                        NSArray *ices = [self getICEServicesWithService:service];
                        [self.ICEServers addObjectsFromArray:ices];
                    }
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hangupEvent) name:kHangUpNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchCamera) name:kSwitchCameraNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(muteButton:) name:kMuteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoMuteButton:) name:kVideoCaptureNotification object:nil];
}


#pragma mark - setter and getter

- (NSMutableDictionary *)roomMemberStreams {
    if (!_roomMemberStreams) {
        _roomMemberStreams = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return _roomMemberStreams;
}

- (void)muteButton:(NSNotification *)notify{
    BOOL isMute = [[notify.object objectForKey:@"isMute"] boolValue];
    [(RTCMediaStreamTrack *)self.localAudioTrack setIsEnabled:!isMute];
}

- (void)videoMuteButton:(NSNotification *)notify{
    BOOL videoOpen = [[notify.object objectForKey:@"videoCapture"] boolValue];
    [(RTCMediaStreamTrack *)self.localVideoTrack setIsEnabled:videoOpen];
}

- (void)switchCamera {
    _usingFrontCamera = !_usingFrontCamera;
    [self startCapture];
}


- (BOOL)hasOpenRoom {
    return self.rtcMeetingView != nil;
}

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

- (void)createRoomById:(NSString *)roomId WithRoomName:(NSString *)roomName{
    [self joinRoomById:roomId WithRoomName:roomName ];
    _createRoom = YES;
}

- (void)joinRoomByMessage:(NSDictionary *)message {
    
    if (message) {
        NSString *roomId = [message objectForKey:@"roomName"];
        NSString *roomName = [message objectForKey:@"topic"];
        NSString *navServer = [message objectForKey:@"navServ"];
        NSString *httpServer = [message objectForKey:@"server"];
        self.navServer = navServer;
        self.httpServer = httpServer;
        long long startTime = [[message objectForKey:@"startTime"] longLongValue];
        _createRoom = NO;
    
        self.roomName = roomName;
        self.roomId = roomId;
        // 更新ICE Servers
        [self updateICEServers];
        
        _addIceCandidate = [NSMutableArray array];
        _localIceCandidate = [NSMutableArray array];
        self.willSendCanDic = [NSMutableDictionary dictionary];
        self.roomMembers = [NSMutableArray array];
        self.remoteVideoTrackDic = [NSMutableDictionary dictionary];
        _configuration = [[RTCConfiguration alloc] init];
        [_configuration setIceServers:self.ICEServers];
        [_configuration setIceTransportPolicy:RTCIceTransportPolicyAll];
        [_configuration setRtcpMuxPolicy:RTCRtcpMuxPolicyRequire];
        [_configuration setTcpCandidatePolicy:RTCTcpCandidatePolicyEnabled];
        [_configuration setBundlePolicy:RTCBundlePolicyMaxBundle];
        [_configuration setContinualGatheringPolicy:RTCContinualGatheringPolicyGatherContinually];
        [_configuration setKeyType:RTCEncryptionKeyTypeECDSA];
        [_configuration setCandidateNetworkPolicy:RTCCandidateNetworkPolicyAll];
        // 1.显示视图
        self.rtcMeetingView = [[QIMRTCView alloc] initWithRoomId:roomId WithRoomName:roomName isJoin:YES];
        self.rtcMeetingView.nickName = roomName;
        self.rtcMeetingView.headerImage = [[QIMKit sharedInstance] getGroupImageFromLocalByGroupId:self.groupId];
        if ([[QIMKit sharedInstance] getCurrentServerTime] - startTime > 24 * 60 * 60 * 1000) {
            [self.rtcMeetingView showAlertMessage:@"该视频会议房间已经超过一天，不能加入。"];
            return;
        } else {
            [self.rtcMeetingView show];
        }
        
        self.peerConnectionDic = [NSMutableDictionary dictionary];
        self.roomMembers = [NSMutableArray array];
        self.peerConnectionCanDic = [NSMutableDictionary dictionary];
        self.navServer = navServer;
        self.httpServer = httpServer;
    }
}

- (void)answerJoinRoom {

    self.rtcMeetingView.socketClient = [[QIMWebRTCSocketClient alloc] init];
    [self.rtcMeetingView.socketClient setDelegate:self];
    if (!self.navServer || !self.httpServer) {
        [self.rtcMeetingView.socketClient updateSocketHost];
    } else {
        [self.rtcMeetingView.socketClient setNavServerAddress:self.navServer];
        [self.rtcMeetingView.socketClient setHttpsServerAddress:self.httpServer];
    }
    [self initRTCSetting];
    [self.rtcMeetingView.socketClient connectWebRTCRoomServer];
}

- (void)joinRoomById:(NSString *)roomId WithRoomName:(NSString *)roomName{
    _createRoom = NO;
    self.roomName = roomName;
    self.roomId = roomId;
    // 更新ICE Servers
    [self updateICEServers];
    
    _addIceCandidate = [NSMutableArray array];
    _localIceCandidate = [NSMutableArray array];
    self.willSendCanDic = [NSMutableDictionary dictionary];
    self.roomMembers = [NSMutableArray array];
    self.remoteVideoTrackDic = [NSMutableDictionary dictionary];
    _configuration = [[RTCConfiguration alloc] init];
    [_configuration setIceServers:self.ICEServers];
    [_configuration setIceTransportPolicy:RTCIceTransportPolicyAll];
    [_configuration setRtcpMuxPolicy:RTCRtcpMuxPolicyRequire];
    [_configuration setTcpCandidatePolicy:RTCTcpCandidatePolicyEnabled];
    [_configuration setBundlePolicy:RTCBundlePolicyMaxBundle];
    [_configuration setContinualGatheringPolicy:RTCContinualGatheringPolicyGatherContinually];
    [_configuration setKeyType:RTCEncryptionKeyTypeECDSA];
    [_configuration setCandidateNetworkPolicy:RTCCandidateNetworkPolicyAll];
    // 1.显示视图
    self.rtcMeetingView = [[QIMRTCView alloc] initWithRoomId:roomId WithRoomName:roomName isJoin:NO];
    self.rtcMeetingView.headerImage = [QIMKit defaultGroupHeaderImage];
    self.rtcMeetingView.nickName = roomName;
    [self.rtcMeetingView show];
    
    self.rtcMeetingView.socketClient = [[QIMWebRTCSocketClient alloc] init];
    [self.rtcMeetingView.socketClient setDelegate:self];
    
    self.peerConnectionDic = [NSMutableDictionary dictionary];
    self.roomMembers = [NSMutableArray array];
    self.peerConnectionCanDic = [NSMutableDictionary dictionary];
    [self initRTCSetting];
    
    [self.rtcMeetingView.socketClient connectWebRTCRoomServer];
}

- (void)createPeerConnection {
    // 更新ICE Servers
    if (self.ICEServers.count <= 0) {
        [self updateICEServers];
    }

    //创建PeerConnection
    RTCMediaConstraints *optionalConstraints = [self defaultLocalPeerConnectionConstraints];
    self.localPeerConnection = [self.peerConnectionFactory peerConnectionWithConfiguration:_configuration constraints:optionalConstraints delegate:self];
    QIMVerboseLog(@"self.localPeerConnection : %@", self.localPeerConnection);
}

/**
 *  关于RTC 的设置
 */
- (void)initRTCSetting {
    
    self.localVideoView = [[RTCCameraPreviewView alloc] init];
    [self.rtcMeetingView.ownImageView addSubview:self.localVideoView];
    [self.localVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
    [self createPeerConnection];
    [self createMediaSenders];
}

- (void)hangupEvent {
    QIMVerboseLog(@"hangupEvent");
    __weak typeof(self) weakSelf = self;
    [self.rtcMeetingView.socketClient leaveRoomComplete:^(BOOL success) {
        [weakSelf.rtcMeetingView.socketClient closeWebRTCRoomServer];
        [weakSelf.rtcMeetingView dismiss];
        [weakSelf cleanCache];
    }];
}

- (void)cleanCache
{
    [self.localPeerConnection setDelegate:nil];
    [self.localPeerConnection close];
    for (RTCPeerConnection *connect in self.peerConnectionDic.allValues) {
        [connect setDelegate:nil];
        [connect close];
    }
    // 1.将试图置为nil
    self.rtcMeetingView = nil;
    
    [self setLocalPeerConnection:nil];
    [self setLocalAudioTrack:nil];
    [self setLocalVideoTrack:nil];
    [self setPeerConnectionDic:nil];
    [self setPeerConnectionCanDic:nil];
    [self setRemoteVideoTrackDic:nil];
    [self setRoomMembers:nil];
    [self setRoomId:nil];
    [self setRoomName:nil];
    [self setGroupId:nil];
}

- (NSString *)getUserNameWithPeerConnection:(RTCPeerConnection *)peerConnection{
    NSString *userName = @"";
    if ([peerConnection isEqual:self.localPeerConnection]) {
        userName = @"我自己";
    } else {
        for (NSString *key in self.peerConnectionDic.allKeys) {
            RTCPeerConnection *pp = [self.peerConnectionDic objectForKey:key];
            if ([pp isEqual:peerConnection]) {
                userName = key;
                break;
            }
        }
    }
    return userName;
}

- (void)setConnectLabelText:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self.rtcMeetingView.connectLabel setStringValue:text];
        [self.rtcMeetingView setContectText:text];
        [self.rtcMeetingView showRoomInfo:text];
    });
}

#pragma mark - RTCPeerConnectionDelegate
// Triggered when the SignalingState changed.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {
    QIMVerboseLog(@"信令状态改变");
    switch (stateChanged) {
        case RTCSignalingStateStable: {
            QIMVerboseLog(@"stateChanged = RTCSignalingStable");
        }
            break;
        case RTCSignalingStateClosed: {
            QIMVerboseLog(@"stateChanged = RTCSignalingClosed");
        }
            break;
        case RTCSignalingStateHaveLocalOffer: {
            QIMVerboseLog(@"stateChanged = RTCSignalingHaveLocalOffer");
        }
            break;
        case RTCSignalingStateHaveLocalPrAnswer: {
            QIMVerboseLog(@"stateChanged = RTCSignalingHaveLocalPrAnswer");
        }
            break;
        case RTCSignalingStateHaveRemoteOffer: {
            QIMVerboseLog(@"stateChanged = RTCSignalingHaveRemoteOffer");
        }
            break;
        case RTCSignalingStateHaveRemotePrAnswer: {
            QIMVerboseLog(@"stateChanged = RTCSignalingHaveRemotePrAnswer");
        }
            break;
        default:
            break;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    QIMVerboseLog(@"已添加多媒体流");
    QIMVerboseLog(@"Received %lu video tracks and %lu audio tracks",
           (unsigned long)stream.videoTracks.count,
           (unsigned long)stream.audioTracks.count);
    if ([stream.videoTracks count]) {
        if ([peerConnection isEqual:self.localPeerConnection]) {
            QIMVerboseLog(@"");
        } else {
            NSString *userName = [self getUserNameWithPeerConnection:peerConnection];
            QIMVerboseLog(@"userName === %@ : %@", userName, stream);
            [self.roomMemberStreams setObject:stream forKey:userName];
            RTCVideoTrack *videoTrack = stream.videoTracks[0];
            [self.remoteVideoTrackDic setObject:videoTrack forKey:userName];
            dispatch_async(dispatch_get_main_queue(), ^{
                RTCEAGLVideoView *remoteVideoView = [self.rtcMeetingView addRemoteVideoViewWithUserName:userName WithUserHeader:YES];
                [videoTrack addRenderer:remoteVideoView];
            });
        }
    }
}

- (void)addedStreamWithClickUserId:(NSString *)userId {
    if (userId) {
        RTCMediaStream *stream = [self.roomMemberStreams objectForKey:userId];
        if (stream.videoTracks.count) {
            RTCVideoTrack *videoTrack = stream.videoTracks[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                RTCEAGLVideoView *remoteVideoView = [self.rtcMeetingView chooseRemoteVideoViewWithUserName:userId];
                [videoTrack addRenderer:remoteVideoView];
            });
        }
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream {
    QIMVerboseLog(@"Stream was removed.");
}

// Called any time the ICEConnectionState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    NSString *user = [self getUserNameWithPeerConnection:peerConnection];
    QIMVerboseLog(@"ICE state changed: %ld", (long)newState);
    switch (newState) {
        case RTCIceConnectionStateNew: {
            QIMVerboseLog(@"user %@ newState = RTCICEConnectionNew",user);
            [self setConnectLabelText:@"连接中..."];
        }
            break;
        case RTCIceConnectionStateChecking: {
            QIMVerboseLog(@"user %@ newState = RTCICEConnectionChecking",user);
            QIMVerboseLog(@"Local ICE LIST %@\r",_localIceCandidate);
            QIMVerboseLog(@"Add ICE LIST %@\r",_addIceCandidate);
        }
            break;
        case RTCIceConnectionStateConnected: {
            QIMVerboseLog(@"user %@ newState = RTCICEConnectionConnected",user);//15:56:56.698 15:56:57.570
            [self setConnectLabelText:@""];
            dispatch_async(dispatch_get_main_queue(), ^{
                //                [self.rtcMeetingView updateButtonState];
            });
            QIMVerboseLog(@"Local ICE LIST %@\r",_localIceCandidate);
            QIMVerboseLog(@"Add ICE LIST %@\r",_addIceCandidate);
        }
            break;
        case RTCIceConnectionStateCompleted: {
            QIMVerboseLog(@"user %@ newState = RTCICEConnectionCompleted",user);//5:56:57.573
            QIMVerboseLog(@"Local ICE LIST RTCIceConnectionStateCompleted %@\r",_localIceCandidate);
            QIMVerboseLog(@"Add ICE LIST RTCIceConnectionStateCompleted %@\r",_addIceCandidate);
        }
            break;
        case RTCIceConnectionStateFailed: {
            QIMVerboseLog(@"user %@ newState = RTCICEConnectionFailed",user);
            [self.rtcMeetingView showAlertMessage:@"连接失败"];
            [self setConnectLabelText:@"连接失败..."];
            //[self hangupEvent];
            QIMVerboseLog(@"Local ICE LIST %@\r",_localIceCandidate);
            QIMVerboseLog(@"Add ICE LIST %@\r",_addIceCandidate);
        }
            break;
        case RTCIceConnectionStateDisconnected: {
            QIMVerboseLog(@"user %@ newState = RTCICEConnectionDisconnected",user);
            [self.rtcMeetingView showAlertMessage:@"连接断开..."];
//            [self setConnectLabelText:@"连接断开..."];
            if ([self.localPeerConnection isEqual:peerConnection]) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.rtcMeetingView showAlertMessage:@"连接已断开。"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *userName = [self getUserNameWithPeerConnection:peerConnection];
                    if (userName) {
                        [self.peerConnectionDic removeObjectForKey:userName];
                    }
                });
            }
        }
            break;
        case RTCIceConnectionStateClosed: {
            QIMVerboseLog(@"user %@ newState = RTCICEConnectionClosed",user);
            //            [self setConnectLabelText:@"关闭..."];
            if ([self.localPeerConnection isEqual:peerConnection]) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.rtcMeetingView showAlertMessage:@"连接已关闭。"];
                });
            }  else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *userName = [self getUserNameWithPeerConnection:peerConnection];
                    if (userName) {
                        [self.peerConnectionDic removeObjectForKey:userName];
                    }
                });
            }
        }
            break;
        case RTCIceConnectionStateCount: {
            QIMVerboseLog(@"user %@ newState = RTCICEConnectionMax",user);
            [self setConnectLabelText:@"连接最大数..."];
        }
            break;
    }
}

// Called any time the ICEGatheringState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {
    QIMVerboseLog(@"%s",__func__);
    switch (newState) {
        case RTCIceGatheringStateNew: {
            QIMVerboseLog(@"newState = RTCICEGatheringNew");
        }
            break;
        case RTCIceGatheringStateGathering: {
            QIMVerboseLog(@"newState = RTCICEGatheringGathering");
        }
            break;
        case RTCIceGatheringStateComplete: {
            QIMVerboseLog(@"newState = RTCICEGatheringComplete");
        }
            break;
    }
}

// New Ice candidate have been found.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    QIMVerboseLog(@"didGenerateIceCandidate %@",candidate);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([peerConnection isEqual:self.localPeerConnection]) {
            if (self.localPeerConnection.remoteDescription) {
                [self.rtcMeetingView.socketClient sendICECandidateWithEndpointName:[[QIMKit sharedInstance] getLastJid] WithCandidate:candidate.sdp WithSdpMLineIndex:(int)candidate.sdpMLineIndex WithSdpMid:candidate.sdpMid complete:^(BOOL success) {
                    QIMVerboseLog(@"success : %d", success);
                }];
            } else {
                NSString *name = [[QIMKit sharedInstance] getLastJid];
                NSMutableArray *array = [self.willSendCanDic objectForKey:name];
                if (array == nil) {
                    array = [NSMutableArray array];
                    [self.willSendCanDic setObject:array forKey:name];
                }
                [array addObject:candidate];
                [_localIceCandidate addObject:candidate];
            }
        } else {
        
        }
    });
    QIMVerboseLog(@"新的 Ice candidate 被发现. %@",candidate);
}

/** New data channel has been opened. */
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel{
    
    NSString *userName = [self getUserNameWithPeerConnection:peerConnection];
    QIMVerboseLog(@"New data channel has been opened. %@", userName);
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
    QIMVerboseLog(@"WARNING: Renegotiation needed but unimplemented.");
}

#pragma mark - WebRTC Socket Delegate
- (void)receveRemoteVideoWithUserName:(NSString *)user WihtStream:(NSArray *)streams {

    RTCPeerConnection *peerConnection = [self.peerConnectionDic objectForKey:user];
    if (peerConnection == nil) {
        peerConnection = [self.peerConnectionFactory peerConnectionWithConfiguration:_configuration constraints:self.pcConstraints delegate:self];
        [self.peerConnectionDic setObject:peerConnection forKey:user];
    }
    __weak __typeof(self)weakSelf = self;
    [peerConnection offerForConstraints:self.pcConstraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        QIMVerboseLog(@"receveRemoteVideoWithUserName: %@, SDP : %@", user,sdp);
        RTCLogError(@"receveRemoteVideoWithUserName : %@, Error : %@", user, error);
        dispatch_async(dispatch_get_main_queue(), ^{
            RTCSessionDescription *sdpH264 = [weakSelf descriptionWithDescription:sdp videoFormat:@"VP8"];
            [peerConnection setLocalDescription:sdpH264 completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    QIMVerboseLog(@"setLocalDescription Error : %@", error);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        RTCPeerConnection *peerConnection = [weakSelf.peerConnectionDic objectForKey:user];
                        NSString *stream = nil;
                        if (streams.count > 0) {
                            stream = [[streams objectAtIndex:0] objectForKey:@"id"];
                        }
                        if (stream == nil) {
                            stream = @"webcam";
                        }
                        NSString *sender = [NSString stringWithFormat:@"%@_%@",user,stream];
                        [weakSelf.rtcMeetingView.socketClient receiveVideoFromWithSender:sender WithOfferSdp:peerConnection.localDescription.sdp complete:^(NSDictionary *result) {
                            NSString *sdpAnswer = [result objectForKey:@"sdpAnswer"];
                            RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdpAnswer];
                            [peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
                                if (error) {
                                    QIMVerboseLog(@"");
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        RTCPeerConnection *peerConnection = [weakSelf.peerConnectionDic objectForKey:user];
                                        NSArray *list = [weakSelf.peerConnectionCanDic objectForKey:user];
                                        for(RTCIceCandidate *can in list) {
                                            [peerConnection addIceCandidate:can];
                                        }
                                        [weakSelf.peerConnectionCanDic removeObjectForKey:user];
                                    });
                                }
                            }];
                        }];
                    });
                }
            }];
        });
    }];
}

// Connected Server
- (void)webRTCSocketClientDidConnected:(QIMWebRTCSocketClient *)client{
    __weak QIMWebRTCMeetingClient *mySelf = self;
    [mySelf.rtcMeetingView.socketClient joinRoom:mySelf.roomId WithTopic:mySelf.roomName WihtNickName:[[QIMKit sharedInstance] getLastJid] complete:^(NSDictionary *resultDic) {
        NSDictionary *result = [resultDic objectForKey:@"result"];
        if (result) {
            NSArray *userList = [result objectForKey:@"value"];
            [mySelf.roomMembers addObjectsFromArray:userList];
            if (_createRoom) {
                // 发送创建房间的Xmpp消息
                NSMutableDictionary *messageDic = [NSMutableDictionary dictionary];
                [messageDic setObject:mySelf.rtcMeetingView.roomId?mySelf.rtcMeetingView.roomId : [[QIMKit sharedInstance] getLastJid] forKey:@"roomName"];
                [messageDic setObject:mySelf.rtcMeetingView.roomName?mySelf.rtcMeetingView.roomName: [QIMUUIDTools UUID] forKey:@"topic"];
                [messageDic setObject:@(600) forKey:@"ttl"];
                [messageDic setObject:[mySelf.rtcMeetingView.socketClient getRTCServerAdress] forKey:@"navServ"];
                [messageDic setObject:@([[QIMKit sharedInstance] getCurrentServerTime]) forKey:@"createTime"];
                [messageDic setObject:[[QIMKit sharedInstance] getLastJid] forKey:@"creator"];
                [messageDic setObject:@([[QIMKit sharedInstance] getCurrentServerTime]) forKey:@"startTime"];
                [messageDic setObject:[mySelf.rtcMeetingView.socketClient getServerAdress] forKey:@"server"];
                NSString *extendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:messageDic];
                Message *msg = [[QIMKit sharedInstance] sendMessage:@"[当前客户端不支持音视频]" WithInfo:extendInfo ToGroupId:mySelf.groupId WihtMsgType:QIMMessageTypeWebRtcMsgTypeVideoMeeting];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:mySelf.groupId userInfo:@{@"message":msg}];
                });
            }
            [mySelf.localPeerConnection offerForConstraints:mySelf.sdpConstraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
                RTCLogError(@"offerForConstraints : %@", error);
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        RTCSessionDescription *sdpH264 = [mySelf descriptionWithDescription:sdp videoFormat:@"VP8"];
                        [mySelf.localPeerConnection setLocalDescription:sdpH264 completionHandler:^(NSError * _Nullable error) {
                            if (error) {
                                QIMVerboseLog(@"error : %@", error);
                            }
                        }];
                        [mySelf.rtcMeetingView.socketClient publishVideoWithOfferSdp:sdp.sdp doLoopback:NO complete:^(NSDictionary *result) {
                            if (result) {
                                NSString *sdpAnswer = [result objectForKey:@"sdpAnswer"];
                                RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdpAnswer];
                                [mySelf.localPeerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
                                    if (error) {
                                        QIMVerboseLog(@"error2 : %@", error);
                                    } else {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            // 这里切了次线程 莫名其妙的 好使了
                                            // 感觉 Webrtc的所有对象初始化放到主线程比较好使 没有任何原因 不知道为什么
                                            NSString *myUserName = [[QIMKit sharedInstance] getLastJid];
                                            for (RTCIceCandidate *candidate in  [mySelf.willSendCanDic objectForKey:myUserName]) {
                                                [mySelf.rtcMeetingView.socketClient sendICECandidateWithEndpointName:myUserName WithCandidate:candidate.sdp WithSdpMLineIndex:candidate.sdpMLineIndex WithSdpMid:candidate.sdpMid complete:^(BOOL success) {
                                                    if (success) {
                                                        
                                                    } else {
                                                        QIMVerboseLog(@"");
                                                    }
                                                    
                                                }];
                                            }
                                            [mySelf.willSendCanDic removeObjectForKey:myUserName];
                                            NSArray *list = [mySelf.peerConnectionCanDic objectForKey:myUserName];
                                            for(RTCIceCandidate *can in list) {
                                                [mySelf.localPeerConnection addIceCandidate:can];
                                            }
                                            [mySelf.peerConnectionCanDic removeObjectForKey:myUserName];
                                            for (NSDictionary *value in userList) {
                                                NSString *user = [value objectForKey:@"id"];
                                                NSArray *streams = [value objectForKey:@"streams"];
                                                NSNumber *plat = [value objectForKey:@"plat"];
//                                                [self.userPlatDic setObject:plat?@(plat.intValue):@(-1) forKey:user];
                                                [self receveRemoteVideoWithUserName:user WihtStream:streams];
                                                
                                            }
                                        });
                                    }
                                }];
                            }
                        }];
                    });
                }
            }];
        } else {
            NSDictionary *errorDic = [resultDic objectForKey:@"error"];
            int errorCode = [[errorDic objectForKey:@"code"] intValue];
            NSString *errorMsg = [errorDic objectForKey:@"message"];
            [mySelf.rtcMeetingView showAlertMessage:[NSString stringWithFormat:@"加入房间失败，%d:%@",errorCode,errorMsg]];
        }
    }];
}

// Closed
- (void)webRTCSocketClient:(QIMWebRTCSocketClient *)client didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    [self.rtcMeetingView showAlertMessage:[NSString stringWithFormat:@"视频会议连接被关闭，[%ld]%@",(long)code,reason]];
}

//
- (void)webRTCSocketClient:(QIMWebRTCSocketClient *)client didFailWithError:(NSError *)error{
    [self.rtcMeetingView showAlertMessage:[NSString stringWithFormat:@"连接视频会议服务器失败，%@",error]];
}

//Participant joined event
//Event sent by server to all other participants in the room as a result of a new user joining in.
//
//Method: participantJoined
//Parameters:
//
//id: the new participant’s id (username)
- (void)participantJoinedWithUserName:(NSString *)userName{
    NSString *user = userName;
    RTCPeerConnection *peerConnection = [self.peerConnectionFactory peerConnectionWithConfiguration:_configuration constraints:self.pcConstraints delegate:self];
    [self.peerConnectionDic setObject:peerConnection forKey:user];
    
    [peerConnection offerForConstraints:self.pcConstraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        RTCSessionDescription *sdpH264 = [self descriptionWithDescription:sdp videoFormat:@"VP8"];
        [peerConnection setLocalDescription:sdpH264 completionHandler:^(NSError * _Nullable error) {
            if (error) {
                QIMVerboseLog(@"participantJoinedWithUserName Error : %@", error);
            }
        }];
    }];
}

//Participant published event
//Event sent by server to all other participants in the room as a result of a user publishing her local media stream.
//
//Method: participantPublished
//Parameters:
//
//id: publisher’s username
//streams: list of stream identifiers that the participant has opened to connect with the room. As only webcam is supported, will always be [{"id":"webcam"}].
- (void)participantPublishedWithUserName:(NSString *)userName WithStreams:(NSArray *)streams{
    QIMVerboseLog(@"%s", __func__);
    [self receveRemoteVideoWithUserName:userName WihtStream:streams];
}

//Participant unpublished event
//Event sent by server to all other participants in the room as a result of a user having stopped publishing her local media stream.
//
//Method: participantUnpublished
//Parameters:
//
//name - publisher’s username
- (void)participantUnpublishedWithUserName:(NSString *)userName{
    QIMVerboseLog(@"%s", __func__);
    // 会议成员取消了 输入流
}

//Receive ICE Candidate event
//Server event that carries info about an ICE candidate gathered on the server side. This information is required to implement the trickle ICE mechanism. Will be received by the client whenever a new candidate is gathered for the local peer on the server.
//
//Method: iceCandidate
//Parameters:
//
//endpointName: the name of the peer whose ICE candidate was found
//candidate: the candidate attribute information
//sdpMLineIndex: the index (starting at zero) of the m-line in the SDP this candidate is associated with
//sdpMid: media stream identification, “audio” or “video”, for the m-line this candidate is associated with
- (void)addIceCandidateWithUserName:(NSString *)userName WithCandidate:(NSString *)candidate WithSdpMLineIndex:(int)sdpMLineIndex WithSdpMid:(NSString *)sdpMid {
    
    RTCIceCandidate *cand = [[RTCIceCandidate alloc] initWithSdp:candidate sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
    if ([userName isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
        if ([self.localPeerConnection remoteDescription]) {
            [self.localPeerConnection addIceCandidate:cand];
        } else {
            QIMVerboseLog(@"");
            NSMutableArray *list = [self.peerConnectionCanDic objectForKey:[[QIMKit sharedInstance] getLastJid]];
            if (list == nil) {
                list = [NSMutableArray array];
                [self.peerConnectionCanDic setObject:list forKey:[[QIMKit sharedInstance] getLastJid]];
            }
            [list addObject:cand];
        }
        [_addIceCandidate addObject:cand];
    } else {
        RTCPeerConnection *peerConnection = [self.peerConnectionDic objectForKey:userName];
        if ([peerConnection remoteDescription]) {
            [peerConnection addIceCandidate:cand];
        } else {
            QIMVerboseLog(@"");
            NSMutableArray *list = [self.peerConnectionCanDic objectForKey:userName];
            if (list == nil) {
                list = [NSMutableArray array];
                [self.peerConnectionCanDic setObject:list forKey:userName];
            }
            [list addObject:cand];
        }
        [_addIceCandidate addObject:cand];
    }
    QIMVerboseLog(@"Add ICE Candidate %@",self.peerConnectionCanDic);
}

//Participant left event
//Event sent by server to all other participants in the room as a consequence of an user leaving the room.
//
//Method: participantLeft
//Parameters:
//
//name: username of the participant that has disconnected
- (void)participantLeftWithUserName:(NSString *)userName{
    QIMVerboseLog(@"participantLeftWithUserName : %@", userName);
    RTCPeerConnection *connection = [self.peerConnectionDic objectForKey:userName];
    [connection setDelegate:nil];
    [connection close];
    [self.peerConnectionDic removeObjectForKey:userName];
    [self.peerConnectionCanDic removeObjectForKey:userName];
    [self.willSendCanDic removeObjectForKey:userName];
    [self.rtcMeetingView removeRemoteVideoViewWithUserName:userName];
    if (self.peerConnectionDic.count <= 0) {
        [self hangupEvent];
    }
}

//Participant evicted event
//Event sent by server to a participant in the room as a consequence of a server-side action requiring the participant to leave the room.
//
//Method: participantEvicted
//Parameters: NONE
- (void)participantLeft{
    QIMVerboseLog(@"%s", __func__);
}

//Message sent event
//Broadcast event that propagates a written message to all room participants.
//
//Method: sendMessage
//Parameters:
//
//room: current room name
//name: username of the text message source
//message: the text message
- (void)receiveMessage:(NSString *)message WithUserName:(NSString *)userName WithRoomName:(NSString *)roomName{
    QIMVerboseLog(@"%s", __func__);
}

//Media error event
//Event sent by server to all participants affected by an error event intercepted on a media pipeline or media element.
//
//Method: mediaError
//Parameters:
//
//error: description of the error
- (void)mediaError:(NSString *)error{
    QIMVerboseLog(@"%s", __func__);
}

#pragma mark - RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size
{
    if (videoView == self.localVideoView) {
        QIMVerboseLog(@"local size === %@",NSStringFromCGSize(size));
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rtcMeetingView setLocalVideoViewSize:size];
            [self.rtcMeetingView updateVideoView];
        });
    }
}

@end

