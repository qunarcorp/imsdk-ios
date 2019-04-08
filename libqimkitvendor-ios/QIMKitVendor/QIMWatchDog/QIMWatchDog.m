//
//  TimeWatch.m
//  qunarChatIphone
//
//  Created by may on 16/5/25.
//
//

#import "QIMWatchDog.h"

@interface QIMWatchDog () {
    double _start;
}

@end

@implementation QIMWatchDog

+ (instancetype) sharedInstance {
    static QIMWatchDog *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[QIMWatchDog alloc] init];
    });
    return monitor;
}

- (CFAbsoluteTime)startTime {
    return CFAbsoluteTimeGetCurrent();
}

- (CFAbsoluteTime)escapedTimewithStartTime:(CFAbsoluteTime)startTime {
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    return endTime - startTime;
}

- (CFAbsoluteTime)endTime {
    return CFAbsoluteTimeGetCurrent();
}

- (double)escapedTimewithStartTime:(CFAbsoluteTime)startTime withEndTime:(CFAbsoluteTime)endTime {
    return endTime - startTime;
}

- (void) start {
    _start = CFAbsoluteTimeGetCurrent();
}

- (double) escapedTime {
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    return end - _start;
}

@end
