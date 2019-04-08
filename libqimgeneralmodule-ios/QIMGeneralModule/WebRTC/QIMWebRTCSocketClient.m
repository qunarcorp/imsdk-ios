//
//  QIMWebRTCSocketClient.m
//  qunarChatMac
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 May. All rights reserved.
//

#import "QIMWebRTCSocketClient.h"
#import "SocketRocket.h"
#import "QIMJSONSerializer.h"
#import "QIMKitPublicHeader.h"
#import "QIMNetwork.h"
#import "QIMPublicRedefineHeader.h"

// http://doc-kurento-room.readthedocs.io/en/stable/websocket_api_room_server.html#websocket-messages

typedef void (^Callback)(NSDictionary *);

WebRTCRoomEvent WebRTCRoomEventFromNSString(NSString *value){
    WebRTCRoomEvent event = WebRTCRoomEvent_Unknow;
    if ([value isEqualToString:@"joinRoom"]) {
        event = WebRTCRoomEvent_JoinRoom;
    } else if ([value isEqualToString:@"participantJoined"]) {
        event =  WebRTCRoomEvent_ParticipantJoined;
    } else if ([value isEqualToString:@"publishVideo"]) {
        event =  WebRTCRoomEvent_PublishVideo;
    } else if ([value isEqualToString:@"participantPublished"]) {
        event =  WebRTCRoomEvent_ParticipantPublished;
    } else if ([value isEqualToString:@"unpublishVideo"]) {
        event =  WebRTCRoomEvent_UnpublishVideo;
    } else if ([value isEqualToString:@"participantUnpublished"]) {
        event =  WebRTCRoomEvent_ParticipantUnpublished;
    } else if ([value isEqualToString:@"receiveVideoFrom"]) {
        event =  WebRTCRoomEvent_ReceiveVideoFrom;
    } else if ([value isEqualToString:@"unsubscribeFromVideo"]) {
        event =  WebRTCRoomEvent_UnsubscribeFromVideo;
    } else if ([value isEqualToString:@"onIceCandidate"]) {
        event =  WebRTCRoomEvent_OnIceCandidate;
    } else if ([value isEqualToString:@"iceCandidate"]) {
        event =  WebRTCRoomEvent_IceCandidate;
    } else if ([value isEqualToString:@"leaveRoom"]) {
        event =  WebRTCRoomEvent_LeaveRoom;
    } else if ([value isEqualToString:@"participantLeft"]) {
        event =  WebRTCRoomEvent_ParticipantLeft;
    } else if ([value isEqualToString:@"participantLeft"]) {
        // 怎么区分
        event =  WebRTCRoomEvent_ParticipantLeftNone;
    } else if ([value isEqualToString:@"sendMessage"]) {
        event =  WebRTCRoomEvent_SendMessage;
    } else if ([value isEqualToString:@"sendMessage"]) {
        // 怎么区分
        event =  WebRTCRoomEvent_SendRoomMessage;
    } else if ([value isEqualToString:@"mediaError"]) {
        event =  WebRTCRoomEvent_MediaError;
    } else if ([value isEqualToString:@"customRequest"]) {
        event =  WebRTCRoomEvent_CustomRequest;
    }
    return event;
}

