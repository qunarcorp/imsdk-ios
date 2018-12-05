//
//  
//
//  Created by kimziv on 13-9-14.
//

#ifndef _QIMPinyinHelper_H_
#define _QIMPinyinHelper_H_

@class QIMHanyuPinyinOutputFormat;

@interface QIMPinyinHelper : NSObject {
}

+ (NSArray *)toHanyuPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toHanyuPinyinStringArrayWithChar:(unichar)ch
                         withQIMHanyuPinyinOutputFormat:(QIMHanyuPinyinOutputFormat *)outputFormat;
+ (NSArray *)getFormattedHanyuPinyinStringArrayWithChar:(unichar)ch
                                   withQIMHanyuPinyinOutputFormat:(QIMHanyuPinyinOutputFormat *)outputFormat;
+ (NSArray *)getUnformattedHanyuPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toTongyongPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toWadeGilesPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toMPS2PinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toYalePinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)convertToTargetPinyinStringArrayWithChar:(unichar)ch
                                  withPinyinRomanizationType:(NSString *)targetPinyinSystem;
+ (NSArray *)toGwoyeuRomatzyhStringArrayWithChar:(unichar)ch;
+ (NSArray *)convertToGwoyeuRomatzyhStringArrayWithChar:(unichar)ch;
+ (NSString *)toHanyuPinyinStringWithNSString:(NSString *)str
                  withQIMHanyuPinyinOutputFormat:(QIMHanyuPinyinOutputFormat *)outputFormat
                                 withNSString:(NSString *)seperater;
+ (NSString *)getFirstHanyuPinyinStringWithChar:(unichar)ch
                    withQIMHanyuPinyinOutputFormat:(QIMHanyuPinyinOutputFormat *)outputFormat;
- (id)init;
@end

#endif // _QIMPinyinHelper_H_
