//
//  QIMFastEntrance.m
//  qunarChatIphone
//
//  Created by admin on 16/6/15.
//
//

#import "QIMFastEntrance.h"
#import "QIMCommonCategoriesPublicHeader.h"
#import "QIMCommonUIFramework.h"
#import "UIApplication+QIMApplication.h"
#import "QIMGroupCardVC.h"
#import "QIMChatVC.h"
#import "QTalkSessionView.h"
#import "QIMAdvertisingVC.h"
#import "QIMProgressHUD.h"
#import "QIMFriendNotifyViewController.h"
#import "QIMSystemVC.h"
#import "QIMGroupChatVC.h"
#import "QIMFriendListViewController.h"
#import "QIMGroupListVC.h"
#import "QIMMessageHelperVC.h"
#import "QIMPublicNumberVC.h"
#import "QIMWebView.h"
#import "QIMPublicNumberCardVC.h"
#import "QIMUserProfileViewController.h"
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
#import "QTalkNotesCategoriesVc.h"
#endif
#import <MessageUI/MFMailComposeViewController.h>
#import "QIMPublicNumberRobotVC.h"
#import "QIMFileManagerViewController.h"
#import "QIMOrganizationalVC.h"
#import "QIMZBarViewController.h"
#import "QIMJumpURLHandle.h"
#import "QIMLoginVC.h"
#import "QIMMainVC.h"
#import "QIMWebLoginVC.h"
#import "QIMQRCodeViewDisplayController.h"
#import "QIMContactSelectionViewController.h"
#import "QIMFileTransMiddleVC.h"
#if defined (QIMRNEnable) && QIMRNEnable == 1
    #import "QimRNBModule.h"
#endif
#import "QIMWatchDog.h"
#import "QIMPublicRedefineHeader.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMFilePreviewVC.h"
#import "QIMUUIDTools.h"

@interface QIMFastEntrance () <MFMailComposeViewControllerDelegate>

@end

@interface QIMFastEntrance () <QIMMWPhotoBrowserDelegate>

@property (nonatomic, strong) UINavigationController *rootNav;

@property (nonatomic, strong) UIViewController *rootVc;

@property (nonatomic, copy) NSString *browerImageUserId;

@property (nonatomic, copy) NSString *browerImageUrl;

@end

@implementation QIMFastEntrance

static QIMFastEntrance *_sharedInstance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[QIMFastEntrance alloc] init];
    });
    return _sharedInstance;
}

+ (instancetype)sharedInstanceWithRootNav:(UINavigationController *)nav rootVc:(UIViewController *)rootVc {
    QIMFastEntrance *instance = [QIMFastEntrance sharedInstance];
    instance.rootVc = rootVc;
    instance.rootNav = nav;
    QIMVerboseLog(@"sharedInstanceWithRootNav : %@, rootVc : %@, rootNav : %@", instance, rootVc, nav);
    return instance;
}

- (UINavigationController *)getQIMFastEntranceRootNav {
    QIMVerboseLog(@"getQIMFastEntranceRootNav: %@", _sharedInstance.rootNav);
    if (!self.rootNav) {
        self.rootNav = [[self getQIMFastEntranceRootVc] navigationController];
    }
    return self.rootNav;
}

- (UIViewController *)getQIMFastEntranceRootVc {
    QIMVerboseLog(@"getQIMFastEntranceRootVc: %@", _sharedInstance.rootVc);
    return self.rootVc;
}

- (void)launchMainControllerWithWindow:(UIWindow *)window {
    QIMVerboseLog(@"开始加载主界面");
    [[QIMWatchDog sharedInstance] start];
    if([[QIMKit sharedInstance] getIsIpad] && [QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
#if defined (QIMIPadEnable) && QIMIPadEnable == 1

#endif
    } else {
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {

            QIMWebLoginVC *loginVc = [[QIMWebLoginVC alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVc];
            [window setRootViewController:nav];
        } else {
            NSString *userFullJid = [[QIMKit sharedInstance] getLastJid];
            NSString * userToken = [[QIMKit sharedInstance] userObjectForKey:@"userToken"];
            if (userFullJid && userToken) {
                
                QIMMainVC *mainVc = [QIMMainVC sharedInstanceWithSkipLogin:YES];
                QIMNavController *navController = [[QIMNavController alloc] initWithRootViewController:mainVc];
                [window setRootViewController:navController];
            } else {
                QIMLoginVC *remoteVC = [[QIMLoginVC alloc] init];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                [window setRootViewController:nav];
            }
        }
    }
    QIMVerboseLog(@"加载主界面VC耗时 : %lld", [[QIMWatchDog sharedInstance] escapedTime]);
}

- (void)launchMainAdvertWindow {
    UIWindow *advertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    advertWindow.backgroundColor = [UIColor whiteColor];
    [advertWindow makeKeyAndVisible];
    QIMAdvertisingVC *vc = [[QIMAdvertisingVC alloc] init];
    QIMNavController *navVC = [[QIMNavController alloc] initWithRootViewController:vc];
    [advertWindow setRootViewController:navVC];
    [[QIMAppWindowManager sharedInstance] setAdvertWindow:advertWindow];
    NSTimeInterval nowAdTime = [NSDate timeIntervalSinceReferenceDate];
    [[QIMKit sharedInstance] setUserObject:@(nowAdTime) forKey:@"lastAdShowTime"];
}

+ (void)showMainVc {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMMainVC *mainVC = [QIMMainVC sharedInstanceWithSkipLogin:NO];
        QIMNavController *navVC = [[QIMNavController alloc] initWithRootViewController:mainVC];
        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navVC];
    });
}

