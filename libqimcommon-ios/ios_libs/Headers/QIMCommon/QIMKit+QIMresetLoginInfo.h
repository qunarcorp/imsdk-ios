//
//  QIMKit+QIMresetLoginInfo.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "QIMKit.h"

@interface QIMKit (QIMresetLoginInfo)

- (void) resetIP:(NSString *) ip port:(int) port domain:(NSString *) domain httpServer:(NSString *) http fileServer:(NSString *) fileServer;

@end
