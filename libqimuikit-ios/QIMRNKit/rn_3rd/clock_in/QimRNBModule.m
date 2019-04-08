//
//  QTalkAuth.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/4/5.
//
//


#import "QimRNBModule.h"
#import "UIApplication+QIMApplication.h"
#import "QimRNBModule+TravelCalendar.h"
#import "QimRNBModule+QIMLocalSearch.h"
#import "QimRNBModule+QIMUser.h"
#import "QimRNBModule+QIMGroup.h"
#import "QimRNBModule+MySetting.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMRNBaseVc.h"
#import "QIMCommonUIFramework.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "TOTPGenerator.h"
#import "QRCodeGenerator.h"
#import "QIMWebView.h"
#import "QIMChatVC.h"
#import "QIMPinYinForObjc.h"
#import "QIMMessageHelperVC.h"
#import "QIMFriendListViewController.h"
#import "QIMGroupListVC.h"
#import "QIMPublicNumberVC.h"
#import "QIMRNExternalAppManager.h"
#import "QIMDressUpController.h"
#import "QIMFileManagerViewController.h"
#import "QIMQNValidationFriendVC.h"
#import "QIMValidationFriendVC.h"
#import "QIMFriendSettingCell.h"
#import "QIMPGroupSelectionView.h"
#import "QIMJumpURLHandle.h"
#import "QIMAboutVC.h"
#import "QIMProgressHUD.h"
#import "QIMPublicNumberSearchVC.h"
#import "QIMOrganizationalVC.h"
#import "QIMMySettingController.h"
#import "QIMServiceStatusViewController.h"
#import "QIMJSONSerializer.h"
#import "QIMDataController.h"
#import "QIMUUIDTools.h"
#import "QIMGroupChatVC.h"
#import "QIMSwitchAccountView.h"
#import "SCLAlertView.h"
#import "NSDate+Extension.h"
#import "Toast.h"
#import "QIMPublicRedefineHeader.h"

#if defined (QIMLogEnable) && QIMLogEnable == 1
#import "QIMLocalLog.h"
#endif

#define MyRedBag @"MyRedBag"
#define BalanceInquiry @"BalanceInquiry"
#define AccountInfo @"AccountInfo"
#define MyFile @"MyFile"

@interface QIMRCTRootView : RCTRootView
@property (nonatomic, weak) UIViewController *ownerVC;
@property (nonatomic, strong) NSString *title;
@end
@implementation QIMRCTRootView

- (instancetype)initWithBridge:(RCTBridge *)bridge moduleName:(NSString *)moduleName initialProperties:(NSDictionary *)initialProperties {
    if (self = [super initWithBridge:bridge moduleName:moduleName initialProperties:initialProperties]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAccountInfo:) name:kNotifySwichUserSuccess object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.ownerVC.navigationItem setTitle:self.title];
}

- (void)reloadAccountInfo:(NSNotification *)notify {
    BOOL switchAccountSuccess = [notify.object boolValue];
    if (switchAccountSuccess) {
        QIMVerboseLog(@"刷新一下RN我的页面");
        [self.bridge.eventDispatcher sendAppEventWithName:@"QIM_RN_Will_Show" body:@{@"name": self.moduleName}];
    }
}

@end

@interface QimRNBModule () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) QIMSwitchAccountView *accountCollectionView;
@property (nonatomic, strong) SCLAlertView *swicthAccountAlert;
@property (nonatomic, strong) SCLAlertView *waitingAlert;

@end

@implementation QimRNBModule

// The React Native bridge needs to know our module
RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport {
    return @{@"greeting": @"Welcome to the DevDactic\n React Native Tutorial!"};
}

RCT_EXPORT_METHOD(getTOTP:(RCTResponseSenderBlock)success) {
    NSString *secret = [NSString stringWithFormat:@"u=%@&k=%@",[[QIMKit sharedInstance] getLastJid],[[QIMKit sharedInstance] myRemotelogginKey]];
    NSData *secretData = [secret dataUsingEncoding:NSASCIIStringEncoding];
    TOTPGenerator *generator = [[TOTPGenerator alloc] initWithSecret:secretData
                                                           algorithm:kOTPGeneratorSHA1Algorithm
                                                              digits:6
                                                              period:30];
    long long time = [[NSDate date] timeIntervalSince1970] - [[QIMKit sharedInstance] getServerTimeDiff];
    NSString *str = [generator generateOTPForTimeInterval:time];
    while (str.length < 6) {
        str = [NSString stringWithFormat:@"0%@",str];
    }
    success(@[@{@"totp":str,@"time":@(time)}]);
}

RCT_EXPORT_METHOD(appConfig:(RCTResponseSenderBlock)success) {

    QIMProjectType projectType = [QIMKit getQIMProjectType];
    NSString *ckey = [[QIMKit sharedInstance] thirdpartKeywithValue];
    NSString *ip = [[QIMKit sharedInstance] getClientIp];
    NSString *userId = [QIMKit getLastUserName];
    NSString *httpHost = [[QIMKit sharedInstance] qimNav_Javaurl];
    BOOL WorkFeedEntrance = [[[QIMKit sharedInstance] userObjectForKey:@"kUserWorkFeedEntrance"] boolValue];
    BOOL notNeedShowLeaderInfo = [[[QIMKit sharedInstance] userObjectForKey:@"notNeedShowLeaderInfo"] boolValue];
    BOOL notNeedShowEmailInfo = [[[QIMKit sharedInstance] userObjectForKey:@"notNeedShowEmailInfo"] boolValue];
    NSNumber *isShowGroupQRCode = [[QIMKit sharedInstance] userObjectForKey:@"isShowGroupQRCode"];
    NSNumber *isShowLocalQuickSearch = [[QIMKit sharedInstance] userObjectForKey:@"isShowLocalQuickSearch"];
    NSArray *appConfig = @[@{@"projectType" : @(projectType), @"isQtalk" : @(!projectType), @"ckey" : ckey,@"clientIp" : ip,@"userId" : userId,@"domain" : [[QIMKit sharedInstance] qimNav_Domain], @"httpHost" : httpHost, @"RNAboutView" : @(0), @"RNMineView": @([[QIMKit sharedInstance] qimNav_RNMineView]), @"RNGroupCardView": @([[QIMKit sharedInstance] qimNav_RNGroupCardView]), @"RNContactView": @([[QIMKit sharedInstance] qimNav_RNContactView]), @"RNSettingView" : @([[QIMKit sharedInstance] qimNav_RNSettingView]), @"RNUserCardView" : @([[QIMKit sharedInstance] qimNav_RNUserCardView]), @"RNGroupListView": @([[QIMKit sharedInstance] qimNav_RNGroupListView]), @"RNPublicNumberListView" : @([[QIMKit sharedInstance] qimNav_RNPublicNumberListView]), @"showOrganizational" : @([[QIMKit sharedInstance] qimNav_ShowOrganizational]), @"showOA" : @([[QIMKit sharedInstance] qimNav_ShowOA]), @"qcAdminHost": [[QIMKit sharedInstance] qimNav_QCHost], @"showServiceState":@(projectType) /*@([[QIMKit sharedInstance] isMerchant]) */, @"fileUrl":[[QIMKit sharedInstance] qimNav_InnerFileHttpHost], @"isShowWorkWorld":@(WorkFeedEntrance), @"notNeedShowLeaderInfo":@(notNeedShowLeaderInfo), @"notNeedShowEmailInfo":@(notNeedShowEmailInfo), @"isShowGroupQRCode": isShowGroupQRCode ?  @([isShowGroupQRCode boolValue]) : @(YES), @"isShowLocalQuickSearch": isShowLocalQuickSearch ? @([isShowLocalQuickSearch boolValue]) : @(YES)}];
    QIMVerboseLog(@"AppConfig : %@", appConfig);
    success(appConfig);
}

RCT_EXPORT_METHOD(updateRemoteKey:(RCTResponseSenderBlock)success) {
    if ([[QIMKit sharedInstance] updateRemoteLoginKey]) {
        success(@[@{@"ok":@(YES)}]);
    } else {
        success(@[@{@"ok":@(NO)}]);
    }
}

RCT_EXPORT_METHOD(updateNavTitle:(NSString *)navTitle) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        [navVC.navigationItem setTitle:navTitle];
    });
}

/**
 打开RN页面
 */
RCT_EXPORT_METHOD(openRNPage:(NSDictionary *)params :(RCTResponseSenderBlock)success) {
    NSString *bundleName = [params objectForKey:@"Bundle"];
    NSString *moduleName = [params objectForKey:@"Module"];
    NSDictionary *properties = [params objectForKey:@"Properties"];
    QIMAppType AppType = [[params objectForKey:@"AppType"] integerValue];
    NSString *bundleVersion = [params objectForKey:@"Version"];
    switch (AppType) {
        case QIMAppExternal: {
            //本地Check
            BOOL check = [[QIMRNExternalAppManager sharedInstance] checkQIMRNExternalAppWithBundleName:bundleName BundleVersion:bundleVersion];
            if (check) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                    if (!navVC) {
                        navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
                    }
                    [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:bundleName WithModule:moduleName WithProperties:properties];
                });
            } else {
                //Download
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:@"正在下载/更新应用"];
                });
                BOOL updateSuccess = [[QIMRNExternalAppManager sharedInstance] downloadQIMRNExternalAppWithBundleParams:params];
                if (updateSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[QIMProgressHUD sharedInstance] closeHUD];
                    });
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                        if (!navVC) {
                            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
                        }
                        [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:bundleName WithModule:moduleName WithProperties:properties];
                    });
                } else {
                    QIMVerboseLog(@"更新失败");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:@"打开应用失败，请移步网络状态良好的地方打开"];
                        [[QIMProgressHUD sharedInstance] closeHUD];
                    });
                }
            }
        }
            break;
        default: {
            dispatch_async(dispatch_get_main_queue(), ^{
//                UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
                }
                [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:bundleName WithModule:moduleName WithProperties:properties];
            });
        }
            break;
    }
}

