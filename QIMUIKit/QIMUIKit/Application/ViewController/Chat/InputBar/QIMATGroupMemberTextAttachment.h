//
//  QIMATGroupMemberTextAttachment.h
//  qunarChatIphone
//
//  Created by QIM on 2018/4/3.
//

#import "QIMCommonUIFramework.h"

@interface QIMATGroupMemberTextAttachment : NSTextAttachment

@property (nonatomic, copy) NSString *groupMemberName;
@property (nonatomic, copy) NSString *groupMemberJid;

@end
