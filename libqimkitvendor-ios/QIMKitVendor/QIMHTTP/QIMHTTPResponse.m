//
//  QIMHTTPResponse.m
//  QIMKitVendor
//
//  Created by 李露 on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMHTTPResponse.h"

@implementation QIMHTTPResponse

- (NSString *)description {
    return [NSString stringWithFormat:@"\n ResponseCode : %d \n ResponseString : %@ \n ", self.code, self.responseString];
}

@end