NSString *NSStringFromWebRTCRoomEvent(WebRTCRoomEvent value){
    NSString *method = nil;
    switch (value) {
            case WebRTCRoomEvent_JoinRoom:
        {
            method = @"joinRoom";
        }
            break;
            case WebRTCRoomEvent_ParticipantJoined:
        {
            method = @"participantJoined";
        }
            break;
            case WebRTCRoomEvent_PublishVideo:
        {
            method = @"publishVideo";
        }
            break;
            case WebRTCRoomEvent_ParticipantPublished:
        {
            method = @"participantPublished";
        }
            break;
            case WebRTCRoomEvent_UnpublishVideo:
        {
            method = @"unpublishVideo";
        }
            break;
            case WebRTCRoomEvent_ParticipantUnpublished:
        {
            method = @"participantUnpublished";
        }
            break;
            case WebRTCRoomEvent_ReceiveVideoFrom:
        {
            method = @"receiveVideoFrom";
        }
            break;
            case WebRTCRoomEvent_UnsubscribeFromVideo:
        {
            method = @"unsubscribeFromVideo";
        }
            break;
            case WebRTCRoomEvent_OnIceCandidate:
        {
            method = @"onIceCandidate";
        }
            break;
            case WebRTCRoomEvent_IceCandidate:
        {
            method = @"iceCandidate";
        }
            break;
            case WebRTCRoomEvent_LeaveRoom:
        {
            method = @"leaveRoom";
        }
            break;
            case WebRTCRoomEvent_ParticipantLeft:
        {
            method = @"participantLeft";
        }
            break;
            case WebRTCRoomEvent_ParticipantLeftNone:
        {
            method = @"participantLeft";
        }
            break;
            case WebRTCRoomEvent_SendMessage:
        {
            method = @"sendMessage";
        }
            break;
            case WebRTCRoomEvent_SendRoomMessage:
        {
            method = @"sendMessage";
        }
            break;
            case WebRTCRoomEvent_MediaError:
        {
            method = @"mediaError";
        }
            break;
            case WebRTCRoomEvent_CustomRequest:
        {
            method = @"customRequest";
        }
            break;
        default:
        {
            method = @"unknow";
        }
            break;
    }
    return method;
}

@interface QIMWebRTCSocketClient()<SRWebSocketDelegate>{
    SRWebSocket *_webSocket;
    NSMutableDictionary *_receipts;
    dispatch_queue_t _webSocketQueue;
    void *_webSocketQueueTag;
    void *_mainQueueTag;
    NSString *_rtcSocketHost;
    NSString *_httpRtcSocketHost;
}
@property (nonatomic, readonly) SRWebSocket *webSocket;
@property (nonatomic, assign) int messageId;
@property (nonatomic, strong) NSMutableDictionary *callbackMap;
@end

@implementation QIMWebRTCSocketClient
@synthesize webSocket = _webSocket;

- (void)dealloc{
    _webSocket = nil;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _mainQueueTag = &_mainQueueTag;
        _webSocketQueueTag = &_webSocketQueueTag;
        _webSocketQueue = dispatch_queue_create("websocket", NULL);
        dispatch_queue_set_specific(_webSocketQueue, _webSocketQueueTag, _webSocketQueueTag, NULL);
        dispatch_queue_set_specific(dispatch_get_main_queue(), _mainQueueTag, _mainQueueTag, NULL);
        _receipts = [NSMutableDictionary dictionary];
        
        _rtcSocketHost = [[QIMKit sharedInstance] qimNav_WssHost];
        _httpRtcSocketHost = [[QIMKit sharedInstance] qimNav_VideoApiHost];
        [self updateSocketHost];
    }
    return self;
}

- (void)updateSocketHost{

    NSString *remoteKey = [[QIMKit sharedInstance] thirdpartKeywithValue];
    NSString *url = [NSString stringWithFormat:@"%@?action=conference&method=get_servers&username=%@", [[QIMKit sharedInstance] qimNav_Group_room_host], remoteKey];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSString *http = result[@"data"][@"server"];
                NSString *nav = result[@"data"][@"navServ"];
                [self setHttpsServerAddress:http];
                [self setNavServerAddress:nav];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)setHttpsServerAddress:(NSString *)serverAddress{
    if (serverAddress) {
        _httpRtcSocketHost = serverAddress;
    }
}

- (void)setNavServerAddress:(NSString *)navServerAddress{
    if (navServerAddress) {
        _rtcSocketHost = navServerAddress;
    }
}

- (NSString *)getServerAdress{
    return _httpRtcSocketHost;
}

- (NSString *)getRTCServerAdress {
    return _rtcSocketHost;
}

- (void)connectWebRTCRoomServer{
    [self.webSocket open];
}

