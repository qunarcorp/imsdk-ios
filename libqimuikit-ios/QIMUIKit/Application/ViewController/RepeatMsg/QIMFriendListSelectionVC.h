//
//  QIMFriendListSelectionVC.h
//  qunarChatIphone
//
//  Created by admin on 16/3/18.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMFriendListSelectionVCDelegate <NSObject>
@optional
- (void)selectContactWithJid:(NSString *)jid;
@end

@interface QIMFriendListSelectionVC : QTalkViewController
@property (nonatomic, weak) id<QIMFriendListSelectionVCDelegate> delegate;
@end
