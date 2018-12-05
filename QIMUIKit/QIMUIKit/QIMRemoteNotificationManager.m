//
//  QIMRemoteNotificationManager.m
//  qunarChatIphone
//
//  Created by chenjie on 2016/09/14.
//
//

#import "QIMRemoteNotificationManager.h"
#import "QIMCommonUIFramework.h"
#import "QIMGroupChatVC.h"
#import "QIMChatVC.h"

@implementation QIMRemoteNotificationManager

+ (void)checkUpNotifacationHandle {
    
    NSDictionary * infoDic = [[QIMKit sharedInstance] userObjectForKey:@"LaunchByRemoteNotificationUserInfo"];
    if (infoDic) {
        [self openChatSessionWithInfoDic:infoDic];
        [[QIMKit sharedInstance] removeUserObjectForKey:@"LaunchByRemoteNotificationUserInfo"];
    }
}

//前往回话列表
+ (void)openChatSessionWithInfoDic:(NSDictionary *)userInfo
{
    NSDictionary * userInfoDic = userInfo[@"aps"];
    if (userInfoDic) {
        NSString * userId = userInfoDic[@"userid"];
        if (userId.length) {
            UINavigationController * navC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
            if ([[[QIMKit sharedInstance] getCurrentSessionUserId] isEqualToString:userId]) {
                return;
            }
            BOOL isGroup = [userId rangeOfString:@"@conference."].location != NSNotFound;
            if (isGroup) {
                NSDictionary * groupInfoDic = [[QIMKit sharedInstance] getGroupCardByGroupId:userId];
                [[QIMKit sharedInstance] openGroupSessionByGroupId:userId ByName:[groupInfoDic objectForKey:@"Name"]];
                QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
                [chatGroupVC setTitle:[groupInfoDic objectForKey:@"Name"]];
                [chatGroupVC setChatId:userId];
                if ([navC respondsToSelector:@selector(popToRootVCThenPush:animated:)]) {
                    
                    [navC popToRootVCThenPush:chatGroupVC animated:YES];
                }
            } else{
                NSDictionary * uInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
                [[QIMKit sharedInstance] openChatSessionByUserId:userId ByName:[uInfoDic objectForKey:@"Name"]];
                
                QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
                [chatVC setStype:kSessionType_Chat];
                [chatVC setChatId:userId];
                [chatVC setName:[uInfoDic objectForKey:@"Name"]]; 
                [chatVC setChatType:ChatType_SingleChat];
                NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
                [chatVC setTitle:remarkName?remarkName:[uInfoDic objectForKey:@"Name"]];
                if ([navC respondsToSelector:@selector(popToRootVCThenPush:animated:)]) {
                    
                    [navC popToRootVCThenPush:chatVC animated:YES];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        }
    }
}


@end
