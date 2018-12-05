//
//  QIMRemoteAudioPlayer.h
//  QunarUGC
//
//  Created by 赵岩 on 12-10-25.
//
//

#import <AVFoundation/AVFoundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "QIMCommonUIFramework.h"

typedef enum
{
    QIMRemoteAudioPlayerLoadingFailure,
    QIMRemoteAudioPlayerPlayingFailure,
}QIMRemoteAudioPlayerErrorCode;

@class QIMRemoteAudioPlayer;

@protocol QIMRemoteAudioPlayerDelegate<NSObject>

- (void)downloadProgress:(float)newProgress;

- (void)remoteAudioPlayerReady:(QIMRemoteAudioPlayer *)player;

- (void)remoteAudioPlayerDidStartPlaying:(QIMRemoteAudioPlayer *)player;

- (void)remoteAudioPlayerDidFinishPlaying:(QIMRemoteAudioPlayer *)player;

- (void)remoteAudioPlayerErrorOccured:(QIMRemoteAudioPlayer *)player withErrorCode:(QIMRemoteAudioPlayerErrorCode)errorCode;

@end

@interface QIMRemoteAudioPlayer : NSObject <ASIHTTPRequestDelegate, AVAudioPlayerDelegate>

@property (nonatomic, assign) id<QIMRemoteAudioPlayerDelegate> delegate;

- (BOOL)ready;

- (BOOL)playing;

- (BOOL)play;

- (void)stop;

- (void)pause;

- (NSTimeInterval)currentTime;

- (void)prepareForURL:(NSString *)url playAfterReady:(BOOL)playAfterReady;

- (void)prepareForFilePath:(NSString *)filePath playAfterReady:(BOOL)playAfterReady;

- (void)prepareForWavFilePath:(NSString *)filePath playAfterReady:(BOOL)playAfterReady;

- (void)prepareForFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl playAfterReady:(BOOL)playAfterReady;

@end
