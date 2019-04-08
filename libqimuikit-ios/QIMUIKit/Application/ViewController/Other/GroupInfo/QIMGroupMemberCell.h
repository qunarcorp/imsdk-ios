//
//  QIMGroupMemberCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/11/19.
//
//

#import "QIMCommonUIFramework.h"

typedef enum {
    GroupMemberIDTypeNone,  //成员
    GroupMemberIDTypeAdmin, //管理员
    GroupMemberIDTypeOwner, //群主
} GroupMemberIDType;

@interface QIMGroupMemberCell : UITableViewCell

- (void)setMemberIDType:(GroupMemberIDType)idType;
@property (nonatomic, assign) BOOL isOnLine;

@end