- (UIView *)getQIMSessionListViewWithBaseFrame:(CGRect)frame {
    QTalkSessionView *sessionView = [[QTalkSessionView alloc] initWithFrame:frame];
    return sessionView;
}

- (void)sendMailWithRootVc:(UIViewController *)rootVc ByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:@[[NSString stringWithFormat:@"%@@qunar.com",[[userId componentsSeparatedByString:@"@"] firstObject]]]];
            [controller setSubject:[NSString stringWithFormat:@"From %@",[[QIMKit sharedInstance] getMyNickName]]];
            [controller setMessageBody:@"\r\r\r\r\r\r\r\r\r\r\r From Iphone QTalk." isHTML:NO];
            if (rootVc) {
                [rootVc presentViewController:controller animated:YES completion:nil];
            } else {
                [[[UIApplication sharedApplication] visibleViewController] presentViewController:controller animated:YES completion:nil];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先配置邮箱账户或该设备不支持发邮件！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (UIViewController *)getUserChatInfoByUserId:(NSString *)userId {
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
    }
    //打开用户名片页
    //导航返回的RNUserCardView 为YES时，默认打开RN 名片页
    if ([[QIMKit sharedInstance] getIsIpad]) {
        
    } else {
#if defined (QIMRNEnable) && QIMRNEnable == 1
        
        if ([[QIMKit sharedInstance] qimNav_RNUserCardView]) {
            return [QimRNBModule getVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:[QimRNBModule getInnerBundleName] WithModule:@"UserCard" WithProperties:@{@"UserId":userId, @"Screen":@"ChatInfo", @"RealJid":userId, @"HeaderUri":@"33"}];
        } else {
#endif
            QIMUserProfileViewController *userProfileVc = [[QIMUserProfileViewController alloc] init];
            userProfileVc.userId = userId;
            return userProfileVc;
#if defined (QIMRNEnable) && QIMRNEnable == 1
        }
#endif
    }
    return nil;
}

+ (void)openUserChatInfoByUserId:(NSString *)userId {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        //打开用户名片页
        //导航返回的RNUserCardView 为YES时，默认打开RN 名片页
        if ([[QIMKit sharedInstance] getIsIpad]) {
            
        } else {
#if defined (QIMRNEnable) && QIMRNEnable == 1
            
            if ([[QIMKit sharedInstance] qimNav_RNUserCardView]) {
                [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:[QimRNBModule getInnerBundleName] WithModule:@"UserCard" WithProperties:@{@"UserId":userId, @"Screen":@"ChatInfo", @"RealJid":userId, @"HeaderUri":@"33"}];
            } else {
#endif
                QIMUserProfileViewController *userProfileVc = [[QIMUserProfileViewController alloc] init];
                userProfileVc.userId = userId;
                [navVC pushViewController:userProfileVc animated:YES];
#if defined (QIMRNEnable) && QIMRNEnable == 1
            }
#endif
        }
    });
}

- (UIViewController *)getUserCardVCByUserId:(NSString *)userId {
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
    }
    //打开用户名片页
    //导航返回的RNUserCardView 为YES时，默认打开RN 名片页
    if ([[QIMKit sharedInstance] getIsIpad]) {
        
    } else {
#if defined (QIMRNEnable) && QIMRNEnable == 1
        
        if ([[QIMKit sharedInstance] qimNav_RNUserCardView]) {
            return [QimRNBModule getVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:[QimRNBModule getInnerBundleName] WithModule:@"UserCard" WithProperties:@{@"UserId":userId}];
        } else {
#endif
            QIMUserProfileViewController *userProfileVc = [[QIMUserProfileViewController alloc] init];
            userProfileVc.userId = userId;
            return userProfileVc;
#if defined (QIMRNEnable) && QIMRNEnable == 1
        }
#endif
    }
    return nil;
}

