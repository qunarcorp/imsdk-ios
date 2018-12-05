//
//  QIMFriendListCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMFriendListCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *userInfoDic;
@property (nonatomic, assign) BOOL isLast;

+ (CGFloat)getCellHeightForDesc:(NSString *)desc;

- (void)refreshUI;

@end
