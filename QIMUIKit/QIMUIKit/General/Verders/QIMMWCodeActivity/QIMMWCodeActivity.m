//
//  MWActivity.m
//  qunarChatIphone
//
//  Created by admin on 15/8/17.
//
//

#import "QIMMWCodeActivity.h"
#import "ZBarReaderController.h"
#import "QIMWebView.h"
#import "QIMJumpURLHandle.h"
#import "QIMGroupCardVC.h"
#import "UIApplication+QIMApplication.h"

static NSString * const HIPMustachifyActivityType = @"com.qtalk.activity.QRCode";

@interface QIMMWCodeActivity()<ZBarReaderDelegate>{
    ZBarSymbol *_symbol;
}

@end

@implementation QIMMWCodeActivity
#pragma mark - UIActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return HIPMustachifyActivityType;
}

- (NSString *)activityTitle {
    return @"二维码";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"QRCode"];
}

- (void)decodeImage:(UIImage *)image{
    
    ZBarReaderController* read = [ZBarReaderController new];
    
    read.readerDelegate = self;
    
    CGImageRef cgImageRef = image.CGImage;
    
    for(_symbol in [read scanImage:cgImageRef])break;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            [self decodeImage:item];
            if (_symbol) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {

}

- (UIViewController *)activityViewController{
    return nil;
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
