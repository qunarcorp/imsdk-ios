//
//  QIMNoteManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/13.
//
//

#import <Foundation/Foundation.h>

#define QTNoteManagerSaveCloudMainSuccessNotification @"QTNoteManagerSaveCloudMainSuccessNotification"
#define QTNoteManagerGetCloudMainSuccessNotification @"QTNoteManagerGetCloudMainSuccessNotification"
#define QTNoteManagerGetCloudMainHistorySuccessNotification  @"QTNoteManagerGetCloudMainHistorySuccessNotification"

#define QTNoteManagerGetCloudSubSuccessNotification  @"QTNoteManagerGetCloudSubSuccessNotification"
#define QTNoteManagerGetCloudSubHistorySuccessNotification  @"QTNoteManagerGetCloudSubHistorySuccessNotification"


#define QTTodolistStateOutOfDate @"QTTodolistStateOutOfDate"
#define QTTodolistStateNormal @"QTTodolistStateNormal"
#define QTTodolistStateComplete @"QTTodolistStateComplete"

//加密会话
#define kNotifyBeginEncryptChat @"kNotifyBeginEncryptChat"
#define kNotifyAgreeEncryptChat @"kNotifyAgreeEncryptChat"
#define kNotifyRefuseEncryptChat @"kNotifyRefuseEncryptChat"
#define kNotifyCancelEncryptChat @"kNotifyCancelEncryptChat"
#define kNotifyCloseEncryptChat @"kNotifyCloseEncryptChat"

@class QIMNoteModel;
typedef enum : NSUInteger {
    QIMNoteTypePassword = 1,
    QIMNoteTypeTodoList = 2,
    QIMNoteTypeEverNote = 3,
    QIMNoteTypeChatPwdBox = 100,
} QIMNoteType;

typedef enum : NSUInteger {
    QIMPasswordTypeText = 1,
    QIMPasswordTypeURL,
    QIMPasswordTypeEmail,
    QIMPasswordTypeAddress,
    QIMPasswordTypeDateTime,
    QIMPasswordTypeYearMonth,
    QIMPasswordTypeOnePassword,
    QIMPasswordTypePassword,
    QIMPasswordTypeTelphone,
} QIMPasswordType;

typedef enum : NSUInteger {
    QIMNoteStateDelete = -1,
    QIMNoteStateNormal = 1,
    QIMNoteStateFavorite,
    QIMNoteStateBasket,
    QIMNoteStateCreate,
    QIMNoteStateUpdate,
} QIMNoteState;

typedef enum : NSUInteger {
    QIMNoteExtendedFlagStateNoNeedUpdatedd = -1,
    QIMNoteExtendedFlagStateLocalCreated = 1,
    QIMNoteExtendedFlagStateLocalModify,
    QIMNoteExtendedFlagStateRemoteUpdated,
} QIMNoteExtendedFlagState;

typedef enum : NSUInteger {
    QIMEncryptMessageType_Begin = 1,
    QIMEncryptMessageType_Agree,
    QIMEncryptMessageType_Refuse,
    QIMEncryptMessageType_Cancel,
    QIMEncryptMessageType_Close,
} QIMEncryptMessageType;

@interface QIMNoteManager : NSObject

+ (QIMNoteManager *)sharedInstance;

@property (nonatomic, copy) NSString *baseUrl;

- (NSString *)getPasswordWithCid:(NSInteger)cid;

- (void)setPassword:(NSString *)password ForCid:(NSInteger)cid;

- (void)setEncryptChatPasswordWithPassword:(NSString *)password ForUserId:(NSString *)userId;

- (NSString *)getEncryptChatPasswordWithUserId:(NSString *)userId;

/***************************Main Local****************************/

/**
 保存新MainItem
 */
- (void)saveNewQTNoteMainItem:(QIMNoteModel *)model;

/**
 更新mainItem
 */
- (void)updateQTNoteMainItemWithModel:(QIMNoteModel *)model;

/**
 删除MainItem
 */
- (void)deleteQTNoteMainItemWithModel:(QIMNoteModel *)model;

/**
 更新MainItem状态值
 */
- (void)updateQTNoteMainItemStateWithModel:(QIMNoteModel *)model;

/**
 根据关键词搜索MainItem
 */
- (NSArray *)getMainItemWithType:(QIMNoteType)type Keywords:(NSString *)keyWords;

/**
 排除某State
 */
- (NSArray *)getMainItemWithType:(QIMNoteType)type WithExceptState:(QIMNoteState)state;

/**
 get某State
 */
- (NSArray *)getMainItemWithType:(QIMNoteType)type State:(QIMNoteState)state;

/**
 读取未更新数据
 */
- (NSArray *)getMainItemWithQExtendedFlag:(QIMNoteExtendedFlagState)qExtendedFlag;

/**
 读取最大MainItem Cid
 */
- (NSInteger)getMaxQTNoteMainItemCid;

/**
 读取MainItem最大Version
 */
- (NSInteger)getQTNoteMainItemMaxTimeWithType:(QIMNoteType)type;


- (NSInteger)getQTNoteSubItemMaxTimeWitModel:(QIMNoteModel *)model;

/**
 根据完成状态读取TodoList
 */
- (NSArray *)getTodoListItemWithCompleteState:(NSString *)completeState;

