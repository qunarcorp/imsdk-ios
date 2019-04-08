
#import "QIMCommonUIFramework.h"

@class QIMMsgBaloonBaseCell;
@interface QIMShockMsgCell : QIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end
