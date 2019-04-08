//
//  QIMKit+QIMMySelfStatus.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "QIMKit.h"

@interface QIMKit (QIMMySelfStatus)

/**
 上线
 */
- (void)goOnline;

/**
 离开
 */
- (void)goAway;

/**
 忙碌
 */
- (void)goDnd;

/**
 下线
 */
- (void)goOffline;

- (void) deactiveReconnect;

/**
 active reconnect
 */
- (void) activeReconnect;

@end
