//
//  QIMCommonCell.m
//  qunarChatIphone
//
//  Created by admin on 15/8/21.
//
//

#import "QIMCommonCell.h"
#import "QIMCommonFont.h"

@interface QIMCommonCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIImageView *notReadFlagView;

@end

@implementation QIMCommonCell

+ (CGFloat)getCellHeight{
    return [[QIMCommonFont sharedInstance] currentFontSize] + 32;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, ([QIMCommonCell getCellHeight] / 1.5-8), ([QIMCommonCell getCellHeight] / 1.5-8))];
        _iconImageView.centerY = self.contentView.centerY;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 10, 0, (CGRectGetMaxX(self.contentView.frame) - ([QIMCommonCell getCellHeight] / 1.5) - 10 - 10), [QIMCommonCell getCellHeight])];
        _titleLabel.centerY = self.contentView.centerY;
    }
    return _titleLabel;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5)];
        [_topLine setBackgroundColor:[UIColor qtalkSplitLineColor]];
    }
    return _topLine;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.titleLabel.left, [QIMCommonCell getCellHeight]-0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [_bottomLine setBackgroundColor:[UIColor qtalkSplitLineColor]];
    }
    return _bottomLine;
}

- (UIImageView *)notReadFlagView {
    if (!_notReadFlagView) {
        _notReadFlagView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 30, ([QIMCommonCell getCellHeight] - 12) / 2.0, 10, 12)];
        _notReadFlagView.centerY = self.contentView.centerY;
        _notReadFlagView.image = [UIImage imageNamed:@"ExploreNewNotify"];
        _notReadFlagView.hidden = YES;
    }
    return _notReadFlagView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.topLine];
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.notReadFlagView];
    }
    return self;
}

- (void)refeshUI{
    
    self.titleLabel.frame = CGRectMake([self.class getCellHeight] + 5, 0, [UIScreen mainScreen].bounds.size.width - [self.class getCellHeight] - 10 - 15, [QIMCommonCell getCellHeight]);
    self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize]];
    [self.iconImageView setImage:self.iconImage];
    [self.titleLabel setText:self.title];
    self.iconImageView.centerY = self.titleLabel.centerY;
    if (self.isFirst) {
        [self.topLine setHidden:NO];
    } else {
        [self.topLine setHidden:YES];
    }
    if (self.isLast) {
        [self.bottomLine setFrame:CGRectMake(0, [QIMCommonCell getCellHeight]-0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    } else {
        [self.bottomLine setFrame:CGRectMake(self.titleLabel.left, [QIMCommonCell getCellHeight]-0.5, [UIScreen mainScreen].bounds.size.width-self.titleLabel.left, 0.5)];
    }
}

- (void)setHasNotRead:(BOOL)hasNotRead{
    _hasNotRead = hasNotRead;
    self.notReadFlagView.hidden = _hasNotRead == NO;
}

@end
