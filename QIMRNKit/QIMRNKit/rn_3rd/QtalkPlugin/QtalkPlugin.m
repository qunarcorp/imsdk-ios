
//
//  QtalkPlugin.m
//  QIMUIKit
//
//  Created by 李露 on 11/13/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QtalkPlugin.h"
#import "QIMFastEntrance.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>


@implementation QtalkPlugin

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(browseBigImage:(NSDictionary *)param :(RCTResponseSenderBlock)callback){
    [[QIMFastEntrance sharedInstance] browseBigHeader:param];
}

RCT_EXPORT_METHOD(openDownLoad:(NSDictionary *)param :(RCTResponseSenderBlock)callback){
    [[QIMFastEntrance sharedInstance] openQIMFilePreviewVCWithParam:param];
}

RCT_EXPORT_METHOD(openNativeWebView:(NSDictionary *)param) {
    if ([QIMFastEntrance handleOpsasppSchema:param] == NO) {
        NSString *linkUrl = [param objectForKey:@"linkurl"];
        if (linkUrl.length > 0) {
            [QIMFastEntrance openWebViewForUrl:linkUrl showNavBar:YES];
        }
    } else {

    }
}

RCT_EXPORT_METHOD(getWorkWorldItem:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    NSDictionary *momentDic = [[QIMKit sharedInstance] getLastWorkMoment];
    NSLog(@"getWorkWorldItem : %@", momentDic);
    callback(@[momentDic ? momentDic : @{}]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[QIMKit sharedInstance] getRemoteLastWorkMoment];
    });
}

RCT_EXPORT_METHOD(openWorkWorld:(NSDictionary *)param) {
    [[QIMFastEntrance sharedInstance] openWorkFeedViewController];
}

@end
