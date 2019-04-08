//
//  QIMPublicRedefineHeader.h
//  QIMPublicRedefineHeader
//
//  Created by 李露 on 11/8/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#ifndef QIMPublicRedefineHeader_h
#define QIMPublicRedefineHeader_h

#if defined (QIMLogEnable) && QIMLogEnable == 1

    #import "CocoaLumberjack.h"

    static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
    //是否开启日志，根据项目配置来
    #define NSLog(frmt, ...) DDLogVerbose(frmt, ##__VA_ARGS__)//版本信息为橙色
    #define QIMErrorLog(frmt, ...) DDLogError(frmt, ##__VA_ARGS__)//错误信息为红白
    #define QIMWarnLog(frmt, ...) DDLogWarn(frmt, ##__VA_ARGS__)//警告为黑黄
    #define QIMInfoLog(frmt, ...) DDLogInfo(frmt, ##__VA_ARGS__)//信息为蓝白
    #define QIMDebugLog(frmt, ...) DDLogDebug(frmt, ##__VA_ARGS__)//调试为白黑
    #define QIMVerboseLog(frmt, ...) DDLogVerbose(frmt, ##__VA_ARGS__)//版本信息为橙色

#else

    //是否开启日志，根据项目配置来
    #define NSLog(frmt, ...)
    #define QIMErrorLog(frmt, ...)
    #define QIMWarnLog(frmt, ...)
    #define QIMInfoLog(frmt, ...)
    #define QIMDebugLog(frmt, ...)
    #define QIMVerboseLog(frmt, ...) 

#endif

#endif /* QIMPublicRedefineHeader_h */