+ (void)openUserCardVCByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        //打开用户名片页
        //导航返回的RNUserCardView 为YES时，默认打开RN 名片页
        if ([[QIMKit sharedInstance] getIsIpad]) {
            
        } else {
#if defined (QIMRNEnable) && QIMRNEnable == 1
            
            if ([[QIMKit sharedInstance] qimNav_RNUserCardView]) {
                [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:[QimRNBModule getInnerBundleName] WithModule:@"UserCard" WithProperties:@{@"UserId":userId}];
            } else {
#endif
                QIMUserProfileViewController *userProfileVc = [[QIMUserProfileViewController alloc] init];
                userProfileVc.userId = userId;
                [navVC pushViewController:userProfileVc animated:YES];
#if defined (QIMRNEnable) && QIMRNEnable == 1
            }
#endif
        }
    });
}

- (UIViewController *)getQIMGroupCardVCByGroupId:(NSString *)groupId {
#if defined (QIMRNEnable) && QIMRNEnable == 1
    
    if ([[QIMKit sharedInstance] qimNav_RNGroupCardView]) {
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        return [QimRNBModule getVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:[QimRNBModule getInnerBundleName] WithModule:@"GroupCard" WithProperties:@{@"groupId":groupId}];
    } else {
#endif
        QIMGroupCardVC *groupCardVC = [[QIMGroupCardVC alloc] init];
        [groupCardVC setGroupId:groupId];
        return groupCardVC;
#if defined (QIMRNEnable) && QIMRNEnable == 1
    }
#endif
    return nil;
}

+ (void)openQIMGroupCardVCByGroupId:(NSString *)groupId {
    
#if defined (QIMRNEnable) && QIMRNEnable == 1
    
    if ([[QIMKit sharedInstance] qimNav_RNGroupCardView]) {
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        BOOL isGroupOwner = [[QIMKit sharedInstance] isGroupOwner:groupId];
        [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:[QimRNBModule getInnerBundleName] WithModule:@"GroupCard" WithProperties:@{@"groupId":groupId, @"permissions":@(!isGroupOwner)}];
    } else {
#endif
        QIMGroupCardVC *groupCardVC = [[QIMGroupCardVC alloc] init];
        [groupCardVC setGroupId:groupId];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:groupCardVC animated:YES];
#if defined (QIMRNEnable) && QIMRNEnable == 1
    }
#endif
}

- (UIViewController *)getFastChatVCByXmppId:(NSString *)userId WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType WithFastMsgTimeStamp:(long long)fastMsgTime{
    UIViewController *fastChatVc = nil;
    switch (chatType) {
        case ChatType_SingleChat: {
            
            QIMChatVC *chatVc = [self getSingleChatVCByUserId:userId];
            [chatVc setFastMsgTimeStamp:fastMsgTime];
            return chatVc;
        }
            break;
        case ChatType_GroupChat: {
            QIMGroupChatVC *groupChatVc = [self getGroupChatVCByGroupId:userId];
            [groupChatVc setFastMsgTimeStamp:fastMsgTime];
            return groupChatVc;
        }
            break;
        case ChatType_System: {
            
        }
            break;
        case ChatType_PublicNumber: {
            
        }
            break;
        case ChatType_Consult: {
            
        }
            break;
        case ChatType_ConsultServer: {
            
        }
            break;
            
        default:
            break;
    }
    return nil;
}

+ (void)openFastChatVCByXmppId:(NSString *)userId WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType WithFastMsgTimeStamp:(long long)fastMsgTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        UIViewController *chatVc = [[QIMFastEntrance sharedInstance] getFastChatVCByXmppId:userId WithRealJid:realJid WithChatType:chatType WithFastMsgTimeStamp:fastMsgTime];
        chatVc.hidesBottomBarWhenPushed = YES;
        [navVC pushViewController:chatVc animated:YES];
    });
}

- (UIViewController *)getConsultChatByChatType:(ChatType)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    QIMChatVC *chatVc = [[QIMChatVC alloc] init];
    [chatVc setStype:kSessionType_Chat];
    [chatVc setChatId:userId];
    [chatVc setVirtualJid:virtualId];
    [chatVc setChatType:chatType];
    return chatVc;
}

+ (void)openConsultChatByChatType:(ChatType)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMChatVC *chatVc = [[QIMChatVC alloc] init];
        [chatVc setStype:kSessionType_Chat];
        [chatVc setChatId:userId];
        [chatVc setVirtualJid:virtualId];
        [chatVc setChatType:chatType];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        chatVc.hidesBottomBarWhenPushed = YES;
        [navVC pushViewController:chatVc animated:YES];
    });
}

- (UIViewController *)getSingleChatVCByUserId:(NSString *)userId {
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    if (userInfo == nil) {
        [[QIMKit sharedInstance] updateUserCard:@[userId]];
        userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    }
    NSString *name = [userInfo objectForKey:@"Name"];
    if (name.length <= 0) {
        name = [userId componentsSeparatedByString:@"@"].firstObject;
    }
    ChatType chatType = [[QIMKit sharedInstance] openChatSessionByUserId:userId ByName:name];
    
    QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
    [chatVC setStype:kSessionType_Chat];
    [chatVC setChatId:userId];
    [chatVC setName:name];
    [chatVC setTitle:name];
    [chatVC setChatType:chatType];
    return chatVC;
}

