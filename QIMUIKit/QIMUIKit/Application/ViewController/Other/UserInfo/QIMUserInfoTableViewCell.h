//
//  QIMUserInfoTableViewCell.h
//  qunarChatIphone
//
//  Created by qitmac000301 on 15/3/24.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@protocol QIMUserInfoTableViewCellDelegate <NSObject>
@optional
- (void)onUserHeaderClick;
@end

@interface QIMUserInfoTableViewCell : UITableViewCell <UITextFieldDelegate>
@property (nonatomic, weak)   id<QIMUserInfoTableViewCellDelegate> delegate;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *nameTitle;
@property (nonatomic, retain) UITextField *nameLabel;
@property (nonatomic, retain) UILabel *IDLabelTitle;
@property (nonatomic, retain) UILabel *IDLabel;
@property (nonatomic, retain) UILabel *departmentLabel;
@property (nonatomic, retain) UILabel *departmentTitle;
@end
