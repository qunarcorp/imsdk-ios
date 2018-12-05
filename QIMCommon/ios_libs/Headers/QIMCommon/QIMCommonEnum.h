//
//  QIMCommonEnum.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/30.
//

#ifndef QIMCommonEnum_h
#define QIMCommonEnum_h

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QIMProjectTypeQTalk = 0,
    QIMProjectTypeQChat,
} QIMProjectType;

typedef enum {
    QDDealState_None = 0,
    QDDealState_True,
    QDDealState_Faild,
    QDDealState_TimeOut,
} QDDealState;

typedef enum {
    AdvertType_Touch = 1,
    AdvertType_Image = 2,
    AdvertType_Video = 3,
} AdvertType;

typedef enum {
    QTLoginTypeSms = 0,
    QTLoginTypePwd = 1,
    QTLoginTypeNone = 2,
} QTLoginType;

typedef enum {
    AppWorkState_Logout = 0,
    AppWorkState_Logining = 1,
    AppWorkState_Updating = 2,
    AppWorkState_Login = 3,
    AppWorkState_NotNetwork = 4,
    AppWorkState_NetworkNotWork = 5,
    AppWorkState_ReLogining = 6,
    AppWorkState_Upgrading = 7, //升级数据中
} AppWorkState;

typedef enum {
    UserPrecenseStatus_Away,
    UserPrecenseStatus_Dnd,
    UserPrecenseStatus_None,
} UserPrecenseStatus;

typedef enum {
    PublicNumberType_Robot,
    PublicNumberType_News,
    PublicNumberType_System,
    PublicNumberType_Notice,
} PublicNumberType;

typedef enum {
    MessageReadFlagDidSend = 3,
    MessageReadFlagDidRead = 4,
} MessageReadFlag;

typedef enum {
    PublicNumberMsgType_None                = 0,
    PublicNumberMsgType_Text                = 1,
    PublicNumberMsgType_Voice               = 2,
    PublicNumberMsgType_Image               = 3,
    PublicNumberMsgType_SogoIcon            = 4,
    PublicNumberMsgType_File                = 5,
    PublicNumberMsgType_Action              = 6,
    PublicNumberMsgType_RichText            = 7,
    PublicNumberMsgType_ActionRichText      = 8,
    PublicNumberMsgType_ClientCookie        = 9,
    PublicNumberMsgType_PostBackCookie      = 10,
    MessageType_note                        = 11,
    PublicNumberMsgType_time                = 101,
    // 扩展消息类型
    PublicNumberMsgType_LocalShare          = 1 << 4,
    PublicNumberMsgType_SmallVideo          = 1 << 5,
    PublicNumberMsgType_SourceCode          = 1 << 6,
    PublicNumberMsgType_BurnAfterRead       = 1 << 7,
    
    MessageType_virtualRbt = 1 << 14,//callcenter 机器人消息
    MessageType_instruction = 1 << 15,//callcenter 指令类型
    
    MessageType_C2BGrabSingle = 2003,  //C2B抢单
    MessageType_C2BGrabSingleFeedBack = 2004, //C2B抢单返回
    MessageType_QCZhongbao  = 2005, //众包消息
    
    PublicNumberMsgType_Notice              = 1 << 27,
    PublicNumberMsgType_OrderNotify         = 1 << 28,
    
} PublicNumberMsgType;

typedef enum {
    ShareLocationType_Join = 1,
    ShareLocationType_Info = 2,
    ShareLocationType_Quit = 3,
} ShareLocationType;

typedef enum {
    QIMFileCacheTypeDefault,
    QIMFileCacheTypeColoction,
} QIMFileCacheType;

typedef enum ProtocolType{
    ProtocolType_Xmpp,
    ProtocolType_Protobuf,
} ProtocolType;

typedef enum {
    QIMGroupIdentityNone        = 0,
    QIMGroupIdentityAdmin       = 1,
    QIMGroupIdentityOwner       = 2,
} QIMGroupIdentity;

typedef enum {
    QIMVerifyMode_AllAgree = 3,    //全部同意
    QIMVerifyMode_Validation = 1,  //人工同意
    QIMVerifyMode_Question_Answer = 2,  //问题认证
    QIMVerifyMode_AllRefused = 0,  //全部拒绝
} QIMVerifyMode;

