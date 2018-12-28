//
//  QIMCustomPopManager.h
//  QIMUIVendorKit
//
//  Created by 李露 on 11/7/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface QIMCustomPopManager : NSObject

+ (void)showPopVC:(UIViewController *)popVc withRootVC:(UIViewController *)rootVc;

@end

NS_ASSUME_NONNULL_END
