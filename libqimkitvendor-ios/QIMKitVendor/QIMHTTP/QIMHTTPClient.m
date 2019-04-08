//
//  QIMHTTPClient.m
//  QIMKitVendor
//
//  Created by 李露 on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMHTTPClient.h"
#import "QIMHTTPResponse.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "QIMJSONSerializer.h"
#import "QIMWatchDog.h"
#import "QIMPublicRedefineHeader.h"

static NSString *baseUrl = nil;

@implementation QIMHTTPClient

+ (NSString *)baseUrl {
    return baseUrl;
}

+ (void)configBaseUrl:(NSString *)httpBaseurl {
    if (httpBaseurl.length > 0) {
        baseUrl = httpBaseurl;
    }
}

+ (void)sendRequestWithUrl:(NSString * _Nonnull)url requesetMethod:(QIMHTTPMethod)method requestBody:(id)httpBody requestHeaders:(NSDictionary <NSString *, NSString *> *)httpHeaders complete:(QIMCompleteHandler)completeHandler failure:(QIMFailureHandler)failureHandler {
    
}

+ (void)sendRequest:(QIMHTTPRequest *)request complete:(QIMCompleteHandler)completeHandler failure:(QIMFailureHandler)failureHandler {
    if (request.uploadComponents.count > 0 || request.postParams || request.HTTPBody) {
        request.HTTPMethod = QIMHTTPMethodPOST;
    }
    if (request.HTTPMethod == QIMHTTPMethodGET) {
        [QIMHTTPClient getMethodRequest:request complete:completeHandler failure:failureHandler];
    } else if (request.HTTPMethod == QIMHTTPMethodPOST) {
        [QIMHTTPClient postMethodRequest:request complete:completeHandler failure:failureHandler];
    } else {
        
    }
}

+ (void)getMethodRequest:(QIMHTTPRequest *)request
                complete:(QIMCompleteHandler)completeHandler
                 failure:(QIMFailureHandler)failureHandler {
    ASIHTTPRequest *asiRequest = [ASIHTTPRequest requestWithURL:request.url];
    [asiRequest setRequestMethod:@"GET"];
    [self configureASIRequest:asiRequest QIMHTTPRequest:request complete:completeHandler failure:failureHandler];
    if (request.shouldASynchronous) {
        [asiRequest startAsynchronous];
    } else {
        [asiRequest startSynchronous];
    }
}

+ (void)postMethodRequest:(QIMHTTPRequest *)request
                 complete:(QIMCompleteHandler)completeHandler
                  failure:(QIMFailureHandler)failureHandler {
    ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:request.url];
    [asiRequest setRequestMethod:@"POST"];
    if (request.postParams) {
        for (id key in request.postParams) {
            [asiRequest setPostValue:request.postParams[key] forKey:key];
        }
    } else {
        if (request.HTTPBody) {
            id bodyStr = [[QIMJSONSerializer sharedInstance] deserializeObject:request.HTTPBody error:nil];
            QIMVerboseLog(@"QIMHTTPRequest请求Url : %@, Body :%@,", request.url, bodyStr);
            [asiRequest setPostBody:[NSMutableData dataWithData:request.HTTPBody]];
        }
    }
    if (request.uploadComponents) {
        for (NSInteger i = 0; i < request.uploadComponents.count; i++) {
            QIMHTTPUploadComponent *component = request.uploadComponents[i];
            if (component.filePath) {
                [asiRequest addFile:component.filePath withFileName:component.fileName andContentType:component.mimeType forKey:component.dataKey];
            } else if (component.data) {
                [asiRequest addData:component.data withFileName:component.fileName andContentType:component.mimeType forKey:component.dataKey];
            }
        }
    }
    [self configureASIRequest:asiRequest QIMHTTPRequest:request complete:completeHandler failure:failureHandler];
    QIMVerboseLog(@"startSynchronous获取当前线程1 :%@, %@",dispatch_get_current_queue(),  request.url);
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    if (request.shouldASynchronous) {
        [asiRequest startAsynchronous];
    } else {
        [asiRequest startSynchronous];
    }
    QIMVerboseLog(@"startSynchronous获取当前线程2 :%@,  %@, %lf", dispatch_get_current_queue(), request.url, [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
}

+ (void)configureASIRequest:(ASIHTTPRequest *)asiRequest
              QIMHTTPRequest:(QIMHTTPRequest *)request
                   complete:(QIMCompleteHandler)completeHandler
                    failure:(QIMFailureHandler)failureHandler {
    [asiRequest setNumberOfTimesToRetryOnTimeout:2];
    [asiRequest setValidatesSecureCertificate:asiRequest.validatesSecureCertificate];
    [asiRequest setTimeOutSeconds:request.timeoutInterval];
    [asiRequest setAllowResumeForFileDownloads:YES];
    if (request.HTTPRequestHeaders) {
        [asiRequest setUseCookiePersistence:NO];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:request.HTTPRequestHeaders];
        [asiRequest setRequestHeaders:dict];
    } else {
        //默认加载Cookie
        [asiRequest setUseCookiePersistence:YES];
    }
    if (request.downloadDestinationPath) { //有下载路径时，认为是下载
        [asiRequest setDownloadDestinationPath:request.downloadDestinationPath];
        [asiRequest setTemporaryFileDownloadPath:request.downloadTemporaryPath];
    }
    __weak typeof(asiRequest) weakAsiRequest = asiRequest;
    asiRequest.completionBlock = ^{
        __strong typeof(weakAsiRequest) strongAsiRequest = weakAsiRequest;
        QIMHTTPResponse *response = [QIMHTTPResponse new];
        response.code = strongAsiRequest.responseStatusCode;
        response.data = strongAsiRequest.responseData;
        response.responseString = strongAsiRequest.responseString;
        QIMVerboseLog(@"【RequestUrl : %@\n RequestHeader : %@\n Response : %@\n", weakAsiRequest.url, weakAsiRequest.requestHeaders, response);
        if (completeHandler) {
            completeHandler(response);
        }
    };
    [asiRequest setFailedBlock:^{
        __strong typeof(weakAsiRequest) strongAsiRequest = weakAsiRequest;
        if (failureHandler) {
            QIMVerboseLog(@"Error : %@", strongAsiRequest.error);
            failureHandler(strongAsiRequest.error);
        }
    }];
}

@end
