//
//  QIMDeviceManager.h
//  QIMUIKit
//
//  Created by 李露 on 10/10/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMDeviceManager : NSObject

+ (instancetype)sharedInstance;

- (CGFloat)getHOME_INDICATOR_HEIGHT;

- (CGFloat)getTAB_BAR_HEIGHT;

- (CGFloat)getNAVIGATION_BAR_HEIGHT;

- (CGFloat)getSTATUS_BAR_HEIGHT;

@end

NS_ASSUME_NONNULL_END
