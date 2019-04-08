//
//  QIMGroupMemberListVC.h
//  qunarChatIphone
//
//  Created by chenjie on 15/11/19.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMGroupMemberListVC : QTalkViewController

@property (nonatomic,copy) NSString                    * groupID;
@property (nonatomic,strong) NSMutableArray            * items;

@end