- (void)closeWebRTCRoomServer{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendPing) object:nil];
    [self.webSocket close];
    [self.webSocket setDelegate:nil];
}

- (SRWebSocket *)webSocket{
    if (_webSocket == nil) {
        _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:_rtcSocketHost]];
        _webSocket.delegate = self;
        self.callbackMap = [NSMutableDictionary dictionary];
    }
    return _webSocket;
}

- (int)messageId{
    @synchronized (self) {
        _messageId++;
        return _messageId;
    }
}

#pragma mark - websocket method

- (NSString *)jsonrpc{
    return @"2.0";
}

- (void)sendPing{
    NSMutableDictionary *pingDic = [NSMutableDictionary dictionary];
    [pingDic setObject:[self jsonrpc] forKey:@"jsonrpc"];
    [pingDic setObject:@([self messageId]) forKey:@"id"];
    [pingDic setObject:@"ping" forKey:@"method"];
    [pingDic setObject:@{@"interval":@(450000)} forKey:@"params"];
    NSString *message = [[QIMJSONSerializer sharedInstance] serializeObject:pingDic];
    if ([self.webSocket readyState] == SR_OPEN) {
        [self.webSocket sendPing:[message dataUsingEncoding:NSUTF8StringEncoding]];
        [self performSelector:@selector(sendPing) withObject:nil afterDelay:30];
    }
}

