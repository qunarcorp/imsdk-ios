//
//  NSBundle+QIMLibrary.m
//  QIMCommonCategories
//
//  Created by 李露 on 2018/5/29.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "NSBundle+QIMLibrary.h"

@implementation NSBundle (QIMLibrary)

+ (NSBundle *)qimBundleWithClassName:(NSString *)className BundleName:(NSString *)bundleName {
    if (className.length > 0) {
        Class qimClass = NSClassFromString(className);
        return [NSBundle bundleWithPath:[[NSBundle bundleForClass:[qimClass class]] pathForResource:bundleName ofType:@"bundle"]];
    }
    return [NSBundle mainBundle];
}

+ (NSString *)qim_myLibraryResourcePathWithClassName:(NSString *)className BundleName:(NSString *)bundleName pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext {
    return [[self qimBundleWithClassName:className BundleName:bundleName] pathForResource:name ofType:ext];
}

+ (NSString *)qim_localizedStringForKey:(NSString *)key
{
    return [self qim_localizedStringForKey:key value:nil];
}

+ (NSString *)qim_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        // （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans、zh-Hant三种情况，其他按照系统默认处理
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans"; // 简体中文
            } else { // zh-Hant\zh-HK\zh-TW
                language = @"zh-Hant"; // 繁體中文
            }
        } else {
            language = @"en";
        }
        
        // 从MJRefresh.bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle qimBundleWithClassName:@"QIMI18N" BundleName:@"QIMI18N"] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
