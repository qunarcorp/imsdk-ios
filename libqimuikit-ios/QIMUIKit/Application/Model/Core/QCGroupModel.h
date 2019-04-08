//
//  QCGroupModel.h
//  qunarChatIphone
//
//  Created by c on 15/5/12.
//  Copyright (c) 2015年 c. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@class QCUserModel;

typedef enum {
    QCGroupPermissionNone,        //未设置
    QCGroupPermissionPublic,      //公开群
    QCGroupPermissionPrivate,     //私密群
}QCGroupPermission;

@interface QCGroupModel : NSObject

@property (nonatomic, strong) NSString          * groupId;              //群Id
@property (nonatomic, strong) NSString          * groupName;            //群Name
@property (nonatomic, strong) NSString          * groupAnnouncement;    //群公告
@property (nonatomic, strong) QCUserModel       * groupAdmin;           //群🐷
@property (nonatomic, assign) QCGroupPermission   groupPermission;      //群权限

@property (nonatomic, strong) NSMutableArray    * members;              //群成员

@end