typedef enum {
    QIMTextBarExpandViewItemType_Photo               = 0,//相册
    QIMTextBarExpandViewItemType_Camer               = 1,//拍照
    QIMTextBarExpandViewItemType_QuickReply          = 2,//快捷回复
    QIMTextBarExpandViewItemType_VideoCall           = 3,//视频聊天
    QIMTextBarExpandViewItemType_Location            = 4,//发送位置
    QIMTextBarExpandViewItemType_BurnAfterReading    = 5,//阅后即焚
    QIMTextBarExpandViewItemType_MyFiles             = 6,//我的文件
    QIMTextBarExpandViewItemType_Shock               = 7,//窗口抖动
    QIMTextBarExpandViewItemType_ChatTransfer        = 8,//会话转移
    QIMTextBarExpandViewItemType_ShareCard           = 9,//分享名片
    QIMTextBarExpandViewItemType_RedPack             = 10,//红包
    QIMTextBarExpandViewItemType_AACollection        = 11,//AA收款
    QIMTextBarExpandViewItemType_SendProduct         = 12,//发送产品
    QIMTextBarExpandViewItemType_SendActivity        = 13,//发送活动
} QIMTextBarExpandViewItemType;

typedef enum {
    
    QIMMessageType_NewMsgTag   = -111,
    QIMMessageType_TransToUser = -33,
    QIMMessageType_PNote       = -11,
    QIMMessageType_CNote       = 11,
    QIMMessageType_Revoke      = -1,
    QIMMessageType_None        = 0,
    QIMMessageType_Text        = 1,
    QIMMessageType_Voice       = 2,
    QIMMessageType_Image       = 3,
    QIMMessageType_SogoIcon    = 4,
    QIMMessageType_File        = 5,
    QIMMessageType_Topic       = 6,
    
    QIMMessageType_Reply       = 9,
    QIMMessageType_Shock       = 10,
    QIMMessageType_NewAt       = 12,
    QIMMessageType_Markdown    = 13,
    QIMMessageType_GroupNotify = 15,
    QIMMessageType_ImageNew    = 30,
    QIMMessageType_RobotAnswer = 47,
    QIMMessageType_Time        = 101,
    // 扩展消息类型
    QIMMessageType_LocalShare  = 1 << 4,
    QIMMessageType_SmallVideo  = 1 << 5,
    QIMMessageType_SourceCode  = 1 << 6,
    QIMMessageType_BurnAfterRead = 1 << 7,
    QIMMessageType_CardShare = 1 << 8,
    QIMMessageTypeMeetingRemind = 257,
    QIMMessageType_RedPack = 1 << 9,
    QIMMessageType_AA = (1 << 9) + 1,
    QIMMessageType_RedPackInfo = 1 << 10,
    QIMMessageType_AAInfo = (1 << 10)+ 1,
    QIMMessageType_product = 1 << 12,
    QIMMessageType_shareLocation = 1 << 13,
    
    // 第三方平台
    QIMMessageType_Consult = 2001,
    QIMMessageType_ConsultResult = 2002,
    QIMMessageType_MicroTourGuide = 3001,
    QIMMessageType_activity = 511,
    
    // 通用的第三方信息Cell 类似链接形式的消息气泡
    QIMMessageType_CommonTrdInfo = 666,
    QIMMessageType_CommonTrdInfoPer = 667,//desc显示完整的 666
    QIMMessageType_Forecast = 668,  //预测消息(666消息复制版，PC只显示body)
    QIMMessageType_ExProduct = 888,
    
    // 扩展机器人里的消息
    QIMMessageType_RichText            = 7,
    QIMMessageType_ActionRichText      = 8,
    QIMMessageType_Notice              = 1 << 27,
    
    QIMWebRTC_MsgType_Audio = 131072,
    QIMWebRTC_MsgType_Video = 65535,
    QIMMessageTypeRobotQuestionList = 65536,
    QIMMessageTypeRobotTurnToUser = 65537,
    QIMMessageTypeWebRtcMsgTypeVideoMeeting = 5001,
    
    QIMMessageType_TransChatToCustomer = 1001,
    QIMMessageType_TransChatToCustomer_Feedback = 1003,
    QIMMessageType_TransChatToCustomerService = 1002,
    QIMMessageType_TransChatToCustomerService_Feedback = 1004,
    
    QIMMessageType_Encrypt = 404, //加密消息
    
} QIMMessageType;

typedef enum {
    MessageClassType_Normal = 0,
    MessageClassType_Info = 1,
    MessageClassType_Hidden = 2,
} MessageClassType;

typedef enum {
    ChatType_SingleChat        = 0,
    ChatType_GroupChat         = 1,
    ChatType_System            = 2,
    ChatType_PublicNumber      = 3,
    ChatType_Consult           = 4,
    ChatType_ConsultServer     = 5,
    ChatType_CollectionChat    = 6,
} ChatType;

typedef enum {
    MessageState_none      = 0,
    MessageState_Waiting,
    MessageState_Success,
    MessageState_Faild,
    MessageState_NotRead    = 0xf,   //未读
    MessageState_didRead    = 0x10, //已读
    MessageState_didDestroyed = 0x11,//已销毁
    MessageState_didControl = 0x12, //已操作
} MessageState;

typedef enum {
    MessageDirection_Sent = 0,
    MessageDirection_Received = 1,
} MessageDirection;

