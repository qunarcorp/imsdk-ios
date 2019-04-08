//
//  UIColor+QIMUtility.h
//
//

#import <UIKit/UIKit.h>

@interface UIColor (QIMUtility)

+ (UIColor *)qim_colorWithHexString:(NSString *)hexString;
+ (UIColor *)qim_colorWithHex:(NSUInteger)hex;
+ (UIColor *)qim_colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha;

//! 系统按钮及文字Label蓝色 色值：0x007aff
+ (UIColor *)systemBlueColor;
//! iPhone 4.2版本后使用，按钮和部分Label蓝色 色值：0x1ba9ba
+ (UIColor *)qunarBlueColor;

//! iPhone 4.2版本后使用，按钮点击态蓝色 色值：0x168795
+ (UIColor *)qunarBlueHighlightColor;

//! iPhone 4.2版本后使用，按钮红色 色值：0xff4500
+ (UIColor *)qunarRedColor;

//! iPhone 4.2版本后使用，按钮点击态红色 色值：0xbe3300
+ (UIColor *)qunarRedHighlightColor;

//! iPhone 4.2版本后使用，灰色 色值：0xff3300
+ (UIColor *)qunarTextRedColor;

//! iPhone 4.2版本后使用，黑色 色值：0x333333
+ (UIColor *)qunarTextBlackColor;

//! iPhone 4.2版本后使用，灰色 色值：0x888888
+ (UIColor *)qunarTextGrayColor;

//! iPhone 4.2版本后使用，边线框颜色 色值：0xc7ced4
+ (UIColor *)qunarGrayColor;

//! iPhone 4.2版本后使用，强提示黄色 色值：0xf8facd
+ (UIColor *)warningYellowColor;


//! 浅色配色方案
+ (UIColor *)spectralColorWhiteColor;       //白
+ (UIColor *)spectralColorLightColor;       //暗白
+ (UIColor *)spectralColorGrayDarkColor;    //暗灰
+ (UIColor *)spectralColorGrayColor;        //灰
+ (UIColor *)spectralColorGrayBlueColor;    //蓝灰
+ (UIColor *)spectralColorDarkBlueColor;    //深蓝
+ (UIColor *)spectralColorBlueColor;        //蓝
+ (UIColor *)spectralColorLightBlueColor;   //浅蓝

//分割线颜色
+ (UIColor *)qtalkSplitLineColor;
+ (UIColor *)qtalkTableDefaultColor;
+ (UIColor *)qtalkTextBlackColor;
+ (UIColor *)qtalkTextLightColor;
+ (UIColor *)qtalkReplyUserNameColor;
+ (UIColor *)qtalkTextSelectedColor;


//绿色系 新版 qtalk 配色
+ (UIColor *)qtalkIconNomalColor;
+ (UIColor *)qtalkIconSelectColor;

+ (UIColor *)qtalkChatBgColor;

@end
