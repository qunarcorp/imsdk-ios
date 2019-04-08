//
//  QIMFriendSettingCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/23.
//
//

#import "QIMCommonUIFramework.h"

typedef enum {
    ReceMsgSetting_All_Allow = 2,
    ReceMsgSetting_Only_Friend = 1,
    ReceMsgSetting_All_Refuse = 0,
}ReceMsgSetting;

typedef enum {
    VerifyMode_AllAgree = 3,    //全部同意
    VerifyMode_Validation = 1,  //人工同意
    VerifyMode_Question_Answer = 2,  //问题认证
    VerifyMode_AllRefused = 0,  //全部拒绝
}VerifyMode;

@interface QIMFriendSettingItem : NSObject
@property (nonatomic, assign) BOOL isReceMsgSetting;
@property (nonatomic, assign) BOOL isVerifyMode;
@property (nonatomic, assign) BOOL isCap;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) int mode;
@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *answer;
@property (nonatomic, assign) BOOL isSelected;
@end

@interface QIMFriendSettingCell : UITableViewCell
@property (nonatomic, strong) QIMFriendSettingItem *item;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end
