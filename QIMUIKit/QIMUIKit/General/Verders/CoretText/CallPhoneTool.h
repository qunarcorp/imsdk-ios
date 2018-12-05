//
//  CallPhoneTool.h
//  feiliao
//
//  Created by lidong cao on 12-10-15.
//  Copyright (c) 2012年 feinno.com. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface CallPhoneTool : NSObject{
    UIWebView *_callPhoneWebView;
}

- (void)CallPhone:(NSString *)mobileNo;
+ (void)ClearCallPhoneTool;
+ (CallPhoneTool *)sharedInstance;
@end
