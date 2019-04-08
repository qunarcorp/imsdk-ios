//
//  QIMGroupMembersCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/11/17.
//
//

#import "QIMCommonUIFramework.h"

@class QIMGroupCardVC;
@class QIMGroupMembersCell;
@protocol QIMGroupMembersCellDelegate <NSObject>

- (void)groupMembersCell:(QIMGroupMembersCell *)cell handleForGes:(UIGestureRecognizer *)ges;

@end

@interface QIMGroupMembersCell : UITableViewCell

@property (nonatomic ,assign) QIMGroupCardVC * target;
@property (nonatomic, assign) id<QIMGroupMembersCellDelegate> delegate;

- (void)setCount:(NSInteger)count;

- (void)setItems:(NSArray *)items;

- (NSInteger)getOnlineMenmbersCount;


@end
