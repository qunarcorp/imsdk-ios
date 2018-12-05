//
//  UserLocationViewController.h
//  Category_demo
//
//  Created by songjian on 13-3-21.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"
#import "QIMMsgBaseVC.h"
#import "QIMCommonUIFramework.h"

@class MapAdressInfo;
@class UserLocationViewController;
@protocol UserLocationViewControllerDelegate <NSObject>

- (void)UserLocationViewController:(UserLocationViewController *)mapVC shouldSendAdressInfo:(MapAdressInfo *)adressInfo;

@end

@interface UserLocationViewController : BaseMapViewController

@property (nonatomic,copy)NSString      * dispalyAdr;
@property (nonatomic,copy)NSString      * dispalyName;

@property (weak,nonatomic) id<UserLocationViewControllerDelegate,QIMMsgBaseVCDelegate> delegate;

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;


@end
