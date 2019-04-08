//
//  ReplayMsgCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/9/9.
//
//

#import "QIMCommonUIFramework.h"

#define kReplyMsgDidTapedNotification @"kReplyMsgDidTapedNotification"

@class QIMReplyMsgCell;
@protocol QIMReplyMsgCellDelegate <NSObject>

- (void)replyMsgCell : (QIMReplyMsgCell *)cell didClickedUserNickName:(NSString *)userNickName;

@end

@interface QIMReplyMsgCell : UITableViewCell

@property (nonatomic,strong) Message        * message;
@property (nonatomic,strong) NSMutableArray * replyMsgList;
@property (nonatomic,weak) id<QIMReplyMsgCellDelegate> delegate;

+ (float)getCellHeightForMessage:(Message *)message replyMsgList:(NSArray *)replyMsgList;

- (void)refreshUI;

@end
