//
//  UINavigationController+QIMOrientation.h
//  QIMUIKit
//
//  Created by 李露 on 2018/9/3.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface UINavigationController (QIMOrientation)

- (BOOL)shouldAutorotate;

- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
