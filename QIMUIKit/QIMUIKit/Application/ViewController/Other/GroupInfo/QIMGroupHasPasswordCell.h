//
//  QIMGroupHasPasswordCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMGroupHasPasswordCellDelegate <NSObject>
@optional
- (BOOL)setGroupHasPassword:(BOOL)hasPassword;
@end
@interface QIMGroupHasPasswordCell : UITableViewCell
@property (nonatomic, weak) id<QIMGroupHasPasswordCellDelegate> delegate;
@property (nonatomic, assign) BOOL hasPassword;
+ (CGFloat)getCellHeight;
- (void)refreshUI; 
@end