/**
 打开Native页面
 */
RCT_EXPORT_METHOD(openNativePage:(NSDictionary *)params){
    NSString *nativeName = [params objectForKey:@"NativeName"];
    if ([nativeName isEqualToString:MyRedBag]) {
        // 我的红包
        [QIMFastEntrance openWebViewForUrl:[[QIMKit sharedInstance] myRedpackageUrl] showNavBar:YES];
    } else if ([nativeName isEqualToString:BalanceInquiry]) {
        // 余额查询
        [QIMFastEntrance openWebViewForUrl:[[QIMKit sharedInstance] redPackageBalanceUrl] showNavBar:YES];
    } else if ([nativeName isEqualToString:AccountInfo]) {
        
        [QIMFastEntrance openMyAccountInfo];
    } else if ([nativeName isEqualToString:MyFile]) {
       
        [QIMFastEntrance openMyFileVC];
    } else if ([nativeName isEqualToString:@"NotReadMsg"]){
        
        [QIMFastEntrance openNotReadMessageVC];
    } else if ([nativeName isEqualToString:@"FriendList"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserFriendsVC];
        });
    } else if ([nativeName isEqualToString:@"GroupList"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openQIMGroupListVC];
        });
    } else if ([nativeName isEqualToString:@"PublicNo"]){
        
        [QIMFastEntrance openQIMPublicNumberVC];
    } else if ([nativeName isEqualToString:@"GroupChat"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *groupId = [params objectForKey:@"GroupId"];
            [QIMFastEntrance openGroupChatVCByGroupId:groupId];
        });
    } else if ([nativeName isEqualToString:@"SearchContact"]){
        
        [QIMFastEntrance openRNSearchVC];
    } else if ([nativeName isEqualToString:@"PublicNumberChat"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *publicNumberId = [params objectForKey:@"PublicNumberId"];
            [QIMFastEntrance openRobotChatVC:publicNumberId];
        });
    } else if ([nativeName isEqualToString:@"Organizational"]) {
        
        [QIMFastEntrance openOrganizationalVC];
    } else if ([nativeName isEqualToString:@"NativeSetting"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
            }
            QIMMySettingController *settingVc = [[QIMMySettingController alloc] init];
            [navVC pushViewController:settingVc animated:YES];
        });
    } else if ([nativeName isEqualToString:@"searchChatHistory"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *searchMsgUrl = [NSString stringWithFormat:@"%@/lookback/main_controller.php", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost]];
            if (searchMsgUrl.length > 0) {
                [QIMFastEntrance openWebViewForUrl:searchMsgUrl showNavBar:YES];
            }
        });
    }
}

RCT_EXPORT_METHOD(exitApp:(NSString *)rnName) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyVCClose object:rnName];
    });
}

+ (void)reloadBridgeCache {
    [__innerCacheBridge.eventDispatcher sendAppEventWithName:@"QIM_RN_Refresh_Count" body:nil];
}

+ (void)loadBridgeCache{
    if (__innerCacheBridge == nil) {
        [QimRNBModule getBridgeByBundleName:[QimRNBModule getInnerBundleName]];
    }
}

+ (RCTBridge *)getBridgeByBundleName:(NSString*)bundleName{
    if ([[QimRNBModule getInnerBundleName] isEqualToString:bundleName]) {
        if (__innerCacheBridge == nil) {
            __innerCacheBridge = [[RCTBridge alloc] initWithBundleURL:[QimRNBModule getJsCodeLocation] moduleProvider:nil launchOptions:nil];
        }
        return __innerCacheBridge;
    } else {
        return [[RCTBridge alloc] initWithBundleURL:[QimRNBModule getOuterJsLocation:bundleName] moduleProvider:nil launchOptions:nil];
    }
}

+ (RCTBridge *)getStaticCacheBridge {
    return __innerCacheBridge;
}

/**
 外部应用JSLocation
 */
+ (NSURL *)getOuterJsLocation:(NSString *)bundleName {
    NSString *localJSCodeFileStr = [[UserCachesPath stringByAppendingPathComponent: [QimRNBModule getCachePath]] stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.jsbundle", bundleName]];
    if (localJSCodeFileStr && [[NSFileManager defaultManager] fileExistsAtPath:localJSCodeFileStr]) {
        QIMVerboseLog(@"本地缓存的更新包地址 : %@", localJSCodeFileStr);
    } else {
        
    }
    NSURL *jsCodeLocation = [NSURL URLWithString:localJSCodeFileStr];
    return jsCodeLocation;
}

/**
 内嵌应用JSLocation
 */
+ (NSURL *)getJsCodeLocation { 
    NSString *innerJsCodeLocation = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMRNKit" BundleName:@"QIMRNKit" pathForResource:[QimRNBModule getInnerBundleName] ofType:@"jsbundle"];
    NSString *localJSCodeFileStr = [[UserCachesPath stringByAppendingPathComponent: [QimRNBModule getCachePath]] stringByAppendingPathComponent: [QimRNBModule getAssetBundleName]];
    if (localJSCodeFileStr && [[NSFileManager defaultManager] fileExistsAtPath:localJSCodeFileStr]) {
        QIMVerboseLog(@"本地缓存的更新包地址 : %@", localJSCodeFileStr);
        innerJsCodeLocation = localJSCodeFileStr;
    } else {
        
    }
    NSURL *jsCodeLocation = [NSURL URLWithString:innerJsCodeLocation];
    return jsCodeLocation;
}

+ (UIViewController *)clockOnVC {
    QIMRNBaseVc *vc = [[QIMRNBaseVc alloc] init];
    vc.rnName = @"ClockIn";
    NSURL *jsCodeLocation = [QimRNBModule getJsCodeLocation];
    
    QIMRCTRootView *rootView = [[QIMRCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                              moduleName:@"ClockIn"
                                                       initialProperties:nil
                                                           launchOptions:nil];
    
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    vc.view = rootView;
    return vc;
}

+ (UIViewController *)TOTPVC {
    [[QIMKit sharedInstance] updateRemoteLoginKey];
    QIMRNBaseVc *vc = [[QIMRNBaseVc alloc] init];
    [vc setHiddenNav:YES];
    vc.rnName = @"TOTP";
    NSURL *jsCodeLocation = [QimRNBModule getJsCodeLocation];
    QIMRCTRootView *rootView = [[QIMRCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                              moduleName:@"TOTP"
                                                       initialProperties:nil
                                                           launchOptions:nil];
    
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    vc.view = rootView;
    return vc;
}

+ (void)openVCWithNavigation:(UINavigationController *)navVC
               WithHiddenNav:(BOOL)hiddenNav
              WithBundleName:(NSString *)bundleName
                  WithModule:(NSString *)module{
    [self openVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:bundleName WithModule:module WithProperties:nil];
}

+ (UIViewController *)getVCWithParam:(NSDictionary *)param {
    UINavigationController *navVC = [param objectForKey:@"navVC"];
    BOOL hiddenNav = [[param objectForKey:@"hiddenNav"] boolValue];
    NSString *bundleName = [param objectForKey:@"bundleName"];
    if (bundleName.length < 0 || !bundleName) {
        bundleName = [QimRNBModule getInnerBundleName];
    }
    NSString *module = [param objectForKey:@"module"];
    NSDictionary *properties = [param objectForKey:@"properties"];
    return [self getVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:bundleName WithModule:module WithProperties:properties];
}

+ (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                           WithBundleName:(NSString *)bundleName
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties {
    QIMRNBaseVc *vc = [[QIMRNBaseVc alloc] init];
    vc.rnName = module;
    vc.hiddenNav = hiddenNav;
    vc.bridge = [QimRNBModule getBridgeByBundleName:bundleName];
    QIMRCTRootView *rootView = [[QIMRCTRootView alloc] initWithBridge:vc.bridge moduleName:module initialProperties:properties];
    rootView.frame = vc.view.bounds;
    [vc.view addSubview:rootView];
    vc.view.backgroundColor = [UIColor whiteColor];
    return vc;
}

+ (void)openQIMRNVCWithParam:(NSDictionary *)param {
    UINavigationController *navVC = [param objectForKey:@"navVC"];
    BOOL hiddenNav = [[param objectForKey:@"hiddenNav"] boolValue];
    NSString *bundleName = [param objectForKey:@"bundleName"];
    if (bundleName.length < 0 || !bundleName) {
        bundleName = [QimRNBModule getInnerBundleName];
    }
    NSString *module = [param objectForKey:@"module"];
    NSDictionary *properties = [param objectForKey:@"properties"];
    [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:bundleName WithModule:module WithProperties:properties];
}

+ (void)openVCWithNavigation:(UINavigationController *)navVC
               WithHiddenNav:(BOOL)hiddenNav
              WithBundleName:(NSString *)bundleName
                  WithModule:(NSString *)module
              WithProperties:(NSDictionary *)properties{
    UIViewController *vc = [QimRNBModule getVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:bundleName WithModule:module WithProperties:properties];
    [navVC pushViewController:vc animated:YES];
}

+ (void)sendQIMRNWillShow {
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"QIM_RN_Will_Show" body:@{@"name": @"aaa"}];
}

+ (id)createQIMRNVCWithParam:(NSDictionary *)param {
    NSString *bundleName = [param objectForKey:@"bundleName"];
    if (bundleName.length < 0 || !bundleName) {
        bundleName = [QimRNBModule getInnerBundleName];
    }
    NSString *module = [param objectForKey:@"module"];
    NSDictionary *properties = [param objectForKey:@"properties"];
    return [QimRNBModule createQIMRNVCWithBundleName:bundleName WithModule:module WithProperties:properties];
}

+ (id)createQIMRNVCWithBundleName:(NSString *)bundleName
                       WithModule:(NSString *)module
                   WithProperties:(NSDictionary *)properties{
    QIMRNBaseVc *vc = [[QIMRNBaseVc alloc] init];
    vc.rnName = module;
    //使用initWithBridge 可以实现对同一个RCTBridge实例的复用
    QIMRCTRootView *rootView = [[QIMRCTRootView alloc] initWithBridge:[QimRNBModule getBridgeByBundleName:bundleName] moduleName:module initialProperties:properties];
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    vc.view = rootView;
    return vc;
}

/*
 * 依赖客户端升级 大版本号
 *
 */
+(NSString *)getAssetBundleName{
    if ([QIMKit getQIMProjectType] != QIMProjectTypeQChat) {
        return @"clock_in.ios.jsbundle_QTalk_V54_215";
    } else if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        return @"clock_in.ios.jsbundle_QChat_V54_5";
    } else {
        return @"clock_in.ios.jsbundle_V54_215";
    }
}

/*
 * 离线资源包 压缩文件名
 *
 */
+(NSString *)getAssetZipBundleName{
    return @"clock_in.ios.jsbundle.tar.gz";
}

/*
 * 内置bundle 文件名
 *
 */
+(NSString *)getInnerBundleName{
    return @"clock_in.ios";
}

/*
 * 缓存路径
 *
 */
+(NSString *)getCachePath{
    return @"rnRes/qim_rn/";
}

@end

static NSString *showNumberId = nil;

@implementation QimRNBModule(UserCard)

//打开用户名片
RCT_EXPORT_METHOD(openUserCard:(NSDictionary *)param) {
    NSString *userId = [param objectForKey:@"UserId"];
    if (![userId isEqualToString:[[QIMKit sharedInstance] getLastJid]] && userId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QIMFastEntrance openUserCardVCByUserId:userId];
        });
    }
}

