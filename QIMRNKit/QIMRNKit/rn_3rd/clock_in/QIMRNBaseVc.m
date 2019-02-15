//
//  QIMRNBaseVc.m
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMRNBaseVc.h"
#import "QimRNBModule.h"
#import "QimRNBModule+QIMUser.h"
#import "QimRNBModule+QIMGroup.h"
#import "QimRNBModule+MySetting.h"
#import "UIApplication+QIMApplication.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTEventDispatcher.h>
#import "Toast.h"

#import "QIMChatVC.h"
#import "QIMPhotoBrowserNavController.h"

@interface QIMRNBaseVc ()

@property (nonatomic, assign) BOOL prepNavHidden;

@end

@implementation QIMRNBaseVc

- (void)willReShow{
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"QIM_RN_Check_Version" body:@{@"name": @"aaa"}];
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"QIM_RN_Will_Show" body:@{@"name": @"aaa"}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _prepNavHidden = self.navigationController.navigationBarHidden;
    if (self.hiddenNav != _prepNavHidden) {
        _prepNavHidden = self.hiddenNav;
        [self.navigationController setNavigationBarHidden:self.hiddenNav animated:YES];
    }
    [self willReShow];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_prepNavHidden != self.navigationController.navigationBarHidden) {
        _prepNavHidden = self.hiddenNav;
        [self.navigationController setNavigationBarHidden:self.hiddenNav animated:YES];        
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registeNotifications];
    }
    return self;
}

#pragma mark - NSNotification

- (void)registeNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBack:) name:kNotifyVCClose object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBundle:) name:kNotify_QIMRN_BUNDLE_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveFriendPresence:) name:kFriendPresence object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseBigHeader:) name:@"BrowseBigHeader" object:nil];
    //        QIMGroupMemberWillUpdate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupMember:) name:@"QIMGroupMemberWillUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyPersonalSignature:) name:kUpdateMyPersonalSignature object:nil];

    //开始上传头像
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyPersonalSignature:) name:kUpdateMyPersonalSignature object:nil];

    //上传头像结果 成功 ：{"ok":YES, "headerUrl":xxx} / 失败 : {"ok":NO}
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyPhotoSuccess:) name:kMyHeaderImgaeUpdateSuccess object:nil];
    
    //用户头像更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserHeader:) name:kUserVCardUpdate object:nil];
    //用户签名更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserMode:) name:kUserVCardUpdate object:nil];
    //群名称更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupName:) name:kGroupNickNameChanged object:nil];
    //群公告更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupTopic:) name:kGroupNickNameChanged object:nil];
    //上传日志进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUpdateProgress:) name:KNotifyUploadProgress object:nil];
    
    //销毁群
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delMuc:) name:kChatRoomDestroy object:nil];
    //退出群
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delMuc:) name:kChatRoomLeave object:nil];
    //更新用户勋章列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserMedal:) name:kUpdateUserMedal object:nil];
    
    //更新用户Leader
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLeaderCard:) name:kUpdateUserLeaderCard object:nil];
}

- (void)updateBundle:(NSNotification *)notify {
    [self.view removeAllSubviews];
    
    NSURL *jsCodeLocation = [QimRNBModule getJsCodeLocation];
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:self.rnName
                                                 initialProperties:nil
                                                     launchOptions:nil];
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    self.view = rootView;
}

- (void)updateUserHeader:(NSNotification *)notify {
    NSArray *xmppIds = notify.object;
    NSString *userJid = [xmppIds firstObject];
    NSDictionary *userInfo = [QimRNBModule qimrn_getUserInfoByUserId:userJid];
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateNick" body:@{@"UserId":userJid, @"UserInfo":userInfo}];
}

- (void)updateUserMode:(NSNotification *)notify {
    NSArray *xmppIds = notify.object;
    NSString *userJid = [xmppIds firstObject];
    NSDictionary *userInfo = [QimRNBModule qimrn_getUserInfoByUserId:userJid];
    if (userInfo.count) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateNick" body:@{@"UserId":userJid, @"UserInfo":userInfo}];
    }
}

- (void)updateGroupName:(NSNotification *)notify {
    
    NSArray *groupIds = notify.object;
    NSString *groupId = [groupIds firstObject];
    NSDictionary *groupInfo = [QimRNBModule qimrn_getGroupInfoByGroupId:groupId];
    if (groupInfo.count) {
        NSString *groupName = [groupInfo objectForKey:@"Name"];
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateGroupName" body:@{@"GroupId":groupId, @"GroupName":groupName?groupName:@""}];
    }
}

