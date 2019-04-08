//
//  
//
//  Created by kimziv on 13-9-14.
//

#ifndef _QIMChineseToPinyinResource_H_
#define _QIMChineseToPinyinResource_H_



#import <Foundation/Foundation.h>

@class NSArray;
@class NSMutableDictionary;

@interface QIMChineseToPinyinResource : NSObject {
    NSString* _directory;
    NSDictionary *_unicodeToHanyuPinyinTable;
}
//@property(nonatomic, strong)NSDictionary *unicodeToHanyuPinyinTable;

- (id)init;
- (void)initializeResource;
- (NSArray *)getHanyuPinyinStringArrayWithChar:(unichar)ch;
- (BOOL)isValidRecordWithNSString:(NSString *)record;
- (NSString *)getHanyuPinyinRecordFromCharWithChar:(unichar)ch;
+ (QIMChineseToPinyinResource *)getInstance;

@end



#endif // _QIMChineseToPinyinResource_H_