//获取用户基本信息
RCT_EXPORT_METHOD(getUserInfo:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId.length <= 0 || !userId) {
        return;
    }
    NSDictionary *properties = [QimRNBModule qimrn_getUserInfoByUserId:userId];
    callback(@[@{@"UserInfo":properties?properties:@{}}]);
}

//获取用户基本信息
RCT_EXPORT_METHOD(getUserInfoByUserCard:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId.length <= 0 || !userId) {
        return;
    }
    NSDictionary *properties = [QimRNBModule qimrn_getUserInfoByUserId:userId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QIMKit sharedInstance] updateUserCard:@[userId]];
    });
    callback(@[@{@"UserInfo" : properties ? properties : @{}}]);
}

//获取单人会话置顶状态
RCT_EXPORT_METHOD(syncChatStickyState:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *realJid = [params objectForKey:@"realJid"];
    NSString *userId = [params objectForKey:@"xmppId"];
    NSString *combineId = (realJid.length > 0) ? [NSString stringWithFormat:@"%@<>%@", userId, realJid] : [NSString stringWithFormat:@"%@<>%@", userId, userId];
    BOOL stickyState = [[QIMKit sharedInstance] isStickWithCombineJid:combineId];
    callback(@[@{@"state" : @(stickyState)}]);
}

//置顶单人会话
RCT_EXPORT_METHOD(updateUserChatStickyState:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *realJid = [params objectForKey:@"realJid"];
    NSString *userId = [params objectForKey:@"xmppId"];
    NSString *combineJid = @"";
    if (realJid.length > 0) {
        combineJid = [NSString stringWithFormat:@"%@<>%@", userId, realJid];
    } else {
        combineJid = [NSString stringWithFormat:@"%@<>%@", userId, userId];
    }
    if ([[QIMKit sharedInstance] isStickWithCombineJid:combineJid]) {
        BOOL success = [[QIMKit sharedInstance] removeStickWithCombineJid:combineJid WithChatType:ChatType_SingleChat];
        callback(@[@{@"ok" : @(success)}]);
    } else {
        BOOL success = [[QIMKit sharedInstance] setStickWithCombineJid:combineJid WithChatType:ChatType_SingleChat];
        callback(@[@{@"ok" : @(success)}]);
    }
}

//用户是否为好友
RCT_EXPORT_METHOD(getFriend:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId) {
        NSDictionary *friendDic = [[QIMKit sharedInstance] selectFriendInfoWithUserId:userId];
        BOOL isFriend = friendDic != nil;
        callback(@[@{@"FriendBOOL" : @(isFriend)}]);
    } else {
        callback(@[@{@"FriendBOOL" : @(NO)}]);
    }
}

//获取用户个性签名
RCT_EXPORT_METHOD(getUserMood:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId.length > 0) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        NSString *mood = [QimRNBModule qimrn_getUserMoodByUserId:userId];
        [properties setObject:mood ? mood : @"" forKey:@"Mood"];
        callback(@[@{@"UserInfo" : properties ? properties : @""}]);
    }
}

//获取用户勋章列表
RCT_EXPORT_METHOD(getUserMedal:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    if (userId.length > 0) {
        NSArray *userMedal = [QimRNBModule qimrn_getUserMedalByUserId:userId];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QIMKit sharedInstance] getRemoteUserMedalWithXmppJid:userId];
        });
        callback(@[@{@"UserMedal" : userMedal ? userMedal : @[]}]);
    }
}

//获取Leader信息
RCT_EXPORT_METHOD(getUserLead:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    NSDictionary *userWorkInfo = nil;
    if (userId.length > 0) {
        NSDictionary *properties = [QimRNBModule qimrn_getUserLeaderInfoByUserId:userId];
        callback(@[@{@"UserInfo":properties ? properties : @{}}]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] getRemoteUserWorkInfoWithUserId:userId];
        });
    }
}

// 设置备注名
RCT_EXPORT_METHOD(saveRemark:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *userId = [param objectForKey:@"UserId"];
    NSString *remark = [param objectForKey:@"Remark"];
    NSString *nickName = [param objectForKey:@"Name"];
    [[QIMKit sharedInstance] updateUserMarkupNameWithUserId:userId WithMarkupName:remark];
    callback(@[@{@"ok" : @(YES)}]);
}

//查看手机号
RCT_EXPORT_METHOD(showUserPhoneNumber:(NSDictionary *)param) {
    QIMVerboseLog(@"点击查看用户手机号 : %@", param);
    NSString *userId = [[[param objectForKey:@"UserId"] componentsSeparatedByString:@"@"] firstObject];
    if (!showNumberId) {
        showNumberId = userId;
        NSString *phoneNumberStr = [[QIMKit sharedInstance] getPhoneNumberWithUserId:userId];
        if (phoneNumberStr.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [NSString stringWithFormat:@"手机号:%@", phoneNumberStr];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIPasteboard generalPasteboard] setString:phoneNumberStr];
                    showNumberId = nil;
                }];
                UIAlertAction *telAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel:%@", phoneNumberStr]];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                        showNumberId = nil;
                    } else {
                        QIMVerboseLog(@"当前设备不支持呼叫");
                        showNumberId = nil;
                    }
                }];
                [alert addAction:copyAction];
                [alert addAction:telAction];
//                UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                UIViewController *rootVc = [[UIApplication sharedApplication] visibleViewController];
                [rootVc presentViewController:alert animated:YES completion:nil];
            });
        } else {
            showNumberId = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有查询到相应记录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            });
        }
    }
}

// 发送邮件
RCT_EXPORT_METHOD(sendEmail:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [[QIMFastEntrance sharedInstance] sendMailWithRootVc:navVC ByUserId:userId];
    });
}

// 评论
RCT_EXPORT_METHOD(commentUser:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
        NSDictionary *userInfo = nil;
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
            [[QIMKit sharedInstance] getQChatUserInfoForUser:userId];
            userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
        } else {
            userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
        }
        NSData *userInfoData = [userInfo objectForKey:@"UserInfo"];
        NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
        NSString *commentUrl = [dic objectForKey:@"commenturl"];
        NSURL *url = [NSURL URLWithString:commentUrl];
        NSString *query = [url query];
        NSString *baseUrl = nil;
        if (query.length > 0) {
            baseUrl =[commentUrl substringToIndex:commentUrl.length - query.length - 1];
            query = [query stringByAppendingString:@"&"];
        } else {
            baseUrl = commentUrl;
            query = @"";
        }
        if (baseUrl.length > 0) {
            commentUrl = [NSString stringWithFormat:@"%@?%@u=%@&k=%@&t=%@",
                          baseUrl,
                          query,
                          [[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [[QIMKit sharedInstance] myRemotelogginKey],
                          [userInfo objectForKey:@"UserId"]];
            [QIMFastEntrance openWebViewForUrl:commentUrl showNavBar:YES];
        }
    });
}

// 查看大头像
RCT_EXPORT_METHOD(browseBigHeader:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BrowseBigHeader" object:param];
    });
    callback(@[@{@"ok" : @(YES)}]);
}

// 打开单人会话
RCT_EXPORT_METHOD(openUserChat:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
        /*
        NSString *userId = [param objectForKey:@"UserId"];
        NSString *name = [param objectForKey:@"Name"];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        ChatType chatType = [[QIMKit sharedInstance] openChatSessionByUserId:userId];
        QIMChatVC *chatVC = [[QIMChatVC alloc] init];
        [chatVC setStype:kSessionType_Chat];
        [chatVC setChatId:userId];
        [chatVC setName:name];
        [chatVC setTitle:name];
        [chatVC setChatType:chatType];
        if (chatType == ChatType_Consult) {
            [chatVC setVirtualJid:userId];
        }
        //备注
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
        [chatVC setTitle:remarkName ? remarkName : name];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        [navVC popToRootVCThenPush:chatVC animated:YES];
        */
        [QIMFastEntrance openSingleChatVCByUserId:userId];
    });
}

