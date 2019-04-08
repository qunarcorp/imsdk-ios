//
//  QIMServiceStatusTableViewCell.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/4/11.
//
//

#import "QIMServiceStatusTableViewCell.h"
#import "QIMCommonFont.h"

@interface QIMServiceStatusTableViewCell () {
    
    UIView *_rootView;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
}

@end

@implementation QIMServiceStatusTableViewCell

+ (CGFloat)getCellHeight {
    return [[QIMCommonFont sharedInstance] currentFontSize] + 32;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, (FONT_SIZE - 2) * 5, self.contentView.height - 10)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_titleLabel];
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.right, 5, self.width - _titleLabel.right - 10, self.contentView.height - 10)];
        [_detailLabel setBackgroundColor:[UIColor clearColor]];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.textColor = [UIColor qtalkTextLightColor];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_detailLabel];
    }
    return self;
}

- (void)setServiceStatusDetail:(NSString *)detailStr {
    if (detailStr) {
        _detailLabel.text = detailStr;
    }
}

- (void)setServiceStatusTitle:(NSString *)statusTitle {
    if (statusTitle) {
        _titleLabel.text = statusTitle;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
