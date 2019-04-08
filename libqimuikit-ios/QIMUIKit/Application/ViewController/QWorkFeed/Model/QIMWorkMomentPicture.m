//
//  QIMWorkMomentPicture.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentPicture.h"

@implementation QIMWorkMomentPicture

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"imageUrl": @"data",
             @"imageWidth" : @"width",
             @"imageHeight":@"height"
             };
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}


@end