//添加好友
RCT_EXPORT_METHOD(addUserFriend:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
        NSDictionary *modeDic = [[QIMKit sharedInstance] getVerifyFreindModeWithXmppId:userId];
        int mode = [[modeDic objectForKey:@"mode"] intValue];
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC setNavigationBarHidden:NO animated:YES];
        switch (mode) {
            case VerifyMode_AllRefused:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"对方拒绝添加好友。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
                break;
            case VerifyMode_AllAgree:
            {
                [[QIMKit sharedInstance] addFriendPresenceWithXmppId:userId WithAnswer:nil];
            }
                break;
            case VerifyMode_Validation:
            {
                QIMValidationFriendVC *valiVC = [[QIMValidationFriendVC alloc] init];
                [valiVC setXmppId:userId];
                [navVC pushViewController:valiVC animated:YES];
            }
                break;
            case VerifyMode_Question_Answer:
            {
                QIMQNValidationFriendVC *validVC = [[QIMQNValidationFriendVC alloc] init];
                [validVC setValidDic:modeDic];
                [validVC setXmppId:userId];
                [navVC pushViewController:validVC animated:YES];
            }
                break;
            default:
                break;
        }
    });
}

RCT_EXPORT_METHOD(deleteUserFriend:(NSDictionary *)param) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [param objectForKey:@"UserId"];
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        UIAlertController *delteFriendSheetVC = [UIAlertController alertControllerWithTitle:@"确定要删除该好友吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除好友" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL isSuccess = [[QIMKit sharedInstance] deleteFriendWithXmppId:userId WithMode:2];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                [[self progressHUD] hide:YES];
                    if (isSuccess) {
                        [navVC popToRootViewControllerAnimated:YES];
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除好友失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];
                    }
                });
            });
        }];
        [delteFriendSheetVC addAction:cancelAction];
        [delteFriendSheetVC addAction:deleteAction];
        [navVC presentViewController:delteFriendSheetVC animated:YES completion:nil];
    });
}

@end

@implementation QimRNBModule(GroupCard)

RCT_EXPORT_METHOD(clearImessage:(NSDictionary *)params) {
    
}

// 获取群二维码图片
RCT_EXPORT_METHOD(getGroupQRCode:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    UIImage *qrCodeImage = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"qtalk://group?id=%@",groupId] imageSize:256];
    NSString *base64Image = [UIImage qim_image2DataURL:qrCodeImage];
    callback(@[@{@"qrCode" : base64Image ? base64Image : @""}]);
}

// 获取群成员列表
RCT_EXPORT_METHOD(getGroupMember:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length <= 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *list = [QimRNBModule qimrn_getGroupMembersByGroupId:groupId];
        callback(@[@{@"GroupMembers" : list, @"ok" : @(YES)}]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[QIMKit sharedInstance] syncgroupMember:groupId];
        });
    });
}

RCT_EXPORT_METHOD(selectMemberFromGroup:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSString *searchText = [param objectForKey:@"searchText"];
    NSArray *userList = [[QIMKit sharedInstance] qimDB_getGroupMember:groupId BySearchStr:searchText];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *userDic in userList) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *xmppId = [userDic objectForKey:@"xmppjid"];
        NSString *name = [userDic objectForKey:@"name"];
        NSString *headerUri = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:xmppId];
        if (headerUri.length <= 0) {
            headerUri = [QIMKit defaultUserHeaderImagePath];
        }
        [dic setQIMSafeObject:xmppId forKey:@"xmppId"];
        [dic setQIMSafeObject:name forKey:@"name"];
        [dic setQIMSafeObject:headerUri forKey:@"headerUri"];
        [array addObject:dic];
    }

    callback(@[@{@"UserList" : array, @"ok" : @(YES)}]);
}

RCT_EXPORT_METHOD(selectGroupMemberForKick:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSInteger affiliation = [[param objectForKey:@"affiliation"] integerValue];
    
    NSArray *userList = [[QIMKit sharedInstance] qimDB_getGroupMember:groupId WithGroupIdentity:affiliation];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *userDic in userList) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *xmppId = [userDic objectForKey:@"xmppjid"];
        NSString *name = [userDic objectForKey:@"name"];
        NSString *headerUri = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:xmppId];
        if (headerUri.length <= 0) {
            headerUri = [QIMKit defaultUserHeaderImagePath];
        }
        [dic setQIMSafeObject:xmppId forKey:@"xmppId"];
        [dic setQIMSafeObject:name forKey:@"name"];
        [dic setQIMSafeObject:headerUri forKey:@"headerUri"];
        [array addObject:dic];
    }

    callback(@[@{@"UserList" : array, @"ok" : @(YES)}]);
}

RCT_EXPORT_METHOD(kickGroupMember:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSDictionary *selectGroupMemebers = [param objectForKey:@"members"];
    BOOL kickSuccess = NO;
    for (NSDictionary *groupMemberDic in [selectGroupMemebers allValues]) {
        NSString *name = [groupMemberDic objectForKey:@"name"];
        NSString *xmppId = [groupMemberDic objectForKey:@"xmppId"];
        kickSuccess = [[QIMKit sharedInstance] removeGroupMemberWithName:name WithJid:xmppId ForGroupId:groupId];
    }
    if (kickSuccess == YES) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"closeKickMembers" body:@{}];
        NSString *str = @"踢出群成员成功";
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject makeToast:str];
            });
        });
    } else {
        NSString *str = @"踢出群成员失败";
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject makeToast:str];
            });
        });
    }
}

RCT_EXPORT_METHOD(showRedView:(RCTResponseSenderBlock)callback) {
    BOOL show = [[[QIMKit sharedInstance] userObjectForKey:@"qimrn_searchlocal"] boolValue];
    callback(@[@{@"show" : @(!show)}]);
}

RCT_EXPORT_METHOD(isShowRedView) {
    [[QIMKit sharedInstance] setUserObject:@(YES) forKey:@"qimrn_searchlocal"];
}

// 获取群PushState
RCT_EXPORT_METHOD(syncPushState:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    BOOL pushState = [[QIMKit sharedInstance] groupPushState:groupId];
    callback(@[@{@"state" : @(pushState)}]);
}

// 更新群PushState
RCT_EXPORT_METHOD(updatePushState:(NSString *)groupId :(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL isSuccess = [[QIMKit sharedInstance] updatePushState:groupId withOn:state];
    callback(@[@{@"ok" : @(isSuccess)}]);
}

//获取群置顶stickyState
RCT_EXPORT_METHOD(syncGroupStickyState:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    NSString *combineId = [NSString stringWithFormat:@"%@<>%@", groupId, groupId];
    BOOL stickyState = [[[QIMKit sharedInstance] stickList] objectForKey:combineId];
    callback(@[@{@"state" : @(stickyState)}]);
}

//更新群置顶状态
RCT_EXPORT_METHOD(updateGroupStickyState:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length > 0) {
        if ([[QIMKit sharedInstance] isStickWithCombineJid:[NSString stringWithFormat:@"%@<>%@", groupId, groupId]]) {
            BOOL isSuccess = [[QIMKit sharedInstance] removeStickWithCombineJid:[NSString stringWithFormat:@"%@<>%@", groupId, groupId] WithChatType:ChatType_GroupChat];
            callback(@[@{@"ok" : @(isSuccess)}]);
        } else {
            BOOL isSuccess = [[QIMKit sharedInstance] setStickWithCombineJid:[NSString stringWithFormat:@"%@<>%@", groupId, groupId] WithChatType:ChatType_GroupChat];
            callback(@[@{@"ok" : @(isSuccess)}]);
        }
    }
}

// 获取群名片信息
RCT_EXPORT_METHOD(getGroupInfo:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length <= 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *properties = [QimRNBModule qimrn_getGroupInfoByGroupId:groupId];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] updateGroupCardByGroupId:groupId];
        });
        callback(@[@{@"ok" : @(YES),@"GroupInfo" : properties ? properties : @{}}]);
    });
}

// 设置群名称
RCT_EXPORT_METHOD(saveGroupName:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"GroupId"];
    NSString *groupName = [param objectForKey:@"GroupName"];
    BOOL isSuccess = [[QIMKit sharedInstance] setMucVcardForGroupId:groupId WithNickName:groupName WithTitle:nil WithDesc:nil WithHeaderSrc:nil];
    callback(@[@{@"ok" : @(isSuccess)}]);
}

// 设置群公告
RCT_EXPORT_METHOD(saveGroupTopic:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"GroupId"];
    NSString *groupName = [param objectForKey:@"GroupName"];
    NSString *groupTopic = [param objectForKey:@"GroupTopic"];
    BOOL isSuccess = [[QIMKit sharedInstance] setMucVcardForGroupId:groupId WithNickName:groupName WithTitle:groupTopic WithDesc:nil WithHeaderSrc:nil];
    callback(@[@{@"ok" : @(isSuccess)}]);
}

