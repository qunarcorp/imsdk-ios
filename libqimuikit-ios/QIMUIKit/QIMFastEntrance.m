//
//  QIMFastEntrance.m
//  qunarChatIphone
//
//  Created by admin on 16/6/15.
//
//

#import "QIMFastEntrance.h"
#import "QIMCommonCategories.h"
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
#import "QIMLoginViewController.h"
#import "QIMWebLoginVC.h"
#import "QIMQRCodeViewDisplayController.h"
#import "QIMContactSelectionViewController.h"
#import "QIMFileTransMiddleVC.h"
#if defined (QIMIPadEnable) && QIMIPadEnable == 1
    #import "IPAD_RemoteLoginVC.h"
#endif
#import "QIMWatchDog.h"
#import "QIMUUIDTools.h"
#import "QIMPublicRedefineHeader.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMFilePreviewVC.h"
#import "QIMMWPhotoSectionBrowserVC.h"
#import "QIMWorkFeedViewController.h"

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
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    if([[QIMKit sharedInstance] getIsIpad] && [QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
#if defined (QIMIPadEnable) && QIMIPadEnable == 1
        IPAD_RemoteLoginVC *ipadVc = [[IPAD_RemoteLoginVC alloc] init];
        [window setRootViewController:ipadVc];
#endif
    } else {
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
            if ([[QIMKit sharedInstance] qimNav_Debug] == 1) {
                QIMLoginViewController *loginVc = [[QIMLoginViewController alloc] initWithNibName:@"QIMLoginViewController" bundle:nil];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVc];
                [window setRootViewController:nav];
            } else {
                QIMWebLoginVC *loginVc = [[QIMWebLoginVC alloc] init];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVc];
                [window setRootViewController:nav];
            }
            return ;
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
    QIMVerboseLog(@"加载主界面VC耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
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
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"getVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"UserCard", @"properties":@{@"UserId":userId, @"Screen":@"ChatInfo", @"RealJid":userId, @"HeaderUri":@"33"}};
                vc = [RunC performSelector:sel withObject:param];
            }
            return vc;
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
                Class RunC = NSClassFromString(@"QimRNBModule");
                SEL sel = NSSelectorFromString(@"openQIMRNVCWithParam:");
                if ([RunC respondsToSelector:sel]) {
                    NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"UserCard", @"properties":@{@"UserId":userId, @"Screen":@"ChatInfo", @"RealJid":userId, @"HeaderUri":@"33"}};
                    [RunC performSelector:sel withObject:param];
                }
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
            
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"getVCWithParam:");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"UserCard", @"properties":@{@"UserId":userId}};
                vc = [RunC performSelector:sel withObject:param];
            }
            return vc;
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
            Class RunC = NSClassFromString(@"QIMIPadWindowManager");
            SEL sel = NSSelectorFromString(@"openSingleChatByJid:");
            if ([RunC respondsToSelector:sel]) {
                [RunC performSelector:sel withObject:userId];
            }
        } else {
#if defined (QIMRNEnable) && QIMRNEnable == 1
            
            if ([[QIMKit sharedInstance] qimNav_RNUserCardView]) {
                Class RunC = NSClassFromString(@"QimRNBModule");
                SEL sel = NSSelectorFromString(@"openQIMRNVCWithParam:");
                if ([RunC respondsToSelector:sel]) {
                    NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"UserCard", @"properties":@{@"UserId":userId}};
                    [RunC performSelector:sel withObject:param];
                }
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
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"getVCWithParam:");
        UIViewController *vc = nil;
        if ([RunC respondsToSelector:sel]) {
            QIMGroupIdentity groupIdentity = [[QIMKit sharedInstance] GroupIdentityForUser:[[QIMKit sharedInstance] getLastJid] byGroup:groupId];
            NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"GroupCard", @"properties":@{@"groupId":groupId}, @"permissions":@(groupIdentity)};
            vc = [RunC performSelector:sel withObject:param];
        }
        return vc;
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
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openQIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            QIMGroupIdentity groupIdentity = [[QIMKit sharedInstance] GroupIdentityForUser:[[QIMKit sharedInstance] getLastJid] byGroup:groupId];
            NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"GroupCard", @"properties":@{@"groupId":groupId, @"permissions":@(groupIdentity)}};
            [RunC performSelector:sel withObject:param];
        }
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
            QIMSystemVC *systemVc = [self getHeaderLineVCByJid:userId];
            [systemVc setFastMsgTimeStamp:fastMsgTime];
            return systemVc;
        }
            break;
        case ChatType_PublicNumber: {
            
        }
            break;
        case ChatType_Consult: {
            QIMChatVC *chatVc = [self getConsultChatByChatType:chatType UserId:realJid WithVirtualId:userId];
            [chatVc setFastMsgTimeStamp:fastMsgTime];
            return chatVc;
        }
            break;
        case ChatType_ConsultServer: {
            QIMChatVC *chatVc = [self getConsultChatByChatType:chatType UserId:realJid WithVirtualId:userId];
            [chatVc setFastMsgTimeStamp:fastMsgTime];
            return chatVc;
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
    [chatVc setChatId:userId];
    [chatVc setVirtualJid:virtualId];
    [chatVc setChatType:chatType];
    return chatVc;
}

