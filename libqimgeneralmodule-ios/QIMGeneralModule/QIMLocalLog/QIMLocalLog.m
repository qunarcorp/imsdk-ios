//
//  QIMLocalLog.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/10.
//
//

#import "QIMLocalLog.h"
#import "QIMZipArchive.h"
#import "NSString+QIMUtility.h"
#import "NSDateFormatter+QIMCategory.h"
#import "QIMKitPublicHeader.h"
#import "QIMJSONSerializer.h"
#import "QIMUUIDTools.h"
#import "QIMNetwork.h"
#import "QIMLogFormatter.h"
#import "CocoaLumberjack.h"
#import "QIMPublicRedefineHeader.h"

static NSString *LocalLogsPath = @"Logs";
static NSString *LocalZipLogsPath = @"ZipLogs";

@interface QIMLocalLog ()

@end

@implementation QIMLocalLog

+ (void)load {
    [QIMLocalLog sharedInstance];
}

+ (instancetype)sharedInstance {
    static QIMLocalLog *__localLog = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __localLog = [[QIMLocalLog alloc] init];
    });
    return __localLog;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        fileLogger.rollingFrequency = (24 * 60 * 60) * 4;   //3天
        fileLogger.maximumFileSize = 1024 * 1024 * 3; //每个log日志文件3M
        fileLogger.logFileManager.maximumNumberOfLogFiles = 1000; //最多保留1000个日志
        fileLogger.logFileManager.logFilesDiskQuota = 300 * 1024 * 1024; //300M
        [DDLog addLogger:fileLogger withLevel:DDLogLevelAll];
        [DDLog addLogger:[DDASLLogger sharedInstance]]; //将日志打印到系统Console中
    }
    return self;
}

- (void)startLog {
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *lastUserName = [QIMKit getLastUserName];
    [[QIMKit sharedInstance] setCacheName:[[QIMKit sharedInstance] getLastJid]];
    QIMLocalLogType logType = [[[QIMKit sharedInstance] userObjectForKey:@"recordLogType"] integerValue];
    logType = QIMLocalLogTypeOpened;
    [[QIMKit sharedInstance] setUserObject:@(QIMLocalLogTypeOpened) forKey:@"recordLogType"];
    if ([lastUserName containsString:@"dan.liu"] || [lastUserName containsString:@"weiping.he"] || [lastUserName containsString:@"lilulucas.li"] || [lastUserName containsString:@"geng.li"] || [lastUserName containsString:@"ping.xue"] || [lastUserName containsString:@"wz.wang"]) {
        QIMLocalLogType logType = [[[QIMKit sharedInstance] userObjectForKey:@"recordLogType"] integerValue];
        if (logType == QIMLocalLogTypeDefault) {
            [[QIMKit sharedInstance] setUserObject:@(QIMLocalLogTypeOpened) forKey:@"recordLogType"];
        }
    }
}

- (void)stopLog {
    QIMVerboseLog(@"关闭记录本地日志");
    fclose(stdout);
    fclose(stderr);
}

- (NSString *)getLogFilePath {
    NSString *logDirectory = [self getLocalLogsPath];

    NSArray *logArray = [self allLogFilesAtPath:logDirectory];
    NSString *logFilePath = nil;
    if (logArray.count > 0) {
        NSString *lastLogFilePath = [logArray lastObject];
        NSDictionary *logFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:lastLogFilePath error:nil];
        if (logFileAttributes != nil) {
            NSDate *fileModDate = [logFileAttributes objectForKey:NSFileModificationDate]; //修改时间
            NSNumber *theFileSize = [logFileAttributes objectForKey:NSFileSize]; //文件字节数
            CGFloat overSizeFileFlag = theFileSize.longLongValue / 1024 / 1024;
            NSTimeInterval timeIntervalSinceNow = [fileModDate timeIntervalSinceNow];
            //如果最后一个log文件超过两小时或文件Size>5M就重新创建一个日志文件
            if (fabs(fabs(timeIntervalSinceNow) / (3600 * 2)) >= 1 || overSizeFileFlag >= 5) {
                logFilePath = [self createNewLogFileWithDirectory:logDirectory];
            } else {
                logFilePath = lastLogFilePath;
            }
        }
    } else {
        logFilePath = [self createNewLogFileWithDirectory:logDirectory];
    }
    if (logFilePath.length <= 0 || !logFilePath) {
        logFilePath = [self createNewLogFileWithDirectory:logDirectory];
    }
    return logFilePath;
}

