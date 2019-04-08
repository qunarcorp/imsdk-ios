//
//  QIMWorkCommentModel.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/15.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkCommentModel.h"

@implementation QIMWorkCommentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"rId": @"id"
             };
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end
