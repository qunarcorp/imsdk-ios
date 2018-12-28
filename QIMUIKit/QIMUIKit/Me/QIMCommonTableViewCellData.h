//
//  QIMCommonTableViewCellData.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "QIMCommonUIFramework.h"

typedef enum {
    QIMCommonTableViewCellDataTypeBlankLines = 0,       //空行
    QIMCommonTableViewCellDataTypeMine = 1,
    QIMCommonTableViewCellDataTypeMyRedEnvelope,        //红包
    QIMCommonTableViewCellDataTypeBalanceInquiry,       //余额查询
    QIMCommonTableViewCellDataTypeAttendance,           //签到打卡
    QIMCommonTableViewCellDataTypeTotpToken,            //Totp Token
    QIMCommonTableViewCellDataTypeAccountInformation,   //个人信息
    QIMCommonTableViewCellDataTypeMyFile,               //我的文件
    QIMCommonTableViewCellDataTypeFeedback,             //意见反馈
    QIMCommonTableViewCellDataTypeSetting,              //设置
    QIMCommonTableViewCellDataTypeMessageNotification,  //开启消息推送
    QIMCommonTableViewCellDataTypeMessageAlertSound,    //通知提示音
    QIMCommonTableViewCellDataTypeMessageVibrate,       //通知震动提示
    QIMCommonTableViewCellDataTypeMessageShowPreviewText,      //通知显示消息详情
    QIMCommonTableViewCellDataTypeMessageOnlineNotification, //在线也接受通知
    QIMCommonTableViewCellDataTypeShowSignature,        //优先展示心情短语
    QIMCommonTableViewCellDataTypeDressUp,              //个性化装扮
    QIMCommonTableViewCellDataTypeSearchHistory,        //历史消息查询
    QIMCommonTableViewCellDataTypeClearSessionList,     //清空消息列表
    QIMCommonTableViewCellDataTypePrivacy,              //隐私
    QIMCommonTableViewCellDataTypeGeneral,              //通用
    QIMCommonTableViewCellDataTypeUpdateConfig,         //更新配置
    QIMCommonTableViewCellDataTypeContactBlack,         //通讯录黑名单
    QIMCommonTableViewCellDataTypeClearCache,           //清除缓存
    QIMCommonTableViewCellDataTypeMconfig,              //账号管理
    QIMCommonTableViewCellDataTypeServiceMode,          //服务模式
    QIMCommonTableViewCellDataTypeAbout,                //关于
    QIMCommonTableViewCellDataTypeLogout,               //退出登录
    QIMCommonTableViewCellDataTypeGroupName,            //群名称
    QIMCommonTableViewCellDataTypeGroupTopic,           //群公告
    QIMCommonTableViewCellDataTypeGroupPush,            //群消息设置
    QIMCommonTableViewCellDataTypeGroupQRcode,          //群二维码
    QIMCommonTableViewCellDataTypeGroupLeave,           //退出群聊
    QIMCommonTableViewCellDataTypeGroupAdd,             //加入群聊
    QIMCommonTableViewCellDataTypeStickChat,            //置顶聊天
} QIMCommonTableViewCellDataType;

@interface QIMCommonTableViewCellData : NSObject

@property (nonatomic, assign) QIMCommonTableViewCellDataType cellDataType;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic) UIImage *icon;

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName cellDataType:(QIMCommonTableViewCellDataType)cellDataType;

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconName:(NSString *)iconName cellDataType:(QIMCommonTableViewCellDataType)cellDataType;

@end

