//
//  CallPhoneTool.m
//  feiliao
//
//  Created by lidong cao on 12-10-15.
//  Copyright (c) 2012年 feinno.com. All rights reserved.
//

#import "CallPhoneTool.h" 

static CallPhoneTool *__global_CallPhoneTool = nil;
@implementation CallPhoneTool

- (id)init{
    self = [super init];
    if (self) {
        _callPhoneWebView = [[UIWebView alloc] init];
    }
    return self;
}

- (void)dealloc{
    _callPhoneWebView = nil;
}

- (void)CallPhone:(NSString *)mobileNo{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:0"]]) {
        if ([mobileNo longLongValue]>0) {
            NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",mobileNo]];
            [_callPhoneWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"手机号不可用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            alertView = nil;
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"当前设备不能拨打电话！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        alertView = nil;
    }
}

+ (void)ClearCallPhoneTool{
    __global_CallPhoneTool = nil;
}

+ (id)sharedInstance{
    if (__global_CallPhoneTool == nil) {
        __global_CallPhoneTool = [[CallPhoneTool alloc] init];
    }
    return __global_CallPhoneTool;
}

@end
