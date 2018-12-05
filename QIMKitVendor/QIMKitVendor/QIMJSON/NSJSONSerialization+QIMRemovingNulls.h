//  NSJSONSerialization+RemovingNulls.h
//  Created by Richard Turton on 23/12/2013.

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (QIMRemovingNulls)

/// As the base class method, but pass YES to remove nulls from containers, optionally ignoring those in arrays.
+(id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError *__autoreleasing *)error removingNulls:(BOOL)removingNulls ignoreArrays:(BOOL)ignoreArrays;

@end

@interface NSMutableDictionary (QIMRemovingNulls)

-(void)qim_recursivelyRemoveNulls;
-(void)qim_recursivelyRemoveNullsIgnoringArrays:(BOOL)ignoringArrays;

@end

@interface NSMutableArray (QIMRemovingNulls)

-(void)qim_recursivelyRemoveNulls;
-(void)qim_recursivelyRemoveNullsIgnoringArrays:(BOOL)ignoringArrays;

@end
