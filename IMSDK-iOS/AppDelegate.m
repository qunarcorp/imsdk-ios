//
//  AppDelegate.m
//  IMSDK-iOS
//
//  Created by 李露 on 11/29/18.
//  Copyright © 2018 QIM. All rights reserved.
//
#import "AppDelegate.h"
#if __has_include(<FlutterPluginRegistrant/GeneratedPluginRegistrant.h>)
    #import <FlutterPluginRegistrant/GeneratedPluginRegistrant.h> // Only if you have Flutter Plugins
#else
#if __has_include("GeneratedPluginRegistrant.h")
    #import "GeneratedPluginRegistrant.h" // Only if you have Flutter Plugins
#endif
#endif
#import <EventKit/EventKit.h>
#import <React/RCTLog.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AVFoundation/AVFoundation.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <objc/runtime.h>
#import <MAMapKit/MAMapKit.h>
//#import "QIMGDPerformanceMonitor.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

#import <UserNotifications/UserNotifications.h>

#endif

#if __has_include("QIMNoteManager.h")

#import "QIMNoteManager.h"

#endif

#if __has_include("QIMLocalLog.h")

#import "QIMLocalLog.h"

#endif

#if __has_include("QIMAutoTracker.h")

#import "QIMAutoTracker.h"
#import "QIMAutoTrackerOperation.h"

#endif

#import "AvoidCrash.h"
#import "NSObject+AvoidCrash.h"

#import "QIMSDK.h"
#import "QIMMainVC.h"
#import "QIMGDPerformanceMonitor.h"
#import "UIScreen+QIMIpad.h"

#pragma mark - 系统错误信号捕获

static int s_fatal_signals[] = {
        SIGABRT,
        SIGBUS,
        SIGFPE,
        SIGILL,
        SIGSEGV,
        SIGTRAP,
        SIGTERM,
        SIGKILL,
};

static int s_fatal_signal_num = sizeof(s_fatal_signals) / sizeof(s_fatal_signals[0]);

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols]; //得到当前调用栈信息
    NSString *reason = [exception reason]; //非常重要，就是崩溃的原因
    NSString *name = [exception name];   //异常类型
    QIMErrorLog(@"CrashMsgArray %@", arr);
    QIMErrorLog(@"CrashMsgReson %@", reason);
    QIMErrorLog(@"CrashMsgName %@", name);

    NSString *userId = [[QIMKit sharedInstance] getLastJid];
    NSString *systemVersion = [[QIMKit sharedInstance] SystemVersion];
    NSString *appVersion = [[QIMKit sharedInstance] AppBuildVersion];
    NSString *eventName = [NSString stringWithFormat:@"【%@】 -【SystemVersion:%@】-【AppVersion:%@】UncaughtExceptionHandler 捕获到崩溃了 - 【%@ %@】\n", userId, systemVersion, appVersion, name, reason];
#if __has_include("QIMLocalLog.h")

    [[QIMLocalLog sharedInstance] submitFeedBackWithContent:[NSString stringWithFormat:@"%@", eventName] withUserInitiative:NO];

#endif
    [[QIMKit sharedInstance] saveUserDefault];
}

void SignalHandler(int code) {
    QIMErrorLog(@"SignalHandler = %d", code);
}

void InitCrashReport() {
    //系统错误信号捕获
    for (int i = 0; i < s_fatal_signal_num; ++i) {
        signal(s_fatal_signals[i], SignalHandler);
    }
    //oc未捕获异常的捕获
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

@interface AppDelegate (updateAltertDelegate) <UIAlertViewDelegate, UNUserNotificationCenterDelegate,NSURLSessionTaskDelegate>
#else
@interface AppDelegate (updateAltertDelegate)<UIAlertViewDelegate>
#endif

@end

@implementation AppDelegate (updateAltertDelegate)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSString *url = objc_getAssociatedObject(alertView, "url");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end

@implementation AppDelegate {

    UIBackgroundTaskIdentifier bgTask;
    NSTimer *bgTaskTimer;
}

#pragma mark - life cicle

- (void)foo {
    [QIMSDKUIHelper signOutWithNoPush];
}

- (void)streamEnd:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *reason = notify.object;
        __block UIAlertController *alertOutOfDateVc = [UIAlertController alertControllerWithTitle:@"下线通知" message:reason ? reason : @"你的账号由于某些原因被迫下线" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            [QIMFastEntrance signOutWithNoPush];
        }];
        [alertOutOfDateVc addAction:okAction];
        [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alertOutOfDateVc animated:YES completion:nil];
    });
}

- (void)QIMSQLiteErrorNotification:(NSNotification *)notify {
    return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *reason = notify.object;
        __block UIAlertController *alertOutOfDateVc = [UIAlertController alertControllerWithTitle:@"数据库文件已损坏" message:reason ? reason : @"由于某些原因，数据库文件已损坏，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            QIMVerboseLog(@"数据库损坏，卡用户到主界面");
            [QIMFastEntrance signOutWithNoPush];
        }];
        [alertOutOfDateVc addAction:okAction];
        [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alertOutOfDateVc animated:YES completion:nil];
    });
}

- (void)reloadWorkFeedEntrance:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        __block UIAlertController *alertOutOfDateVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"程序检测到更新,即将退出,请稍后重启!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            exit(0);
        }];
        [alertOutOfDateVc addAction:okAction];
        [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alertOutOfDateVc animated:YES completion:nil];
    });
}

- (void)initEventKit {
    /*
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    // the selector is available, so we must be on iOS 6 or newer
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (error) {
            //当发生了错误会
            NSLog(@"发生了错误:%@",error);
        } else if (!granted) {
            //被用户拒绝，不允许访问日历
            QIMVerboseLog(@"用户不允许访问系统日历");
        } else {
            QIMVerboseLog(@"用户允许访问系统日历");
        }
    }];
    */
}

