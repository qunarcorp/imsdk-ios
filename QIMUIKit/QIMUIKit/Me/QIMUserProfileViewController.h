//
//  QIMUserProfileViewController.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/25.
//

#import "QIMCommonUIFramework.h"
#import "QIMUserInfoModel.h"

@interface QIMUserProfileViewController : QTalkViewController

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) QIMUserInfoModel *model;

@property (nonatomic, assign) BOOL myOwnerProfile; //是否打开的我个人资料

@end
