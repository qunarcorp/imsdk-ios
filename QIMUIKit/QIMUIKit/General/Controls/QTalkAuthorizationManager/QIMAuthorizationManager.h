//
//  QTalkPermissionManager.h
//  Noob2017
//
//  Created by lihuaqi on 2017/9/11.
//  Copyright © 2017年 lihuaqi. All rights reserved.
//

#import "QIMCommonUIFramework.h"
/**
 *  用户权限类型.
 */
typedef enum {
    ENUM_QAM_AuthorizationTypePhotos = 0,//相册权限
    ENUM_QAM_AuthorizationTypeCamera,//相机
    ENUM_QAM_AuthorizationTypeLocation,//定位
    ENUM_QAM_AuthorizationTypePush//推送
} ENUM_QAM_AuthorizationType;

/**
 *  用户权限状态.
 */
typedef enum {
    ENUM_QAM_AuthorizationStatusDenied = 0,//不允许
    ENUM_QAM_AuthorizationStatusAuthorized,//允许
    ENUM_QAM_AuthorizationStatusNotDetermined//没有做出选择
} ENUM_QAM_AuthorizationStatus;


/**
 *  用户授权回调.
 */
typedef void (^AuthorizedBlock)();

@interface QIMAuthorizationManager : NSObject

/**
 *  严格单例，唯一获得实例的方法.
 *
 *  @return 用户权限管理类.
 */
+ (instancetype)sharedManager;

@property (nonatomic, copy) AuthorizedBlock authorizedBlock;

//获取用户全部授权状态.
@property (nonatomic, strong) NSMutableDictionary *authorizationStatus;

//请求用户授权.
- (void)requestAuthorizationWithType:(ENUM_QAM_AuthorizationType )authorizationType;
@end

