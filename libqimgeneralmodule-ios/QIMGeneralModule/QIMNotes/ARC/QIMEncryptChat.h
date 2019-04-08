//
//  QIMEncryptChatView.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/5.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class Message;
typedef enum : NSUInteger {
    QIMEncryptChatStateNone = 0,
    QIMEncryptChatStateEncrypting,
    QIMEncryptChatStateDecrypted,
} QIMEncryptChatState;

typedef enum : NSUInteger {
    QIMEncryptChatDirectionSent = 0,
    QIMEncryptChatDirectionReceived,
} QIMEncryptChatDirection;

@protocol QIMEncryptChatReloadViewDelegate <NSObject>

- (void)reloadBaseViewWithUserId:(NSString *)userId WithEncryptChatState:(QIMEncryptChatState)encryptChatState;

@end

@class QIMNoteManager;
@interface QIMEncryptChat : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, weak) id <QIMEncryptChatReloadViewDelegate> delegate;


/**
 做一些跟加密解密相关的操作

 @param userId 用户Id
 */

- (void)doSomeEncryptChatWithUserId:(NSString *)userId;
- (void)closeEncrypt;
- (void)cancelDescrpytChat;

#pragma mark - EncryptChatState

- (QIMEncryptChatState)getEncryptChatStateWithUserId:(NSString *)userId;

#pragma mark - Setter SecurityTime

- (void)setEncryptChatLeaveTimeWithUserId:(NSString *)userId
                                 WithTime:(NSTimeInterval)leftTime;

- (NSTimeInterval)getEncryptChatLeaveTimeWithUserId:(NSString *)userId;

#pragma mark - Encrypt Message

- (NSString *)encryptMessageWithMsgType:(NSInteger)msgType WithOriginBody:(NSString *)body WithOriginExtendInfo:(NSString *)extendInfo WithUserId:(NSString *)userId;

#pragma mark - DeCrypt Message

/**
 解密得到MessageType
 */
- (NSInteger)getMessageTypeWithEncryptMsg:(Message *)msg WithUserId:(NSString *)userId;

/**
 解密得到MessageBody
 */
- (NSString *)getMessageBodyWithEncryptMsg:(Message *)msg WithUserId:(NSString *)userId;

/**
 解密得到MessageExtendInfo
 */
- (NSString *)getMessageExtendInfoWithEncryptMsg:(Message *)msg WithUserId:(NSString *)userId;

@end
