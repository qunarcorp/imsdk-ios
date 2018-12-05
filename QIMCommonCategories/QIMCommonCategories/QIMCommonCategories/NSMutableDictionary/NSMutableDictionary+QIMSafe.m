//
//  NSMutableDictionary+Safe.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/3.
//
//

#import "NSMutableDictionary+QIMSafe.h"

@implementation NSMutableDictionary (QIMSafe)
-(void)setQIMSafeObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (anObject && aKey && self) { 
        [self setObject:anObject forKey:aKey];
    } else {
//        QIMDebugLog(@"");
    }
}
@end
