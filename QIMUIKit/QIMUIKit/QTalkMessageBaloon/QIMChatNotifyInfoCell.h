//
//  QIMChatNotifyInfoCell.h
//  qunarChatIphone
//
//  Created by admin on 16/2/26.
//
//

#import "QIMCommonUIFramework.h"

@class QIMMsgBaloonBaseCell;
@protocol QIMChatNotifyInfoCellDelegate <NSObject>

@end

@interface QIMChatNotifyInfoCell : QIMMsgBaloonBaseCell

@property (nonatomic, weak) id<QIMChatNotifyInfoCellDelegate,QIMMsgBaloonBaseCellDelegate> delegate;

@end

@interface TransferInfoCell : QIMMsgBaloonBaseCell

@property (nonatomic, weak) id<QIMChatNotifyInfoCellDelegate,QIMMsgBaloonBaseCellDelegate> delegate;

@end
