//
//  QIMMWQRCodeActivity.m
//  QIMUIKit
//
//  Created by 李露 on 2018/6/27.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMMWQRCodeActivity.h"
#import "ZBarReaderController.h"
#import "QIMWebView.h"
#import "UIApplication+QIMApplication.h"
#import "QIMJumpURLHandle.h"
#import "QIMGroupCardVC.h"

@interface QIMMWQRCodeActivity() <ZBarReaderDelegate>{
    ZBarSymbol *_symbol;
}

@end

@implementation QIMMWQRCodeActivity

+ (instancetype)sharedInstance {
    static QIMMWQRCodeActivity *_qrCodeActivity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qrCodeActivity = [[QIMMWQRCodeActivity alloc] init];
    });
    return _qrCodeActivity;
}

- (void)decodeImage:(UIImage *)image{
    
    ZBarReaderController* read = [ZBarReaderController new];
    
    read.readerDelegate = self;
    
    CGImageRef cgImageRef = image.CGImage;
    
    for(_symbol in [read scanImage:cgImageRef])break;
}

- (BOOL)canPerformQRCodeWithImage:(UIImage *)image {
    if ([image isKindOfClass:[UIImage class]]) {
        [self decodeImage:image];
        if (_symbol) {
            return YES;
        }
    }
    return NO;
}

- (void)performActivity {
    
    [self.fromPhotoBrowser dismissViewControllerAnimated:NO completion:^{
        NSString *str = _symbol.data;
//        QIMNavController *rootNav = (QIMNavController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        UINavigationController *rootNav = [[UIApplication sharedApplication] visibleNavigationController];
        if ([str qim_hasPrefixHttpHeader]) {
            QIMWebView *webVC = [[QIMWebView alloc] init];
            [webVC setUrl:str];
            [rootNav pushViewController:webVC animated:YES];
        } else {
            NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if (url) {
                if ([url.scheme.lowercaseString isEqualToString:@"qtalk"]) {
                    [QIMJumpURLHandle parseURL:url];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            } else {
                NSString *subString = [str substringWithRange:NSMakeRange(0, 7)];
                if ([subString isEqualToString:@"GroupId"]) {
                    NSString *sub = [str substringFromIndex:8];
                    QIMGroupCardVC *GVC = [[QIMGroupCardVC alloc] init];
                    GVC.groupId = sub;
                    [rootNav pushViewController:GVC animated:YES];
                } else if ([subString isEqualToString:@"MuserId"]) {
                    NSString *sub = [str substringFromIndex:8];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [QIMFastEntrance openUserCardVCByUserId:sub];
                    });
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"结果：%@",str]delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                }
            }
        }
    }];
}

@end
