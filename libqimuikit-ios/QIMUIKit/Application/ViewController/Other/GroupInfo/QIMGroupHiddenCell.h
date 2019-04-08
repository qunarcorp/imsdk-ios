//
//  QIMGroupHiddenCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMGroupHiddenCellDelegate <NSObject>
@optional
- (BOOL)setGroupHidden:(BOOL)hidden;
@end
@interface QIMGroupHiddenCell : UITableViewCell
@property (nonatomic, weak) id<QIMGroupHiddenCellDelegate> delegate;
@property (nonatomic, assign) BOOL groupHidden;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end