- (void)redirectNSLogToDocumentFolder {
    
    NSString *logFilePath = [self getLogFilePath];
    // 将log输入到文件
    QIMVerboseLog(@"本地日志路径 : %@", logFilePath);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (NSArray *)allLogFilesAtPath:(NSString *)dirPath {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *tempArray = [fileMgr contentsOfDirectoryAtPath:dirPath error:nil];
    for (NSString *fileName in tempArray) {
        BOOL flag = YES;
        NSString *fullPath = [dirPath stringByAppendingPathComponent:fileName];
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                [array addObject:fullPath];
            }
        }
    }
    return array;
}

- (NSArray *)allLogFileAttributes {
    NSString *dirPath = [self getLocalLogsPath];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *tempArray = [fileMgr contentsOfDirectoryAtPath:dirPath error:nil];
    for (NSString *fileName in tempArray) {
        BOOL flag = YES;
        NSString *fullPath = [dirPath stringByAppendingPathComponent:fileName];
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                NSDictionary *logFileAttributeDict = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
                [array addObject:@{@"LogFilePath":fullPath, @"logFileAttribute":logFileAttributeDict}];
            }
        }
    }
    return array;
}

- (NSString *)createNewLogFileWithDirectory:(NSString *)logDirectory {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter qim_defaultDateFormatter];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSString *newFileName = [dateStr stringByAppendingString:@".log"];
    NSString *newLogFilePath = [logDirectory stringByAppendingPathComponent:newFileName];
    if (newLogFilePath.length) {
        return newLogFilePath;
    }
    return nil;
}

- (void)deleteLocalLog {
    NSString *logDirectory = [self getLocalLogsPath];
    NSArray *logArray = [self allLogFilesAtPath:logDirectory];
    for (NSString *logFilePath in logArray) {
        NSDictionary *logFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:logFilePath error:nil];
        NSDate *fileModDate = [logFileAttributes objectForKey:NSFileModificationDate]; //修改时间
        NSTimeInterval timeIntervalSinceNow = [fileModDate timeIntervalSinceNow];
        if (fabs(fabs(timeIntervalSinceNow) / (3600 * 24 * 1.5)) >= 1) { //删除间隔超过一天半的日志
            NSError *error = nil;
            BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&error];
            if (removeSuccess) {
                QIMVerboseLog(@"删除旧日志<%@>成功", logFilePath);
            } else {
                QIMVerboseLog(@"<删除旧日志失败, 失败原因 : %@>", error);
            }
        }
    }
}

- (NSString *)getLocalLogsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:LocalLogsPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:logDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return logDirectory;
}

- (NSString *)getLocalZipLogsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:LocalZipLogsPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:logDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return logDirectory;
}

//合并数据库，本地日志等
- (NSData *)allLogData {
    
    NSMutableArray *logArray = [NSMutableArray arrayWithCapacity:5];

    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    
    //UserDefault文件
    NSString *userDefaultPath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.plist", @"Preferences", [[NSBundle mainBundle] bundleIdentifier]]];
    [logArray addObject:userDefaultPath];
    
    [[QIMKit sharedInstance] qimDB_dbCheckpoint];
    
    //数据库文件
    NSString *UserPath = [[QIMKit sharedInstance] qimNav_Debug] ? @"_Beta": @"_Release";
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@/data.dat", [[QIMKit sharedInstance] getLastJid], UserPath]];
    [logArray addObject:dbPath];
    
    NSString *cpBundlePath = [[[QIMLocalLog sharedInstance] getLocalLogsPath] stringByAppendingPathComponent:@"suggest.jsbundle"];
    [logArray addObject:cpBundlePath];
    
    NSString *cpBundlePath2 = [[[QIMLocalLog sharedInstance] getLocalLogsPath] stringByAppendingPathComponent:@"suggestAssetBundle.jsbundle"];
    [logArray addObject:cpBundlePath2];

    //本地日志
    NSArray *allLocalLogs = [self allLogFilesAtPath:[self getLocalLogsPath]];
    for (NSString *logPath in allLocalLogs) {
        [logArray addObject:logPath];
    }
    NSString *zipFileName = [NSString stringWithFormat:@"%@-log.zip", [[QIMKit sharedInstance] getLastJid]];

    NSString *zipFilePath = [[QIMZipArchive sharedInstance] zipFiles:logArray ToFile:[[QIMLocalLog sharedInstance] getLocalZipLogsPath] ToZipFileName:zipFileName WithZipPassword:@"lilulucas.li"];
    NSData *logData = [NSData dataWithContentsOfFile:zipFilePath];
    return logData;
}

