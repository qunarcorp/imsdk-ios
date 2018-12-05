//
//  QIMMessageCellCache.h
//  qunarChatIphone
//
//  Created by chenjie on 16/7/6.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMMessageCellCache : NSObject

+ (instancetype) sharedInstance;

- (BOOL)isExistForKey:(NSString *)key;

- (void)setObject:(id)value forKey:(NSString *)key;

- (id)getObjectForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeObjectsForKeys:(NSArray *)keys;

- (void)clearUp;

@end