+ (void)openConsultChatByChatType:(ChatType)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *consultChatVc = [[QIMFastEntrance sharedInstance] getConsultChatByChatType:chatType UserId:userId WithVirtualId:virtualId];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:consultChatVc animated:YES];
    });
}

- (UIViewController *)getConsultServerChatByChatType:(ChatType)chatType WithVirtualId:(NSString *)virtualId WithRealJid:(NSString *)realjid {
    QIMChatVC *chatVc = [[QIMChatVC alloc] init];
    [chatVc setChatId:realjid];
    [chatVc setVirtualJid:virtualId];
    [chatVc setChatType:chatType];
    return chatVc;
}

+ (void)openConsultServerChatByChatType:(ChatType)chatType WithVirtualId:(NSString *)virtualId WithRealJid:(NSString *)realjid {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *consultChatVc = [[QIMFastEntrance sharedInstance] getConsultServerChatByChatType:chatType WithVirtualId:virtualId WithRealJid:realjid];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:consultChatVc animated:YES];
    });
}

- (UIViewController *)getSingleChatVCByUserId:(NSString *)userId {
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    if (userInfo == nil) {
        [[QIMKit sharedInstance] updateUserCard:@[userId]];
        userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
    }
    NSString *name = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    if (name.length <= 0) {
        name = [userId componentsSeparatedByString:@"@"].firstObject;
    }
    ChatType chatType = [[QIMKit sharedInstance] openChatSessionByUserId:userId];
    
    QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
    [chatVC setChatId:userId];
    [chatVC setTitle:name];
    [chatVC setChatType:chatType];
    [chatVC setVirtualJid:userId];
    return chatVC;
}

+ (void)openSingleChatVCByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *chatVC = [[QIMFastEntrance sharedInstance] getSingleChatVCByUserId:userId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
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
        [chatGroupVC setChatType:ChatType_GroupChat];
        [chatGroupVC setChatId:groupId];
        [chatGroupVC setTitle:groupName];
        return chatGroupVC;
    }
    return nil;
}

