//
//  QIMKit+QIMSystemMessage.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMKit.h"

@interface QIMKit (QIMSystemMessage)

- (void)checkHeadlineMsg;

- (void)updateLastSystemMsgTime;

- (void)updateOfflineSystemNoticeMessages;

- (void)getSystemMsgLisByUserId:(NSString *)userId WithFromHost:(NSString *)fromHost WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete;

@end
