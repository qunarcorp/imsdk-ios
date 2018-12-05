//
//  QIMVoiceNoReadStateManager.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/6/6.
//
//

#import <Foundation/Foundation.h>
@class Message;
@interface QIMVoiceNoReadStateManager : NSObject

+ (instancetype)sharedVoiceNoReadStateManager;

- (BOOL) playVoiceIsNoReadWithMsgId:(NSString *)msgId ChatId:(NSString *)chatId;

- (NSInteger)getIndexOfMsgIdWithChatId:(NSString *)chatId msgId:(NSString *)msgId;


/**
 获取当前未读语音消息
 
 @param chatId chatId
 @param index 消息index
 */
- (NSString *)getMsgIdWithChatId:(NSString *)chatId index:(NSInteger)index;
/**
 获取当前对话中未读语音消息数
 
 @param chatId chatId
 @return 未读语音消息数
 */
- (NSInteger)getVisibleNoReadSoundsCountWithChatId:(NSString *)chatId;

- (BOOL)isReadWithMsgId:(NSString *)messageId ChatId:(NSString *)chatId;

- (void)setVoiceNoReadStateWithMsgId:(NSString *)messageId ChatId:(NSString *)chatId withState:(BOOL) unread;

//Save Message
- (NSString *)getVoiceReadStatePath;

//保存语音消息
- (void)saveVoiceReadStateWithVoiceReadStateDict;

@end