- (void)initRemoteNotification {
    //注册系统通知
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {

        UNUserNotificationCenter *notifyCenter = [UNUserNotificationCenter currentNotificationCenter];
        notifyCenter.delegate = self;
        [notifyCenter requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (granted) {
                QIMInfoLog(@"通知权限request authorization successed!");
            }
        }];

        //用户通知权限变更
        [notifyCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *_Nonnull settings) {
            QIMInfoLog(@"用户通知权限设置%@", settings);
            QIMInfoLog(@"用户通知权限状态%ld", (long) settings.authorizationStatus); //// .authorized | .denied | .notDetermined
            QIMInfoLog(@"用户通知红角标权限%ld", (long) settings.badgeSetting); //
        }];
        UNTextInputNotificationAction *textInputAction = [UNTextInputNotificationAction actionWithIdentifier:@"comments" title:@"快捷回复" options:UNNotificationActionOptionDestructive textInputButtonTitle:@"回复" textInputPlaceholder:@"请输入回复内容"];
        //创建通知模板
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"msg" actions:@[textInputAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        [notifyCenter setNotificationCategories:[NSSet setWithObjects:category, nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIMutableUserNotificationCategory *categorys = nil;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
            action.identifier = @"comments";
            action.title = @"回复";
            //当点击的时候不启动程序，在后台处理
            action.activationMode = UIUserNotificationActivationModeBackground;
            action.authenticationRequired = NO;
            //设置了behavior属性为 UIUserNotificationActionBehaviorTextInput 的话，则用户点击了该按钮会出现输入框供用户输入
            action.behavior = UIUserNotificationActionBehaviorTextInput;
            //这个字典定义了当用户点击了评论按钮后，输入框右侧的按钮名称，如果不设置该字典，则右侧按钮名称默认为 “发送”
            action.parameters = @{UIUserNotificationTextInputActionButtonTitleKey: @"回复"};

            categorys = [[UIMutableUserNotificationCategory alloc] init];
            categorys.identifier = @"msg";
            NSArray *actions = @[action];
            [categorys setActions:actions forContext:UIUserNotificationActionContextMinimal];
        }
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:[NSSet setWithObjects:categorys, nil]];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
        }
    }
#else
    UIMutableUserNotificationCategory *categorys = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = @"comments";
        action.title = @"回复";
        //当点击的时候不启动程序，在后台处理
        action.activationMode = UIUserNotificationActivationModeBackground;
        action.authenticationRequired = YES;
        //设置了behavior属性为 UIUserNotificationActionBehaviorTextInput 的话，则用户点击了该按钮会出现输入框供用户输入
        action.behavior = UIUserNotificationActionBehaviorTextInput;
        //这个字典定义了当用户点击了评论按钮后，输入框右侧的按钮名称，如果不设置该字典，则右侧按钮名称默认为 “发送”
        action.parameters = @{UIUserNotificationTextInputActionButtonTitleKey: @"回复"};
        
        categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"msg";
        NSArray *actions = @[action];
        [categorys setActions:actions forContext:UIUserNotificationActionContextMinimal];
    }
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:[NSSet setWithObjects:categorys, nil]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
#endif
}

- (void)applicationInit {

    [QIMSDKUIHelper shareInstance];
    InitCrashReport();
    [[QIMKit sharedInstance] isFirstLauched];

    {
        // 检查版本，做首次升级使用。回头再挪
        long long localVersion = [[[QIMKit sharedInstance] userObjectForKey:@"QTalkApplicationLastVersion"] longLongValue];
        long long currentVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey] longLongValue];

        if (localVersion != currentVersion) {
            // 清掉表情检查配置
            [[QIMKit sharedInstance] removeUserObjectForKey:@"emotion_check"];
        }
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
            [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES];
            // 更新应用模版
            [[QIMSDKUIHelper shareInstance] updateMicroTourModel];
        }
    });
    {
        // 做登录超期使用
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamEnd:) name:@"kNotificationOutOfDate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamEnd:) name:@"kNotificationStreamEnd" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(QIMSQLiteErrorNotification:) name:@"QIMSQLiteErrorNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWorkFeedEntrance:) name:kNotifyReloadWorkFeedEntrance object:nil];
    }

    {
        [self configureAPIKey];
        [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    }
    [self initEventKit];
    [self initRemoteNotification];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [[QIMSDKUIHelper shareInstance] launchMainControllerWithWindow:self.window];
    //距离上次展示广告是否超过间隔时间
    NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval lastAdTime = [[[QIMKit sharedInstance] userObjectForKey:@"lastAdShowTime"] longLongValue];
    long long adShowIntervalTime = nowTime - lastAdTime;
    if ([[QIMKit sharedInstance] qimNav_AdShown] && [[[QIMKit sharedInstance] qimNav_AdItems] count] > 0 && adShowIntervalTime > [[QIMKit sharedInstance] qimNav_AdInterval]) {
        //展示广告window
        [[QIMSDKUIHelper shareInstance] launchMainAdvertWindow];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if __has_include(<Flutter/Flutter.h>)
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"io.flutter" project:nil];
    [self.flutterEngine runWithEntrypoint:nil];
#endif
#if __has_include("GeneratedPluginRegistrant.h")
    [GeneratedPluginRegistrant registerWithRegistry:self.flutterEngine];
#endif
    
    [QIMKit setQIMApplicationState:QIMApplicationStateLaunch];
    [QIMKit setQIMProjectType:0];
//    [[QIMKit sharedInstance] setCustomDeviceModel:@"iPhone"];
//    [[SMLagMonitor shareInstance] beginMonitor];
    BOOL isInstruments = [[[QIMKit sharedInstance] userObjectForKey:@"isInstruments"] boolValue];
    if (isInstruments) {
        [[QIMGDPerformanceMonitor sharedInstance] startMonitoring];
    }

    UIImage *image = [UIImage qim_imageWithColor:[UIColor qim_colorWithHex:0xDDDDDD] size:CGSizeMake([[UIScreen mainScreen] qim_rightWidth], 0.5)];
    [[UINavigationBar appearance] setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:image];

    [self initAvoidCrash];
    [self applicationInit];
    [[QIMKit sharedInstance] chooseNewData:YES];
    return YES;
}

