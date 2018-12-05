//
//  QIMWebRTCSocketClient.h
//  qunarChatMac
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 May. All rights reserved.
//

#import "QIMGeneralModuleFramework.h"

typedef NS_ENUM(SInt32, WebRTCRoomEvent) {
    WebRTCRoomEvent_Unknow = 0,
    WebRTCRoomEvent_JoinRoom = 1,
    WebRTCRoomEvent_ParticipantJoined = 2,
    WebRTCRoomEvent_PublishVideo = 3,
    WebRTCRoomEvent_ParticipantPublished = 4,
    WebRTCRoomEvent_UnpublishVideo = 5,
    WebRTCRoomEvent_ParticipantUnpublished = 6,
    WebRTCRoomEvent_ReceiveVideoFrom = 7,
    WebRTCRoomEvent_UnsubscribeFromVideo = 8,
    WebRTCRoomEvent_OnIceCandidate = 9,
    WebRTCRoomEvent_IceCandidate = 10,
    WebRTCRoomEvent_LeaveRoom = 11,
    WebRTCRoomEvent_ParticipantLeft = 12,
    WebRTCRoomEvent_ParticipantLeftNone = 13,
    WebRTCRoomEvent_SendMessage = 14,
    WebRTCRoomEvent_SendRoomMessage = 15,
    WebRTCRoomEvent_MediaError = 16,
    WebRTCRoomEvent_CustomRequest = 17,
};

NSString *NSStringFromWebRTCRoomEvent(WebRTCRoomEvent value);

@protocol QIMWebRTCSocketClientDelegate;
@interface QIMWebRTCSocketClient : NSObject

@property (nonatomic, weak) id<QIMWebRTCSocketClientDelegate> delegate;

- (void)updateSocketHost;
- (void)setHttpsServerAddress:(NSString *)serverAddress;
- (void)setNavServerAddress:(NSString *)navServerAddress;
- (NSString *)getRTCServerAdress;
- (NSString *)getServerAdress;

// Connect WebRTC Room Server
- (void)connectWebRTCRoomServer;
- (void)closeWebRTCRoomServer;

//Join room
//Represents a client’s request to join a room. If the room does not exist, it is created. To obtain the available rooms, the client should previously use the REST method getAllRooms.
- (void)joinRoom:(NSString *)roomName WithTopic:(NSString *)topic WihtNickName:(NSString *)nickName complete:(void(^)(NSDictionary *))complete;

//Publish video
//Represents a client’s request to start streaming her local media to anyone inside the room. The user can use the SDP answer from the response to display her local media after having passed through the KMS server (as opposed or besides using just the local stream), and thus check what other users in the room are receiving from her stream. The loopback can be enabled using the corresponding parameter.
//
//Method: publishVideo
//Parameters:
//
//sdpOffer: SDP offer sent by this client
//doLoopback: boolean enabling media loopback
- (void)publishVideoWithOfferSdp:(NSString *)offerSdp doLoopback:(BOOL)loopback complete:(void(^)(NSDictionary *))complete;

//Unpublish video
//Represents a client’s request to stop streaming her local media to her room peers.
//
//Method: unpublishVideo
//Parameters: No parameters required
- (void)unpublishVideoComplete:(void(^)(BOOL))complete;;

//Receive video
//Represents a client’s request to receive media from participants in the room that published their media. This method can also be used for loopback connections.
//
//Method: receiveVideoFrom
//Parameters:
//
//sender: id of the publisher’s endpoint, build by appending the publisher’s name and her currently opened stream (usually webcam)
//sdpOffer: SDP offer sent by this client
- (void)receiveVideoFromWithSender:(NSString *)sender WithOfferSdp:(NSString *)offerSdp complete:(void(^)(NSDictionary *))complete;

//Unsubscribe from video
//Represents a client’s request to stop receiving media from a given publisher.
//
//Method: unsubscribeFromVideo
//Parameters:
//
//sender: id of the publisher’s endpoint, build by appending the publisher’s name and her currently opened stream (usually webcam)
- (void)unsubscribeFromVideoWithSender:(NSString *)sender complete:(void(^)(NSDictionary *))complete;

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
- (void)sendICECandidateWithEndpointName:(NSString *)endpointName WithCandidate:(NSString *)candidate WithSdpMLineIndex:(int)sdpMLineIndex WithSdpMid:(NSString *)sdpMid complete:(void(^)(BOOL))complete;

//Leave room
//Represents a client’s notification that she’s leaving the room.
//
//Method: leaveRoom
//Parameters: NONE
- (void)leaveRoomComplete:(void(^)(BOOL))complete;

//Send message
//Used by clients to send written messages to all other participants in the room.
//
//Method: sendMessage
//Parameters:
//
//message: the text message
//userMessage: message originator (username)
//roomMessage: room identifier (room name)
- (void)sendMessage:(NSString *)text WithUserName:(NSString *)userName WithRoomName:(NSString *)roomName complete:(void(^)(BOOL))complete;;


@end

@protocol QIMWebRTCSocketClientDelegate <NSObject>
@optional
// Connected Server
- (void)webRTCSocketClientDidConnected:(QIMWebRTCSocketClient *)client;

// Closed
- (void)webRTCSocketClient:(QIMWebRTCSocketClient *)client  didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

//
- (void)webRTCSocketClient:(QIMWebRTCSocketClient *)client didFailWithError:(NSError *)error;

//Participant joined event
//Event sent by server to all other participants in the room as a result of a new user joining in.
//
//Method: participantJoined
//Parameters:
//
//id: the new participant’s id (username)
- (void)participantJoinedWithUserName:(NSString *)userName;

//Participant published event
//Event sent by server to all other participants in the room as a result of a user publishing her local media stream.
//
//Method: participantPublished
//Parameters:
//
//id: publisher’s username
//streams: list of stream identifiers that the participant has opened to connect with the room. As only webcam is supported, will always be [{"id":"webcam"}].
- (void)participantPublishedWithUserName:(NSString *)userName WithStreams:(NSArray *)streams;

//Participant unpublished event
//Event sent by server to all other participants in the room as a result of a user having stopped publishing her local media stream.
//
//Method: participantUnpublished
//Parameters:
//
//name - publisher’s username
- (void)participantUnpublishedWithUserName:(NSString *)userName;

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
- (void)addIceCandidateWithUserName:(NSString *)userName WithCandidate:(NSString *)candidate WithSdpMLineIndex:(int)sdpMLineIndex WithSdpMid:(NSString *)sdpMid;

//Participant left event
//Event sent by server to all other participants in the room as a consequence of an user leaving the room.
//
//Method: participantLeft
//Parameters:
//
//name: username of the participant that has disconnected
- (void)participantLeftWithUserName:(NSString *)userName;

//Participant evicted event
//Event sent by server to a participant in the room as a consequence of a server-side action requiring the participant to leave the room.
//
//Method: participantEvicted
//Parameters: NONE
- (void)participantLeft;

//Message sent event
//Broadcast event that propagates a written message to all room participants.
//
//Method: sendMessage
//Parameters:
//
//room: current room name
//name: username of the text message source
//message: the text message
- (void)receiveMessage:(NSString *)message WithUserName:(NSString *)userName WithRoomName:(NSString *)roomName;

//Media error event
//Event sent by server to all participants affected by an error event intercepted on a media pipeline or media element.
//
//Method: mediaError
//Parameters:
//
//error: description of the error
- (void)mediaError:(NSString *)error;

@end