// 添加群成员
RCT_EXPORT_METHOD(addGroupMember:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    //如果是群组情况直接添加
    BOOL isGroup = [[param objectForKey:@"isGroup"] boolValue];
    NSDictionary *selectMembers = [param objectForKey:@"members"];
    NSMutableArray *memberIds = [NSMutableArray arrayWithCapacity:5];
    
    NSMutableString *groupName = [NSMutableString stringWithString:[selectMembers count] > 1 ? @"":@"群组("];
    NSString *nickName = [[QIMKit sharedInstance] getMyNickName];
    
    for (NSDictionary *memberDict in [selectMembers allValues]) {
        NSString *memberName = [memberDict objectForKey:@"name"];
        NSString *memberId = [memberDict objectForKey:@"xmppId"];
        [groupName appendString:memberName];
        [groupName appendString:([memberDict isEqual:[[selectMembers allValues] lastObject]]) ? selectMembers.count>1?@"":@")" :@","];
        [memberIds addObject:memberId];
    }
    
    if (isGroup) {
        NSString *groupId = [param objectForKey:@"groupId"];
        [[QIMKit sharedInstance] joinGroupWithBuddies:groupId groupName:@"" WithInviteMember:memberIds withCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UINavigationController *nav = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
//                QIMNavController *navVC = (QIMNavController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                [nav popViewControllerAnimated:YES];
            });
        }];
    } else {
        NSString *nickName = [[QIMKit sharedInstance] getMyNickName];
        [[QIMKit sharedInstance] createGroupByGroupName:[QIMUUIDTools UUID]
                                         WithMyNickName:nickName
                                       WithInviteMember:memberIds
                                            WithSetting:[[QIMKit sharedInstance] defaultGroupSetting]
                                               WithDesc:@""
                                      WithGroupNickName:groupName
                                           WithComplate:^(BOOL finish,NSString *groupId) {
                                               if (finish) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [[QIMKit sharedInstance] clearNotReadMsgByGroupId:groupId];
                                                       [QIMFastEntrance openGroupChatVCByGroupId:groupId];
                                                       /*
                                                       QIMGroupChatVC *chatGroupVC = [[QIMGroupChatVC alloc] init];
                                                       [chatGroupVC setTitle:groupName];
                                                       [chatGroupVC setChatId:groupId];
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifySelectTab" object:@(0)];
//                                                        QIMNavController *navVC = (QIMNavController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                                                       UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                                                       if (!navVC) {
                                                           navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
                                                       }
                                                       [navVC pushViewController:chatGroupVC animated:YES];
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNickNameChanged object:@[groupId]];
                                                       */
                                                   });
                               
                                               } else {
                                                   
                                               }
                                           }];
    }
}

//退出群组
RCT_EXPORT_METHOD(quitGroup:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length > 0) {
        BOOL result = [[QIMKit sharedInstance] quitGroupId:groupId];
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *combineGroupId = [NSString stringWithFormat:@"%@<>%@", groupId, groupId];
                [[QIMKit sharedInstance] removeStickWithCombineJid:combineGroupId WithChatType:ChatType_GroupChat];
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
                }
                [navVC popToRootViewControllerAnimated:YES];
            });
        }
        callback(@[@{@"ok" : @(result)}]);
    }
}

//退出群聊
RCT_EXPORT_METHOD(destructionGroup:(NSString *)groupId :(RCTResponseSenderBlock)callback) {
    if (groupId.length > 0) {
        BOOL result = [[QIMKit sharedInstance] destructionGroup:groupId];
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *combineGroupId = [NSString stringWithFormat:@"%@<>%@", groupId, groupId];
                [[QIMKit sharedInstance] removeStickWithCombineJid:combineGroupId WithChatType:ChatType_GroupChat];
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
                }
                [navVC popToRootViewControllerAnimated:YES];
            });
        }
        callback(@[@{@"ok" : @(result)}]);
    }
}

RCT_EXPORT_METHOD(selectUserListByText:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [params objectForKey:@"groupId"];
    NSString *searchText = [params objectForKey:@"searchText"];
    NSArray *users = [[QIMKit sharedInstance] searchUserBySearchStr:searchText notInGroup:groupId];
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:3];

    for (NSDictionary *memberDic in users) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
        NSString *name = [memberDic objectForKey:@"Name"];
        NSString *userId = [memberDic objectForKey:@"UserId"];
        NSString *xmppId = [memberDic objectForKey:@"XmppId"];
        NSString *uri = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:xmppId];
        [dic setQIMSafeObject:name forKey:@"name"];
        [dic setQIMSafeObject:xmppId forKey:@"xmppId"];
        [dic setQIMSafeObject:uri forKey:@"headerUri"];
        [properties addObject:dic];
    }
    
    callback(@[@{@"ok" : @(YES), @"UserList" : properties ? properties : @[]}]);
}

@end

@implementation QimRNBModule(MySetting)

// 获取自己的信息
RCT_EXPORT_METHOD(getMyInfo:(RCTResponseSenderBlock)callback) {
    NSString *userId = [[QIMKit sharedInstance] getLastJid];
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    NSString *name = [userInfo objectForKey:@"Name"];
    NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"";
    NSString *mood = [QimRNBModule qimrn_getUserMoodByUserId:userId];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:name ? name : [userId componentsSeparatedByString:@"@"].firstObject forKey:@"Name"];
    [info setObject:mood ? mood : @"" forKey:@"Mood"];
    NSString *headerSrc = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:userId];

    [info setObject:headerSrc ? headerSrc : @"" forKey:@"HeaderUri"];
    [info setObject:department ? department : @"" forKey:@"Department"];
    [info setObject:userId ? userId : @"" forKey:@"UserId"];
    
    callback(@[@{@"MyInfo":info?info:@{}}]);
}

//获取自己的个性签名
RCT_EXPORT_METHOD(getMyMood:(RCTResponseSenderBlock)callback) {
    NSString *userId = [[QIMKit sharedInstance] getLastJid];
    NSString *mood = [QimRNBModule qimrn_getUserMoodByUserId:userId];
    callback(@[@{@"mood": mood ? mood : @""}]);
}

// 设置个性签名
RCT_EXPORT_METHOD(savePersonalSignature:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *userId = [params objectForKey:@"UserId"];
    NSString *signature = [params objectForKey:@"PersonalSignature"];
    if ([userId isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
        [[QIMKit sharedInstance] updateUserSignatureForUser:userId signature:signature];
        callback(@[@{@"ok":@(YES)}]);
    } else {
        callback(@[@{@"ok":@(NO),@"message":@"无权访问"}]);
    }
}

// 设置我的二维码
RCT_EXPORT_METHOD(getUserQRCode:(NSString *)userId :(RCTResponseSenderBlock)callback) {
    UIImage *qrCodeImage = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"qtalk://user?id=%@",userId] imageSize:256];
    NSString *base64Image = [UIImage qim_image2DataURL:qrCodeImage];
    callback(@[@{@"qrCode":base64Image?base64Image:@""}]);
}

//从相册更新我的头像
RCT_EXPORT_METHOD(updateMyPhotoFromImagePicker) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        }
        picker.delegate = self;
        picker.allowsEditing = YES;
        [navVC presentViewController:picker animated:YES completion:nil];
    });
}

//拍照更新我的头像
RCT_EXPORT_METHOD(takePhoto) {
    dispatch_async(dispatch_get_main_queue(), ^{
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerControllerSourceType souceType = UIImagePickerControllerSourceTypeCamera;
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = souceType;
            [navVC presentViewController:picker animated:YES completion:nil];
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备不支持拍照" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    });
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [__innerCacheBridge.eventDispatcher sendAppEventWithName:@"imageUpdateStart" body:@{@"name": @"aaa"}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self saveImage:image WithImageName:@"currentImage"];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image WithImageName:(NSString *)ImageName{
    NSData *currentImageData = UIImageJPEGRepresentation(image, 1.0);
    if (currentImageData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[QIMKit sharedInstance] updateMyPhoto:currentImageData];
        });
    }
}

@end

@implementation QimRNBModule(AdviceAndFeedback)

// 打开开发人员会话窗口
RCT_EXPORT_METHOD(openDeveloperChat) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [QIMFastEntrance openSingleChatVCByUserId:@"lilulucas.li@ejabhost1"];
        /*
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        QIMChatVC *chatVC = [[QIMChatVC alloc] init];
        [chatVC setStype:kSessionType_Chat];
        [chatVC setChatId:@"lilulucas.li@ejabhost1"];
        [chatVC setName:@"李露lucas"];
        [chatVC setTitle:@"李露lucas"];
        [chatVC setChatType:ChatType_SingleChat];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        [navVC popToRootVCThenPush:chatVC animated:YES];
        */
    });
}

// 发送反馈意见
RCT_EXPORT_METHOD(sendAdviceMessage:(NSDictionary *)adviceParam :(RCTResponseSenderBlock)callback) {
    
    NSString *adviceMsg = [adviceParam objectForKey:@"adviceText"];
    BOOL logSelected = [[adviceParam objectForKey:@"logSelected"] boolValue];
#if defined (QIMLogEnable) && QIMLogEnable == 1
    callback(@[@{@"ok":@(YES)}]);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject makeToast:@"感谢您的反馈"];
    });//这句话的意思是1.5秒后，把label移出视图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        [[[UIApplication sharedApplication] visibleViewController].view.subviews.firstObject hideAllToasts];
    });//这句话的意思是1.5秒后，把label移出视图
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       [[QIMLocalLog sharedInstance] submitFeedBackWithContent:adviceMsg WithLogSelected:logSelected];
    });
#endif
}

@end

@implementation QimRNBModule(Contacts)

RCT_EXPORT_METHOD(getContactsNick:(NSString *)xmppId :(RCTResponseSenderBlock)callback) {
    
    if (xmppId.length <= 0 || !xmppId) {
        return;
    }
    NSDictionary *userInfo = nil;
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        [[QIMKit sharedInstance] getQChatUserInfoForUser:xmppId];
        userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:xmppId];
    } else {
        userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:xmppId];
    }
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:xmppId];
    NSString *userNickName = [userInfo objectForKey:@"Name"];
    NSString *name = remarkName.length ? remarkName : (userNickName.length ? userNickName : [xmppId componentsSeparatedByString:@"@"].firstObject);
    NSString *pinyin = [QIMPinYinForObjc chineseConvertToPinYin:userNickName];
    NSString *headerSrc = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:xmppId];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:name forKey:@"Name"];
    [properties setObject:headerSrc ? headerSrc : @"" forKey:@"HeaderUri"];
    [properties setObject:pinyin forKey:@"SearchIndex"];
    [properties setObject:xmppId forKey:@"XmppId"];
    callback(@[@{@"nick":properties ? properties : @{}}]);
}

