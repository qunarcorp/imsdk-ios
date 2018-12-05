//
//  QIMGroupTempCell.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMGroupTempCellDelegate <NSObject>
@optional
- (BOOL)setGroupTemp:(BOOL)hidden;
@end
@interface QIMGroupTempCell : UITableViewCell
@property (nonatomic, weak) id<QIMGroupTempCellDelegate> delegate;
@property (nonatomic, assign) BOOL groupTemp;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end
