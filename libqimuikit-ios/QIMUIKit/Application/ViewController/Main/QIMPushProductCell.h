//
//  QIMPushProductCell.h
//  qunarChatIphone
//
//  Created by chenjie on 16/1/26.
//
//

#import "QIMCommonUIFramework.h"

@class QIMPushProductCell;
@protocol QIMPushProductCellDelegate <NSObject>

- (void)sendBtnClickedForCell:(QIMPushProductCell *)cell;

@end

@interface QIMPushProductCell : UITableViewCell

@property (nonatomic,assign) id<QIMPushProductCellDelegate> delegate;

- (void)setCellInfo:(NSDictionary *)infoDic;

+ (CGFloat)getCellHeight;

@end
