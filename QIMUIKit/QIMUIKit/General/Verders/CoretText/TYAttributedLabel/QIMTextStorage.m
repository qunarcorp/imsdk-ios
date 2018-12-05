//
//  QIMTextStorage.m
//  QIMAttributedLabelDemo
//
//  Created by chenjie on 16/7/7.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//  

#import "QIMTextStorage.h"
#import "NSMutableAttributedString+QCTY.h"

@implementation QIMTextStorage

#pragma mark - protocol

- (void)addTextStorageWithAttributedString:(NSMutableAttributedString *)attributedString
{
    
    // 颜色
    if (_textColor) {
        [attributedString addAttributeTextColor:_textColor range:_range];
    }
    // 字体
    if (_font) {
        [attributedString addAttributeFont:_font range:_range];
    }
    
    // 下划线
    if (_underLineStyle) {
        [attributedString addAttributeUnderlineStyle:_underLineStyle modifier:_modifier range:_range];
    }
}

- (NSAttributedString *)appendTextStorageAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_text];
    
    // 验证范围
    if (NSEqualRanges(_range, NSMakeRange(0, 0))) {
        _range = NSMakeRange(0, attributedString.length);
    }
    
    [self addTextStorageWithAttributedString:attributedString];
    return [attributedString copy];
}

@end
