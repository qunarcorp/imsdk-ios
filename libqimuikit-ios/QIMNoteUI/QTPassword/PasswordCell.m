//
//  PasswordCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/11.
//
//

#import "PasswordCell.h"
#import "QIMNoteModel.h"
#import "QIMNoteUICommonFramework.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PasswordCell ()
{
    BOOL _selected;
}

@property (nonatomic, strong) QIMNoteModel *model;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *passwordTitleLabel;
@property (nonatomic, strong) UILabel *passwordGenerateTimeLabel;
@property (nonatomic, strong) UIImageView *selectBtn;

@end

@implementation PasswordCell

- (void)setQIMNoteModel:(QIMNoteModel *)model {
    if (model != nil) {
        _model = model;
        [self refreshUI];
    }
}

+ (CGFloat)getCellHeight{
    return 50.0;
}

- (UIImageView *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 24, 24)];
        [_selectBtn setImage:[UIImage imageNamed:@"common_checkbox_no_44px"]];
        _selectBtn.centerY = self.contentView.centerY;
    }
    return _selectBtn;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 45, 50)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.image = [UIImage imageNamed:@"explore_tab_password"];
    }
    _iconView.centerY = self.centerY;
    return _iconView;
}

- (UILabel *)passwordTitleLabel {
    if (!_passwordTitleLabel) {
        _passwordTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconView.right + 5, 8, [UIScreen mainScreen].bounds.size.width - CGRectGetWidth(self.iconView.frame) - 5, 20)];
    }
    return _passwordTitleLabel;
}

- (UILabel *)passwordGenerateTimeLabel {
    if (!_passwordGenerateTimeLabel) {
        _passwordGenerateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconView.right + 5, CGRectGetMaxY(self.passwordTitleLabel.frame) + 5, [UIScreen mainScreen].bounds.size.width - CGRectGetWidth(self.iconView.frame) - 5, 15)];
        _passwordGenerateTimeLabel.font = [UIFont fontWithName:FONT_NAME size:14];
        _passwordGenerateTimeLabel.textColor = [UIColor qtalkTextLightColor];
    }
    return _passwordGenerateTimeLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _selected = NO;
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.passwordTitleLabel];
        [self.contentView addSubview:self.passwordGenerateTimeLabel];
        self.iconView.image = [UIImage imageNamed:@"explore_tab_password"];
        self.passwordTitleLabel.text = @"Password";
        NSString *timeStr = [[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:self.model.qs_time] qim_formattedDateDescription];
        self.passwordGenerateTimeLabel.text = timeStr;
        self.iconView.centerY = self.centerY;
    }
    return self;
}

- (void)refreshUI {
    if (self.isSelect) {
        [self.contentView addSubview:self.selectBtn];
    }
    self.passwordTitleLabel.text = self.model.qs_title;
    NSString *timeStr = [[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:self.model.qs_time] qim_formattedDateDescription];
    self.passwordGenerateTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
}


- (void)setCellSelected:(BOOL)selected {
    _selected = selected;
    [self.selectBtn setImage:selected ? [UIImage imageNamed:@"common_checkbox_yes_44px"] : [UIImage imageNamed:@"common_checkbox_no_44px"]];
}

- (BOOL)isCellSelected {
    return _selected;
}

@end
