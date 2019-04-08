//
//  QIMHTTPRequest.h
//  QIMKitVendor
//
//  Created by 李露 on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMHTTPUploadComponent.h"
#import "QIMHTTPResponse.h"

typedef enum : NSUInteger {
    QIMHTTPMethodGET = 0,
    QIMHTTPMethodPOST,
} QIMHTTPMethod;

typedef void(^QIMCompleteHandler)(QIMHTTPResponse *response);
typedef void(^QIMFailureHandler)(NSError *error);
typedef void(^QIMProgressHandler)(float progressValue);

@interface QIMHTTPRequest : NSObject

/**
 请求的url,若为GET请求，直接在url后面拼接参数。
 */
@property (nonatomic, copy) NSURL *url;
@property (nonatomic) NSTimeInterval timeoutInterval;
/**
 http请求头
 */
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *HTTPRequestHeaders;
/**
 http请求参数,GET请求会拼接到url后面，POST请求会拼接到body里面。若为GET请求，不要在此设置值。
 */
@property (nonatomic, strong) NSDictionary *postParams;
/**
 上传文件需要的数据，不需要设置此项。
 */
@property (nonatomic, strong) NSArray <QIMHTTPUploadComponent *> *uploadComponents;
/**
 defaut is NO,不对证书做校验
 */
@property (nonatomic) BOOL validatesSecureCertificate;
/*!
 @abstract Sets the HTTP request method of the receiver. POST or GET,default is GET.
 */
@property (nonatomic) QIMHTTPMethod HTTPMethod;

@property (nonatomic, strong) NSData *HTTPBody;

@property (assign) BOOL useCookiePersistence;
/**
 default is YES,不做同步请求
 */
@property (nonatomic) BOOL shouldASynchronous;
/**
 下载文件存储的目标路径，要精确到文件名，在设定之前，需要在外部判定文件是否存在，是否需要删除。
 */
@property (nonatomic, copy) NSString *downloadDestinationPath;
/**
 下载文件存储的临时路径,如果下载时不设定此项，会有默认的临时路径。
 */
@property (nonatomic, copy) NSString *downloadTemporaryPath;

- (instancetype)initWithURL:(NSURL *)url;

+ (instancetype)requestWithURL:(NSURL *)url;

@end
