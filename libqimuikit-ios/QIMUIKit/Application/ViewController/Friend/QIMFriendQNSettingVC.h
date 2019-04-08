//
//  QIMFriendQNSettingVC.h
//  qunarChatIphone
//
//  Created by admin on 15/11/23.
//
//

#import "QIMCommonUIFramework.h"

@class QIMFriendSettingItem;
@protocol QIMFriendQNSettingVCDelegate <NSObject>
@optional
- (void)setQuestion:(NSString *)question Answer:(NSString *)answer;
@end
@interface QIMFriendQNSettingVC : QTalkViewController
@property (nonatomic, weak) QIMFriendSettingItem *settingItem;
@property (nonatomic, weak) id<QIMFriendQNSettingVCDelegate> delegate;
@end
