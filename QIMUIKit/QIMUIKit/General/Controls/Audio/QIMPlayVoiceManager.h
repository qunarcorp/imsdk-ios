//
//  QIMPlayVoiceManager.h
//  qunarChatIphone
//
//  Created by lilu on 16/6/21.
//
//
#import "QIMCommonUIFramework.h"

#define kNotifyBeginToPlay                @"kNotifyBeginToPlay"
#define kNotifyEndPlay                    @"kNotifyEndPlay"

@class Message;

@protocol PlayVoiceManagerDelegate <NSObject>

- (void)playVoiceWithMsgId:(NSString *)msgId WithFilePath:(NSString *)filePath;

- (void)playVoiceWithMsgId:(NSString *)msgID WithFileName:(NSString *)fileName andVoiceUrl:(NSString *)voiceUrl;

@end

@interface QIMPlayVoiceManager : NSObject

@property (nonatomic, weak) id <PlayVoiceManagerDelegate> playVoiceManagerDelegate;
@property (nonatomic, copy) NSString *chatId;

+ (instancetype) defaultPlayVoiceManager;

- (void)playVoiceWithMsgId:(NSString *)msg;
- (NSString *)currentMsgId;
- (NSInteger)currentMsgIndex;

@end
