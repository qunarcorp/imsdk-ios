//
//  QTPHImagePickerManager.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/6.
//  Copyright © 2019 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QTPHImagePickerManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) NSInteger maximumNumberOfSelection;

@property (nonatomic, assign) BOOL notAllowSelectVideo;

@end

NS_ASSUME_NONNULL_END
