//
//  QTalkAuth.h
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/4/5.
//
//

#ifndef QTalkAuth_h
#define QTalkAuth_h

#import <React/RCTBridgeModule.h>
#import "QIMRnCheckUpdate.h"
#import "QIMCommonUIFramework.h"

#define kNotify_QIMRN_BUNDLE_UPDATE @"kNotify_QIMRN_BUNDLE_UPDATE"
#define kNotifyVCClose @"kNotifyVCClose"

typedef enum {
    QIMAppTypeInner = 1,    //内部应用
    QIMAppExternal, //外部App
    QIMAppTypeH5,   //H5 App
} QIMAppType;

static RCTBridge *__innerCacheBridge = nil;

@interface QimRNBModule : NSObject <RCTBridgeModule>

+ (void)loadBridgeCache;

+ (RCTBridge *)getStaticCacheBridge;

+ (NSURL *)getOuterJsLocation:(NSString *)bundleName;

/**
 内嵌应用JSLocation
 */
+ (NSURL *)getJsCodeLocation;

+ (id)clockOnVC;

+ (id)TOTPVC;

+ (void)sendQIMRNWillShow;

+ (id)createQIMRNVCWithParam:(NSDictionary *)param;
+ (id)createQIMRNVCWithBundleName:(NSString *)bundleName
                       WithModule:(NSString *)module
                   WithProperties:(NSDictionary *)properties;

+ (void)openVCWithNavigation:(UINavigationController *)navVC
               WithHiddenNav:(BOOL)hiddenNav
              WithBundleName:(NSString *)bundleName
                  WithModule:(NSString *)module;

+ (UIViewController *)getVCWithParam:(NSDictionary *)param;
+ (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                           WithBundleName:(NSString *)bundleName
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties;

+ (void)openQIMRNVCWithParam:(NSDictionary *)param;
+ (void)openVCWithNavigation:(UINavigationController *)navVC
               WithHiddenNav:(BOOL)hiddenNav
              WithBundleName:(NSString *)bundleName
                  WithModule:(NSString *)module
              WithProperties:(NSDictionary *)properties;
/*
 * 依赖客户端升级 大版本号
 *
 */
+ (NSString *)getAssetBundleName;

/*
 * 离线资源包 压缩文件名
 *
 */
+ (NSString *)getAssetZipBundleName;

/*
 * 内置bundle 文件名
 *
 */
+ (NSString *)getInnerBundleName;

/*
 * 缓存路径
 *
 */
+ (NSString *)getCachePath;

@end

#endif /* QTalkAuth_h */
