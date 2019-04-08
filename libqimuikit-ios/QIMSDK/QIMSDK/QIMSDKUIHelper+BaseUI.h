//
//  QIMSDKUIHelper+BaseUI.h
//  QIMSDK
//
//  Created by 李露 on 2018/9/29.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMSDKUIHelper.h"

@class Message;

@interface QIMSDKUIHelper (BaseUI)

- (void)launchMainControllerWithWindow:(UIWindow *)window;

- (void)launchMainAdvertWindow;

- (UIView *)getQIMSessionListViewWithBaseFrame:(CGRect)frame;

//获取单人个人信息VC -> scheme : "/openSingleChatInfo"
- (UIViewController *)getUserChatInfoByUserId:(NSString *)userId;

//获取单人名片VC -> scheme : "/openUserCard"
- (UIViewController *)getUserCardVCByUserId:(NSString *)userId;

//获取群名片VC -> scheme : "/openGroupChatInfo"
- (UIViewController *)getQIMGroupCardVCByGroupId:(NSString *)groupId;

//获取Consult会话VC
- (UIViewController *)getConsultChatByChatType:(NSInteger)chatType UserId:(NSString *)userId WithVirtualId:(NSString *)virtualId;

//获取单人会话VC -> scheme : "/openSingleChat"
- (UIViewController *)getSingleChatVCByUserId:(NSString *)userId;

//获取群会话VC -> scheme : "/openGroupChat"
- (UIViewController *)getGroupChatVCByGroupId:(NSString *)groupId;

//获取HeadLine系统消息会话VC -> scheme : "/headLine"
- (UIViewController *)getHeaderLineVCByJid:(NSString *)jid;

//获取RNVC -> scheme : "rnservice", 参数来自scheme
- (UIViewController *)getVCWithNavigation:(UINavigationController *)navVC
                            WithHiddenNav:(BOOL)hiddenNav
                               WithModule:(NSString *)module
                           WithProperties:(NSDictionary *)properties;

//获取机器人名片VC
- (UIViewController *)getRobotCard:(NSString *)robotJid;

//获取RN搜索VC -> scheme : "rnsearch"
- (UIViewController *)getRNSearchVC;

//获取我的好友列表VC
- (UIViewController *)getUserFriendsVC;

//获取我的群组列表VC
- (UIViewController *)getQIMGroupListVC;

//获取未读消息列表VC -> scheme : "/unreadList"
- (UIViewController *)getNotReadMessageVC;

//scheme : "/publicNumber"
- (UIViewController *)getQIMPublicNumberVC;

//获取我的文件VC -> scheme : "/myfile"
- (UIViewController *)getMyFileVC;

//获取组织架构VC -> scheme : "/openOrganizational"
- (UIViewController *)getOrganizationalVC;

- (UIViewController *)getRobotChatVC:(NSString *)robotJid;

- (UIViewController *)getQTalkNotesVC;

//获取我的红包VC -> scheme : "/hongbao"
- (UIViewController *)getMyRedPack;

//获取余额查询VC -> scheme : "/hongbao_balance"
- (UIViewController *)getMyRedPackageBalance;

- (UIViewController *)getQRCodeWithQRId:(NSString *)qrId withType:(NSInteger)qrcodeType;

- (UIViewController *)getContactSelectionVC:(Message *)msg withExternalForward:(BOOL)externalForward;

@end
