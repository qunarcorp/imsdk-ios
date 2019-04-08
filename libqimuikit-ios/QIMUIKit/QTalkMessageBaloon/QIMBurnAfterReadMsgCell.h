
#import "QIMCommonUIFramework.h"
#import "QIMMsgBaloonBaseCell.h"

@class QIMBurnAfterReadMsgCell;

@protocol QIMBurnAfterReadMsgCellDelegate <NSObject>

- (void)browserMessage:(Message *)message;

@end

@interface QIMBurnAfterReadMsgCell : QIMMsgBaloonBaseCell

@property (nonatomic, assign) id<QIMBurnAfterReadMsgCellDelegate,QIMMsgBaloonBaseCellDelegate> delegate;

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end
