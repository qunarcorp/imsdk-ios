//
//  QIMOriginMessageParser.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/4.
//

#import "QIMCommonUIFramework.h"

@interface QIMOriginMessageParser : NSObject

+ (instancetype)shareParserOriginMessage;

//解析PB消息
- (NSString *)getOriginPBMessageWithMsgId:(NSString *)msgId;

//解析原始消息
- (NSDictionary *)getOriginMessageWithMsgId:(NSString *)msgId;

//解析原始消息Content
- (NSString *)getOriginMsgContentWithMsgId:(NSString *)msgId;

//解析原始消息ExtendInfo
- (NSString *)getOriginMsgExtendInfoWithMsgId:(NSString *)msgId;

//解析原始消息BackUpInfo
- (NSString *)getOriginMsgBackupInfoWithMsgId:(NSString *)msgId;

//根据MsgRaw解析
- (NSString *)getOriginMsgBackupInfoWithMsgRaw:(id)msgRaw WithMsgId:(NSString *)msgId;

@end
