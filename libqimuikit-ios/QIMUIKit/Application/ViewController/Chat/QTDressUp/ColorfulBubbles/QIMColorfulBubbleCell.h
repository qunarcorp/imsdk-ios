//
//  QIMColorfulBubbleCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@class QIMColorfulBubbleCell;
@protocol QIMColorfulBubbleCellDelegate <NSObject>

- (void)colorfulBubbleCell :(QIMColorfulBubbleCell *)cell didSelectedBubbleAtIndex:(NSInteger)index;

@end

@interface QIMColorfulBubbleCell : UITableViewCell

@property (nonatomic,assign)id<QIMColorfulBubbleCellDelegate>  delegate;

- (void)setBubbles:(NSArray *)bubbles;

@end