typedef enum {
    IMPlatform_UNKNOW   = 0,
    IMPlatform_Mac      = 1,
    IMPlatform_iOS      = 2,
    IMPlatform_PC       = 3,
    IMPlatform_Web      = 4,
    IMPlatform_Android  = 5,
} IMPlatform;

typedef enum : NSUInteger {
    QIMMSGSETTINGSHOW_CONTENT = 0x01,
    QIMMSGSETTINGPUSH_ONLINE = QIMMSGSETTINGSHOW_CONTENT << 1,
    QIMMSGSETTINGSOUND_INAPP = QIMMSGSETTINGPUSH_ONLINE << 1,
    QIMMSGSETTINGVIBRATE_INAPP = QIMMSGSETTINGSOUND_INAPP << 1,
    QIMMSGSETTINGPUSH_SWITCH = QIMMSGSETTINGVIBRATE_INAPP << 1
} QIMMSGSETTING;

typedef enum : NSUInteger {
    QIMClientConfigTypeKMarkupNames = 0,        //用户备注（通用）
    QIMClientConfigTypeKCollectionCacheKey,     //收藏表情（通用）
    QIMClientConfigTypeKStickJidDic,            //置顶会话（通用）
    QIMClientConfigTypeKNotificationSetting,    //客户端通知中心设置（通用）
    QIMClientConfigTypeKConversationParamDic,   //众包需求（通用）
    QIMClientConfigTypeKQuickResponse,          //快捷回复（通用）
    QIMClientConfigTypeKChatColorInfo,          //消息气泡颜色
    QIMClientConfigTypeKCurrentFontInfo,        //客户端字体
    QIMClientConfigTypeKNoticeStickJidDic,      //会话提醒
    QIMClientConfigTypeKStarContact,            //星标联系人
    QIMClientConfigTypeKBlackList,              //黑名单
    QIMClientConfigTypeKLocalIncrementUpdateTime, //本地组织架构时间戳
    QIMClientConfigTypeKLocalMucRemarkUpdateTime, //本地群阅读指针时间戳
    QIMClientConfigTypeKLocalMucHistoryUpdateTime, //本地群历史时间戳
    QIMClientConfigTypeKLocalSingleHistoryUpdateTime, //本地单人历史时间戳
    QIMClientConfigTypeKLocalSystemHistoryUpdateTime, //本地系统历史时间戳
    QIMClientConfigTypeKLocalTripUpdateTime,     //本地行程更新时间戳
    QIMClientConfigTypeALL,                     //所有
} QIMClientConfigType;

typedef enum : NSUInteger {
    QIMAppConfigurationModeDebug = 0,
    QIMAppConfigurationModeBeta,
    QIMAppConfigurationModeRelease,
} QIMAppConfigurationMode;

typedef enum {
    QRCodeType_UserQR,
    QRCodeType_GroupQR,
    QRCodeType_RobotQR,
    QRCodeType_ClientNav,
} QRCodeType;

typedef enum : NSUInteger {
    QIMMessageErrCodeRefused = 406,
} QIMMessageErrCode;

typedef enum : NSUInteger {
    QIMCategoryNotifyMsgTypeOrganizational = 1,         //组织架构更新
    QIMCategoryNotifyMsgTypeSession = 2,                //打开新的会话
    QIMCategoryNotifyMsgTypeNavigation = 3,             //导航更新
    QIMCategoryNotifyMsgTypeOPSUnreadCount = 4,         //OPS未读数
    QIMCategoryNotifyMsgTypePersonalConfig = 6,         //个人配置更新
    QIMCategoryNotifyMsgTypeBigIM = 7,                  //大客户端
    QIMCategoryNotifyMsgTypeCalendar = 8,               //日历同步
    QIMCategoryNotifyMsgTypeOnline = 9,                 //其他客户端上线下线通知
    QIMCategoryNotifyMsgTypeAskLog = 10,                //自动收集日志
    QIMCategoryNotifyMsgTypeGlobalNotification = 98,    //全局通知
    QIMCategoryNotifyMsgTypeDesignatedNotification = 99, //指定通知
    QIMCategoryNotifyMsgTypeTickUser = 100,             //踢
} QIMCategoryNotifyMsgType;

static const NSString *QIMNavNameKey = @"title";
static const NSString *QIMNavUrlKey = @"NavUrl";

typedef void(^QIMKitSendTPRequesSuccessedBlock)(NSData *responseData);
typedef void(^QIMKitSendTPRequesFailedBlock)(NSError *error);
typedef void(^QIMKitGetTripAreaAvailableRoomBlock)(NSArray *availableRooms);
typedef void(^QIMKitGetTripMemberCheckBlock)(BOOL isConform);   //isConform 冲突
typedef void(^QIMKitCreateTripBlock)(BOOL success);

#endif /* QIMCommonEnum_h */