- (void)initAvoidCrash {

    QIMInfoLog(@"初始化AvoidCrash");
    [AvoidCrash makeAllEffective];
    NSArray *noneSelClassStrings = @[
            @"NSNull",
            @"NSNumber",
            @"NSString",
            @"NSMutableString",
            @"NSDictionary",
            @"NSMutableDictionary",
            @"NSArray",
            @"NSMutableArray"
    ];
    [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
    [AvoidCrash avoidCrashExchangeMethodIfDealWithNoneSel:YES];
    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
}

- (void)dealwithCrashMessage:(NSNotification *)note {
    //注意:所有的信息都在userInfo中
    QIMInfoLog(@"dealwithCrashMessage : %@", note.userInfo);
    NSString *userId = [[QIMKit sharedInstance] getLastJid];
    NSString *systemVersion = [[QIMKit sharedInstance] SystemVersion];
    NSString *appVersion = [[QIMKit sharedInstance] AppBuildVersion];
    NSString *eventName = [NSString stringWithFormat:@"【%@】-【SystemVersion:%@】-【AppVersion:%@】AvoidCrash捕获到崩溃了\n", userId, systemVersion, appVersion];
    QIMInfoLog(@"%@", eventName);
//    [[QIMLocalLog sharedInstance] submitFeedBackWithContent:[NSString stringWithFormat:@"%@", eventName]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    QIMInfoLog(@"应用程序将要入非活动状态执行,applicationWillResignActive");
    QIMInfoLog(@"applicationWillResignActive setWillCancelLogin = YES 开始");
    [[QIMKit sharedInstance] setWillCancelLogin:YES];
    QIMInfoLog(@"applicationWillResignActive setWillCancelLogin = YES 结束");
    QIMVerboseLog(@"应用程序将要入非活动状态执行,applicationWillResignActive之前初始化数据库文件之后更新各种时间戳开始");
    [[QIMKit sharedInstance] updateLastMsgTime];
    [[QIMKit sharedInstance] updateLastGroupMsgTime];
    [[QIMKit sharedInstance] updateLastSystemMsgTime];
    QIMVerboseLog(@"应用程序将要入非活动状态执行,applicationWillResignActive之前初始化数据库文件之后更新各种时间戳完成");
    [[QIMKit sharedInstance] saveUserDefault];
    if ([QIMKit getLastUserName]) {
        [[QIMKit sharedInstance] setNeedTryRelogin:YES];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //            NSTimer *testTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(testiOS10LocalQuickReplyNotification) userInfo:nil repeats:YES];
        //            [[NSRunLoop currentRunLoop] addTimer:testTimer forMode:NSRunLoopCommonModes];
        //            [[NSRunLoop currentRunLoop] run];
        //        });
        //        [self performSelector:@selector(testiOS10LocalQuickReplyNotification) withObject:nil afterDelay:0.5];
        //        [self performSelector:@selector(testiOS10LocalQuickReplyNotification) withObject:nil afterDelay:1];
        //        [self performSelector:@selector(testiOS10LocalQuickReplyNotification) withObject:nil afterDelay:1.5];
    } else {
        //        [self testLocalQuickReplyNotification];
        //        [self performSelector:@selector(testLocalQuickReplyNotification) withObject:nil afterDelay:0.5];
        //        [self performSelector:@selector(testLocalQuickReplyNotification) withObject:nil afterDelay:1];
        //        [self performSelector:@selector(testLocalQuickReplyNotification) withObject:nil afterDelay:1.5];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    QIMInfoLog(@"应用程序入活动状态执行,applicationDidBecomeActive");
    QIMInfoLog(@"setWillCancelLogin = NO 开始");
    [[QIMKit sharedInstance] setWillCancelLogin:YES];
    QIMInfoLog(@"setWillCancelLogin = NO 结束");
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
//        [self performSelector:@selector(testiOS10LocalQuickReplyNotification) withObject:nil afterDelay:0.5];
//        [self performSelector:@selector(testiOS10LocalQuickReplyNotification) withObject:nil afterDelay:1];
//        [self performSelector:@selector(testiOS10LocalQuickReplyNotification) withObject:nil afterDelay:1.5];
    } else {
//        [self testLocalQuickReplyNotification];
//        [self performSelector:@selector(testLocalQuickReplyNotification) withObject:nil afterDelay:0.5];
//        [self performSelector:@selector(testLocalQuickReplyNotification) withObject:nil afterDelay:1];
//        [self performSelector:@selector(testLocalQuickReplyNotification) withObject:nil afterDelay:1.5];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    QIMInfoLog(@"应用程序将要入后台状态执行,applicationDidEnterBackground");
    QIMInfoLog(@"Supported background:%@", [UIDevice currentDevice].multitaskingSupported ? @"YES" : @"NO");
    QIMInfoLog(@"applicationDidEnterBackground setWillCancelLogin = YES 开始");
    [[QIMKit sharedInstance] setWillCancelLogin:YES];
    QIMInfoLog(@"applicationDidEnterBackground setWillCancelLogin = YES 结束");
    QIMVerboseLog(@"applicationDidEnterBackground之前初始化数据库文件之后更新各种时间戳开始");
    [[QIMKit sharedInstance] updateLastMsgTime];
    [[QIMKit sharedInstance] updateLastGroupMsgTime];
    [[QIMKit sharedInstance] updateLastSystemMsgTime];
    QIMVerboseLog(@"applicationDidEnterBackground之前初始化数据库文件之后更新各种时间戳完成");
    
    //QIMVerboseLog(@"applicationDidEnterBackground之前对数据库文件进行checkPoint");
    //[[QIMKit sharedInstance] qimDB_dbCheckpoint];
    //QIMVerboseLog(@"applicationDidEnterBackground之前对数据库文件进行checkPoint完成");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        QIMInfoLog(@"applicationDidEnterBackground 开始写入KeyChain");
        [[QIMKit sharedInstance] saveUserDefault];
        [QIMKit updateSessionListToKeyChain];
        [QIMKit updateGroupListToKeyChain];
        [QIMKit updateFriendListToKeyChain];
        [QIMKit updateRequestURL];
        [QIMKit updateNewHttpRequestURL];
        [QIMKit updateRequestFileURL];
        [QIMKit updateRequestDomain];
    });

    [[QIMKit sharedInstance] updateAppNotReadCount];
    if ([QIMKit getLastUserName]) {
        [[QIMKit sharedInstance] setNeedTryRelogin:YES];
        QIMInfoLog(@"进去后台，下次可能需要重新登录");
        //最近联系人数据写入3D Touch, 重新注册
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(setShortcutItems:)]) {
            [self create3DItemsWithIcons];
        }
        //设置状态为 离开
        [[QIMKit sharedInstance] goAway];
    }
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    if (bgTask == UIBackgroundTaskInvalid) {
        QIMInfoLog(@"failed to start background task!");
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        bgTaskTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(doSomeTest) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:bgTaskTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
        // Do the work associated with the task, preferably in chunks.
        NSTimeInterval timeRemain = 0;
        do {
            [NSThread sleepForTimeInterval:5];
            if (bgTask != UIBackgroundTaskInvalid) {
                timeRemain = [application backgroundTimeRemaining];
                QIMVerboseLog(@"Time remaining: %f", timeRemain);
            }
        } while (bgTask != UIBackgroundTaskInvalid && timeRemain > 0);
        // 如果改为timeRemain > 5*60,表示后台运行5分钟
        // done!
        // 如果没到10分钟，也可以主动关闭后台任务，但这需要在主线程中执行，否则会出错
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)doSomeTest {
    QIMVerboseLog(@"backGround Task");
    [[QIMKit sharedInstance] sendHeartBeat];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    QIMInfoLog(@"应用程序将要入前台状态执行, applicationWillEnterForeground");
    QIMInfoLog(@"applicationWillEnterForeground setWillCancelLogin = NO 开始");
    [QIMKit setQIMApplicationState:QIMApplicationStateActive];
    [[QIMKit sharedInstance] setWillCancelLogin:NO];
    QIMInfoLog(@"applicationWillEnterForeground setWillCancelLogin = NO 结束");
    QIMInfoLog(@"applicationWillEnterForeground 前台进入重新登录");
    [[QIMKit sharedInstance] relogin];
    QIMInfoLog(@"applicationWillEnterForeground 前台进入重新登录结束");
    // 如果没到10分钟，也可以主动关闭后台任务，但这需要在主线程中执行，否则会出错
    [bgTaskTimer invalidate];
    bgTaskTimer = nil;
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // 更新应用模版
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
            [[QIMSDKUIHelper shareInstance] updateMicroTourModel];
        }
    });
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {

        //获取设备已收到的消息推送
        [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> *_Nonnull notifications) {
            QIMVerboseLog(@"已收到推送 : %@", notifications);
        }];
        [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> *_Nonnull requests) {
            QIMVerboseLog(@"还没收到推送 : %@", requests);
        }];
    }
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];

    [[QIMKit sharedInstance] removeUserObjectForKey:@"LaunchByRemoteNotificationUserInfo"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    QIMErrorLog(@"App 异常退出了");
    QIMVerboseLog(@"App 异常退出了之前初始化数据库文件之后更新各种时间戳开始");
    [[QIMKit sharedInstance] updateLastMsgTime];
    [[QIMKit sharedInstance] updateLastGroupMsgTime];
    [[QIMKit sharedInstance] updateLastSystemMsgTime];
    [[QIMKit sharedInstance] updateLastWorkFeedMsgTime];
    QIMVerboseLog(@"App 异常退出了之前初始化数据库文件之后更新各种时间戳完成");
    [[QIMKit sharedInstance] saveUserDefault];
}

