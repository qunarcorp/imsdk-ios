//
//  QIMFriendNotifyCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMFriendNotifyCellDelete <NSObject>
@optional
- (void)agreeAddFriendWihtUserInfoDic:(NSDictionary *)userInfoDic;
@end

@interface QIMFriendNotifyCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *userDic;
@property (nonatomic, weak) id<QIMFriendNotifyCellDelete> delegate;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end
