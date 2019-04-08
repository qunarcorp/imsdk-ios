//
//  QIMLocalLog.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/10.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QIMLocalLogTypeDefault = 0,
    QIMLocalLogTypeClosed = 1,
    QIMLocalLogTypeOpened = 2,
} QIMLocalLogType;

@interface QIMLocalLog : NSObject

+ (instancetype)sharedInstance;

/**
 开始记录日志
 */
- (void)startLog;

/**
 停止记录日志
 */
- (void)stopLog;

- (NSArray *)allLogFileAttributes;

/**
 获取本地日志路径
 */
- (NSString *)getLocalLogsPath;

/**
 获取本地日志压缩包路径
 */
- (NSString *)getLocalZipLogsPath;

- (NSData *)logData;

- (void)submitFeedBackWithContent:(NSString *)content WithLogSelected:(BOOL)selected;

- (void)submitFeedBackWithContent:(NSString *)content withUserInitiative:(BOOL)initiative;

@end
