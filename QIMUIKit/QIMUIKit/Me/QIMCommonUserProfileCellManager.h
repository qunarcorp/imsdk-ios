//
//  QIMCommonUserProfileCellManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/25.
//

#import "QIMCommonUIFramework.h"
#import "QIMCommonTableViewCellData.h"
typedef enum {
    QCUserProfileUserInfo = 0,      //用户
    QCUserProfileHeader,        //头像
    QCUserProfileUserSignature, //个性签名
    QCUserProfileMyQrcode,      //二维码
    QCUserProfileRemark,        //备注
    QCUserProfileUserName,      //用户名称
    QCUserProfileUserId,        //用户Id
    QCUserProfileLeader,        //直属上级
    QCUserProfileWorderId,      //工号
    QCUserProfilePhoneNumber,   //手机号
    QCUserProfileDepartment,    //部门
    QCUserProfileComment,       //评论
    QCUserProfileSendMail,      //发送邮件
    QCUserProfileRNView,        //RN展示
    QCUserProfileCustom,        //自定义
} QCUserProfileType;

@class QIMUserInfoModel;

@interface QIMCommonUserProfileCellManager : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) QIMUserInfoModel *model;
@property (nonatomic, strong) NSDictionary *userInfo;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController WithUserId:(NSString *)userId;

@end
