//
//  QIMPublicNumberOrderMsgCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/4.
//
//

#import "QIMCommonUIFramework.h"

@protocol PNOrderMsgCellDelegate <NSObject>
@optional
- (void)openWebUrl:(NSString *)url;
@end

@interface QIMPublicNumberOrderMsgCell : UITableViewCell

@property (nonatomic, weak) Message *message;

@property (nonatomic, weak) id<PNOrderMsgCellDelegate> delegate;

+ (CGFloat)getCellHeightByContent:(NSString *)content;

- (void)refreshUI;

@end