- (void)sendMessage:(NSMutableDictionary *)params msgId:(int)msgId complete:(Callback)complete {
    if (params) {
        [params setObject:[[QIMKit sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
        [params setObject:@(1) forKey:@"plat"];
        [params setObject:@(msgId) forKey:@"msgId"];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:[[QIMKit sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
        [params setObject:@(1) forKey:@"plat"];
        [params setObject:@(msgId) forKey:@"msgId"];
    }
    NSString *message = [[QIMJSONSerializer sharedInstance] serializeObject:params];
    if ([self.webSocket readyState] == SR_OPEN) {
        [self.webSocket send:message];
    } else {
        complete(nil);
    }
    [self.callbackMap setObject:complete forKey:@(msgId)];
}

- (void)sendMessage:(NSMutableDictionary *)params WithRoomEvent:(WebRTCRoomEvent)roomEvent WithMsgId:(int)msgId complete:(Callback)complete{
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionary];
    [messageDic setObject:[self jsonrpc] forKey:@"jsonrpc"];
    [messageDic setObject:@(msgId) forKey:@"id"];
    [messageDic setObject:NSStringFromWebRTCRoomEvent(roomEvent) forKey:@"method"];
    if (params) {
        [params setObject:[[QIMKit sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
        [params setObject:@(3) forKey:@"plat"];
        [messageDic setObject:params forKey:@"params"];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:[[QIMKit sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
        [params setObject:@(3) forKey:@"plat"];
        [messageDic setObject:params forKey:@"params"];
    }
    NSString *message = [[QIMJSONSerializer sharedInstance] serializeObject:messageDic];
    if ([self.webSocket readyState] != SR_CONNECTING) {
        [self.webSocket send:message];
    }
    [self.callbackMap setObject:complete forKey:@(msgId)];
}

- (void)paserMessage:(NSString *)message{
    //    dispatch_block_t block = ^{ @autoreleasepool {
    NSDictionary *messageDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message error:nil];
    NSNumber *msgId = [messageDic objectForKey:@"id"];
    if (msgId) {
        Callback complete = [self.callbackMap objectForKey:msgId];
        if (complete) {
            complete(messageDic);
            [self.callbackMap removeObjectForKey:msgId];
        }
    } else {
        WebRTCRoomEvent event = WebRTCRoomEventFromNSString([messageDic objectForKey:@"method"]);
        NSDictionary *params = [messageDic objectForKey:@"params"];
        switch (event) {
                case WebRTCRoomEvent_ParticipantJoined:
            {
                NSString *userName = [params objectForKey:@"id"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(participantJoinedWithUserName:)]) {
                        [self.delegate participantJoinedWithUserName:userName];
                    }
                });
            }
                break;
                case WebRTCRoomEvent_ParticipantPublished:
            {
                NSString *userName = [params objectForKey:@"id"];
                NSArray *streams = [params objectForKey:@"streams"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(participantPublishedWithUserName:WithStreams:)]) {
                        [self.delegate participantPublishedWithUserName:userName WithStreams:streams];
                    }
                });
            }
                break;
                case WebRTCRoomEvent_ParticipantUnpublished:
            {
                NSString *userName = [params objectForKey:@"name"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(participantUnpublishedWithUserName:)]) {
                        [self.delegate participantUnpublishedWithUserName:userName];
                    }
                });
            }
                break;
                case WebRTCRoomEvent_IceCandidate:
            {
                NSString *userName = [params objectForKey:@"endpointName"];
                NSString *candidate = [params objectForKey:@"candidate"];
                int sdpMLineIndex = [[params objectForKey:@"sdpMLineIndex"] intValue];
                NSString *sdpMid = [params objectForKey:@"sdpMid"];
                if ([self.delegate respondsToSelector:@selector(addIceCandidateWithUserName:WithCandidate:WithSdpMLineIndex:WithSdpMid:)]) {
                    [self.delegate addIceCandidateWithUserName:userName WithCandidate:candidate WithSdpMLineIndex:sdpMLineIndex WithSdpMid:sdpMid];
                }
            }
                break;
                case WebRTCRoomEvent_ParticipantLeft:
            {
                NSString *userName = [params objectForKey:@"name"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (userName.length > 0) {
                        if ([self.delegate respondsToSelector:@selector(participantLeftWithUserName:)]) {
                            [self.delegate participantLeftWithUserName:userName];
                        }
                    } else {
                        if ([self.delegate respondsToSelector:@selector(participantLeft)]) {
                            [self.delegate participantLeft];
                        }
                    }
                });
            }
                break;
                case WebRTCRoomEvent_SendMessage:
            {
                NSString *roomName = [params objectForKey:@"room"];
                NSString *userName = [params objectForKey:@"user"];
                NSString *message = [params objectForKey:@"message"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(receiveMessage:WithUserName:WithRoomName:)]) {
                        [self.delegate receiveMessage:message WithUserName:userName WithRoomName:roomName];
                    }
                });
            }
                break;
                case WebRTCRoomEvent_MediaError:
            {
                NSString *error = [params objectForKey:@"error"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(mediaError:)]) {
                        [self.delegate mediaError:error];
                    }
                });
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - webrtc message
//Join room
//Represents a client’s request to join a room. If the room does not exist, it is created. To obtain the available rooms, the client should previously use the REST method getAllRooms.
- (void)joinRoom:(NSString *)roomName WithTopic:(NSString *)topic WihtNickName:(NSString *)nickName complete:(void (^)(NSDictionary *))complete{
    NSAssert(dispatch_get_specific(_mainQueueTag) != NULL, @"Not Allow Call Metod In Main Queue");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:nickName?nickName:@"飞翔的昵称" forKey:@"user"];
    [params setObject:roomName?roomName:@"test" forKey:@"room"];
    [params setObject:topic?topic:@"视频会议" forKey:@"topic"];
    [params setObject:@(NO) forKey:@"dataChannels"];
    [params setObject:@([[QIMKit sharedInstance] getCurrentServerTime]) forKey:@"startTime"];
    [self sendMessage:params WithRoomEvent:WebRTCRoomEvent_JoinRoom WithMsgId:[self messageId] complete:^(NSDictionary *result){
        complete(result);
    }];
}