+ (void)openSingleChatVCByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
        if (userInfo == nil) {
            [[QIMKit sharedInstance] updateUserCard:@[userId]];
            userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
        }
        NSString *name = [userInfo objectForKey:@"Name"];
        if (name.length <= 0) {
            name = [userId componentsSeparatedByString:@"@"].firstObject;
        }
        ChatType chatType = [[QIMKit sharedInstance] openChatSessionByUserId:userId ByName:name];
        
        QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
        [chatVC setStype:kSessionType_Chat];
        [chatVC setChatId:userId];
        [chatVC setName:name];
        [chatVC setTitle:name];
        [chatVC setChatType:chatType];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        chatVC.hidesBottomBarWhenPushed = YES;
        [navVC pushViewController:chatVC animated:YES];
    });
}

- (UIViewController *)getGroupChatVCByGroupId:(NSString *)groupId {
    NSDictionary *groupCard = [[QIMKit sharedInstance] getGroupCardByGroupId:groupId];
    if (groupCard) {
        NSString *groupName = [groupCard objectForKey:@"Name"];
        QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
        [chatGroupVC setChatId:groupId];
        [chatGroupVC setTitle:groupName];
        return chatGroupVC;
    }
    return nil;
}

+ (void)openGroupChatVCByGroupId:(NSString *)groupId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *groupCard = [[QIMKit sharedInstance] getGroupCardByGroupId:groupId];
        if (groupCard) {
            NSString *groupName = [groupCard objectForKey:@"Name"];
            QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
            [chatGroupVC setChatId:groupId];
            [chatGroupVC setTitle:groupName];
            //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
            }
            [navVC pushViewController:chatGroupVC animated:YES];
        }
    });
}

- (UIViewController *)getHeaderLineVCByJid:(NSString *)jid {
    if ([jid hasPrefix:@"FriendNotify"]) {
        
        QIMFriendNotifyViewController *friendVC = [[QIMFriendNotifyViewController alloc] init];
        return friendVC;
    }  else if ([jid hasPrefix:@"rbt-qiangdan"]) {
        QIMWebView *webView = [[QIMWebView alloc] init];
        webView.needAuth = YES;
        webView.fromOrderManager = YES;
        webView.navBarHidden = YES;
        webView.url = [[QIMKit sharedInstance] qimNav_QcGrabOrder];
        return webView;
    } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
        QIMWebView *webView = [[QIMWebView alloc] init];
        webView.needAuth = YES;
        webView.navBarHidden = YES;
        [[QIMKit sharedInstance] clearNotReadMsgByJid:jid];
        webView.url = [[QIMKit sharedInstance] qimNav_QcOrderManager];
        return webView;
    } else {
        
        QIMSystemVC *chatSystemVC = [[QIMSystemVC alloc] init];
        [chatSystemVC setChatId:jid];
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
            
            if ([jid hasPrefix:@"rbt-notice"]) {
                [chatSystemVC setName:@"公告通知"];
                [chatSystemVC setTitle:@"公告通知"];
            } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                [chatSystemVC setName:@"抢单通知"];
                [chatSystemVC setTitle:@"抢单通知"];
            } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                [chatSystemVC setName:@"抢单"];
                [chatSystemVC setTitle:@"抢单"];
            } else {
                [chatSystemVC setName:@"系统消息"];
                [chatSystemVC setTitle:@"系统消息"];
            }
        } else {
            
            [chatSystemVC setName:@"系统消息"];
            [chatSystemVC setTitle:@"系统消息"];
        }
        return chatSystemVC;
    }
}

