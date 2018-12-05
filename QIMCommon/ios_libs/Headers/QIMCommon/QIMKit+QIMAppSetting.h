//
//  QIMKit+QIMAppSetting.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMAppSetting)

/**
 判断是否为第一次安装
 */
- (BOOL)isFirstLauched;

/**
 设置当前App环境配置
 */
+ (void)setAppConfigurationMode:(QIMAppConfigurationMode)mode;


/**
 获取当前App环境配置
 */
+ (QIMAppConfigurationMode)getCurrentAppConfigurationMode;

/**
 判断是否为Debug模式
 */
- (BOOL)debugMode;

/**
 获取当前系统语言
 */
- (NSString *)currentLanguage;

/**
 设置高德地图的Key
 */
- (void)setGAODE_APIKEY:(NSString *)key;

/**
 获取高德地图的Key
 */
- (NSString *)getGAODE_APIKEY;

@end
