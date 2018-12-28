//
//  QIMOriginMessageParser.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/4.
//

#import "QIMOriginMessageParser.h"
#import "QIMJSONSerializer.h"

@interface QIMOriginMessageParser ()

@property (nonatomic, strong) NSMutableDictionary *originMsgDict;

@end

@implementation QIMOriginMessageParser

- (NSMutableDictionary *)originMsgDict {
    if (!_originMsgDict) {
        _originMsgDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _originMsgDict;
}

static QIMOriginMessageParser *_message = nil;
+ (instancetype)shareParserOriginMessage {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _message = [[QIMOriginMessageParser alloc] init];
    });
    return _message;
}

- (NSString *)getOriginPBMessageWithMsgId:(NSString *)msgId {
    NSDictionary *msgDic = [[QIMKit sharedInstance] getMsgDictByMsgId:msgId];
    id msgRaw = msgDic[@"MsgRaw"];
    if (msgRaw) {
        NSDictionary *originMsgDic = [[QIMKit sharedInstance] parseOriginMessageByMsgRaw:msgRaw];
        return [[QIMJSONSerializer sharedInstance] serializeObject:originMsgDic];
    }
    return nil;
}

//解析原始消息
- (NSDictionary *)getOriginMessageWithMsgId:(NSString *)msgId {
    NSDictionary *msgDic = [[QIMKit sharedInstance] getMsgDictByMsgId:msgId];
    id msgRaw = msgDic[@"MsgRaw"];
    NSDictionary *messageHeaders = msgDic[@"MessageHeaders"];
    NSString * content = nil;
    NSString * extnedInfo = nil;
    NSString * backupInfo = nil;
    QIMMessageType msgType;
    if (msgRaw) {
        NSDictionary * originMsgDic = [[QIMKit sharedInstance] parseMessageByMsgRaw:msgRaw];
        BOOL isJsonMsg = [[originMsgDic objectForKey:@"isJSONMessage"] boolValue];
        if (!isJsonMsg) {
            content = originMsgDic[@"content"];
            messageHeaders = originMsgDic[@"MessageHeaders"];
            extnedInfo = messageHeaders[@"extendInfo"];
            backupInfo = messageHeaders[@"backupinfo"];
            msgType = [[msgDic objectForKey:@"MsgType"] intValue];
        } else {
            NSDictionary *originJsonMsgDic = [originMsgDic objectForKey:@"JSONMessage"];
            content = originJsonMsgDic[@"body"][@"content"];
            extnedInfo = originJsonMsgDic[@"body"][@"extendInfo"];
            backupInfo = originJsonMsgDic[@"body"][@"backupinfo"];
            msgType = [originJsonMsgDic[@"body"][@"msgType"] integerValue];
        }
    }
    NSString *msgContent = [msgDic objectForKey:@"Content"];
    NSDictionary *originMsg = @{@"Content":extnedInfo.length?content:msgContent, @"ExtendInfo":extnedInfo.length?extnedInfo:@"", @"MsgType":@(msgType), @"backupInfo": backupInfo.length?backupInfo:@""};
    return originMsg;
}

- (NSString *)getOriginMsgContentWithMsgId:(NSString *)msgId {
    NSDictionary *originMsgDic = [self getOriginMessageWithMsgId:msgId];
    NSString *msgContent = [originMsgDic objectForKey:@"content"];
    return msgContent;
}

- (NSString *)getOriginMsgExtendInfoWithMsgId:(NSString *)msgId {
    NSDictionary *originMsgDic = [self getOriginMessageWithMsgId:msgId];
    NSString *extendInfo = [originMsgDic objectForKey:@"extendInfo"];
    return extendInfo;
}

- (NSString *)getOriginMsgBackupInfoWithMsgId:(NSString *)msgId {
    NSDictionary *originMsgDic = [self.originMsgDict objectForKey:msgId];
    if (!originMsgDic) {
        originMsgDic = [self getOriginMessageWithMsgId:msgId];
        [self.originMsgDict setQIMSafeObject:originMsgDic forKey:msgId];
    }
    NSString *backupinfo = [originMsgDic objectForKey:@"backupInfo"];
    return backupinfo;
}

- (NSString *)getOriginMsgBackupInfoWithMsgRaw:(id)msgRaw WithMsgId:(NSString *)msgId {
    NSString *memOriginMsg = [self.originMsgDict objectForKey:msgId];
    if (!memOriginMsg.length) {
        NSString * backupInfo = nil;
        if (msgRaw && msgId.length > 0) {
            NSDictionary * originMsgDic = [[QIMKit sharedInstance] parseMessageByMsgRaw:msgRaw];
            BOOL isJsonMsg = [[originMsgDic objectForKey:@"isJSONMessage"] boolValue];
            if (!isJsonMsg) {
                NSDictionary *messageHeaders = originMsgDic[@"MessageHeaders"];
                backupInfo = messageHeaders[@"backupinfo"];
            } else {
                NSDictionary *originJsonMsgDic = [originMsgDic objectForKey:@"JSONMessage"];
                backupInfo = originJsonMsgDic[@"body"][@"backupinfo"];
            }
        }
        [self.originMsgDict setQIMSafeObject:backupInfo forKey:msgId];
        return backupInfo;
    }
    return memOriginMsg;
}

@end