+ (void)openHeaderLineVCByJid:(NSString *)jid {
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[QIMKit sharedInstance] clearNotReadMsgByJid:jid];
        });
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        if ([jid hasPrefix:@"FriendNotify"]) {
            
            QIMFriendNotifyViewController *friendVC = [[QIMFriendNotifyViewController alloc] init];
            [navVC pushViewController:friendVC animated:YES];
        }  else if ([jid hasPrefix:@"rbt-qiangdan"]) {
            QIMWebView *webView = [[QIMWebView alloc] init];
            webView.needAuth = YES;
            webView.fromOrderManager = YES;
            webView.navBarHidden = YES;
            webView.url = [[QIMKit sharedInstance] qimNav_QcGrabOrder];
            [navVC pushViewController:webView animated:YES];
        } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
            QIMWebView *webView = [[QIMWebView alloc] init];
            webView.needAuth = YES;
            webView.navBarHidden = YES;
            [[QIMKit sharedInstance] clearNotReadMsgByJid:jid];
            webView.url = [[QIMKit sharedInstance] qimNav_QcOrderManager];
            [navVC pushViewController:webView animated:YES];

        } else {
            
            QIMSystemVC *chatSystemVC = [[QIMSystemVC alloc] init];
            [chatSystemVC setChatId:jid];
            if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
                
                if ([jid hasPrefix:@"rbt-notice"]) {
                    [chatSystemVC setName:@"公告通知"];
                    [chatSystemVC setTitle:@"公告通知"];
                } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                    [chatSystemVC setName:@"抢单通知"];
                    [chatSystemVC setTitle:@"抢单通知"];
                } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                    [chatSystemVC setName:@"抢单"];
                    [chatSystemVC setTitle:@"抢单"];
                } else {
                    [chatSystemVC setName:@"系统消息"];
                    [chatSystemVC setTitle:@"系统消息"];
                }
            } else {
                
                [chatSystemVC setName:@"系统消息"];
                [chatSystemVC setTitle:@"系统消息"];
            }
            [navVC pushViewController:chatSystemVC animated:YES];
        }
    });
}

- (UIViewController *)getWebViewWithHtmlStr:(NSString *)htmlStr showNavBar:(BOOL)showNavBar {
    QIMWebView *webView = [[QIMWebView alloc] init];
    [webView setHtmlString:htmlStr];
    if(!showNavBar){
        webView.navBarHidden = !showNavBar;
    }
    return webView;
}

+ (void)openWebViewWithHtmlStr:(NSString *)htmlStr showNavBar:(BOOL)showNavBar {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMWebView *webView = [[QIMWebView alloc] init];
        [webView setHtmlString:htmlStr];
        if(!showNavBar){
            webView.navBarHidden = !showNavBar;
        }
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:webView animated:YES];
    });
}

- (UIViewController *)getWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar{
    QIMWebView *webView = [[QIMWebView alloc] init];
    [webView setUrl:url];
    if(!showNavBar){
        webView.navBarHidden = !showNavBar;
    }
    return webView;
}

+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMWebView *webView = [[QIMWebView alloc] init];
        [webView setUrl:url];
        if(!showNavBar){
            webView.navBarHidden = !showNavBar;
        }
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:webView animated:YES];
    });
}

+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar FromRedPack:(BOOL)fromRedPack {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMWebView *webView = [[QIMWebView alloc] init];
        [webView setUrl:url];
        [webView setFromRegPackage:YES];
        if(!showNavBar){
            webView.navBarHidden = !showNavBar;
        }
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:webView animated:YES];
    });
}

- (UIViewController *)getRNSearchVC {
    return nil;
}

+ (void)openRNSearchVC {
    
}

- (UIViewController *)getUserFriendsVC {
    QIMFriendListViewController *friendListVC = [[QIMFriendListViewController alloc] init];
    return friendListVC;
}

+ (void)openUserFriendsVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMFriendListViewController *friendListVC = [[QIMFriendListViewController alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:friendListVC animated:YES];
    });
}

- (UIViewController *)getQIMGroupListVC {
    QIMGroupListVC * groupListVC = [[QIMGroupListVC alloc] init];
    return groupListVC;
}

+ (void)openQIMGroupListVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMGroupListVC * groupListVC = [[QIMGroupListVC alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:groupListVC animated:YES];
    });
}

- (UIViewController *)getNotReadMessageVC {
    QIMMessageHelperVC *helperVC = [[QIMMessageHelperVC alloc] init];
    return helperVC;
}

+ (void)openNotReadMessageVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMMessageHelperVC *helperVC = [[QIMMessageHelperVC alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:helperVC animated:YES];
    });
}

- (UIViewController *)getQIMPublicNumberVC {
    QIMPublicNumberVC *publicVC = [[QIMPublicNumberVC alloc] init];
    return publicVC;
}

+ (void)openQIMPublicNumberVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMPublicNumberVC *publicVC = [[QIMPublicNumberVC alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:publicVC animated:YES];
    });
}

- (UIViewController *)getMyFileVC {
    QIMFileManagerViewController *fileManagerVc = [[QIMFileManagerViewController alloc] init];
    return fileManagerVc;
}

+ (void)openMyFileVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        QIMFileManagerViewController *fileManagerVc = [[QIMFileManagerViewController alloc] init];
        [navVC pushViewController:fileManagerVc animated:YES];
    });
}

- (UIViewController *)getOrganizationalVC {
    QIMOrganizationalVC *organizationalVC = [[QIMOrganizationalVC alloc] init];
    return organizationalVC;
}

+ (void)openOrganizationalVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        QIMOrganizationalVC *organizationalVC = [[QIMOrganizationalVC alloc] init];
        [navVC pushViewController:organizationalVC animated:YES];
    });
}

