//
//  QIMSDKUIHelper+JumpHandle.m
//  QIMSDK
//
//  Created by 李露 on 2018/9/29.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMSDKUIHelper+JumpHandle.h"
#import "QIMJumpURLHandle.h"
#import "QIMFastEntrance.h"

@implementation QIMSDKUIHelper (JumpHandle)

- (BOOL)parseURL:(NSURL *)url {
    return [QIMJumpURLHandle parseURL:url];
}

- (void)sendMailWithRootVc:(UIViewController *)rootVc ByUserId:(NSString *)userId {
    [[QIMFastEntrance sharedInstance] sendMailWithRootVc:rootVc ByUserId:userId];
}

+ (void)openUserChatInfoByUserId:(NSString *)userId {
    [QIMFastEntrance openUserChatInfoByUserId:userId];
}

+ (void)openUserCardVCByUserId:(NSString *)userId {
    [QIMFastEntrance openUserCardVCByUserId:userId];
}

+ (void)openQIMGroupCardVCByGroupId:(NSString *)groupId {
    [QIMFastEntrance openQIMGroupCardVCByGroupId:groupId];
}

+ (void)openConsultChatByChatType:(NSInteger)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId {
    [QIMFastEntrance openConsultChatByChatType:chatType UserId:userId WithVirtualId:virtualId];
}

+ (void)openSingleChatVCByUserId:(NSString *)userId {
    [QIMFastEntrance openSingleChatVCByUserId:userId];
}

+ (void)openGroupChatVCByGroupId:(NSString *)groupId {
    [QIMFastEntrance openGroupChatVCByGroupId:groupId];
}

+ (void)openHeaderLineVCByJid:(NSString *)jid {
    [QIMFastEntrance openHeaderLineVCByJid:jid];
}

+ (void)openQIMRNVCWithModuleName:(NSString *)moduleName WithProperties:(NSDictionary *)properties {
    [QIMFastEntrance openQIMRNVCWithModuleName:moduleName WithProperties:properties];
}

+ (void)openRobotCard:(NSString *)robotJId {
    [QIMFastEntrance openRobotCard:robotJId];
}

+ (void)openWebViewWithHtmlStr:(NSString *)htmlStr showNavBar:(BOOL)showNavBar {
    [QIMFastEntrance openWebViewWithHtmlStr:htmlStr showNavBar:showNavBar];
}

+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar {
    [QIMFastEntrance openWebViewForUrl:url showNavBar:showNavBar];
}

+ (void)openRNSearchVC {
    [QIMFastEntrance openRNSearchVC];
}

+ (void)openUserFriendsVC {
    [QIMFastEntrance openUserFriendsVC];
}

+ (void)openQIMGroupListVC {
    [QIMFastEntrance openQIMGroupListVC];
}

+ (void)openNotReadMessageVC {
    [QIMFastEntrance openNotReadMessageVC];
}

+ (void)openQIMPublicNumberVC {
    [QIMFastEntrance openQIMPublicNumberVC];
}

+ (void)openMyFileVC {
    [QIMFastEntrance openMyFileVC];
}

+ (void)openOrganizationalVC {
    [QIMFastEntrance openOrganizationalVC];
}

+ (void)openQRCodeVC {
    [QIMFastEntrance openQRCodeVC];
}

+ (void)openRobotChatVC:(NSString *)robotJid {
    [QIMFastEntrance openRobotChatVC:robotJid];
}

+ (void)openQTalkNotesVC {
    [QIMFastEntrance openQTalkNotesVC];
}

+ (void)openTransferConversation:(NSString *)shopId withVistorId:(NSString *)realJid {
    [QIMFastEntrance openTransferConversation:shopId withVistorId:realJid];
}

+ (void)openMyAccountInfo {
    [QIMFastEntrance openMyAccountInfo];
}

+ (void)showQRCodeWithQRId:(NSString *)qrId withType:(NSInteger)qrcodeType {
    [QIMFastEntrance showQRCodeWithQRId:qrId withType:qrcodeType];
}

+ (void)signOut {
    [QIMFastEntrance signOut];
}

+ (void)signOutWithNoPush {
    [QIMFastEntrance signOutWithNoPush];
}

@end
