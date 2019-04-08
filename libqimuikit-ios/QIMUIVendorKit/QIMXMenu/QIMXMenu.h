//
//  QIMXMenu.h
//  QIMXMenuDemo_ObjC
//
//  Created by 牛萌 on 15/5/6.
//  Copyright (c) 2015年 NiuMeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMXMenuItem.h"

typedef void(^QIMXMenuSelectedItem)(NSInteger index, QIMXMenuItem *item);

typedef enum {
    QIMXMenuBackgrounColorEffectSolid      = 0, //!<背景显示效果.纯色
    QIMXMenuBackgrounColorEffectGradient   = 1, //!<背景显示效果.渐变叠加
} QIMXMenuBackgrounColorEffect;

@interface QIMXMenu : NSObject

+ (void)showMenuInView:(UIView *)view fromRect:(CGRect)rect menuItems:(NSArray *)menuItems selected:(QIMXMenuSelectedItem)selectedItem;

+ (void)dismissMenu;

// 主题色
+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;

// 标题字体
+ (UIFont *)titleFont;
+ (void)setTitleFont:(UIFont *)titleFont;

// 背景效果
+ (QIMXMenuBackgrounColorEffect)backgrounColorEffect;
+ (void)setBackgrounColorEffect:(QIMXMenuBackgrounColorEffect)effect;

// 是否显示阴影
+ (BOOL)hasShadow;
+ (void)setHasShadow:(BOOL)flag;

@end
