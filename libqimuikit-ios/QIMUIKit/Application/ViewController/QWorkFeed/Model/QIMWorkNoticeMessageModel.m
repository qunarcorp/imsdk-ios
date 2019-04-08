//
//  QIMWorkNoticeMessageModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/17.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkNoticeMessageModel.h"

@implementation QIMWorkNoticeMessageModel

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end
