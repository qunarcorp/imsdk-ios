//
//  QIMUserTableViewCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/17.
//

#import "QIMCommonUIFramework.h"

#define kQTalkUserCellHeaderLeftMargin 17.0f
#define kQTalkUserCellHeaderTopMargin 9.0f
#define kQTalkUserCellHeaderWidth 36
#define kQTalkUserCellHeaderHeight 36
#define kQTalkUserCellNameLabelLeftMargin 15.0f

@interface QIMUserTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *userInfoDic;

- (void)refreshUI;

@end
