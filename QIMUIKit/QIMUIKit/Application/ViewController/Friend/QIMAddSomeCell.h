//
//  QIMAddSomeCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/24.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMAddSomeCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *userInfoDic;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end