+ (void)openQRCodeVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMZBarViewController*vc = [[QIMZBarViewController alloc] initWithBlock:^(NSString *str, BOOL isScceed) {
            if (isScceed) {
                [QIMJumpURLHandle decodeQCodeStr:str];
            }
        }];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC presentViewController:vc animated:YES completion:nil];
    });
}

- (UIViewController *)getRobotChatVC:(NSString *)robotJid {
    NSDictionary *cardDic = [[QIMKit sharedInstance] getPublicNumberCardByJId:robotJid];
    if (cardDic.count > 0) {
        QIMPublicNumberRobotVC *robotVC = [[QIMPublicNumberRobotVC alloc] init];
        [robotVC setRobotJId:[cardDic objectForKey:@"XmppId"]];
        [robotVC setPublicNumberId:[cardDic objectForKey:@"PublicNumberId"]];
        [robotVC setName:[cardDic objectForKey:@"Name"]];
        [robotVC setTitle:robotVC.name];
        return robotVC;
    }
    return nil;
}

+ (void)openRobotChatVC:(NSString *)robotJid {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *cardDic = [[QIMKit sharedInstance] getPublicNumberCardByJId:robotJid];
        if (cardDic.count > 0) {
            QIMPublicNumberRobotVC *robotVC = [[QIMPublicNumberRobotVC alloc] init];
            [robotVC setRobotJId:[cardDic objectForKey:@"XmppId"]];
            [robotVC setPublicNumberId:[cardDic objectForKey:@"PublicNumberId"]];
            [robotVC setName:[cardDic objectForKey:@"Name"]];
            [robotVC setTitle:robotVC.name];
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
            }
            [navVC pushViewController:robotVC animated:YES];
        }
    });
}

- (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties {
#if defined (QIMRNEnable) && QIMRNEnable == 1
    return [QimRNBModule getVCWithNavigation:navVC WithHiddenNav:hiddenNav WithBundleName:@"clock_in.ios" WithModule:module WithProperties:properties];
#endif
    return nil;
}

+ (void)openQIMRNVCWithModuleName:(NSString *)moduleName WithProperties:(NSDictionary *)properties {
    dispatch_async(dispatch_get_main_queue(), ^{
#if defined (QIMRNEnable) && QIMRNEnable == 1
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:@"clock_in.ios" WithModule:moduleName WithProperties:properties];
#endif
    });
}

- (UIViewController *)getRobotCard:(NSString *)robotJid {
    QIMPublicNumberCardVC *cardVC = [[QIMPublicNumberCardVC alloc] init];
    NSString *publicNumberId = [[robotJid componentsSeparatedByString:@"@"] firstObject];
    if (publicNumberId) {
        [cardVC setPublicNumberId:publicNumberId];
    }
    [cardVC setJid:robotJid];
    if ([[QIMKit sharedInstance] getPublicNumberCardByJid:robotJid]) {
        [cardVC setNotConcern:NO];
    } else {
        [cardVC setNotConcern:YES];
    }
    return cardVC;
}

+ (void)openRobotCard:(NSString *)robotJId {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!robotJId) {
            return;
        } else {
            UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
            if (!navVC) {
                navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
            }
            QIMPublicNumberCardVC *cardVC = [[QIMPublicNumberCardVC alloc] init];
            NSString *publicNumberId = [[robotJId componentsSeparatedByString:@"@"] firstObject];
            if (publicNumberId) {
                [cardVC setPublicNumberId:publicNumberId];
            }
            [cardVC setJid:robotJId];
            if ([[QIMKit sharedInstance] getPublicNumberCardByJid:robotJId]) {
                [cardVC setNotConcern:NO];
            } else {
                [cardVC setNotConcern:YES];
            }
            [navVC pushViewController:cardVC animated:YES];
        }
    });
}

- (UIViewController *)getQTalkNotesVC {
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    QTalkNotesCategoriesVc *notesCategoriesVc = [[QTalkNotesCategoriesVc alloc] init];
    return notesCategoriesVc;
#endif
    return nil;
}

