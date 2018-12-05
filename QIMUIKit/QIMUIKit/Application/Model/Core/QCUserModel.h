//
//  QCUserModel.h
//  qunarChatIphone
//
//  Created by c on 15/5/12.
//  Copyright (c) 2015年 c. All rights reserved.
//

#import "QIMCommonUIFramework.h"

//用户性别
typedef enum{
    QCUserGenderNone,   //未设置
    QCUserGenderMale,   //男
    QCUserGenderFemale, //女
}QCUserGender;

@interface QCUserModel : NSObject

@property (nonatomic, strong) NSString       * userId;          //用户id
@property (nonatomic, strong) NSString       * rtxId;           //rtx id

@property (nonatomic, strong) NSString       * username;        //用户名
@property (nonatomic, strong) NSString       * nickname;        //昵称
//@property (nonatomic, strong) NSArray        * shotName;        //
@property (nonatomic, strong) NSString       * password;        //密码(一般不存储，登录用户存储)

@property (nonatomic, strong) NSString       * avatar;          //头像
@property (nonatomic, strong) NSString       * email;           //邮件

@property (nonatomic, assign) QCUserGender     gender;          //性别（枚举）
@property (nonatomic, strong) NSString       * genderToString;  //性别（字符串）

@property (nonatomic, assign) BOOL             isOnline;        //是否在线
@property (nonatomic, assign) NSTimeInterval   lastOnlineTime;  //最后一次在线时间

@end