RCT_EXPORT_METHOD(selectFriendsForGroupAdd:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSString *groupId = [param objectForKey:@"groupId"];
    NSArray *friendList = [[QIMKit sharedInstance] qimDB_selectFriendListInGroupId:groupId];
    if (friendList) {
        NSMutableArray *contactList = [NSMutableArray array];
        for (NSDictionary *userInfo in friendList) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            NSString *jid = [dic objectForKey:@"XmppId"];
            NSString *name = [dic objectForKey:@"Name"];
            NSString *pinyin = [QIMPinYinForObjc chineseConvertToPinYin:name];
            NSString *uri = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:jid];
            NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
            NSString *username = remarkName.length ? remarkName : (name.length ? name : [jid componentsSeparatedByString:@"@"].firstObject);
            [dic setObject:name forKey:@"name"];
            [dic setObject:jid forKey:@"xmppId"];
            [dic setObject:uri ? uri : @"" forKey:@"headerUri"];
            [dic setObject:@(YES) forKey:@"friend"];
            [contactList addObject:dic];
        }
        callback(@[@{@"UserList":contactList?contactList:@[], @"ok":@(YES)}]);
    } else {
        callback(@[@{@"UserList":@[], @"ok":@(YES)}]);
    }
}

// 获取联系人页展示的用户
RCT_EXPORT_METHOD(getContacts:(RCTResponseSenderBlock)callback) {
    NSArray *friendList = [[QIMKit sharedInstance] selectFriendList];
    if (friendList) {
        NSMutableArray *contactList = [NSMutableArray array];
        for (NSDictionary *userInfo in friendList) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            NSString *jid = [dic objectForKey:@"XmppId"];
            NSString *name = [dic objectForKey:@"Name"];
            NSString *pinyin = [QIMPinYinForObjc chineseConvertToPinYin:name];
            NSString *uri = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:jid];
            [dic setObject:uri ? uri : @"" forKey:@"HeaderUri"];
            [dic setObject:@(1) forKey:@"Type"];
            [dic setObject:pinyin forKey:@"SearchIndex"];
            [contactList addObject:dic];
        }
        callback(@[@{@"contacts" : contactList ? contactList : @[]}]);
    } else {
        callback(@[@{@"contacts" : @[]}]);
    }
}

// 获取群列表
RCT_EXPORT_METHOD(getGroupList:(RCTResponseSenderBlock)callback) {
    NSArray *tempList = [[QIMKit sharedInstance] getMyGroupList];
    NSMutableArray *groupList = [NSMutableArray array];
    for (NSDictionary *groupInfo in tempList) {
        NSMutableDictionary *groupDic = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
        NSString *groupId = [groupDic objectForKey:@"GroupId"];
        NSString *headerUri = [[QIMKit sharedInstance] getGroupImagePathFromLocalByGroupId:groupId];
        [groupDic setObject:headerUri forKey:@"HeaderUri"];
        [groupList addObject:groupDic];
    }
    callback(@[@{@"groupList":groupList?groupList:@[]}]);
}

// 获取公众号列表
RCT_EXPORT_METHOD(getPublicNumberList:(RCTResponseSenderBlock)callback) {
    NSArray *tempList = [[QIMKit sharedInstance] getPublicNumberList];
    NSMutableArray *publicNumberList = [NSMutableArray array];
    for (NSDictionary *pInfo in tempList) {
        NSMutableDictionary *pNumberDic = [NSMutableDictionary dictionaryWithDictionary:pInfo];
        NSString *headerSrc = [pInfo objectForKey:@"HeaderSrc"];
        NSString *headerPath = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithHeaderUrl:headerSrc];
        if (![[NSFileManager defaultManager] fileExistsAtPath:headerPath] || !headerPath) {
            headerPath = [[QIMKit sharedInstance] getPublicNumberDefaultHeaderPath];
        }
        [pNumberDic setQIMSafeObject:headerPath ? headerPath : [[QIMKit sharedInstance] getPublicNumberDefaultHeaderPath] forKey:@"HeaderUri"];
        [publicNumberList addObject:pNumberDic];
    }
    callback(@[@{@"publicNumberList":publicNumberList?publicNumberList:@[]}]);
}

RCT_EXPORT_METHOD(searchGroupListWithKey:(NSString *)searchText :(RCTResponseSenderBlock)callback) {
    NSArray *tempList = [[QIMKit sharedInstance] getMyGroupList];
    NSMutableArray *groupList = [NSMutableArray array];
    NSString * keyName = @"Name";
    for (NSDictionary * groupInfo in tempList) {
        
        NSString *pinyin = [groupInfo objectForKey:@"pinyin"];
        if (pinyin == nil){
            pinyin = [QIMPinYinForObjc chineseConvertToPinYin:[groupInfo objectForKey:keyName]];
            NSMutableDictionary *dicn = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
            [dicn setObject:pinyin forKey:@"pinyin"];
        }
        if ([pinyin rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [[groupInfo objectForKey:keyName] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            NSMutableDictionary *groupDic = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
            NSString *groupId = [groupDic objectForKey:@"GroupId"];
            NSString *headerUri = [[QIMKit sharedInstance] getGroupImagePathFromLocalByGroupId:groupId];
            [groupDic setObject:headerUri ? headerUri : @"" forKey:@"HeaderUri"];
            [groupList addObject:groupDic];
        }
    }
    callback(@[@{@"groupList":groupList?groupList:@[]}]);
}

@end

@implementation QimRNBModule (PublicNumberList)

//RCT_EXPORT_METHOD(getPublicNumberList:(RCTResponseSenderBlock)callback) {
//    NSMutableArray *publicNumberList = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getPublicNumberList]];
//    callback(@[@{@"publicNumberList":publicNumberList ? publicNumberList : @[]}]);
//}

@end

@interface QimRNBModule (Setting) <QIMSwitchAccountViewDelegate>

@end

@implementation QimRNBModule (Setting)

//是否是黑名单和星标用户
RCT_EXPORT_METHOD(isStarOrBlackContact:(NSString *) xmppid ConfigKey:(NSString *) pkey :(RCTResponseSenderBlock)callback){
    BOOL flag = [[QIMKit sharedInstance] isStarOrBlackContact:xmppid ConfigKey:pkey];
    callback(@[@{@"ok" : @(flag)}]);
}
//设置取消星标&黑名单
RCT_EXPORT_METHOD(setStarOrblackContact:(NSString *)xmppid ConfigKey:(NSString *)pkey :(BOOL)value :(RCTResponseSenderBlock)callback){
    BOOL flag = [[QIMKit sharedInstance] setStarOrblackContact:xmppid ConfigKey:pkey Flag:value];
    callback(@[@{@"ok" : @(flag)}]);
}
//设置取消星标&黑名单(多个)
RCT_EXPORT_METHOD(setStarOrBlackContacts:(NSDictionary*)map ConfigKey:(NSString *)pkey :(BOOL)value :(RCTResponseSenderBlock)callback){
    BOOL flag = [[QIMKit sharedInstance] setStarOrblackContacts:map ConfigKey:pkey Flag:value];
    callback(@[@{@"ok" : @(flag)}]);
}

//获取用户在线也收通知状态
RCT_EXPORT_METHOD(syncOnLineNotifyState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[QIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGPUSH_ONLINE];
    QIMVerboseLog(@"syncOnLineNotifyState : %d", state);
    callback(@[@{@"state" : @(state)}]);
}

//设置在线也收通知状态
RCT_EXPORT_METHOD(updateOnLineNotifyState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[QIMKit sharedInstance] setMsgNotifySettingWithIndex:QIMMSGSETTINGPUSH_ONLINE WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取用户通知声音状态
RCT_EXPORT_METHOD(getNotifySoundState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[QIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGSOUND_INAPP];
    QIMVerboseLog(@"getNotifySoundState : %d", state);
    callback(@[@{@"state" : @(state)}]);
}

//设置用户通知声音状态
RCT_EXPORT_METHOD(updateNotifySoundState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[QIMKit sharedInstance] setMsgNotifySettingWithIndex:QIMMSGSETTINGSOUND_INAPP WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取消息推送状态
RCT_EXPORT_METHOD(getStartPushState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[QIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGPUSH_SWITCH];
    callback(@[@{@"state" : @(state)}]);
}

//设置开启消息推送状态
RCT_EXPORT_METHOD(updateStartNotifyState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[QIMKit sharedInstance] setMsgNotifySettingWithIndex:QIMMSGSETTINGPUSH_SWITCH WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取用户通知震动状态
RCT_EXPORT_METHOD(getNotifyVibrationState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[QIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGVIBRATE_INAPP];
    callback(@[@{@"state" : @(state)}]);
}

//设置用户通知震动状态
RCT_EXPORT_METHOD(updateNotifyVibrationState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[QIMKit sharedInstance] setMsgNotifySettingWithIndex:QIMMSGSETTINGVIBRATE_INAPP WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取用户是否显示通知详情
RCT_EXPORT_METHOD(getNotifyPushDetailsState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[QIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGSHOW_CONTENT];
    callback(@[@{@"state" : @(state)}]);
}

//设置用户通知是否显示详情
RCT_EXPORT_METHOD(updateNotifyPushDetailsState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    BOOL updateSuccess = [[QIMKit sharedInstance] setMsgNotifySettingWithIndex:QIMMSGSETTINGSHOW_CONTENT WithSwitchOn:state];
    callback(@[@{@"ok" : @(updateSuccess)}]);
}

//获取显示用户签名状态
RCT_EXPORT_METHOD(getShowUserModState:(RCTResponseSenderBlock)callback) {
    BOOL state = [[QIMKit sharedInstance] moodshow];
    QIMVerboseLog(@"getShowUserModState : %d", state);
    callback(@[@{@"state" : @(state)}]);
}

//
RCT_EXPORT_METHOD(updateShowUserModState:(BOOL)state :(RCTResponseSenderBlock)callback) {
    [[QIMKit sharedInstance] setMoodshow:state];
    callback(@[@{@"ok" : @(YES)}]);
}

//获取客服服务模式
RCT_EXPORT_METHOD(getServiceState:(RCTResponseSenderBlock)callback) {
    
    NSArray *array = [[QIMKit sharedInstance] getSeatSeStatus];
    callback(@[@{@"JsonData" : array ? array : @[]}]);
}

//设置客服服务模式
RCT_EXPORT_METHOD(setServiceState:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    if (!param) {
        return;
    }
    NSInteger st = [[param objectForKey:@"state"] integerValue];
    NSInteger sid = [[param objectForKey:@"sid"] integerValue];
    if (sid) {
        BOOL success = [[QIMKit sharedInstance] updateSeatSeStatusWithShopId:sid WithStatus:st];
        callback(@[@{@"result" : @(success)}]);
    }
}

//获取App版本信息
RCT_EXPORT_METHOD(getAppVersion:(RCTResponseSenderBlock)callback) {
    NSString *appVersion = [NSString stringWithFormat:@"%@", [[QIMKit sharedInstance] AppVersion]];
    callback(@[@{@"AppVersion" : appVersion ? appVersion : @""}]);
}

//打开装扮
RCT_EXPORT_METHOD(openDressUpVc) {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMDressUpController *dressUpVC = [[QIMDressUpController alloc] init];
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:dressUpVC animated:YES];
    });
}

//搜索聊天历史
RCT_EXPORT_METHOD(openSearchHistoryVc) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *searchUrl = [NSString stringWithFormat:@"%@/lookback/main_controller.php", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost]];
        if (searchUrl.length > 0) {
            [QIMFastEntrance openWebViewForUrl:searchUrl showNavBar:YES];
        }
    });
}

