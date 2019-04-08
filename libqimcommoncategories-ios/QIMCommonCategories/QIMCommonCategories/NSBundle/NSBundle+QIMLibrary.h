//
//  NSBundle+QIMLibrary.h
//  QIMCommonCategories
//
//  Created by 李露 on 2018/5/29.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (QIMLibrary)

+ (NSBundle *)qimBundleWithClassName:(NSString *)className BundleName:(NSString *)bundleName;

+ (NSString *)qim_myLibraryResourcePathWithClassName:(NSString *)className BundleName:(NSString *)bundleName pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext;

+ (NSString *)qim_localizedStringForKey:(NSString *)key;
+ (NSString *)qim_localizedStringForKey:(NSString *)key value:(NSString *)value;

@end
