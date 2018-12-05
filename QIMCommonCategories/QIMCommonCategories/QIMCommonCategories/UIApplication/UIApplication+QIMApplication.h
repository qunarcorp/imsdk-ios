//
//  UIApplication+QIMApplication.h
//  QIMCommonCategories
//
//  Created by QIM on 2018/9/16.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (QIMApplication)

- (UIWindow *)mainWindow;

- (UINavigationController *)visibleNavigationController;

- (UIViewController *)visibleViewController;

//逐层遍历，获取当前所在控制器
- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc;

@end
