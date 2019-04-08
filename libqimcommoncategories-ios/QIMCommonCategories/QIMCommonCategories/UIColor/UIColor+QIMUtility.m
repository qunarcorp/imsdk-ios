//
//  UIColor+QIMUtility.m
//
//

#import "UIColor+QIMUtility.h"

@implementation UIColor (QIMUtility)

+ (UIColor *)qim_colorWithHexString:(NSString *)hexString {
    unsigned long colorHex = strtoul([hexString UTF8String], 0, 16);
    return [self qim_colorWithHex:colorHex];
}

+ (UIColor *)qim_colorWithHex:(NSUInteger)hex {
    NSUInteger a = 0xFF;
    if (hex > 0xFFFFFF) {
        a = (hex >> 24) & 0xFF;
    }
    NSUInteger r = (hex >> 16) & 0xFF;
    NSUInteger g = (hex >> 8 ) & 0xFF;
    NSUInteger b = hex & 0xFF;
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:a / 255.0f];
}

+ (UIColor *)qim_colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hexValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alpha];
}

+ (UIColor *)systemBlueColor {
    return [UIColor qim_colorWithHex:0x007aff alpha:1.0];
}

+ (UIColor *)qunarBlueColor
{
    return [UIColor qim_colorWithHex:0x1ba9ba alpha:1.0];
}

+ (UIColor *)qunarBlueHighlightColor
{
    return [UIColor qim_colorWithHex:0x168795 alpha:1.0];
}

+ (UIColor *)qunarRedColor
{
    return [UIColor qim_colorWithHex:0xff4500 alpha:1.0];
}

+ (UIColor *)qunarRedHighlightColor
{
    return [UIColor qim_colorWithHex:0xbe3300 alpha:1.0];
}

+ (UIColor *)qunarTextRedColor
{
    return [UIColor qim_colorWithHex:0xff3300 alpha:1.0];
}

+ (UIColor *)qunarTextBlackColor
{
    return [UIColor qim_colorWithHex:0x333333 alpha:1.0];
}

+ (UIColor *)qunarTextGrayColor
{
    return [UIColor qim_colorWithHex:0x888888 alpha:1.0];
}

+ (UIColor *)qunarGrayColor
{
    return [UIColor qim_colorWithHex:0xc7ced4 alpha:1.0];
}

+ (UIColor *)warningYellowColor
{
    return [UIColor qim_colorWithHex:0xf8facd alpha:1.0];
}

//! 浅色配色方案
//白
+ (UIColor *)spectralColorWhiteColor
{
    return [UIColor qim_colorWithHex:0xFFFFFF alpha:1.0];
}

//暗白
+ (UIColor *)spectralColorLightColor
{
    return [UIColor qim_colorWithHex:0xF2F1F8 alpha:1.0];
}

//暗灰
+ (UIColor *)spectralColorGrayDarkColor
{
    return [UIColor qim_colorWithHex:0x333333 alpha:1];
}

//灰
+ (UIColor *)spectralColorGrayColor
{
    return [UIColor qim_colorWithHex:0xDBE0E6 alpha:1.0];
}

//蓝灰
+ (UIColor *)spectralColorGrayBlueColor
{
    return [UIColor qim_colorWithHex:0x597A96 alpha:1.0];
}

//深蓝
+ (UIColor *)spectralColorDarkBlueColor
{
    return [UIColor qim_colorWithHex:0x275482 alpha:1.0];
}

//蓝
+ (UIColor *)spectralColorBlueColor
{ //0x129FDD
    return [UIColor qim_colorWithHex:0x29b8e7 alpha:1.0];
}

//浅蓝
+ (UIColor *)spectralColorLightBlueColor{
    return [UIColor qim_colorWithHex:0x90d9ed alpha:1.0];
}

//分割线颜色
+ (UIColor *)qtalkSplitLineColor{
    return [UIColor qim_colorWithHex:0xd1d1d1 alpha:1];
}

+ (UIColor *)qtalkTableDefaultColor{
    return [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0];
}

+ (UIColor *)qtalkTextBlackColor{
    return [UIColor qim_colorWithHex:0x212121 alpha:1.0];
}

+ (UIColor *)qtalkTextLightColor{
    return [UIColor qim_colorWithHex:0x9e9e9e alpha:1];
}

+ (UIColor *)qtalkReplyUserNameColor
{
    return [UIColor qim_colorWithHex:0x5c6c96 alpha:1.0];
}

+ (UIColor *)qtalkTextSelectedColor{
    return [UIColor blueColor];
}

//绿色系 相关颜色
+ (UIColor *)qtalkIconNomalColor{
    return [UIColor qim_colorWithHex:0xa9b7b7 alpha:1.0];
}

+ (UIColor *)qtalkIconSelectColor{
    return [UIColor qim_colorWithHex:0x11cd6e alpha:1.0];
}

+ (UIColor *)qtalkChatBgColor{
    return [UIColor qim_colorWithHex:0xf4f4f4 alpha:1.0];
}

@end
