//
//  QIMHTTPClient.h
//  QIMKitVendor
//
//  Created by QIM on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMHTTPRequest.h"

@interface QIMHTTPClient : NSObject

+ (void)sendRequest:(QIMHTTPRequest *)request
           complete:(QIMCompleteHandler)completeHandler
            failure:(QIMFailureHandler)failureHandler;

@end
