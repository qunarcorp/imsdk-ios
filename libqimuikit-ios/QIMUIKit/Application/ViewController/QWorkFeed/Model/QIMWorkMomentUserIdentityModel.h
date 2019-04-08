//
//  QIMWorkMomentUserIdentityModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentUserIdentityModel : NSObject

@property (nonatomic, assign) BOOL isAnonymous; //是否匿名发布

@property (nonatomic, assign) NSInteger anonymousId;  //匿名Id

@property (nonatomic, copy) NSString *anonymousName;   //匿名名称

@property (nonatomic, copy) NSString *anonymousPhoto;   //匿名头像

@end

@interface QIMWorkMomentUserIdentityManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL isAnonymous;         //是否匿名发布

@property (nonatomic, assign) NSInteger anonymousId;      //匿名Id

@property (nonatomic, copy) NSString *anonymousName;    //匿名名称

@property (nonatomic, copy) NSString *anonymousPhoto;   //匿名头像

@end

NS_ASSUME_NONNULL_END
