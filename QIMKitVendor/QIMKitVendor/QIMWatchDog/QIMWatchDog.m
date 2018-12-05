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

- (void) start {
    _start = CFAbsoluteTimeGetCurrent();
}

- (double) escapedTime {
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    return end - _start;
}

@end