//performFetchWithCompletionHandler
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    [QTalkFastCommonTool excutePatch:3 completion:completionHandler];
}

#pragma mark - 本地通知
- (void)testiOS10LocalQuickReplyNotification {

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {

        UNTextInputNotificationAction *action = [UNTextInputNotificationAction actionWithIdentifier:@"comments" title:@"回复" options:UNNotificationActionOptionDestructive textInputButtonTitle:@"回复" textInputPlaceholder:@"请输入回复内容"];
        //创建通知模板
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"comments" actions:@[action] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.badge = @1;
        content.body = [NSString localizedUserNotificationStringForKey:@"测试推送的快捷回复" arguments:nil];
        content.subtitle = [NSString localizedUserNotificationStringForKey:@"这里是副标题" arguments:nil];
        content.title = [NSString localizedUserNotificationStringForKey:@"这里是通知的标题" arguments:nil];
//        NSString *imageFile = [[NSBundle mainBundle] pathForResource:@"1242-2208" ofType:@"png"];
//
//        UNNotificationAttachment *imageAttachment = [UNNotificationAttachment attachmentWithIdentifier:@"imageAttachment" URL:[NSURL fileURLWithPath:imageFile] options:nil error:nil];
////        noticeSound wav
//        NSString *videoFile = [[NSBundle mainBundle] pathForResource:@"noticeSound" ofType:@"wav"];
//        UNNotificationAttachment *videoAttachment = [UNNotificationAttachment attachmentWithIdentifier:@"videoAttachment" URL:[NSURL fileURLWithPath:videoFile] options:nil error:nil];
//        content.attachments = @[imageAttachment];
        //默认的通知提示音
        content.sound = [UNNotificationSound defaultSound];
        //设置通知内容对应的模板 需要注意 这里的值要与对应模板id一致
        content.categoryIdentifier = @"comments";
        content.userInfo = @{@"aps": @{
                @"alert": @{
                        @"title": @"Title is Happy day",
                        @"subtitle": @"Subtitle is Happy day",
                        @"body": @"按下以显示更多"
                },
                @"sound": @"新咨询的播报.wav",
                @"mutable-content": @(1),
                @"badge": @(1),
                @"userid": @"lilulucas.li@ejabhost1",
//            @"userid":@"e5ad60f2a824456d87027246f7fa6e3d@conference.qunar.com",
        },
                @"category": @"msg",
//            @"userid":@"e5ad60f2a824456d87027246f7fa6e3d@conference.qunar.com",
                @"userid": @"lilulucas.li@ejabhost1",
                @"image": @"https://source.qunarzz.com/common/hf/logo.png"
        };
        //设置5S之后执行
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category, nil]];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"comments" content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            if (error) {
                QIMErrorLog(@"Error");
            }
        }];
    }