+ (void)openGroupChatVCByGroupId:(NSString *)groupId {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[QIMKit sharedInstance] getIsIpad]) {
            Class RunC = NSClassFromString(@"QIMIPadWindowManager");
            SEL sel = NSSelectorFromString(@"openGrouChatByGroupId:");
            if ([RunC respondsToSelector:sel]) {
                [RunC performSelector:sel withObject:groupId];
            }
        } else {
            UIViewController *chatGroupVC = [[QIMFastEntrance sharedInstance] getGroupChatVCByGroupId:groupId];
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
                [chatSystemVC setTitle:@"公告通知"];
            } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                [chatSystemVC setTitle:@"抢单通知"];
            } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                [chatSystemVC setTitle:@"抢单"];
            } else {
                [chatSystemVC setTitle:@"系统消息"];
            }
        } else {
            
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
        UIViewController *chatSystemVC = [[QIMFastEntrance sharedInstance] getHeaderLineVCByJid:jid];
        [navVC pushViewController:chatSystemVC animated:YES];

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

+ (BOOL)handleOpsasppSchema:(NSDictionary *)reactInfoDic {
#if defined (QIMOPSRNEnable) && QIMOPSRNEnable == 1
    BOOL canParse = NO;
    Class RunC = NSClassFromString(@"RNSchemaParse");
    SEL sel = NSSelectorFromString(@"canHandleURL:");
    if ([RunC respondsToSelector:sel]) {
        canParse = [[RunC performSelector:sel withObject:reactInfoDic] boolValue];
    }
    if (canParse && [QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        
        NSString *reacturl = reactInfoDic[@"reacturl"];
        NSURL *url = [NSURL URLWithString:[reacturl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        UIViewController *reactVC = nil;
        QIMVerboseLog(@"url : %@", url);
        Class RunC = NSClassFromString(@"RNSchemaParse");
        SEL sel = NSSelectorFromString(@"handleOpsasppSchema:");
        UIViewController *vc = nil;
        if ([RunC respondsToSelector:sel]) {
            reactVC = [RunC performSelector:sel withObject:url];
        }
        
        if (reactVC != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
                if (!navVC) {
                    navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
                }
                [navVC pushViewController:reactVC animated:YES];
            });
            return YES;
        }
        return NO;
    }
#endif
    return NO;
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
    
    
#if defined (QIMRNEnable) && QIMRNEnable == 1
    UIViewController *reactVC = [[NSClassFromString(@"QTalkSearchViewManager") alloc] init];
    return reactVC;
#endif
    return nil;
}

+ (void)openRNSearchVC {
#if defined (QIMRNEnable) && QIMRNEnable == 1
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.duration = 0.4f;   //时间间隔
        animation.fillMode = kCAFillModeForwards;
        animation.type = @"rippleEffect";
        //动画效果
        animation.subtype = kCATransitionFromTop;   //动画方向
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC.view.layer addAnimation:animation forKey:@"animation"];
        UIViewController *reactVC = [[QIMFastEntrance sharedInstance] getRNSearchVC];
        [navVC.view.layer addAnimation:animation forKey:nil];
        navVC.delegate = self;
        [navVC pushViewController:reactVC animated:YES];
        [navVC setNavigationBarHidden:YES animated:YES];
        navVC.delegate = nil;
    });
#endif
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
    
    Class RunC = NSClassFromString(@"QimRNBModule");
    SEL sel = NSSelectorFromString(@"getVCWithParam:");
    UIViewController *vc = nil;
    if ([RunC respondsToSelector:sel]) {
        NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(hiddenNav), @"module":module, @"properties":properties};
        vc = [RunC performSelector:sel withObject:param];
    }
    return vc;
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
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openQIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":moduleName, @"properties":properties};
            [RunC performSelector:sel withObject:param];
        }
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

+ (void)openLocalMediaWithXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMMWPhotoSectionBrowserVC *mwphotoVc = [[QIMMWPhotoSectionBrowserVC alloc] init];
        mwphotoVc.chatType = chatType;
        mwphotoVc.xmppId = xmppId;
        mwphotoVc.realJid = realJid;
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:mwphotoVc animated:YES];
    });
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
        
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openQIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"Merchant", @"properties":@{@"Screen":@"Seats", @"from":[[QIMKit sharedInstance] getLastJid], @"to":chatId, @"customerName":realJid}};
            [RunC performSelector:sel withObject:param];
        }
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
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openQIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"Merchant", @"properties":@{@"Screen":@"Seats", @"shopJid":shopId, @"customerName":realJid}};
            [RunC performSelector:sel withObject:param];
        }
#endif
    });
}