//Publish video
//Represents a client’s request to start streaming her local media to anyone inside the room. The user can use the SDP answer from the response to display her local media after having passed through the KMS server (as opposed or besides using just the local stream), and thus check what other users in the room are receiving from her stream. The loopback can be enabled using the corresponding parameter.
//
//Method: publishVideo
//Parameters:
//
//sdpOffer: SDP offer sent by this client
//doLoopback: boolean enabling media loopback
- (void)publishVideoWithOfferSdp:(NSString *)offerSdp doLoopback:(BOOL)loopback complete:(void (^)(NSDictionary *))complete{
    NSAssert(dispatch_get_specific(_mainQueueTag) != NULL, @"Not Allow Call Metod In Main Queue");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:offerSdp forKey:@"sdpOffer"];
    [params setObject:@"viewer" forKey:@"id"];
    [params setObject:@(NO) forKey:@"doLoopback"];
    [self sendMessage:params WithRoomEvent:WebRTCRoomEvent_PublishVideo WithMsgId:[self messageId] complete:^(NSDictionary *result) {
        complete(result[@"result"]);
    }];
}

//Unpublish video
//Represents a client’s request to stop streaming her local media to her room peers.
//
//Method: unpublishVideo
//Parameters: No parameters required
- (void)unpublishVideoComplete:(void (^)(BOOL))complete{
    NSAssert(dispatch_get_specific(_mainQueueTag) != NULL, @"Not Allow Call Metod In Main Queue");
    [self sendMessage:nil WithRoomEvent:WebRTCRoomEvent_UnpublishVideo WithMsgId:[self messageId] complete:^(NSDictionary *result) {
        NSString *sessionId = [[result objectForKey:@"result"] objectForKey:@"sessionId"];
        if (sessionId) {
            complete(YES);
        } else {
            complete(NO);
        }
    }];
}

//Receive video
//Represents a client’s request to receive media from participants in the room that published their media. This method can also be used for loopback connections.
//
//Method: receiveVideoFrom
//Parameters:
//
//sender: id of the publisher’s endpoint, build by appending the publisher’s name and her currently opened stream (usually webcam)
//sdpOffer: SDP offer sent by this client
- (void)receiveVideoFromWithSender:(NSString *)sender WithOfferSdp:(NSString *)offerSdp complete:(void (^)(NSDictionary *))complete{
    NSAssert(dispatch_get_specific(_mainQueueTag) != NULL, @"Not Allow Call Metod In Main Queue");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:offerSdp forKey:@"sdpOffer"];
    [params setObject:sender forKey:@"sender"];
    [self sendMessage:params WithRoomEvent:WebRTCRoomEvent_ReceiveVideoFrom WithMsgId:[self messageId] complete:^(NSDictionary *result) {
        complete(result[@"result"]);
    }];
}

//Unsubscribe from video
//Represents a client’s request to stop receiving media from a given publisher.
//
//Method: unsubscribeFromVideo
//Parameters:
//
//sender: id of the publisher’s endpoint, build by appending the publisher’s name and her currently opened stream (usually webcam)
- (void)unsubscribeFromVideoWithSender:(NSString *)sender complete:(void (^)(NSDictionary *))complete{
    NSAssert(dispatch_get_specific(_mainQueueTag) != NULL, @"Not Allow Call Metod In Main Queue");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:sender forKey:@"sender"];
    [self sendMessage:params WithRoomEvent:WebRTCRoomEvent_ReceiveVideoFrom WithMsgId:[self messageId] complete:^(NSDictionary *result) {
        complete(result[@"result"]);
    }];
}