#endif
}

- (void)testLocalQuickReplyNotification {

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = @"测试推送的快捷回复";
    notification.category = @"msg";
    notification.userInfo = @{@"aps": @{@"alert": @{@"body": @"测试推送进入"}, @"sound": @"hongbao.acc", @"badge": @(110), @"category": @"msg", @"userid": @"lilulucas.li@ejabhost1"}, @"userid": @"lilulucas.li@ejabhost1"};
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - register notification

//ios8 需要调用内容
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

//本地通知快捷回复，点击回复后回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {
    QIMInfoLog(@"LocalNotification Identifier : %@, notification : %@, responseInfo : %@", identifier, notification, responseInfo);
    if ([identifier isEqualToString:@"comments"]) {
        NSString *replyValue = responseInfo[UIUserNotificationActionResponseTypedTextKey];
        NSDictionary *userInfo = notification.userInfo[@"aps"];
        if (userInfo) {
            NSString *userid = notification.userInfo[@"userid"];
            if (userid.length && replyValue.length) {
                [self send:replyValue to:userid extendInfo:nil msgType:QIMMessageType_Text completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                }];
            }
        }
    }
    completionHandler();
}

//远程通知快捷回复，点击回复后回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {
    QIMInfoLog(@"iOS10之前远程通知快捷回复，点击回复后回调RemoteNotification Identifier : %@, userInfo : %@, responseInfo : %@", identifier, userInfo, responseInfo);
    if ([identifier isEqualToString:@"comments"]) {
        NSString *replyValue = responseInfo[UIUserNotificationActionResponseTypedTextKey];
        NSDictionary *userInfoDic = userInfo[@"aps"];
        QIMInfoLog(@"iOS10之前远程通知快捷回复 APS : %@", userInfoDic);
        if (userInfoDic) {

            NSString *userid = userInfo[@"userid"];

            if (userid.length && replyValue.length) {
                [self send:replyValue to:userid extendInfo:nil msgType:QIMMessageType_Text completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                }];
            }
        }
    }
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    QIMInfoLog(@"收到本地通知 : %@,  userInfo : %@", notification, notification.userInfo);
    if (application.applicationState == UIApplicationStateInactive && notification.userInfo) {
        [[QIMKit sharedInstance] setUserObject:notification.userInfo forKey:@"LaunchByRemoteNotificationUserInfo"];
        if ([[QIMKit sharedInstance] appWorkState] == AppWorkState_Login) {
            [[QIMSDKUIHelper shareInstance] checkUpNotifacationHandle];
        }
    } else {
        [[QIMKit sharedInstance] removeUserObjectForKey:@"LaunchByRemoteNotificationUserInfo"];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if (userInfo) {
        [[QIMKit sharedInstance] setUserObject:userInfo forKey:@"LaunchByRemoteNotificationUserInfo"];
        if (application.applicationState == UIApplicationStateInactive) {
            [[QIMSDKUIHelper shareInstance] checkUpNotifacationHandle];
        }
    } else {
        [[QIMKit sharedInstance] removeUserObjectForKey:@"LaunchByRemoteNotificationUserInfo"];
    }
}

