
//
//  QtalkPlugin.m
//  QIMUIKit
//
//  Created by QIM on 11/13/18.
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

@end