+ (void)openQTalkNotesVC {
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    dispatch_async(dispatch_get_main_queue(), ^{
        QTalkNotesCategoriesVc *notesCategoriesVc = [[QTalkNotesCategoriesVc alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:notesCategoriesVc animated:YES];
    });
#endif
}

- (UIViewController *)getMyRedPack {
    //我的红包
    NSString *myRedpackageUrl = [[QIMKit sharedInstance] myRedpackageUrl];
    if (myRedpackageUrl.length > 0) {
        return [[QIMFastEntrance sharedInstance] getWebViewForUrl:myRedpackageUrl showNavBar:YES];
    }
    return nil;
}

- (UIViewController *)getMyRedPackageBalance {
    //余额查询
    NSString *balacnceUrl = [[QIMKit sharedInstance] redPackageBalanceUrl];
    if (balacnceUrl.length > 0) {
        return [[QIMFastEntrance sharedInstance] getWebViewForUrl:balacnceUrl showNavBar:YES];
    }
    return nil;
}

+ (void)openQIMRNWithScheme:(NSString *)scheme withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
#if defined (QIMRNEnable) && QIMRNEnable == 1
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        [properties setQIMSafeObject:@"" forKey:@"Screen"];
        [properties setQIMSafeObject:[[QIMKit sharedInstance] getLastJid] forKey:@"from"];
        [properties setQIMSafeObject:chatId forKey:@"to"];
        [properties setQIMSafeObject:realJid forKey:@"realjid"];
        [properties setQIMSafeObject:@(chatType) forKey:@"chatType"];
        [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:[QimRNBModule getInnerBundleName] WithModule:@"Merchant" WithProperties:@{@"Screen":@"Seats", @"from":[[QIMKit sharedInstance] getLastJid], @"to":chatId, @"customerName":realJid}];
#endif
    });
}

+ (void)openTransferConversation:(NSString *)shopId withVistorId:(NSString *)realJid {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
#if defined (QIMRNEnable) && QIMRNEnable == 1
        [QimRNBModule openVCWithNavigation:navVC WithHiddenNav:YES WithBundleName:[QimRNBModule getInnerBundleName] WithModule:@"Merchant" WithProperties:@{@"Screen":@"Seats", @"shopJid":shopId, @"customerName":realJid}];
#endif
    });
}

+ (void)openMyAccountInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
#if defined (QIMRNEnable) && QIMRNEnable == 1
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_QtalkSuggest_handle_opsapp_event object:nil userInfo:@{@"module":@"user-info", @"initParam":@[]}];
#endif
    });
}

- (UIViewController *)getQRCodeWithQRId:(NSString *)qrId withType:(QRCodeType)qrcodeType {
    QIMQRCodeViewDisplayController *QRVC = [[QIMQRCodeViewDisplayController alloc]init];
    QRVC.QRtype = qrcodeType;
    QRVC.jid = qrId;
    NSString *qrName = @"";
    switch (qrcodeType) {
        case QRCodeType_UserQR: {
            NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:qrId];
            qrName = [userInfo objectForKey:@"Name"];
        }
            break;
        case QRCodeType_GroupQR: {
            NSDictionary *groupVCard = [[QIMKit sharedInstance] getGroupCardByGroupId:qrId];
            qrName = [groupVCard objectForKey:@"Name"];
        }
            break;
        case QRCodeType_RobotQR: {
            NSDictionary *robotVCard = [[QIMKit sharedInstance] getPublicNumberCardByJid:qrId];
            qrName = [robotVCard objectForKey:@"Name"];
        }
            break;
        case QRCodeType_ClientNav: {
            
        }
            break;
        default:
            break;
    }
    QRVC.name = qrName ? qrName : qrId;
    return QRVC;
}

+ (void)showQRCodeWithQRId:(NSString *)qrId withType:(QRCodeType)qrcodeType {
    if (qrId.length <= 0) {
        NSAssert(qrId, @"UserId is nil, Please Check it");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *qrVC = [[QIMFastEntrance sharedInstance] getQRCodeWithQRId:qrId withType:qrcodeType];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:qrVC animated:YES];
    });
}

+ (void)signOutWithNoPush {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[QIMKit sharedInstance] sendNoPush];
        [[QIMKit sharedInstance] clearcache];
        [[QIMKit sharedInstance] clearDataBase];
        [[QIMKit sharedInstance] clearLogginUser];
        [[QIMKit sharedInstance] quitLogin];
        [[QIMKit sharedInstance] setNeedTryRelogin:NO];
        [[QIMKit sharedInstance] removeUserObjectForKey:@"userToken"];
        [[QIMKit sharedInstance] removeUserObjectForKey:@"kTempUserToken"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
                QIMLoginVC * remoteVC = [[QIMLoginVC alloc] init];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                [remoteVC quit];
                [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
            } else {
                QIMWebLoginVC *loginVC = [[QIMWebLoginVC alloc] init];
                [loginVC clearLoginCookie];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
            }
        });
    });
}

+ (void)signOut {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:@"退出登录中..."];
        BOOL result = [[QIMKit sharedInstance] sendPushTokenWithMyToken:nil WithDeleteFlag:YES];
        [[QIMProgressHUD sharedInstance] closeHUD];
        if (result) {
            [[QIMKit sharedInstance] sendNoPush];
            [[QIMKit sharedInstance] clearcache];
            [[QIMKit sharedInstance] clearDataBase];
            [[QIMKit sharedInstance] clearLogginUser];
            [[QIMKit sharedInstance] quitLogin];
            [[QIMKit sharedInstance] setNeedTryRelogin:NO];
            [[QIMKit sharedInstance] removeUserObjectForKey:@"userToken"];
            [[QIMKit sharedInstance] removeUserObjectForKey:@"kTempUserToken"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
                    QIMLoginVC * remoteVC = [[QIMLoginVC alloc] init];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:remoteVC];
                    [remoteVC quit];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                } else {
                    QIMWebLoginVC *loginVC = [[QIMWebLoginVC alloc] init];
                    [loginVC clearLoginCookie];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"退出登录失败，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            });
        }
    });
}