- (void)submitFeedBackWithContent:(NSString *)content WithLogSelected:(BOOL)selected {
    QIMVerboseLog(@"提交反馈");
    if (selected) {
        [self submitFeedBackWithContent:content withUserInitiative:YES];
    } else {
        [self sendFeedBackWithLogFileUrl:nil WithContent:content withUserInitiative:YES];
    }
}

//提交反馈
- (void)submitFeedBackWithContent:(NSString *)content withUserInitiative:(BOOL)initiative {
    QIMVerboseLog(@"提交日志");
    NSString *logFileUrl = [QIMKit updateLoadFile:[[QIMLocalLog sharedInstance] allLogData] WithMsgId:[QIMUUIDTools UUID] WithMsgType:QIMMessageType_File WihtPathExtension:@"zip"];
    if (logFileUrl.length) {
        if (![logFileUrl qim_hasPrefixHttpHeader]) {
            logFileUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], logFileUrl];
        }
        [self sendFeedBackWithLogFileUrl:logFileUrl WithContent:content withUserInitiative:initiative];
    }
}

- (void)sendFeedBackWithLogFileUrl:(NSString *)logFileUrl WithContent:(NSString *)content withUserInitiative:(BOOL)initiative{
    NSString *title = [NSString stringWithFormat:@"【IOS】来自：%@的反馈日志",[[QIMKit sharedInstance] getLastJid]];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic setObject:@"qchat@qunar.com" forKey:@"from"];
    [requestDic setObject:@"QChat Team" forKey:@"from_name"];
    [requestDic setObject:@[@{@"to":@"lilulucas.li@qunar.com",@"name":@"李露"}] forKey:@"tos"];
    [requestDic setObject:title forKey:@"subject"];
    NSString *systemVersion = [[QIMKit sharedInstance] SystemVersion];
    NSString *appVersion = [[QIMKit sharedInstance] AppBuildVersion];
    NSString *eventName = [NSString stringWithFormat:@"【SystemVersion:%@】-【AppVersion:%@】", systemVersion, appVersion];
    if (content.length > 0) {
        [requestDic setObject:[NSString stringWithFormat:@"%@ ---- %@ ------  %@", eventName, content, logFileUrl ? logFileUrl : @""] forKey:@"body"];
    } else {
        [requestDic setObject:logFileUrl forKey:@"body"];
    }
    [requestDic setObject:@"日志反馈" forKey:@"alt_body"];
    [requestDic setObject:@(YES) forKey:@"is_html"];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:requestDic error:nil];
    NSURL *requestUrl = [NSURL URLWithString:@"http://qt.qunar.com/test_public/public/mainSite/sendMail.php"];
    
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestHeader setObject:@"application/json;" forKey:@"Content-type"];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:requestData];
    [request setTimeoutInterval:10];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            QIMVerboseLog(@"提交日志成功");
            if (initiative == YES) {
                [[QIMLocalLog sharedInstance] deleteLocalLog];
                NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
                BOOL isOk = [[responseDic objectForKey:@"ok"] boolValue];
                if (isOk) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySubmitLogSuccessed object:nil];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySubmitLogFaild object:nil];
                    });
                }
            }
        }
    } failure:^(NSError *error) {
        QIMVerboseLog(@"提交日志失败 : %@", error);
        if (initiative == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySubmitLogFaild object:nil];
            });
        }
    }];
}

@end
