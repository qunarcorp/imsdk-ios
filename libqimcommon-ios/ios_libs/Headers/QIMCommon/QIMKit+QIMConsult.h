//
//  QIMKit+QIMConsult.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/31.
//

#import "QIMKit.h"

@interface QIMKit (QIMConsult)

/**
 虚拟账号的RealJid列表
 */
//@property (nonatomic, strong) NSMutableDictionary *virtualRealJidDic;

/**
 虚拟账号列表
 */
//@property (nonatomic, strong) NSArray *virtualList;

/**
 获取虚拟账号列表
 */
//- (NSArray *)getVirtualList;


/**
 获取虚拟帐号列表
 */
- (NSDictionary *)getVirtualDic;

/**
 获取我服务的虚拟帐号列表
 */
- (NSArray *)getMyhotLinelist;

- (void)getHotlineShopList;

/**
 根据虚拟Id获取真实RealJid

 @param virtualJid 虚拟Id
 */
//- (NSString *)getRealJidForVirtual:(NSString *)virtualJid;

/**
 发送Consult消息

 @param msgId MsgId
 @param msg 消息Body内容
 @param info 消息ExtendInfo
 @param toJid 消息
 @param realToJid 真实RealJid
 @param chatType 会话类型
 @param msgType 消息类型
 @return 消息对象Message
 */
- (Message *)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)msg WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid WithChatType:(ChatType)chatType WithMsgType:(int)msgType;

- (void)chatTransferTo:(NSString *)user message:(NSString *)message chatId:(NSString *)chatId;

/**
 会话转移
 
 @param from from
 @param to to
 @param user user
 @param reson 原因
 @param chatId chat id
 @param msgId msgId
 */
- (void)chatTransferFrom:(NSString *)from To:(NSString *)to User:(NSString *)user Reson:(NSString *)reson chatId:(NSString *)chatId WithMsgId:(NSString *)msgId;

- (void)customerConsultServicesayHelloWithUser:(NSString *)user WithVirtualId:(NSString *)virtualId WithFromUser:(NSString *)fromUser;

/**
 欢迎语接口？
 
 @param user 客服id
 */
- (void)customerServicesayHelloWithUser:(NSString *)user;

/**
 输入预测
 
 @param keyword 关键词
 @return 返回预测结果
 */
- (NSArray *)searchSuggestWithKeyword:(NSString *)keyword;

/**
 organization预测
 
 @param suggestId 输入id
 @return 返回预测结果
 */
- (NSArray *)getSuggestOrganizationBySuggestId:(NSString *)suggestId;

/**
 根据店铺Id 设置服务模式

 @param shopId 店铺Id
 @param shopServiceStatus 服务模式
 @return 是否设置成功
 */
- (BOOL)updateSeatSeStatusWithShopId:(NSInteger)shopId WithStatus:(NSInteger)shopServiceStatus;

/**
 根据服务模式获取基础信息

 @param userStatus 服务模式
 */
- (NSDictionary *)userSeatStatusDict:(int)userStatus;


- (NSString *)userStatusTitleWithStatus:(int)userStatus;

/**
 获取坐席状态
 
 @return 返回坐席状态
 */
- (NSArray *)getSeatSeStatus;

/**
 获取状态坐席状态列表
 */
- (NSArray *)availableUserSeatStatus;

/**
 关闭会话
 
 @param shopId ShopId
 @param visitorId 客人Id
 @return 关闭之后的提示语
 */
- (void)closeSessionWithShopId:(NSString *)shopId WithVisitorId:(NSString *)visitorId withBlock:(QIMCloseSessionBlock)block;

@end