- (void)batchSyncToRemoteMainItems;

/***************************Sub Local****************************/

/**
 保存新SubItem
 */
- (void)saveNewQTNoteSubItem:(QIMNoteModel *)model;

/**
 更新SubItem
 */
- (void)updateQTNoteSubItemWithQSModel:(QIMNoteModel *)model;

/**
 删除SubItem
 */
- (void)deleteQTNoteSubItemWithQSModel:(QIMNoteModel *)model;

/**
 更新SubItem状态值
 */
- (void)updateQTNoteSubItemStateWithQSModel:(QIMNoteModel *)model;

/**
 读取本地未更新SubItem
 */
- (NSArray *)getSubItemWithCid:(NSInteger)cid WithQSExtendedFlag:(QIMNoteExtendedFlagState)qsExtendedFlag;

- (NSArray *)getSubItemWithCid:(NSInteger)cid WithType:(QIMNoteType)type WithQState:(QIMNoteState)state;

- (NSArray *)getSubItemWithCid:(NSInteger)cid WithType:(QIMNoteType)type WithExpectState:(QIMNoteState)state;

/**
 读取某Cid下State的SubItem
 */
- (NSArray *)getSubItemWithCid:(NSInteger)cid WithState:(QIMNoteState)state;

/**
 排除某Cid下State的SubItem
 */
- (NSArray *)getSubItemWithCid:(NSInteger)cid WithExpectState:(QIMNoteState)state;

/**
 读取某State的SubItem
 */
- (NSArray *)getSubItemWithState:(QIMNoteState)state;

/**
 排除某State的SubItem
 */
- (NSArray *)getSubItemWithExpectState:(QIMNoteState)state;

/**
 读取最大SubItem的本地索引值
 */
- (NSInteger)getMaxQTNoteSubItemCSid;

- (void)batchSyncToRemoteSubItemsWithMainQid:(NSString *)qid;

/***************************Main Remote****************************/

- (void)saveToRemoteMainWithMainItem:(QIMNoteModel *)model;

- (void)updateToRemoteMainWithMainItem:(QIMNoteModel *)model;

- (void)deleteToRemoteMainWithQid:(NSInteger)qid;

- (void)collectToRemoteMainWithQid:(NSInteger)qid;

- (void)cancelCollectToRemoteMainWithQid:(NSInteger)qid;

- (void)moveToRemoteBasketMainWithQid:(NSInteger)qid;

- (void)moveOutRemoteBasketMainWithQid:(NSInteger)qid;

- (void)getCloudRemoteMainWithVersion:(NSInteger)version
                             WithType:(QIMNoteType)type;

- (void)getCloudRemoteMainHistoryWithQId:(NSInteger)qid;

/***************************Sub Remote****************************/

- (void)saveToRemoteSubWithSubModel:(QIMNoteModel *)model;

- (void)updateToRemoteSubWithSubModel:(QIMNoteModel *)model;

- (void)deleteToRemoteSubWithQSid:(NSInteger)qsid;

- (void)collectionToRemoteSubWithQSid:(NSInteger)qsid;

- (void)cancelCollectionToRemoteSubWithQSid:(NSInteger)qsid;

- (void)moveToBasketRemoteSubWithQSid:(NSInteger)qsid;

- (void)moveOutRemoteBasketSubWithQSid:(NSInteger)qsid;

- (void)getCloudRemoteSubWithQid:(NSInteger)qid
                             Cid:(NSInteger)cid
                         version:(NSInteger)version
                            type:(QIMPasswordType)type;

- (NSArray *)getCloudRemoteSubHistoryWithQSid:(NSInteger)qsid;

//get sub evernotes
- (void)getCloudRemoteSubWithQid:(NSInteger)qid
                             Cid:(NSInteger)cid
                         version:(NSInteger)version;

@end

@interface QIMNoteManager (EncryptMessage)

- (void)beginEncryptionSessionWithUserId:(NSString *)userId
                            WithPassword:(NSString *)password;
    
/**
 同意加密会话请求

 @param userId 用户Id
 */
- (void)agreeEncryptSessionWithUserId:(NSString *)userId;


/**
 拒绝加密会话请求

 @param userId 用户Id
 */
- (void)refuseEncryptSessionWithUserId:(NSString *)userId;

    
/**
 取消加密会话请求

 @param userId 用户Id
 */
- (void)cancelEncryptSessionWithUserId:(NSString *)userId;

/**
 关闭加密会话

 @param userId 用户Id
 */
- (void)closeEncryptSessionWithUserId:(NSString *)userId;


- (void)getCloudRemoteEncrypt;

/**
 获取加密会话密码箱

 @return 加密会话密码箱Model
 */
- (QIMNoteModel *)getEncrptPwdBox;


/**
 获取加密会话密码

 @param userId 用户Id
 @param cid cid
 @return 获取对方Id对应的加密会话密码
 */
-  (NSString *)getChatPasswordWithUserId:(NSString *)userId
                                 WithCid:(NSInteger)cid;


/**
 保存加密会话密码

 @param userId 用户Id
 @param password 密码
 @param cid cid
 @return 加密会话密码Model
 */
- (QIMNoteModel *)saveEncryptionPasswordWithUserId:(NSString *)userId
                                     WithPassword:(NSString *)password
                                          WithCid:(NSInteger)cid;

@end
