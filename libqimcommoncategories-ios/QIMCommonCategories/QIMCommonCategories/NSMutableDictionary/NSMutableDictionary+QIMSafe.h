//
//  NSMutableDictionary+QIMSafe.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/3.
//
//


#import <Foundation/Foundation.h>

@interface NSMutableDictionary (QIMsafe)

- (void)setQIMSafeObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
