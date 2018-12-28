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
    if (userInfo.count) {
        NSString * userId = userInfo[@"userid"];
        if (userId.length) {
            UINavigationController * navC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
            if ([[[QIMKit sharedInstance] getCurrentSessionUserId] isEqualToString:userId]) {
                return;
            }
            NSInteger chatType = [[userInfo objectForKey:@"chattype"] integerValue];
            switch (chatType) {
                case 6: {
                    [QIMFastEntrance openSingleChatVCByUserId:userId];
                }
                    break;
                case 7: {
                    [QIMFastEntrance openGroupChatVCByGroupId:userId];
                }
                    break;
                case 132: {
                    NSInteger qchatId = [[userInfo objectForKey:@"chatid"] integerValue];
                    NSString *realJid = [userInfo objectForKey:@"realjid"];
                    if (qchatId == 4) {
                        [QIMFastEntrance openConsultServerChatByChatType:ChatType_ConsultServer WithVirtualId:userId WithRealJid:realJid];
                    } else {
                        [QIMFastEntrance openConsultChatByChatType:ChatType_Consult UserId:realJid WithVirtualId:userId];
                    }
                }
                    break;
                default:
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySelectTab object:@(0)];
        }
    }
}


@end
