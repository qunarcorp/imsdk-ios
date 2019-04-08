//
//  QIMAppWindowManager.h
//  QIMUIKit
//
//  Created by 李露 on 2018/6/13.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QIMAppWindowManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) UIWindow *advertWindow;

@end