#pragma mark - iOS10接收远程通知
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//iOS10获取用户选择的action
/*
{
    "aps":{
        "badge":32,
        "alert":{
            "body":"xuejie.bi：xuejie.bi"
        },
        "category":"msg",
        "sound":"default",
        "userId":"xuejie.bi@ejabhost1"
    },
    "category":"msg",
    "userId":"xuejie.bi@ejabhost1",
    "image":"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png"
}
*/
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    QIMInfoLog(@"iOS10通知快捷回复 %s : %@", __func__, response);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    QIMInfoLog(@"iOS10通知快捷回复 userInfo : %@", userInfo);
    /*
    userInfo : {
        aps =     {
            alert =         {
                body = "\U7fa4\U7ec4(\U674e\U9732lucas)(appstore)\Uff1a\Uff0c\U8001\U4e86\Uff0c";
            };
            badge = 1;
            category = msg;
            sound = default;
        };
        userid = "44b222d956714ae7b31455fcdf7d84b6@conference.ejabhost1";
    }
     */

    NSString *actionIdentifier = response.actionIdentifier;
    if ([actionIdentifier isEqualToString:@"comments"]) {
        if ([response respondsToSelector:@selector(userText)]) {
            NSString *replyValue = [(UNTextInputNotificationResponse *) response userText];
            NSDictionary *userInfoDic = userInfo[@"aps"];
            QIMInfoLog(@"iOS10通知快捷回复 aps : %@", userInfoDic);
            if (userInfoDic) {
                NSString *userid = userInfo[@"userid"];
                if (userid.length > 0 && replyValue.length > 0) {
                    [self send:replyValue to:userid extendInfo:nil msgType:QIMMessageType_Text completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    }];
                }
            }
        }
    } else {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive && userInfo) {
            [[QIMKit sharedInstance] setUserObject:userInfo forKey:@"LaunchByRemoteNotificationUserInfo"];
            if ([[QIMKit sharedInstance] appWorkState] == AppWorkState_Login || [[QIMKit sharedInstance] appWorkState] == AppWorkState_ReLogining) {
                [[QIMSDKUIHelper shareInstance] checkUpNotifacationHandle];
            }
        } else {
            [[QIMKit sharedInstance] removeUserObjectForKey:@"LaunchByRemoteNotificationUserInfo"];
        }
    }
    //移除还未展示的通知消息
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    completionHandler();
}

#endif

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    completionHandler();
}

//ios8 push下拉扩展
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]) {
    } else if ([identifier isEqualToString:@"answerAction"]) {
    }
    completionHandler();
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //添加token注册的回调

    // Token
    NSMutableString *deviceTokenString = [[NSMutableString alloc] init];
    // 获取bytes
    NSInteger length = [deviceToken length];
    if (length > 0) {
        const void *deviceBytes = [deviceToken bytes];
        for (NSInteger i = 0; i < length; i++) {
            [deviceTokenString appendFormat:@"%02.2hhx", ((char *) deviceBytes)[i]];
        }
        [[QIMKit sharedInstance] setPushToken:deviceTokenString];
        QIMInfoLog(@"注册的推送通知token : %@", deviceTokenString);
    } else {
        [[QIMKit sharedInstance] setPushToken:nil];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    QIMErrorLog(@"Push register token failed %@", error);
}

- (void)configureAPIKey {
    NSString *reason = [NSString stringWithFormat:@"apiKey为空，请检查key是否正确设置。"];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

    [alert show];
}

- (void)send:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int)msgType completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {

    [[QIMKit sharedInstance] sendWlanMessage:content to:targetID extendInfo:extendInfo msgType:msgType completionHandler:completionHandler];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

- (void)create3DItemsWithIcons {

    if ([QIMKit getQIMProjectType] != QIMProjectTypeQChat) {

        CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (!(systemVersion >= 9.0)) {
            return;
        }
        NSString *lastUserName = [QIMKit getLastUserName];
        NSString *userToken = [[QIMKit sharedInstance] getLastUserToken];
//        [[QIMKit sharedInstance] userObjectForKey:@"userToken"];
        if (lastUserName && userToken) {

            NSArray *applicationShortcutItems = nil;

            UIApplicationShortcutIcon *quickChatIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"qunar-msg_empty_o"];
            UIMutableApplicationShortcutItem *quickStartChatItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"quickChat" localizedTitle:@"发起聊天" localizedSubtitle:@"" icon:quickChatIcon userInfo:nil];
            UIApplicationShortcutIcon *lastedSingleChatIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"qunar-porfile_o"];
            NSDictionary *lastedSingleChatDic = [[QIMKit sharedInstance] getLastedSingleChatSession];
            NSString *userId = nil;
            NSString *userName = nil;
            if (lastedSingleChatDic.count) {
                userId = lastedSingleChatDic[@"XmppId"];
                if (userId) {
                    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
                    if (userInfo.count) {
                        userName = userInfo[@"Name"];
                        if (userName) {
                            UIMutableApplicationShortcutItem *lastedSingleChatItem = [[UIMutableApplicationShortcutItem alloc] initWithType:@"lastestSingleChat" localizedTitle:userName localizedSubtitle:@"" icon:lastedSingleChatIcon userInfo:userInfo];
                            applicationShortcutItems = @[quickStartChatItem, lastedSingleChatItem];
                        }
                    }
                }
            } else {
                applicationShortcutItems = @[quickStartChatItem];
            }

            if ([[UIApplication sharedApplication] respondsToSelector:@selector(setShortcutItems:)]) {
                [UIApplication sharedApplication].shortcutItems = applicationShortcutItems;
            }
        } else {
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(setShortcutItems:)]) {
                [UIApplication sharedApplication].shortcutItems = nil;
            }
        }
    }
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler {
    //判断先前我们设置的唯一标识

    //我的二维码
    if ([shortcutItem.type isEqualToString:@"MyQRCode"]) {
        [QIMSDKUIHelper showQRCodeWithQRId:[[QIMKit sharedInstance] getLastJid] withType:QRCodeType_UserQR];
    }
    //扫一扫
    if ([shortcutItem.type isEqualToString:@"qrcode"]) {
        [QIMSDKUIHelper openQRCodeVC];
    }
    //发起聊天
    if ([shortcutItem.type isEqualToString:@"quickChat"]) {
        [QIMSDKUIHelper openQIMGroupListVC];
    }
    //最近联系人
    if ([shortcutItem.type isEqualToString:@"lastestSingleChat"]) {
        NSDictionary *resultInfo = shortcutItem.userInfo;
        [[QIMKit sharedInstance] openChatSessionByUserId:[resultInfo objectForKey:@"XmppId"]];
        NSString *jid = [resultInfo objectForKey:@"XmppId"];
        [QIMSDKUIHelper openSingleChatVCByUserId:jid];
    }
}

