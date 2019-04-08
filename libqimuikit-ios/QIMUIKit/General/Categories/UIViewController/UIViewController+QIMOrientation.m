//
//  UIViewController+QIMOrientation.m
//  QIMUIKit
//
//  Created by 李露 on 2018/9/1.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "UIViewController+QIMOrientation.h"

@implementation UIViewController (QIMOrientation)

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

@end
