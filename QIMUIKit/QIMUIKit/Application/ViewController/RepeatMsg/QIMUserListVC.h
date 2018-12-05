//
//  QIMUserListVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/16.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMUserListVCDelegate <NSObject>
@optional
- (void)selectContactWithJid:(NSString *)jid;
@end

@interface QIMUserListVC : QTalkViewController
@property (nonatomic, weak) id<QIMUserListVCDelegate> delegate;
@property (nonatomic, assign) BOOL      isTransfer;//是否是会话转移
@end