#endif

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *, id> *)options {

    QIMVerboseLog(@"applicationOpenURL : %@, options : %@", url, options);
    
    NSString * navAddress;
    NSString * navUrl;
    NSString * urlTempStr = url.absoluteString;

    NSURL * myurl = [NSURL URLWithString:urlTempStr];
    NSString * query = [myurl query];
    NSArray * parameters = [query componentsSeparatedByString:@"&"];
    if (parameters && parameters.count > 0) {
        for (NSString * item in parameters) {
            NSArray * value = [item componentsSeparatedByString:@"="];
            NSString * key = [value objectAtIndex:0];
            if ([key isEqualToString:@"c"]) {
                navUrl = urlTempStr;
                navAddress = [item stringByReplacingOccurrencesOfString:@"c=" withString:@""];
                [self onSaveWith:navAddress navUrl:navUrl];
            }
            else if([key isEqualToString:@"configurl"]){
                NSString * configUrlStr = [[item stringByReplacingOccurrencesOfString:@"configurl=" withString:@""] qim_base64DecodedString];
                NSURL *  configUrl = [NSURL URLWithString:configUrlStr];
                NSString * configQuery = [configUrl query];
                NSArray * parameters = [configQuery componentsSeparatedByString:@"&"];
                if (parameters.count > 0 && parameters) {
                    for (NSString * tempItems in parameters) {
                        NSArray * tempValue = [tempItems componentsSeparatedByString:@"="];
                        NSString * tempKey = [tempValue objectAtIndex:0];
                        if ([tempKey isEqualToString:@"c"]) {
                            navUrl = configUrl.absoluteString;
                            navAddress = [tempItems stringByReplacingOccurrencesOfString:@"c=" withString:@""];
                            [self onSaveWith:navAddress navUrl:navUrl];
                        }
                    }
                }
                else{
                    navUrl = configUrl.absoluteString;
                    navAddress =configUrl.absoluteString;
                    [self requestByURLSessionWithUrl:configUrl.absoluteString];
                }
            }
        }
    }
    else if([urlTempStr containsString:@"star_nav"]){
        navUrl = urlTempStr;
        navAddress = urlTempStr;
        [self requestByURLSessionWithUrl:urlTempStr];
    }
    else if ([url.scheme.lowercaseString isEqualToString:@"startalk"]) {
        //        qimlogin://qrcodelogin?k=55D5492202ABEE3D491D9B43254146CF&v=1.0&p=wiki&type=wiki
        NSString *navHost = [url host];
        NSDictionary *navConfigQuery = [[url query] qim_dictionaryFromQueryComponents];
        if ([navHost.lowercaseString isEqualToString:@"start_nav_config"]) {
            NSString *configurl = [navConfigQuery objectForKey:@"configurl"]; //登录验证的key
            if (configurl.length > 0) {
                configurl = [configurl qim_base64DecodedString];
            }
            if (configurl.length > 0) {
                if ([configurl qim_hasPrefixHttpHeader]) {
                    [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithNavUrl:configurl WithUserName:nil withCallBack:^(BOOL success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (success) {
                                [[QIMKit sharedInstance] removeUserObjectForKey:@"userToken"];
                                [QIMMainVC setMainVCReShow:YES];
                                [[QIMSDKUIHelper shareInstance] launchMainControllerWithWindow:self.window];
                            } else {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"配置导航信息失败，请检查网络后重试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                [alert show];
                            }
                        });
                    }];
  
                } else {
                    [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithNavUrl:configurl WithUserName:nil withCallBack:^(BOOL success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (success) {
                                [[QIMKit sharedInstance] removeUserObjectForKey:@"userToken"];
                                [[QIMSDKUIHelper shareInstance] launchMainControllerWithWindow:self.window];
                            } else {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"配置导航信息失败，请检查网络后重试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                [alert show];
                            }
                        });
                    }];

                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无效的导航信息" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
            QIMVerboseLog(@"configUrl : %@", configurl);
        }
    } else {
        //mark temp
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        if (fileData.length > 0) {
            NSString *fileName = url.absoluteString.lastPathComponent;
            [[QIMKit sharedInstance] qim_saveLocalFileData:fileData withFileName:fileName];
            NSString *filePath = [[QIMKit sharedInstance] qim_getLocalFileDataWithFileName:fileName];
            NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[NSData dataWithContentsOfURL:url].length countStyle:NSByteCountFormatterCountStyleFile];
            NSString *fileMd5 = [fileData qim_md5String];
            NSDictionary *jsonObject = @{
                                         @"FileName": fileName,
                                         @"FileSize": fileSize,
                                         @"FileLength": @(fileData.length),
                                         @"FileMd5": fileMd5 ? fileMd5 : @"",
                                         @"IPLocalPath": filePath!=nil?filePath:@"",
                                         @"Uploading": @(1)
                                         };
            NSString *extendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:jsonObject];
            QIMMessageModel *msg = [QIMMessageModel new];
            [msg setMessage:extendInfo];
            [msg setMessageType:QIMMessageType_File];
            [msg setMessageSendState:QIMMessageSendState_Waiting];
            [msg setExtendInformation:extendInfo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UINavigationController *navigation = (UINavigationController *)application.keyWindow.rootViewController;
                UIViewController *contactVc = [[QIMSDKUIHelper shareInstance] getContactSelectionVC:msg withExternalForward:YES];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:contactVc];
                
                [navigation presentViewController:nav animated:YES completion:nil];
            });
        }
    }
    return NO;
}


