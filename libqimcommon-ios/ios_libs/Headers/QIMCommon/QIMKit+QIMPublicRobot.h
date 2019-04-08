//
//  QIMKit+QIMPublicRobot.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMPublicRobot)

/**
 get deal id status
 
 @param dealId deal id
 @return state
 */
- (int)getDealIdState:(NSString *)dealId;

/**
 set deal id
 
 @param dealId deal id
 @param state state
 */
- (void)setDealId:(NSString *)dealId ForState:(int)state;

#pragma mark - 公众号名片信息

/**
 根据文件名获取公众号头像
 
 @param fileName 头像文件名称
 @return 头像
 */
- (UIImage *)getPublicNumberHeaderImageByFileName:(NSString *)fileName;

/**
 获取公众号默认头像地址
 
 @return 默认头像地址
 */
- (NSString *)getPublicNumberDefaultHeaderPath;

/**
 根据公众号Id获取公众号名片信息
 
 @param publicNumberId 公众号Id
 @return 公众号名片信息
 */
- (NSDictionary *)getPublicNumberCardByJid:(NSString *)publicNumberId;

/**
 根据公众号Id列表 更新公众号名片
 
 @param publicNumberIdList 公众号Id列表
 @param flag 是否需要更新本地数据库
 */
- (NSArray *)updatePublicNumberCardByIds:(NSArray *)publicNumberIdList WithNeedUpdate:(BOOL)flag;

#pragma mark - sss

/**
 获取推荐机器人
 */
- (NSArray *)recommendRobot;

/**
 注册公众号
 */
- (void)registerPublicNumber;


/**
 获取本地公众号列表
 */
- (NSArray *)getPublicNumberList;


/**
 远端获取公众号列表
 */
- (void)updatePublicNumberList;

/**
 根据公众号Id关注公众号
 
 @param publicNumberId 公众号Id
 @return 是否关注成功
 */
- (BOOL)focusOnPublicNumberId:(NSString *)publicNumberId;

/**
 根据公众号Id取消关注公众号
 
 @param publicNumberId 公众号Id
 @return 是否取消关注成功
 */
- (BOOL)cancelFocusOnPublicNumberId:(NSString *)publicNumberId;


#pragma mark - 公众号消息

/**
 创建公众号消息
 
 @param msg 消息body内容
 @param extendInfo 消息extendInfo
 @param publicNumberId 公众号Id
 @param msgType 消息类型
 @return 消息对象Message
 */
- (Message *)createPublicNumberMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo publicNumberId:(NSString *)publicNumberId msgType:(PublicNumberMsgType)msgType;

/**
 发送消息->公众号
 
 @param msg 消息Body内容
 @param publicNumberId 公众号Id
 @param msgId 消息id
 @param msgType 消息类型
 */
- (Message *)sendMessage:(NSString *)msg ToPublicNumberId:(NSString *)publicNumberId WithMsgId:(NSString *)msgId WihtMsgType:(int)msgType;

/**
 获取公众号消息列表
 
 @param publicNumberId 公众号Id
 @param limit 限制消息条数
 @param offset 偏移量
 @return 消息列表
 */
- (NSArray *)getPublicNumberMsgListById:(NSString *)publicNumberId WihtLimit:(int)limit WithOffset:(int)offset;

/**
 根据公众号Id清空未读消息
 */
- (void)clearNotReadMsgByPublicNumberId:(NSString *)jid;

/**
 设置某公众号下的未读数
 
 @param count 未读数
 @param jid 公众号Id
 */
- (void)setNotReaderMsgCount:(int)count ForPublicNumberId:(NSString *)jid;

/**
 根据公众号Id获取未读消息数
 
 @param jid 公众号Id
 @return 未读消息数
 */
- (int)getNotReaderMsgCountByPublicNumberId:(NSString *)jid;

- (void)checkPNMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate;

/**
 根据关键字搜索公众号
 */
- (NSArray *)searchRobotByKeyStr:(NSString *)keyStr;

@end