//清除缓存
RCT_EXPORT_METHOD(clearSessionList) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[QIMKit sharedInstance] clearAllNoRead];
        [[QIMKit sharedInstance] deleteSessionList];
    });
}

//打开账户关联页面
RCT_EXPORT_METHOD(openMcConfig) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *linkUrl = [NSString stringWithFormat:@"%@?u=%@&d=%@&navBarBg=208EF2", [[QIMKit sharedInstance] qimNav_Mconfig], [QIMKit getLastUserName], [[QIMKit sharedInstance] qimNav_Domain]];
        [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
    });
}

//打开切换账号
RCT_EXPORT_METHOD(openSwitchAccount) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self swicthAccount];
    });
}

- (QIMSwitchAccountView *)accountCollectionView {
    
    NSDictionary *addDict = @{@"userFullJid":@"Add@System"};
    NSArray *accounts = [[QIMKit sharedInstance] getLoginUsers];
    NSMutableArray *userDatas = [NSMutableArray arrayWithArray:accounts];
    [userDatas addObject:addDict];
    QIMSwitchAccountView *accountCollectionView = [[QIMSwitchAccountView alloc] initWithFrame:CGRectMake(0, 0, 220, 120) WithAccounts:userDatas];
    accountCollectionView.delegate = self;
    _accountCollectionView = accountCollectionView;
    return _accountCollectionView;
}

- (SCLAlertView *)swicthAccountAlert {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSwitchAccount:) name:kNotifySwichUserSuccess object:nil];
    SCLAlertView *swicthAccountAlert = [[SCLAlertView alloc] init];
    swicthAccountAlert.shouldDismissOnTapOutside = YES;
    [swicthAccountAlert setHorizontalButtons:YES];
    [swicthAccountAlert addCustomView:self.accountCollectionView];
    swicthAccountAlert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];
    _swicthAccountAlert = swicthAccountAlert;
    return _swicthAccountAlert;
}

- (SCLAlertView *)waitingAlert {
    _waitingAlert = [[SCLAlertView alloc] init];
    return _waitingAlert;
}

- (void)swicthAccount {
    [[self swicthAccountAlert] showCustom:[[[[UIApplication sharedApplication] delegate] window] rootViewController] image:[UIImage imageNamed:@"switch"] color:[UIColor brownColor] title:@"切换账号" subTitle:nil closeButtonTitle:@"取消" duration:0];
}

- (void)showSwitchAccountView {
    [[self swicthAccountAlert] showCustom:[[[[UIApplication sharedApplication] delegate] window] rootViewController] image:[UIImage imageNamed:@"switch"] color:[UIColor brownColor] title:@"切换账号" subTitle:nil closeButtonTitle:@"取消" duration:0];
}

- (void)swicthAccountWithAccount:(NSDictionary *)accountDict {
    
    QIMVerboseLog(@"将要切换账号 ： %@", accountDict);
    if (accountDict) {
        NSString *userId = [accountDict objectForKey:@"userId"];
        [[QIMKit sharedInstance] setUserObject:userId forKey:@"currentLoginName"];
        if (![userId isEqualToString:@"Add"]) {
            NSString *userFullJid = [accountDict objectForKey:@"userFullJid"];
            userId = [[userFullJid componentsSeparatedByString:@"@"] firstObject];
            NSString *pwd = [accountDict objectForKey:@"LoginToken"];
            NSDictionary *navDict = [accountDict objectForKey:@"NavDict"];
            if (userId && pwd) {
                [[QIMKit sharedInstance] sendNoPush];
                [[QIMKit sharedInstance] clearcache];
                [[QIMKit sharedInstance] clearLogginUser];
                [[QIMKit sharedInstance] quitLogin];
                [[QIMKit sharedInstance] removeUserObjectForKey:@"userToken"];
                [[QIMKit sharedInstance] removeUserObjectForKey:@"kTempUserToken"];
                [[QIMKit sharedInstance] setCacheName:userFullJid];
                [[QIMKit sharedInstance] qimNav_swicthLocalNavConfigWithNavDict:navDict];
                [[QIMKit sharedInstance] loginWithUserName:userId WithPassWord:pwd WithLoginNavDict:navDict];
                [[self waitingAlert] showWaiting:[[[[UIApplication sharedApplication] delegate] window] rootViewController] title:@"Waiting..." subTitle:@"账号切换中" closeButtonTitle:nil duration:20.0f];
            } else if (userId && !pwd) {
                [[QIMKit sharedInstance] quitLogin];
                [[QIMKit sharedInstance] clearLogginUser];
                [[QIMKit sharedInstance] setCacheName:userFullJid];
                [self reloginAccount];
            }
        } else {
            [[QIMKit sharedInstance] quitLogin];
            [[QIMKit sharedInstance] clearLogginUser];
            [[QIMKit sharedInstance] setCacheName:@""];
            [self reloginAccount];
        }
    }
    [_swicthAccountAlert hideView];
}

- (void)reloginAccount {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //Comment by lilulucas.li
        //        [[QIMKit sharedInstance] clearQC_IMManager];
        [QIMFastEntrance reloginAccount];
    });
}

- (void)refreshSwitchAccount:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_swicthAccountAlert hideView];
        [_waitingAlert hideView];
    });
}

RCT_EXPORT_METHOD(openQChatServers) {
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
            }
            [navVC setNavigationBarHidden:NO animated:NO];
            QIMServiceStatusViewController *serverVc = [[QIMServiceStatusViewController alloc] init];
            [navVC pushViewController:serverVc animated:YES];
        });
    }
}

RCT_EXPORT_METHOD(updateCheckConfig) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[QIMKit sharedInstance] checkClientConfig];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"配置更新完成，建议重启客户端进行查看！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        });
    });
}

RCT_EXPORT_METHOD(getAppCache:(RCTResponseSenderBlock)callback) {
    long long totalSize = [[QIMDataController getInstance] sizeofImagePath];
    NSString *str = nil;
    if (totalSize < 1048576) {
        // 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1024.0;
        str = [NSString stringWithFormat:@"%.2fKB", result];
    } else if (totalSize < 1073741824) {
        // 1024 * 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1048576.0;
        str = [NSString stringWithFormat:@"%.2fMB", result];
    } else if (totalSize < 1099511627776) {
        // 1024 * 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1073741824.0;
        str = [NSString stringWithFormat:@"%.2fGB", result];
    }
    callback(@[@{@"AppCache" : str ? str : @""}]);
}

//清除App缓存
RCT_EXPORT_METHOD(clearAppCache) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[QIMDataController getInstance] removeAllImage];
    });
    [__innerCacheBridge.eventDispatcher sendAppEventWithName:@"QIM_AppCache_Will_Update" body:@{@"name": @"aaa"}];
}

//退出登录
RCT_EXPORT_METHOD(logout) {
    [QIMFastEntrance signOut];
}

@end

@implementation QimRNBModule (PublicNumber)

RCT_EXPORT_METHOD(scanQrcode) {
    [QIMFastEntrance openQRCodeVC];
}

RCT_EXPORT_METHOD(searchPublicNumber) {
    dispatch_async(dispatch_get_main_queue(), ^{
//        UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        QIMPublicNumberSearchVC *searchVC = [[QIMPublicNumberSearchVC alloc] init];
        [navVC pushViewController:searchVC animated:YES];
    });
}

@end

@implementation QimRNBModule (About)

RCT_EXPORT_METHOD(openAbout) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC setNavigationBarHidden:NO animated:NO];
        QIMAboutVC *aboutVc = [[QIMAboutVC alloc] init];
        [navVC pushViewController:aboutVc animated:YES];
    });
}

