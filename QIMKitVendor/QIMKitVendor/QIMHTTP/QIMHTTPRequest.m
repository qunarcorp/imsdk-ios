//
//  QIMHTTPRequest.m
//  QIMKitVendor
//
//  Created by QIM on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMHTTPRequest.h"

@implementation QIMHTTPRequest

- (instancetype)initWithURL:(NSURL *)url{
    if (self = [super init]) {
        _url = url;
        _timeoutInterval = 10;
        _HTTPMethod = QIMHTTPMethodGET;
    }
    return self;
}

+ (instancetype)requestWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

@end
