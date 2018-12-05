//
//  QIMKit+QIMUserCacheManager.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMUserCacheManager)

- (void)chooseNewData:(BOOL)flag;
- (void)setCacheName:(NSString *)cacheName;

- (void)setUserObject:(nullable id)object forKey:(nonnull NSString *)aKey;
- (nullable id)userObjectForKey:(nonnull NSString *)aKey;
- (void)removeUserObjectForKey:(nonnull NSString *)aKey;
- (void)clearUserCache;
- (void)saveUserDefault;

- (void)removeUserDefaultFilePath;

@end