- (void)updateGroupTopic:(NSNotification *)notify {
    
    NSArray *groupIds = notify.object;
    NSString *groupId = [groupIds firstObject];
    NSDictionary *groupInfo = [QimRNBModule qimrn_getGroupInfoByGroupId:groupId];
    if (groupInfo.count) {
        NSString *groupTopic = [groupInfo objectForKey:@"Topic"];
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateGroupTopic" body:@{@"GroupId":groupId, @"GroupTopic":groupTopic?groupTopic:@""}];
    }
}

- (void)updateUpdateProgress:(NSNotification *)notify {
    
    float uploadProgress = [notify.object floatValue];
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateFeedBackProgress" body:@{@"progress":@(uploadProgress)}];
}

- (void)delMuc:(NSNotification *)notify {
    NSString *groupId = notify.object;
    if (groupId) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"Del_Destory_Muc" body:@{@"groupId":groupId}];
    }
}

- (void)updateUserMedal:(NSNotification *)notify {
//    @{@"userId":xmppId, @"UserMedals":data}
    NSDictionary *notifyDic = notify.object;
    NSString *userId = [notifyDic objectForKey:@"UserId"];
    if (userId.length > 0 && notifyDic.count > 0) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateMedal" body:notifyDic];
    }
}

- (void)updateUserLeaderCard:(NSNotification *)notify {
    QIMVerboseLog(@"updateUserLeaderCard : %@", notify);
    NSDictionary *notifyDic = notify.object;
    NSString *userId = [notifyDic objectForKey:@"UserId"];
    NSDictionary *userLeaderInfo = [QimRNBModule qimrn_getUserLeaderInfoByUserId:userId];
    if (userId.length > 0 && userLeaderInfo.count > 0) {
        QIMVerboseLog(@"updateLeaderInfo : %@", userLeaderInfo);
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateLeader" body:@{@"LeaderInfo":userLeaderInfo ? userLeaderInfo : @{}}];
    }
}

- (void)goBack:(NSNotification *)notify {
    if ([self.rnName isEqualToString:notify.object]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onReceiveFriendPresence:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *presenceDic = notify.userInfo;
        NSString *result = [presenceDic objectForKey:@"result"];
        if ([result isEqualToString:@"success"]) {
            [self openChatSessionWithUserId:notify.object UserName:notify.object];
        } else {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"添加好友" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertVc addAction:okAction];
            UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            [navVC presentViewController:alertVc animated:YES completion:nil];
        }
    });
}

- (void)updateGroupMember:(NSNotification *)notify {
    
    NSString *groupId = notify.object;
    if (groupId.length > 0) {
        NSArray *groupmembers = [QimRNBModule qimrn_getGroupMembersByGroupId:groupId];
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updateGroupMember" body:@{@"GroupId":groupId, @"GroupMembers": groupmembers?groupmembers:@[]}];
    }
}

- (void)updateMyPersonalSignature:(NSNotification *)notify {
    
    [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"updatePersonalSignature" body:@{@"UserId":[[QIMKit sharedInstance] getLastJid], @"PersonalSignature":[QimRNBModule qimrn_getUserMoodByUserId:[[QIMKit sharedInstance] getLastJid]]}];
}

- (void)updateMyPhotoSuccess:(NSNotification *)notify {
    if (notify.object) {
        [[QimRNBModule getStaticCacheBridge].eventDispatcher sendAppEventWithName:@"imageUpdateEnd" body:notify.object];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    QIMVerboseLog(@"QIMRNBaseVc %@ dealloc", self.rnName);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)openChatSessionWithUserId:(NSString *)userId UserName:(NSString *)userName {
    [QIMFastEntrance openSingleChatVCByUserId:userId];
    /*
    ChatType chatType = [[QIMKit sharedInstance] openChatSessionByUserId:userId];
    
    QIMChatVC *chatVC  = [[QIMChatVC alloc] init];
    [chatVC setStype:kSessionType_Chat];
    [chatVC setChatId:userId];
    [chatVC setName:userName];
    */
    /*
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        NSString *realJid = [[QIMKit sharedInstance] getRealJidForVirtual:[userId componentsSeparatedByString:@"@"].firstObject];
        realJid = [realJid stringByAppendingString:[NSString stringWithFormat:@"@%@", [[QIMKit sharedInstance] qimNav_Domain]]];
        [chatVC setVirtualJid:userId];
        [chatVC setChatId:realJid];
    }
    */
    /*
    [chatVC setChatType:chatType];
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
    [chatVC setTitle:remarkName?remarkName:userName];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
    });
    UINavigationController *navVC = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [navVC popToRootVCThenPush:chatVC animated:YES];
    */
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end


@implementation QIMRNBaseVc (UserCard)

#pragma mark - 浏览大头像
// 查看大头像
- (void)browseBigHeader:(NSNotification *)notify {
    
    NSDictionary *param = [notify object];
    [[QIMFastEntrance sharedInstance] browseBigHeader:param];
}

@end
