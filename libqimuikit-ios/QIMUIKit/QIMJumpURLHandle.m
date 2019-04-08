//
//  QIMJumpURLHandle.m
//  qunarChatIphone
//
//  Created by admin on 15/8/13.
//
//

#import "QIMJumpURLHandle.h"
#import "QIMCommonUIFramework.h"
#import "UIApplication+QIMApplication.h"
#import "QIMGroupCardVC.h"
#import "QIMWebView.h"
#import "QIMPublicNumberRobotVC.h"
#import "QIMPublicNumberCardVC.h"
#import "QIMQRCodeLoginVC.h"
#import "QIMQRCodeLoginManager.h"

@implementation QIMJumpURLHandle

+ (BOOL)parseURL:(NSURL *)url{
    if ([url.scheme.lowercaseString isEqualToString:@"qtalk"]) {
        NSString *host = [url host];
        NSDictionary *dictionaryQuery = [[url query] qim_dictionaryFromQueryComponents];
        if ([host.lowercaseString isEqualToString:@"group"]) {
            NSString *groupId = [dictionaryQuery objectForKey:@"id"];
            id nav = [[UIApplication sharedApplication] visibleNavigationController];
            if (groupId.length > 0) {
                QIMGroupCardVC *GVC = [[QIMGroupCardVC alloc] init];
                GVC.groupId = groupId;
                [nav popToRootVCThenPush:GVC animated:YES];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法识别该信息。" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [alertView show];
            }
        } else if ([host.lowercaseString isEqualToString:@"user"]){
            id nav = [[UIApplication sharedApplication] visibleNavigationController];
            NSString *userId = [dictionaryQuery objectForKey:@"id"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [QIMFastEntrance openUserCardVCByUserId:userId];
            });
        } else if ([host.lowercaseString isEqualToString:@"robot"]){
            id nav = [[UIApplication sharedApplication] visibleNavigationController];
            if ([nav isKindOfClass:[QIMNavController class]]) {
                NSString *publicNumberId = [dictionaryQuery objectForKey:@"id"];
                NSString *publicNumberType = [dictionaryQuery objectForKey:@"type"];
                NSString *content = [dictionaryQuery objectForKey:@"content"];
                NSString *msgType = [dictionaryQuery objectForKey:@"msgType"];
                if([publicNumberType.lowercaseString isEqualToString:@"robot"]){
                    NSDictionary *cardDic =
                    [[QIMKit sharedInstance] getPublicNumberCardByJId:[NSString stringWithFormat:@"%@@%@",publicNumberId,[[QIMKit sharedInstance] getDomain]]];
                    if (cardDic.count > 0) {
                        QIMPublicNumberRobotVC *robotVC = [[QIMPublicNumberRobotVC alloc] init];
                        [robotVC setRobotJId:[cardDic objectForKey:@"XmppId"]];
                        [robotVC setPublicNumberId:publicNumberId];
                        [robotVC setName:[cardDic objectForKey:@"Name"]];
                        [robotVC setTitle:robotVC.name];
                        [nav popToRootVCThenPush:robotVC animated:YES];
                        if (content.length > 0) {
                            if ([msgType isEqualToString:@"action"]) {
                                [robotVC sendMessage:content WithInfo:nil ForMsgType:PublicNumberMsgType_Action];
                            } else {
                                [robotVC sendMessage:content WithInfo:nil ForMsgType:PublicNumberMsgType_Text];
                            }
                        }
                    } else {
                        QIMPublicNumberCardVC *cardVC = [[QIMPublicNumberCardVC alloc] init];
                        [cardVC setJid:[NSString stringWithFormat:@"%@@%@",publicNumberId,[[QIMKit sharedInstance] getDomain]]];
                        [cardVC setPublicNumberId:publicNumberId];
                        [cardVC setNotConcern:YES];
                        [nav popToRootVCThenPush:cardVC animated:YES];
                    }
                } 
            }
        }
    } else if ([url.scheme.lowercaseString isEqualToString:@"qimlogin"]) {
//        qimlogin://qrcodelogin?k=55D5492202ABEE3D491D9B43254146CF&v=1.0&p=wiki&type=wiki
        NSString *qdrcodeLoginHost = [url host];
        NSDictionary *qdrcodeLoginQuery = [[url query] qim_dictionaryFromQueryComponents];
        if ([qdrcodeLoginHost.lowercaseString isEqualToString:@"qrcodelogin"]) {
            NSString *loginKey = [qdrcodeLoginQuery objectForKey:@"k"]; //登录验证的key
            NSString *loginVersion = [qdrcodeLoginQuery objectForKey:@"v"]; //登录的版本号
            NSString *loginplatForm = [qdrcodeLoginQuery objectForKey:@"p"]; //登录的平台
            NSString *loginType = [qdrcodeLoginQuery objectForKey:@"type"];     //登录平台的类型
            NSString *loginPlatIcon = [qdrcodeLoginQuery objectForKey:@"iconurl"];  //登录平台的icon
            if (loginKey && loginVersion && loginplatForm) {
                id nav = [[UIApplication sharedApplication] visibleNavigationController];
                QIMQRCodeLoginVC *qrcodeLoginVc = [[QIMQRCodeLoginVC alloc] init];
                if (loginType.length > 0) {
                    qrcodeLoginVc.platForm = [NSString stringWithFormat:@"%@ ", loginType];
                } else {
                    qrcodeLoginVc.platForm = [NSString stringWithFormat:@"%@ ", [QIMKit getQIMProjectTitleName]];
                }
                if (loginType.length > 0) {
                    qrcodeLoginVc.type = loginType;
                }
                if (loginPlatIcon.length > 0) {
                    qrcodeLoginVc.iconUrl = loginPlatIcon;
                }
                QIMNavController *qrcodeLoginNav = [[QIMNavController alloc] initWithRootViewController:qrcodeLoginVc];
                [nav presentViewController:qrcodeLoginNav animated:YES completion:nil];
                [[QIMQRCodeLoginManager shareQIMQRCodeLoginManagerWithKey:loginKey WithType:loginType] confirmQRCodeAction];
            }
        }
    } else if ([url.scheme.lowercaseString isEqualToString:@"qpr"]) {
#if defined (QIMOPSRNEnable) && QIMOPSRNEnable == 1
        UIViewController *reactVC = nil;
        Class RunC = NSClassFromString(@"RNSchemaParse");
        SEL sel = NSSelectorFromString(@"handleOpsasppSchema:");
        UIViewController *vc = nil;
        if ([RunC respondsToSelector:sel]) {
            reactVC = [RunC performSelector:sel withObject:url];
        }
        if (reactVC != nil) {
            id nav = [[UIApplication sharedApplication] visibleNavigationController];
            [nav pushViewController:reactVC animated:YES];
        }
#endif
    }
    return YES;
}

+ (void)decodeQCodeStr:(NSString *)str {
    id nav = [[UIApplication sharedApplication] visibleNavigationController];
    if ([str qim_hasPrefixHttpHeader]) {
        QIMWebView *webVC = [[QIMWebView alloc] init];
        [webVC setUrl:str];
        [nav popToRootVCThenPush:webVC animated:YES];
    } else {
        NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if (url) {
            if ([url.scheme.lowercaseString isEqualToString:@"qtalk"] || [url.scheme.lowercaseString isEqualToString:@"qimlogin"] || [url.scheme.lowercaseString isEqualToString:@"qpr"]) {
                [QIMJumpURLHandle parseURL:url];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        } else {
            NSString *subString = [str substringWithRange:NSMakeRange(0, 7)];
            if ([subString isEqualToString:@"GroupId"]) {
                NSString *sub = [str substringFromIndex:8];
                NSDictionary *groupCardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:sub];
                if (groupCardDic) {
                    QIMGroupCardVC *GVC = [[QIMGroupCardVC alloc] init];
                    GVC.groupId = sub;
                    [nav popToRootVCThenPush:GVC animated:YES];
                }
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
    QIMVerboseLog(@"扫描后的结果~%@",str);
}

@end
