//
//  QTPHImagePickerManager.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/6.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QTPHImagePickerManager.h"

@implementation QTPHImagePickerManager

static QTPHImagePickerManager *__imagePickerManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __imagePickerManager = [[QTPHImagePickerManager alloc] init];
        __imagePickerManager.maximumNumberOfSelection = 9;
    });
    return __imagePickerManager;
}

@end
