//
//  QIMLogFormatter.m
//  QIMGeneralModule
//
//  Created by 李露 on 2018/9/5.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMLogFormatter.h"

@implementation QIMLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError : logLevel = @"❗️❗️❗️"; break;
        case DDLogFlagWarning : logLevel = @"⚠️⚠️⚠️"; break;
        case DDLogFlagInfo : logLevel = @"ℹ️ℹ️ℹ️"; break;
        case DDLogFlagDebug : logLevel = @"🔧🔧🔧"; break;
        default : logLevel = @""; break;
    }
    //以上是根据不同的类型 定义不同的标记字符
    return [NSString stringWithFormat:@"%@ %@[line:%zd%@]: %@\n", logMessage.timestamp, logMessage->_function, logMessage->_line, logLevel, logMessage->_message];
}

@end