+ (void)openMyAccountInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
#if defined (QIMOPSRNEnable) && QIMOPSRNEnable == 1
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
                if ([[QIMKit sharedInstance] qimNav_Debug] == 1) {
                    QIMLoginViewController *loginViewController = [[QIMLoginViewController alloc] initWithNibName:@"QIMLoginViewController" bundle:nil];
                    [loginViewController setLinkUrl:nil];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                } else {
                    QIMWebLoginVC *loginVC = [[QIMWebLoginVC alloc] init];
                    [loginVC clearLoginCookie];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                }
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
                    if ([[QIMKit sharedInstance] qimNav_Debug] == 1) {
                        QIMLoginViewController *loginViewController = [[QIMLoginViewController alloc] initWithNibName:@"QIMLoginViewController" bundle:nil];
                        [loginViewController setLinkUrl:nil];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                    } else {
                        QIMWebLoginVC *loginVC = [[QIMWebLoginVC alloc] init];
                        [loginVC clearLoginCookie];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
                    }
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
            if ([[QIMKit sharedInstance] qimNav_Debug] == 1) {
                QIMLoginViewController *loginVC = [[QIMLoginViewController alloc] initWithNibName:@"QIMLoginViewController" bundle:nil];
                [loginVC setLinkUrl:nil];
                [[[[UIApplication sharedApplication] delegate] window] setRootViewController:loginVC];
            } else {
                QIMWebLoginVC *loginVC = [[QIMWebLoginVC alloc] init];
                [loginVC clearLoginCookie];
                [[[[UIApplication sharedApplication] delegate] window] setRootViewController:loginVC];
            }
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
    NSString *fileSize = [param objectForKey:@"fileSize"];
    NSString *fileMd5 = [param objectForKey:@"fileMD5"];
    if (fileUrl.length <= 0 || fileName.length <= 0 || fileSize.length <= 0) {
        return;
    }
    Message *fileMsg = [[Message alloc] init];
    fileMsg.messageId = [QIMUUIDTools UUID];
    NSMutableDictionary *fileInfoDic = [[NSMutableDictionary alloc] init];
    [fileInfoDic setQIMSafeObject:fileUrl forKey:@"HttpUrl"];
    [fileInfoDic setQIMSafeObject:fileName forKey:@"FileName"];
    [fileInfoDic setQIMSafeObject:fileSize forKey:@"FileLength"];
    [fileInfoDic setQIMSafeObject:(fileMd5.length > 0) ? fileMd5 : fileName forKey:@"FileMd5"];
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

- (void)openLocalSearchWithXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid withChatType:(NSInteger)chatType {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
#if defined (QIMRNEnable) && QIMRNEnable == 1
        
        Class RunC = NSClassFromString(@"QimRNBModule");
        SEL sel = NSSelectorFromString(@"openQIMRNVCWithParam:");
        if ([RunC respondsToSelector:sel]) {
            NSDictionary *param = @{@"navVC":navVC, @"hiddenNav":@(YES), @"module":@"Search", @"properties":@{@"Screen":@"LocalSearch", @"xmppid":xmppId, @"realjid":realJid, @"chatType":@(chatType)}};
            [RunC performSelector:sel withObject:param];
        }
#endif
    });
}

- (void)openWorkFeedViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMWorkFeedViewController *workfeedVc = [[QIMWorkFeedViewController alloc] init];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:workfeedVc animated:YES];
    });
}

- (void)openUserWorkWorldWithParam:(NSDictionary *)param {
    NSLog(@"param : %@", param);
    if (![param objectForKey:@"UserId"]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMWorkFeedViewController *userWorkFeedVc = [[QIMWorkFeedViewController alloc] init];
        userWorkFeedVc.userId = [param objectForKey:@"UserId"];
        
        //        userWorkFeedVc.title = [NSString stringWithFormat:@"%@的动态", [[QIMKit sharedInstance] getUserMarkupNameWithUserId:[param objectForKey:@"UserId"]]];
        UINavigationController *navVC = [[UIApplication sharedApplication] visibleNavigationController];
        if (!navVC) {
            navVC = [[QIMFastEntrance sharedInstance] getQIMFastEntranceRootNav];
        }
        [navVC pushViewController:userWorkFeedVc animated:YES];
    });
}

@end