- (void)requestByURLSessionWithUrl:(NSString *)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:url];
    quest.HTTPMethod = @"GET";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                  {
                                      NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                                      
                                      NSLog(@"statusCode: %ld", urlResponse.statusCode);
                                      NSDictionary * dataSerialDic = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
                                      
                                      if (dataSerialDic && dataSerialDic.count > 0) {
                                          NSDictionary * baseAddress = [dataSerialDic objectForKey:@"baseaddess"];
                                          if (baseAddress && baseAddress.count >0) {
                                              NSString * domain = [baseAddress objectForKey:@"domain"];
                                              if (domain && domain.length >0) {
                                                  [self onSaveWith:domain navUrl:urlStr];
                                                  return ;
                                              }
                                          }
                                      }
                                      NSLog(@"%@", urlResponse.allHeaderFields);
                                      if (urlResponse.allHeaderFields.count >0 && urlResponse.allHeaderFields) {
                                          NSString * requestLocation = [urlResponse.allHeaderFields objectForKey:@"Location"];
                                          if (requestLocation.length >0 && requestLocation) {
                                              QIMVerboseLog(@"%@",requestLocation);
                                              NSString * navAddress;
                                              NSString * navUrl;
                                              NSURL * requestLocationUrl = [NSURL URLWithString:requestLocation];
                                              NSString * queryStr = [requestLocationUrl query];
                                              NSArray * parameters = [queryStr componentsSeparatedByString:@"&"];
                                              if (parameters.count>0 && parameters) {
                                                  for (NSString * item in parameters) {
                                                      NSArray * value = [item componentsSeparatedByString:@"="];
                                                      
                                                      NSString * key = [value objectAtIndex:0];
                                                      if ([key isEqualToString:@"c"]) {
                                                          navUrl = requestLocationUrl.absoluteString;
                                                          navAddress = [item stringByReplacingOccurrencesOfString:@"c=" withString:@""];
                                                          [self onSaveWith:navAddress navUrl:navUrl];
                                                      }
                                                      else if([key isEqualToString:@"configurl"]){
                                                          NSString * configUrlStr = [[item stringByReplacingOccurrencesOfString:@"configurl=" withString:@""] qim_base64DecodedString];
                                                          NSURL * configUrl = [NSURL URLWithString:configUrlStr];
                                                          NSString * configQuery = [configUrl query];
                                                          NSArray * parameters = [configQuery componentsSeparatedByString:@"&"];
                                                          if (parameters.count > 0 && parameters) {
                                                              for (NSString * tempItems in parameters) {
                                                                  NSArray * tempValue = [tempItems componentsSeparatedByString:@"="];
                                                                  NSString * tempKey = [tempValue objectAtIndex:0];
                                                                  if ([tempKey isEqualToString:@"c"]) {
                                                                      navUrl = configUrl.absoluteString;
                                                                      navAddress = [tempItems stringByReplacingOccurrencesOfString:@"c=" withString:@""];
                                                                      [self onSaveWith:navAddress navUrl:navUrl];
                                                                  }
                                                                  else{
                                                                      //                                                                      navUrl = configUrl.absoluteString;
                                                                      //                                                                      navAddress =configUrl.absoluteString;
                                                                      //                                                                      [self onSaveWith:navAddress navUrl:navUrl];
                                                                  }
                                                              }
                                                          }
                                                          else if([configUrlStr containsString:@"startalk_nav"]){
                                                              [self requestByURLSessionWithUrl:configUrlStr];
                                                              return;
                                                          }
                                                          else{
                                                              navUrl = configUrlStr;
                                                              [self onSaveWith:navAddress navUrl:navUrl];
                                                          }
                                                      }
                                                  }
                                              }
                                              else {
                                                  navUrl = requestLocation;
                                                  [self onSaveWith:navAddress navUrl:navUrl];
                                              }
                                          }
                                          else{
                                              
                                              [self onSaveWith:urlStr navUrl:urlStr];
                                          }
                                      }
                                  }];
    [task resume];
}
#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler
{
    NSLog(@"statusCode: %ld", response.statusCode);
    
    NSDictionary *headers = response.allHeaderFields;
    NSString * requestLocation = [headers objectForKey:@"Location"];
    completionHandler(nil);
}


- (void)onSaveWith:(NSString *)navAddressText navUrl:(NSString *)navUrl{
    NSString *navHttpName = navAddressText;
    if (navAddressText.length > 0) {
        __block NSDictionary *userWillsaveNavDict = @{QIMNavNameKey:(navHttpName.length > 0) ? navHttpName : [[navUrl.lastPathComponent componentsSeparatedByString:@"="] lastObject], QIMNavUrlKey:navUrl};
        [[QIMKit sharedInstance] setUserObject:userWillsaveNavDict forKey:@"QC_UserWillSaveNavDict"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithCheck:YES withCallBack:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [[QIMKit sharedInstance] setUserObject:userWillsaveNavDict forKey:@"QC_CurrentNavDict"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NavConfigSettingChanged" object:nil];
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                            message:@"无可用的导航信息"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                });
            }];
        });
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"请输入可用的导航地址"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
//    [[QIMSDImageCache sharedImageCache] clearMemory];
}

@end
