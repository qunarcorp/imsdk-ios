//
//  
//
//  Created by kimziv on 13-9-14.
//

#ifndef _QIMPinyinFormatter_H_
#define _QIMPinyinFormatter_H_

@class QIMHanyuPinyinOutputFormat;

@interface QIMPinyinFormatter : NSObject {
}

+ (NSString *)formatHanyuPinyinWithNSString:(NSString *)pinyinStr
                withQIMHanyuPinyinOutputFormat:(QIMHanyuPinyinOutputFormat *)outputFormat;
+ (NSString *)convertToneNumber2ToneMarkWithNSString:(NSString *)pinyinStr;
- (id)init;
@end

#endif // _QIMPinyinFormatter_H_
