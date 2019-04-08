//
//  QCMessageModel.h
//  qunarChatIphone
//
//  Created by c on 15/5/12.
//  Copyright (c) 2015年 c. All rights reserved.
//

#import "QIMCommonUIFramework.h"

//消息类型
typedef enum {
    QCMessageTypeNone,      //未定义
    QCMessageTypeText,      //文本
    QCMessageTypeImage,     //图片
    QCMessageTypeVoice,     //语音
    QCMessageTypeFile,      //文件
    QCMessageTypeNotice,    //通知（系统）
}QCMessageType;

//消息来源
typedef enum {
    QCMessageSourceSingle,  //单聊
    QCMessageSourceGroup,   //群聊

}QCMessageSource;

@interface QCMessageModel : NSObject

@property (nonatomic, strong) NSString        * messageId;              //消息id
@property (nonatomic, strong) NSData          * messageContent;         //消息内容（nsstring）
@property (nonatomic, assign) QCMessageType   * messageType;            //消息类型
@property (nonatomic, assign) QCMessageSource * messageSource;          //消息类型

@property (nonatomic, assign) NSTimeInterval    messageTime;            //消息时间
@property (nonatomic, strong) NSString        * messageTimeToString;    //消息时间（字符串）

@property (nonatomic, strong) NSString        * from;                   //发送方
@property (nonatomic, strong) NSString        * to;                     //接收方

@end
