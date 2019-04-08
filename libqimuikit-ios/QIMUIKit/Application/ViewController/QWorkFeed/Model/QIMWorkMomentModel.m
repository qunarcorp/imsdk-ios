//
//  QIMWorkMomentModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/2.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentModel.h"
#import "QIMWorkMomentContentModel.h"

@implementation QIMWorkMomentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"rId": @"id",
             @"momentId" : @"uuid",
             @"ownerId":@"owner"
             };
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end
