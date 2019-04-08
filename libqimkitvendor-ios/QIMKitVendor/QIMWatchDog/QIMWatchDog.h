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

- (CFAbsoluteTime)startTime;

- (CFAbsoluteTime)escapedTimewithStartTime:(CFAbsoluteTime)startTime;

- (CFAbsoluteTime)endTime;

//- (double)escapedTimewithStartTime:(CFAbsoluteTime)startTime withEndTime:(CFAbsoluteTime)endTime;

//- (void)start;

//- (NSTimeInterval) escapedTime;

@end
