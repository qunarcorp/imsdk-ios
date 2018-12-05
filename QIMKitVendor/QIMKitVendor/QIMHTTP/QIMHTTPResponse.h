//
//  QIMHTTPResponse.h
//  QIMKitVendor
//
//  Created by QIM on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMHTTPResponse : NSObject

@property (nonatomic) NSInteger code;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *responseString;

@end
