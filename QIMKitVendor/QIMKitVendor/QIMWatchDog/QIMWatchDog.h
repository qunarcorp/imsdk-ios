//
//  TimeWatch.h
//  qunarChatIphone
//
//  Created by may on 16/5/25.
//
//

#import <Foundation/Foundation.h>

@interface QIMWatchDog : NSObject

+ (instancetype) sharedInstance;

- (void)start;

- (NSTimeInterval) escapedTime;

@end