//Send ICE Candidate
//Request that carries info about an ICE candidate gathered on the client side. This information is required to implement the trickle ICE mechanism. Should be sent whenever an ICECandidate event is created by a RTCPeerConnection.
//
//Method: onIceCandidate
//Parameters:
//
//endpointName: the name of the peer whose ICE candidate was found
//candidate: the candidate attribute information
//sdpMLineIndex: the index (starting at zero) of the m-line in the SDP this candidate is associated with
//sdpMid: media stream identification, “audio” or “video”, for the m-line this candidate is associated with
- (void)sendICECandidateWithEndpointName:(NSString *)endpointName WithCandidate:(NSString *)candidate WithSdpMLineIndex:(int)sdpMLineIndex WithSdpMid:(NSString *)sdpMid complete:(void (^)(BOOL))complete{
    NSAssert(dispatch_get_specific(_mainQueueTag) != NULL, @"Not Allow Call Metod In Main Queue");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:endpointName forKey:@"endpointName"];
    [params setObject:candidate forKey:@"candidate"];
    [params setObject:@(sdpMLineIndex) forKey:@"sdpMLineIndex"];
    [params setObject:sdpMid forKey:@"sdpMid"];
    QIMVerboseLog(@"Send Candidate %@",params);
    [self sendMessage:params WithRoomEvent:WebRTCRoomEvent_OnIceCandidate WithMsgId:[self messageId] complete:^(NSDictionary *result) {
        NSString *sessionId = [[result objectForKey:@"result"] objectForKey:@"sessionId"];
        if (sessionId) {
            complete(YES);
        } else {
            complete(NO);
        }
    }];
}

//Leave room
//Represents a client’s notification that she’s leaving the room.
//
//Method: leaveRoom
//Parameters: NONE
- (void)leaveRoomComplete:(void (^)(BOOL))complete{
    NSAssert(dispatch_get_specific(_mainQueueTag) != NULL, @"Not Allow Call Metod In Main Queue");
    [self sendMessage:nil WithRoomEvent:WebRTCRoomEvent_LeaveRoom WithMsgId:[self messageId] complete:^(NSDictionary *result) {
        NSString *sessionId = [[result objectForKey:@"result"] objectForKey:@"sessionId"];
        if (sessionId) {
            complete(YES);
        } else {
            complete(NO);
        }
    }];
}

//Send message
//Used by clients to send written messages to all other participants in the room.
//
//Method: sendMessage
//Parameters:
//
//message: the text message
//userMessage: message originator (username)
//roomMessage: room identifier (room name)
- (void)sendMessage:(NSString *)text WithUserName:(NSString *)userName WithRoomName:(NSString *)roomName complete:(void (^)(BOOL))complete{
    NSAssert(dispatch_get_specific(_mainQueueTag) != NULL, @"Not Allow Call Metod In Main Queue");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:text forKey:@"message"];
    [params setObject:userName forKey:@"userMessage"];
    [params setObject:roomName forKey:@"roomMessage"];
    [self sendMessage:nil WithRoomEvent:WebRTCRoomEvent_SendMessage WithMsgId:[self messageId] complete:^(NSDictionary *result) {
        NSString *sessionId = [[result objectForKey:@"result"] objectForKey:@"sessionId"];
        if (sessionId) {
            complete(YES);
        } else {
            complete(NO);
        }
    }];
}

///--------------------------------------
#pragma mark - SRWebSocketDelegate
///--------------------------------------

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    QIMVerboseLog(@"Websocket Connected");
    if ([self.delegate respondsToSelector:@selector(webRTCSocketClientDidConnected:)]) {
        [self.delegate webRTCSocketClientDidConnected:self];
        [self sendPing];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    QIMVerboseLog(@"Websocket Failed With Error %@", error);
    if ([self.delegate respondsToSelector:@selector(webRTCSocketClient:didCloseWithCode:reason:wasClean:)]) {
        [self.delegate webRTCSocketClient:self didFailWithError:error];
    }
    _webSocket = nil;
}
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    QIMVerboseLog(@"Received \"%@\"", message);
    [self paserMessage:message];
}

//长链接关闭
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    QIMVerboseLog(@"WebSocket closed");
    if ([self.delegate respondsToSelector:@selector(webRTCSocketClient:didCloseWithCode:reason:wasClean:)]) {
        [self.delegate webRTCSocketClient:self didCloseWithCode:code reason:reason wasClean:wasClean];
    }
    _webSocket = nil;
}

//接收服务器发送的pong消息
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    QIMVerboseLog(@"WebSocket received pong : %@", reply);
}

@end
