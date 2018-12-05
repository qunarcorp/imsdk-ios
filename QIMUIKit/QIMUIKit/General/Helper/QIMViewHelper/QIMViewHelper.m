//
//  QIMViewHelper.m
//  qunarChatIphone
//
//  Created by c on 15/5/6.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMViewHelper.h"

@implementation QIMViewHelper

#pragma mark - 登录页

//设置view圆角
+(void)setRadiusToView:(UIView *)view{
    [view.layer setBorderColor:[UIColor clearColor].CGColor];
    [view.layer setCornerRadius:3.0f];
    view.clipsToBounds = YES;
}

//设置textfield左侧留白
+(void)setTextFieldLeftView:(UITextField *)textField{
    [textField setLeftView:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 0)]];
    [textField setLeftViewMode:UITextFieldViewModeAlways];
}

@end
