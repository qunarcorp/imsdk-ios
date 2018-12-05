//
//  QIMGroupMaxMemberCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMGroupMaxMemberCell : UITableViewCell

@property (nonatomic, assign) NSString *maxCount;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end
