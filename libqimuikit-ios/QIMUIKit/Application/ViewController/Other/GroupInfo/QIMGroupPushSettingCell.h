//
//  QIMGroupPushSettingCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMGroupPushSettingCell : UITableViewCell
@property (nonatomic, strong) NSString *groupId;
- (void)refreshUI;
@end