+ (void)reloginAccount {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[QIMKit sharedInstance] setNeedTryRelogin:NO];
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
            [[QIMKit sharedInstance] removeUserObjectForKey:@"userToken"];
            [[QIMKit sharedInstance] removeUserObjectForKey:@"kTempUserToken"];
            QIMLoginVC * remoteVC = [[QIMLoginVC alloc] init];
            [remoteVC quit];
            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:remoteVC];
        } else {
            QIMWebLoginVC *loginVC = [[QIMWebLoginVC alloc] init];
            [loginVC clearLoginCookie];
            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:loginVC];
        }
    });
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            
        } else {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[error description] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

- (UIViewController *)getContactSelectionVC:(Message *)msg withExternalForward:(BOOL)externalForward {
    QIMContactSelectionViewController *controllerVc = [[QIMContactSelectionViewController alloc] init];
    controllerVc.ExternalForward = YES;
    [controllerVc setMessage:msg];
    return controllerVc;
}

- (void)openFileTransMiddleVC {
    QIMFileTransMiddleVC *fileMiddleVc = [[QIMFileTransMiddleVC alloc] init];
    UINavigationController *fileMiddleNav = [[UINavigationController alloc] initWithRootViewController:fileMiddleVc];
    if (!self.rootVc) {
        self.rootVc = [[UIApplication sharedApplication] visibleViewController];
    }
    [self.rootVc presentViewController:fileMiddleNav animated:YES completion:nil];
}

- (void)browseBigHeader:(NSDictionary *)param {

    self.browerImageUserId = [param objectForKey:@"UserId"];
    NSString *imageUrl = [param objectForKey:@"imageUrl"];
    if (imageUrl.length > 0) {
        self.browerImageUrl = imageUrl;
    } else {
        //1.根据UserId读取名片信息，取出RemoteUrl，直接加载用户头像大图
        NSString *headerUrl = [[QIMKit sharedInstance] getUserHeaderSrcByUserId:self.browerImageUserId];
        if (![headerUrl qim_hasPrefixHttpHeader]) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
        }
        self.browerImageUrl = headerUrl;
    }
    QIMMWPhotoBrowser *browser = [[QIMMWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableSwipeToDismiss = NO;
    [browser setCurrentPhotoIndex:0];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    
    //初始化navigation
    QIMNavController *nc = [[QIMNavController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       [navVC presentViewController:nc animated:YES completion:nil];
    });
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
#pragma mark - 查看大图
    if (![self.browerImageUrl qim_hasPrefixHttpHeader]) {
        self.browerImageUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], self.browerImageUrl];
    }
    QIMMWPhoto *photo = [[QIMMWPhoto alloc] initWithURL:[NSURL URLWithString:self.browerImageUrl]];
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
    }];
}

- (void)openQIMFilePreviewVCWithParam:(NSDictionary *)param {
    NSString *fileUrl = [param objectForKey:@"httpUrl"];
    NSString *fileName = [param objectForKey:@"fileName"];
    NSString *fileSize = [NSString stringWithFormat:@"%ld", [[param objectForKey:@"fileSize"] longValue]];
    NSString *fileMd5 = [param objectForKey:@"fileMD5"];
    if (fileUrl.length <= 0 || fileName.length <= 0 || fileSize.length <= 0 || fileMd5.length <= 0) {
        return;
    }
    Message *fileMsg = [[Message alloc] init];
    fileMsg.messageId = [QIMUUIDTools UUID];
    NSMutableDictionary *fileInfoDic = [[NSMutableDictionary alloc] init];
    [fileInfoDic setQIMSafeObject:fileUrl forKey:@"HttpUrl"];
    [fileInfoDic setQIMSafeObject:fileName forKey:@"FileName"];
    [fileInfoDic setQIMSafeObject:fileSize forKey:@"FileLength"];
    [fileInfoDic setQIMSafeObject:fileMd5 forKey:@"FileMd5"];
    fileMsg.message = [[QIMJSONSerializer sharedInstance] serializeObject:fileInfoDic];
    QIMFilePreviewVC *filePreviewVc = [[QIMFilePreviewVC alloc] init];
    filePreviewVc.message = fileMsg;
    UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
    if (!navVC) {
        navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       [navVC pushViewController:filePreviewVc animated:YES];
    });
}

@end
