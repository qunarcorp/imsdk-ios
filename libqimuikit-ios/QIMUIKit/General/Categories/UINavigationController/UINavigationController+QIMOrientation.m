//
//  UINavigationController+QIMOrientation.m
//  QIMUIKit
//
//  Created by 李露 on 2018/9/3.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "UINavigationController+QIMOrientation.h"

@implementation UINavigationController (QIMOrientation)

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

@end
