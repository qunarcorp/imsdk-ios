//
//  QTalk.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QTalk.h"
#import "QIMKitPublicHeader.h"
#import "QIMIconFont.h"
#import "QIMImageManager.h"
#import "QIMEmotionManager.h"

static QTalk *__global_qtalk = nil;

@implementation QTalk

+ (void)load {
    [[QTalk sharedInstance] initConfiguration];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __global_qtalk = [[QTalk alloc] init];
    });
    return __global_qtalk;
}

- (void)initConfiguration{
    //初始化字体集
    [QIMIconFont setFontName:@"QTalk-QChat"];
    
    //初始化图片缓存地址
    [[QIMImageManager sharedInstance] initWithQIMImageCacheNamespace:@"QIMImageCache"];

    // 初始化表情
    [QIMEmotionManager sharedInstance];
    // 初始化管理类
    [QIMKit sharedInstance];
    // 注册支持的消息类型
    // 文本消息
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMDefalutMessageCell" ForMessageType:QIMMessageType_Text];
    [[QIMKit sharedInstance] setMsgShowText:@"[文本]" ForMessageType:QIMMessageType_Text];
    // 图片
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSingleChatImageCell" ForMessageType:QIMMessageType_Image];
    [[QIMKit sharedInstance] setMsgShowText:@"[图片]" ForMessageType:QIMMessageType_Image];
    [[QIMKit sharedInstance] setMsgShowText:@"[表情]" ForMessageType:QIMMessageType_ImageNew];

    // 语音
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSingleChatVoiceCell" ForMessageType:QIMMessageType_Voice];
    [[QIMKit sharedInstance] setMsgShowText:@"[语音]" ForMessageType:QIMMessageType_Voice];
    // 文件
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMFileCell" ForMessageType:QIMMessageType_File];
    [[QIMKit sharedInstance] setMsgShowText:@"[文件]" ForMessageType:QIMMessageType_File];
    // 时间戳
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSingleChatTimestampCell" ForMessageType:QIMMessageType_Time];
    // Topic
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMGroupTopicCell" ForMessageType:QIMMessageType_Topic];
    [[QIMKit sharedInstance] setMsgShowText:@"[群公告]" ForMessageType:QIMMessageType_Topic];
    // Location Share 
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMLocationShareMsgCell" ForMessageType:QIMMessageType_LocalShare];
    // card Share
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMCardShareMsgCell" ForMessageType:QIMMessageType_CardShare];
    [[QIMKit sharedInstance] setMsgShowText:@"[位置分享]" ForMessageType:QIMMessageType_LocalShare];
    
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMShareLocationChatCell" ForMessageType:QIMMessageType_shareLocation];
    [[QIMKit sharedInstance] setMsgShowText:@"[位置共享]" ForMessageType:QIMMessageType_shareLocation];
    
    // Video
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMVideoMsgCell" ForMessageType:QIMMessageType_SmallVideo];
    [[QIMKit sharedInstance] setMsgShowText:@"[视频]" ForMessageType:QIMMessageType_SmallVideo];
    // Source Code
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSourceCodeCell" ForMessageType:QIMMessageType_SourceCode];
    [[QIMKit sharedInstance] setMsgShowText:@"[代码段]" ForMessageType:QIMMessageType_SourceCode];
//    QIMMessageType_Markdown
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSourceCodeCell" ForMessageType:QIMMessageType_Markdown];
    [[QIMKit sharedInstance] setMsgShowText:@"[Markdown]" ForMessageType:QIMMessageType_Markdown];
    // burn after read
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMBurnAfterReadMsgCell" ForMessageType:QIMMessageType_BurnAfterRead];
    [[QIMKit sharedInstance] setMsgShowText:@"[阅后即焚消息]" ForMessageType:QIMMessageType_BurnAfterRead];
    
    // red pack
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRedPackCell" ForMessageType:QIMMessageType_RedPack];
    [[QIMKit sharedInstance] setMsgShowText:@"[红包]" ForMessageType:QIMMessageType_RedPack];
    
    // red pack desc
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRedPackDescCell" ForMessageType:QIMMessageType_RedPackInfo];
    [[QIMKit sharedInstance] setMsgShowText:@"[红包]" ForMessageType:QIMMessageType_RedPackInfo];
    
    //预测对赌
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMForecastCell" ForMessageType:QIMMessageType_Forecast];
    [[QIMKit sharedInstance] setMsgShowText:@"[预测]" ForMessageType:QIMMessageType_Forecast];
    
    //抢单消息
    [[QIMKit sharedInstance] setMsgShowText:@"[抢单]" ForMessageType:MessageType_C2BGrabSingle];
    [[QIMKit sharedInstance] setMsgShowText:@"[抢单]" ForMessageType:MessageType_QCZhongbao];

    
    // red pack desc
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRedPackDescCell" ForMessageType:QIMMessageType_RedPackInfo];
    [[QIMKit sharedInstance] setMsgShowText:@"[红包]" ForMessageType:QIMMessageType_RedPackInfo];
    
    // AA收款
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMAACollectionCell" ForMessageType:QIMMessageType_AA];
    [[QIMKit sharedInstance] setMsgShowText:@"[AA收款]" ForMessageType:QIMMessageType_AA];
    
    // AA收款 desc
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMAACollectionDescCell" ForMessageType:QIMMessageType_AAInfo];
    [[QIMKit sharedInstance] setMsgShowText:@"[AA收款]" ForMessageType:QIMMessageType_AAInfo];
    
    // 产品信息
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMProductInfoCell" ForMessageType:QIMMessageType_product];
    [[QIMKit sharedInstance] setMsgShowText:@"[产品信息]" ForMessageType:QIMMessageType_product];
    
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMExtensibleProductCell" ForMessageType:QIMMessageType_ExProduct];
    [[QIMKit sharedInstance] setMsgShowText:@"[产品信息]" ForMessageType:QIMMessageType_ExProduct];
    
    // 活动
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMActivityCell" ForMessageType:QIMMessageType_activity];
    [[QIMKit sharedInstance] setMsgShowText:@"[活动]" ForMessageType:QIMMessageType_activity];
    
    // 撤回消息
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMSingleChatTimestampCell" ForMessageType:QIMMessageType_Revoke];
    [[QIMKit sharedInstance] setMsgShowText:@"撤回了一条消息" ForMessageType:QIMMessageType_Revoke];
    
#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
    //语音聊天
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRTCChatCell" ForMessageType:QIMWebRTC_MsgType_Audio];
    //视频聊天
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRTCChatCell" ForMessageType:QIMWebRTC_MsgType_Video];
    
    [[QIMKit sharedInstance] setMsgShowText:@"[语音聊天]" ForMessageType:QIMWebRTC_MsgType_Audio];
    
    [[QIMKit sharedInstance] setMsgShowText:@"[视频聊天]" ForMessageType:QIMWebRTC_MsgType_Video];
#endif
#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
    //视频会议
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRTCChatCell" ForMessageType:QIMMessageTypeWebRtcMsgTypeVideoMeeting];

    [[QIMKit sharedInstance] setMsgShowText:@"[视频会议]" ForMessageType:QIMMessageTypeWebRtcMsgTypeVideoMeeting];
#endif
    // 窗口抖动
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMShockMsgCell" ForMessageType:QIMMessageType_Shock];
    [[QIMKit sharedInstance] setMsgShowText:@"[窗口抖动]" ForMessageType:QIMMessageType_Shock];

    //问题列表
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRobotQuestionCell" ForMessageType:QIMMessageTypeRobotQuestionList];
    [[QIMKit sharedInstance] setMsgShowText:@"[问题列表]" ForMessageType:QIMMessageTypeRobotQuestionList];
    
    //机器人答案
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMRobotAnswerCell" ForMessageType:QIMMessageType_RobotAnswer];
    [[QIMKit sharedInstance] setMsgShowText:@"[机器人回答]" ForMessageType:QIMMessageType_RobotAnswer];
    
    // 第三方通用Cell
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMCommonTrdInfoCell" ForMessageType:QIMMessageType_CommonTrdInfo];
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMCommonTrdInfoCell" ForMessageType:QIMMessageType_CommonTrdInfoPer];
    //加密消息Cell
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMEncryptChatCell" ForMessageType:QIMMessageType_Encrypt];
    [[QIMKit sharedInstance] setMsgShowText:@"[加密消息]" ForMessageType:QIMMessageType_Encrypt];
    
    //会议室提醒
    [[QIMKit sharedInstance] registerMsgCellClassName:@"QIMMeetingRemindCell" ForMessageType:QIMMessageTypeMeetingRemind];
    [[QIMKit sharedInstance] setMsgShowText:@"会议室提醒" ForMessageType:QIMMessageTypeMeetingRemind];
    
    [[QIMKit sharedInstance] setMsgShowText:@"收到一条消息" ForMessageType:QIMMessageType_GroupNotify];
}

@end
