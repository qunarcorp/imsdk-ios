//
//  NSMutableAttributedString+QC.h
//  QIMAttributedLabelDemo
//
//  Created by chenjie on 16/7/7.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <CoreText/CoreText.h>

@interface NSMutableAttributedString (QCTY)

/**
 *  添加文本颜色属性
 *
 *  @param color 文本颜色
 */
- (void)addAttributeTextColor:(UIColor*)color;

- (void)addAttributeTextColor:(UIColor*)color range:(NSRange)range;

/**
 *  添加文本字体属性
 *
 *  @param font 字体
 */
- (void)addAttributeFont:(UIFont *)font;

- (void)addAttributeFont:(UIFont *)font range:(NSRange)range;

/**
 *  添加文本字符间隔
 *
 *  @param characterSpacing 字符间隔
 */
- (void)addAttributeCharacterSpacing:(unichar)characterSpacing;

- (void)addAttributeCharacterSpacing:(unichar)characterSpacing range:(NSRange)range;

/**
 *  添加下划线样式
 *
 *  @param style    下划线 （单下划线 双 无）
 *  @param modifier 下划线样式 （点 线）
 */
- (void)addAttributeUnderlineStyle:(CTUnderlineStyle)style
                          modifier:(CTUnderlineStyleModifiers)modifier;

- (void)addAttributeUnderlineStyle:(CTUnderlineStyle)style
                          modifier:(CTUnderlineStyleModifiers)modifier
                             range:(NSRange)range;

/**
 *  添加空心字
 *
 *  @param strokeWidth 空心字边框宽
 *  @param strokeColor 空心字边框颜色
 */
- (void)addAttributeStrokeWidth:(unichar)strokeWidth
                    strokeColor:(UIColor *)strokeColor;

- (void)addAttributeStrokeWidth:(unichar)strokeWidth
                    strokeColor:(UIColor *)strokeColor
                          range:(NSRange)range;

/**
 *  添加文本段落样式
 *
 *  @param textAlignment    文本对齐样式
 *  @param linesSpacing     文本行间距
 *  @param paragraphSpacing 段落间距
 *  @param lineBreakMode    文本换行样式
 */
- (void)addAttributeAlignmentStyle:(CTTextAlignment)textAlignment
                    lineSpaceStyle:(CGFloat)linesSpacing
               paragraphSpaceStyle:(CGFloat)paragraphSpacing
                    lineBreakStyle:(CTLineBreakMode)lineBreakMode;

- (void)addAttributeAlignmentStyle:(CTTextAlignment)textAlignment
                    lineSpaceStyle:(CGFloat)linesSpacing
               paragraphSpaceStyle:(CGFloat)paragraphSpacing
                    lineBreakStyle:(CTLineBreakMode)lineBreakMode
                             range:(NSRange)range;

@end
