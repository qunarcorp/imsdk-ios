//
//  QIMPwdBoxSecuritySettingCell.h
//  QIMNoteUI
//
//  Created by QIM on 10/12/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMPwdBoxSecuritySettingCell : UITableViewCell

+ (CGFloat)getCellHeight;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setServiceStatusDetail:(NSString *)detailStr;

- (void)setServiceStatusTitle:(NSString *)statusTitle;

@end

NS_ASSUME_NONNULL_END
