//
//  QIMBacktraceLogger.h
//  QIMBacktraceLogger
//
//  Created by QTalk on 16/8/27.
//  Copyright © 2016年 QTalk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QTalkLOG NSLog(@"%@",[QIMBacktraceLogger QTalk_backtraceOfCurrentThread]);
#define QTalkLOG_MAIN NSLog(@"%@",[QIMBacktraceLogger QTalk_backtraceOfMainThread]);
#define QTalkLOG_ALL NSLog(@"%@",[QIMBacktraceLogger QTalk_backtraceOfAllThread]);

@interface QIMBacktraceLogger : NSObject

+ (NSString *)qt_backtraceOfAllThread;
+ (NSString *)qt_backtraceOfCurrentThread;
+ (NSString *)qt_backtraceOfMainThread;
+ (NSString *)qt_backtraceOfNSThread:(NSThread *)thread;

@end
