//
//  QIMRTCChatCell.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/22.
//
//

@class QIMMsgBaloonBaseCell;
@interface QIMRTCChatCell : QIMMsgBaloonBaseCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType;

- (void)refreshUI;

@end
