//
//  QIMPinYinForObjc.m
//  Search
//
//  Created by LYZ on 14-1-24.
//  Copyright (c) 2014年 LYZ. All rights reserved.
//

#import "QIMPinYinForObjc.h"

@implementation QIMPinYinForObjc

+ (NSString*)chineseConvertToPinYin:(NSString*)chinese {
    NSString *sourceText = chinese;
    QIMHanyuPinyinOutputFormat *outputFormat = [[QIMHanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSString *outputPinyin = [QIMPinyinHelper toHanyuPinyinStringWithNSString:sourceText withQIMHanyuPinyinOutputFormat:outputFormat withNSString:@""]; 
    return outputPinyin;
}

+ (NSString*)chineseConvertToPinYinHead:(NSString *)chinese {
    QIMHanyuPinyinOutputFormat *outputFormat = [[QIMHanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSMutableString *outputPinyin = [[NSMutableString alloc] init];
    for (int i=0;i <chinese.length;i++) {
        NSString *mainPinyinStrOfChar = [QIMPinyinHelper getFirstHanyuPinyinStringWithChar:[chinese characterAtIndex:i] withQIMHanyuPinyinOutputFormat:outputFormat];
        if (nil!=mainPinyinStrOfChar) {
            [outputPinyin appendString:[mainPinyinStrOfChar substringToIndex:1]];
        } else {
            break;
        }
    }
    return outputPinyin;
}
@end
