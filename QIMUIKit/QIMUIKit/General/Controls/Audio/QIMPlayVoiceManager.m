//
//  QIMPlayVoiceManager.m
//  qunarChatIphone
//
//  Created by lilu on 16/6/21.
//
//

#import "QIMPlayVoiceManager.h"
#import "QIMVoiceNoReadStateManager.h"
#import "QIMJSONSerializer.h"
@interface QIMPlayVoiceManager ()

@property (nonatomic, assign) NSInteger currentMsgIndex;

//@property (nonatomic, strong) NSString *currentMsgId;
@property (nonatomic, copy) NSString *currentMsgId;
@end

@implementation QIMPlayVoiceManager

+ (instancetype) defaultPlayVoiceManager {
    
    static QIMPlayVoiceManager *__playVoiceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        __playVoiceManager = [[QIMPlayVoiceManager alloc] init];
    });
    
    return __playVoiceManager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        //自动播放下一条未读语音
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNextVoice:) name:kAutoPlayNextVoiceMsgHandleNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

- (void)playNextVoice:(NSNotification *)notify {
    
    NSInteger index = [notify.object integerValue];
    NSString *msgId = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getMsgIdWithChatId:self.chatId index:index];
    [[QIMPlayVoiceManager defaultPlayVoiceManager] playVoiceWithMsgId:msgId];
}

- (void)setCurrentMsgIdWithMsgId:(NSString *)msgId {
    
    self.currentMsgId = msgId;
}

- (NSInteger)currentMsgIndex {
    
    return [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] getIndexOfMsgIdWithChatId:self.chatId msgId:self.currentMsgId];
}

- (NSString *)currentMsgId {
    
    return _currentMsgId;
}

- (void)playVoiceWithMsgId:(NSString *)msgId {
    
    [self setCurrentMsgIdWithMsgId:msgId];
    NSDictionary *infoDic = [[QIMKit sharedInstance] getMsgDictByMsgId:msgId];
    NSString *content = infoDic[@"Content"];
    NSDictionary *messageDict = [[QIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
    if (content) {
        NSString *fileName = [messageDict objectForKey:@"FileName"];
        NSString *httpUrl = [messageDict objectForKey:@"HttpUrl"];
        NSString *filePath = [messageDict objectForKey:@"filepath"];
        if (httpUrl && ![httpUrl isEqualToString:@""]) {
            [self.playVoiceManagerDelegate playVoiceWithMsgId:msgId WithFileName:fileName andVoiceUrl:httpUrl];
        }else{
            [self.playVoiceManagerDelegate playVoiceWithMsgId:msgId WithFilePath:filePath];
        }
    }
}

@end
