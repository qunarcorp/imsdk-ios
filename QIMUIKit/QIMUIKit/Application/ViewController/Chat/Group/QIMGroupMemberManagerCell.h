//
//  QIMGroupMemberManagerCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/8/17.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMGroupMemberManagerCell : UITableViewCell

@property (nonatomic,strong) NSDictionary * memberInfo;
@property (nonatomic,assign) BOOL           canEdit;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