RCT_EXPORT_METHOD(rateApp:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    NSString *AppStr = [params objectForKey:@"AppStr"];
    if (AppStr.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStr]];
        });
    }
}

@end

@implementation QimRNBModule (Travel)

RCT_EXPORT_METHOD(selectUserTripByDate:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    
    NSString *date = [params objectForKey:@"showDate"];
    NSArray *list = [[QIMKit sharedInstance] selectTripByYearMonth:date];
    list = [list sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *tripDic1 = (NSDictionary *)obj1;
        NSDictionary *tripDic2 = (NSDictionary *)obj2;
        NSString *beginTime1 = [tripDic1 objectForKey:@"beginTime"];
        NSString *beginTime2 = [tripDic2 objectForKey:@"beginTime"];
        NSDate *beginDate1 = [NSDate date:beginTime1 WithFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *beginDate2 = [NSDate date:beginTime2 WithFormat:@"yyyy-MM-dd HH:mm:ss"];
        return [beginDate1 compare:beginDate2];
    }];
    NSMutableArray *localMap = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *tripItem in list) {
        NSDictionary *newTripItem = [self qimrn_grtRNDataByTrip:tripItem];
        [localMap addObject:newTripItem];
    }
    
    NSMutableArray *indexArray = [NSMutableArray array];
    indexArray = [localMap valueForKeyPath:@"tripDate"];
    // 将array装换成NSSet类型，重新排序生成新的数组
    NSSet *indexSet = [NSSet setWithArray:indexArray];
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortSetArray = [indexSet sortedArrayUsingDescriptors:sortDesc];
    // 遍历数组并进行归类
    NSMutableArray *resultArray = [NSMutableArray array];
    NSMutableDictionary *dataMap = [NSMutableDictionary dictionaryWithCapacity:2];
    [sortSetArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 根据NSPredicate获取array
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripDate == %@",obj];
        NSArray *indexArray = [localMap filteredArrayUsingPredicate:predicate];
        QIMVerboseLog(@"indexArray : %@", indexArray);
        // 将查询结果加入到dataMap中
        [dataMap setQIMSafeObject:indexArray forKey:obj];
    }];
    
    callback(@[@{@"ok" : @(YES),@"data" : dataMap ? dataMap : @{}}]);
}

RCT_EXPORT_METHOD(getTripArea:(RCTResponseSenderBlock)callback) {
    
    NSArray *areaList = [self qimrn_getTripArea];
    callback(@[@{@"ok" : @(YES),@"areaList" : areaList ? areaList : @[]}]);
}

RCT_EXPORT_METHOD(getTripAreaAvailableRoom:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    QIMVerboseLog(@"params : %@", params);
    NSInteger areaId = [[params objectForKey:@"areaId"] integerValue];
    NSString *date = [params objectForKey:@"date"];
    NSString *endTime = [params objectForKey:@"endTime"];
    NSString *startTime = [params objectForKey:@"startTime"];
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    [[QIMKit sharedInstance] getTripAreaAvailableRoom:params callBack:^(NSArray *availableRooms) {
        QIMVerboseLog(@"callBack : %@", availableRooms);
        for (NSDictionary *roomInfo in availableRooms) {
            NSInteger roomId = [[roomInfo objectForKey:@"roomId"] integerValue];
            NSString *roomName = [roomInfo objectForKey:@"roomName"];
            NSInteger capacity = [[roomInfo objectForKey:@"capacity"] integerValue];
            NSString *description = [roomInfo objectForKey:@"description"];
            BOOL canUse = [roomInfo objectForKey:@"canUse"];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setQIMSafeObject:@(areaId) forKey:@"AddressNumber"];
            [dic setQIMSafeObject:roomName forKey:@"RoomName"];
            [dic setQIMSafeObject:@(roomId) forKey:@"RoomNumber"];
            [dic setQIMSafeObject:description forKey:@"RoomDetails"];
            [dic setQIMSafeObject:@(capacity) forKey:@"RoomCapacity"];
            if (canUse) {
                [result addObject:dic];
            }
        }
        if (result.count) {
            callback(@[@{@"ok" : @(YES), @"roomList" : result ? result : @[]}]);
        }
    }];
}

RCT_EXPORT_METHOD(tripMemberCheck:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    QIMVerboseLog(@"tripMemberCheck : %@", params);
    [[QIMKit sharedInstance] tripMemberCheck:params callback:^(BOOL isConform) {
        callback(@[@{@"ok" : @(YES), @"isConform" : @(isConform)}]);
    }];
}

RCT_EXPORT_METHOD(createTrip:(NSDictionary *)params :(RCTResponseSenderBlock)callback) {
    QIMVerboseLog(@"createTrip : %@", params);
    NSMutableDictionary *newParam = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSMutableArray *newMemberList = [[NSMutableArray alloc] init];
    NSArray *memberList = [params objectForKey:@"memberList"];
    BOOL checkMe = NO;
    for (NSDictionary *memberInfo in memberList) {
        NSString *memberId = [memberInfo objectForKey:@"memberId"];
        if (memberId.length > 0) {
            if ([memberId isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
                checkMe = YES;
            }
            [newMemberList addObject:@{@"memberId" : memberId}];
        }
    }
    if (!checkMe) {
        [newMemberList addObject:@{@"memberId":[[QIMKit sharedInstance] getLastJid]}];
    }
    [newParam setObject:newMemberList forKey:@"memberList"];
    [newParam setObject:@(111) forKey:@"updateTime"];
    [newParam setObject:[[QIMKit sharedInstance] getLastJid] forKey:@"tripInviter"];
    [[QIMKit sharedInstance] createTrip:newParam callBack:^(BOOL success) {
        callback(@[@{@"ok" : @(success)}]);
    }];
}

@end

@implementation QimRNBModule (Search)

//本地消息搜索
RCT_EXPORT_METHOD(searchLocalMessageByKeyword:(NSDictionary *)param :(RCTResponseSenderBlock)callback){

    NSDictionary *map = [QimRNBModule qimrn_searchLocalMsgWithUserParam:param];
    callback(@[map]);
}
//搜索后点击跳转会话
RCT_EXPORT_METHOD(openChatForLocalSearch:(NSString *)xmppid :(NSString *)realjid :(NSString *)chattype :(nonnull NSNumber *)time){
    QIMVerboseLog(@"xmppid= %@ realjid= %@ chattype=%@ time=%@", xmppid, realjid, chattype, time);
    long long fastMsgTime = [time longLongValue];
    if (chattype == nil) {
        chattype = [xmppid containsString:@"conference."] ? @"1" : @"0";
    }
    NSInteger chatType = [chattype integerValue];
    [QIMFastEntrance openFastChatVCByXmppId:xmppid WithRealJid:realjid WithChatType:chatType WithFastMsgTimeStamp:fastMsgTime];
}

//搜索图片视频
RCT_EXPORT_METHOD(openLocalSearchImage:(NSDictionary *)param) {
    NSString *xmppId = [param objectForKey:@"xmppid"];
    NSString *realjid = [param objectForKey:@"realjid"];
    ChatType chattype = [[param objectForKey:@"chatType"] integerValue];
    [QIMFastEntrance openLocalMediaWithXmppId:xmppId withRealJid:realjid withChatType:chattype];
}

//本地文件搜索
RCT_EXPORT_METHOD(searchLocalFile:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSDictionary *map = [QimRNBModule qimrn_searchLocalFileWithUserParam:param];
    callback(@[map]);
}

//本地链接搜索
RCT_EXPORT_METHOD(searchLocalLink:(NSDictionary *)param callback:(RCTResponseSenderBlock)callback) {
    NSDictionary *map = [QimRNBModule qimrn_searchLocalLinkWithUserParam:param];
    callback(@[map]);
}

@end

@implementation QimRNBModule (StarBlackContacts)

//黑名单&星标联系人
RCT_EXPORT_METHOD(selectStarOrBlackContacts:(NSString *)pkey :(RCTResponseSenderBlock)callback){
    NSMutableArray *contacts = [[QIMKit sharedInstance] selectStarOrBlackContacts:pkey];
    callback(@[@{@"data" : contacts ? contacts : @[]}]);
}
RCT_EXPORT_METHOD(selectFriendsNotInStarContacts:(RCTResponseSenderBlock)callback){
    NSMutableArray *contacts = [[QIMKit sharedInstance] selectFriendsNotInStarContacts];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:3];
    for (NSDictionary *friendInfo in contacts) {
        NSMutableDictionary *tempFriendInfo = [NSMutableDictionary dictionaryWithDictionary:friendInfo];
        NSString *userXmppJid = [friendInfo objectForKey:@"XmppId"];
        NSString *userName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userXmppJid];
        NSString *userHeaderUrl = [[QIMImageManager sharedInstance] qim_getHeaderCachePathWithJid:userXmppJid];
        
        [tempFriendInfo setQIMSafeObject:userName forKey:@"Name"];
        [tempFriendInfo setQIMSafeObject:userHeaderUrl forKey:@"HeaderUri"];
        [result addObject:tempFriendInfo];
    }
    callback(@[@{@"contacts" : result ? result : @[]}]);
}

RCT_EXPORT_METHOD(selectUserNotInStartContacts:(NSString *)key :(RCTResponseSenderBlock)callback){
    NSMutableArray *contacts = [[QIMKit sharedInstance] selectUserNotInStartContacts:key];
    callback(@[@{@"users" : contacts ? contacts : @[]}]);
}

@end

@implementation QimRNBModule (WorkFeed)

RCT_EXPORT_METHOD(openUserWorkWorld:(NSDictionary *)param) {
    [[QIMFastEntrance sharedInstance] openUserWorkWorldWithParam:param];
}

@end
