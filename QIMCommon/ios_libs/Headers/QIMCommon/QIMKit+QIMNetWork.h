//
//  QIMKit+QIMNetWork.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit.h"
#import "QIMCommonEnum.h"

@interface QIMKit (QIMNetWork)


/**
 获取当前网络状态

 @return appWorkState
 */
- (AppWorkState)appWorkState;


/**
 检查网络是否能够连接到互联网

 @return YES / NO
 */
- (BOOL)checkNetworkCanUser;


/**
 检查用户是否掉线，是否需要重新登录
 */
- (void)checkNetworkStatus;


/**
 接收网络变更通知

 @param notify 网络变更通知
 */
- (void)onNetworkChange:(NSNotification *)notify;


/**
 更新当前网络状态

 @param appWorkState 网络状态
 */
- (void)updateAppWorkState:(AppWorkState)appWorkState;


/**
 更新当前网络状态为“未登录”
 */
- (void)onDisconnect;

@end
