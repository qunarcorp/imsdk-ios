//
//  QIMSDKUIHelper+BaseUI.m
//  QIMSDK
//
//  Created by 李露 on 2018/9/29.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMSDKUIHelper+BaseUI.h"
#import "QIMKitPublicHeader.h"
#import "QIMFastEntrance.h"
#import "QIMAppWindowManager.h"

@implementation QIMSDKUIHelper (BaseUI)

- (void)launchMainControllerWithWindow:(UIWindow *)window {
    [[QIMFastEntrance sharedInstance] launchMainControllerWithWindow:window];
}

- (void)launchMainAdvertWindow {
    [[QIMFastEntrance sharedInstance] launchMainAdvertWindow];
}

- (UIView *)getQIMSessionListViewWithBaseFrame:(CGRect)frame {
    return [[QIMFastEntrance sharedInstance] getQIMSessionListViewWithBaseFrame:frame];
}

- (UIViewController *)getUserChatInfoByUserId:(NSString *)userId {
    return [[QIMFastEntrance sharedInstance] getUserChatInfoByUserId:userId];
}

- (UIViewController *)getUserCardVCByUserId:(NSString *)userId {
    return [[QIMFastEntrance sharedInstance] getUserCardVCByUserId:userId];
}

- (UIViewController *)getQIMGroupCardVCByGroupId:(NSString *)groupId {
    return [[QIMFastEntrance sharedInstance] getQIMGroupCardVCByGroupId:groupId];
}

- (UIViewController *)getConsultChatByChatType:(NSInteger)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    return [[QIMFastEntrance sharedInstance] getConsultChatByChatType:chatType UserId:userId WithVirtualId:virtualId];
}

- (UIViewController *)getSingleChatVCByUserId:(NSString *)userId {
    return [[QIMFastEntrance sharedInstance] getSingleChatVCByUserId:userId];
}

- (UIViewController *)getGroupChatVCByGroupId:(NSString *)groupId {
    return [[QIMFastEntrance sharedInstance] getGroupChatVCByGroupId:groupId];
}

- (UIViewController *)getHeaderLineVCByJid:(NSString *)jid {
    return [[QIMFastEntrance sharedInstance] getHeaderLineVCByJid:jid];
}

- (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties {
    return [[QIMFastEntrance sharedInstance] getVCWithNavigation:navVC WithHiddenNav:hiddenNav WithModule:module WithProperties:properties];
}

- (UIViewController *)getRobotCard:(NSString *)robotJid {
    return [[QIMFastEntrance sharedInstance] getRobotCard:robotJid];
}

- (UIViewController *)getRNSearchVC {
    return [[QIMFastEntrance sharedInstance] getRNSearchVC];
}

- (UIViewController *)getUserFriendsVC {
    return [[QIMFastEntrance sharedInstance] getUserFriendsVC];
}

- (UIViewController *)getQIMGroupListVC {
    return [[QIMFastEntrance sharedInstance] getQIMGroupListVC];
}

- (UIViewController *)getNotReadMessageVC {
    return [[QIMFastEntrance sharedInstance] getNotReadMessageVC];
}

- (UIViewController *)getQIMPublicNumberVC {
    return [[QIMFastEntrance sharedInstance] getQIMPublicNumberVC];
}

- (UIViewController *)getMyFileVC {
    return [[QIMFastEntrance sharedInstance] getMyFileVC];
}

- (UIViewController *)getOrganizationalVC {
    return [[QIMFastEntrance sharedInstance] getOrganizationalVC];
}

- (UIViewController *)getRobotChatVC:(NSString *)robotJid {
    return [[QIMFastEntrance sharedInstance] getRobotChatVC:robotJid];
}

- (UIViewController *)getQTalkNotesVC {
    return [[QIMFastEntrance sharedInstance] getQTalkNotesVC];
}

- (UIViewController *)getMyRedPack {
    return [[QIMFastEntrance sharedInstance] getMyRedPack];
}

- (UIViewController *)getMyRedPackageBalance {
    return [[QIMFastEntrance sharedInstance] getMyRedPackageBalance];
}

- (UIViewController *)getQRCodeWithQRId:(NSString *)qrId withType:(NSInteger)qrcodeType {
    return [[QIMFastEntrance sharedInstance] getQRCodeWithQRId:qrId withType:qrcodeType];
}

- (UIViewController *)getContactSelectionVC:(Message *)msg withExternalForward:(BOOL)externalForward {
    return [[QIMFastEntrance sharedInstance] getContactSelectionVC:msg withExternalForward:externalForward];
}

@end
