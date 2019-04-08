//
//  QIMSDKUIHelper+JumpHandle.h
//  QIMSDK
//
//  Created by 李露 on 2018/9/29.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMSDKUIHelper.h"

@interface QIMSDKUIHelper (JumpHandle)

- (BOOL)parseURL:(NSURL *)url;

- (void)sendMailWithRootVc:(UIViewController *)rootVc ByUserId:(NSString *)userId;

+ (void)openUserChatInfoByUserId:(NSString *)userId;

+ (void)openUserCardVCByUserId:(NSString *)userId;

+ (void)openQIMGroupCardVCByGroupId:(NSString *)groupId;

+ (void)openConsultChatByChatType:(NSInteger)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId;

+ (void)openSingleChatVCByUserId:(NSString *)userId;

+ (void)openGroupChatVCByGroupId:(NSString *)groupId;

+ (void)openHeaderLineVCByJid:(NSString *)jid;

+ (void)openQIMRNVCWithModuleName:(NSString *)moduleName WithProperties:(NSDictionary *)properties;

+ (void)openRobotCard:(NSString *)robotJId;

+ (void)openWebViewWithHtmlStr:(NSString *)htmlStr showNavBar:(BOOL)showNavBar;
+ (void)openWebViewForUrl:(NSString *)url showNavBar:(BOOL)showNavBar;

+ (void)openRNSearchVC;

+ (void)openUserFriendsVC;

+ (void)openQIMGroupListVC;

+ (void)openNotReadMessageVC;

+ (void)openQIMPublicNumberVC;

+ (void)openMyFileVC;

+ (void)openOrganizationalVC;

+ (void)openQRCodeVC;

+ (void)openRobotChatVC:(NSString *)robotJid;

+ (void)openQTalkNotesVC;

+ (void)openTransferConversation:(NSString *)shopId withVistorId:(NSString *)realJid;

+ (void)openMyAccountInfo;

+ (void)showQRCodeWithQRId:(NSString *)qrId withType:(NSInteger)qrcodeType;

//退出登录-> scheme : logout
+ (void)signOut;

+ (void)signOutWithNoPush;

@end
