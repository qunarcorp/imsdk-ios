//
//  QIMGroupPassworCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMGroupPassworCell : UITableViewCell
@property (nonatomic, assign) NSString *password;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end
