//
//  QIMLoginViewController.h
//  qunarChatIphone
//
//  Created by ping.xue on 14-3-4.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMLoginViewController : QTalkViewController

@property (nonatomic, strong) IBOutlet  UIView      *dashLineView;          //虚线
@property (nonatomic, strong) IBOutlet  UITextField *usernameTextField;     //用户名
@property (nonatomic, strong) IBOutlet  UITextField *passwordTextField;     //密码
@property (nonatomic, strong) IBOutlet  UIButton    *loginButton;           //登录按钮
@property (nonatomic, strong) IBOutlet  UIButton    *registerButton;        //登录按钮

@property(nonatomic,readwrite,retain) NSString * linkUrl;

//登录
-(IBAction)login:(id)sender;


//注册
-(IBAction)registerUser:(id)sender;

@end
