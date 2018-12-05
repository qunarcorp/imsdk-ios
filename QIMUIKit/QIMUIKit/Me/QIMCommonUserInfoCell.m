//
//  QIMCommonUserInfoCell.m
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "QIMCommonUserInfoCell.h"
#import "QIMIconInfo.h"

@interface QIMCommonUserInfoCell ()

@property (nonatomic, strong) UIImageView *myQrcodeView;

@end

@implementation QIMCommonUserInfoCell

- (YLImageView *)avatarImage {
    if (!_avatarImage) {
        _avatarImage = [[YLImageView alloc] initWithFrame:CGRectMake(19, 16, 50, 50)];
        _avatarImage.layer.cornerRadius = 25;
        _avatarImage.layer.masksToBounds = YES;
        _avatarImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _avatarImage;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 17, 150, 22)];
        _nickNameLabel.textColor = [UIColor qtalkTextBlackColor];
        _nickNameLabel.font = [UIFont systemFontOfSize:16];
    }
    return _nickNameLabel;
}

- (UILabel *)signatureLabel {
    if (!_signatureLabel) {
        _signatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 46, self.width - 87, 20)];
        _signatureLabel.textColor = [UIColor qtalkTextLightColor];
        _signatureLabel.font = [UIFont systemFontOfSize:14];
    }
    return _signatureLabel;
}

- (UIImageView *)myQrcodeView {
    if (!_myQrcodeView) {
        _myQrcodeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 60, 0, 28, 29)];
        _myQrcodeView.contentMode = UIViewContentModeScaleAspectFit;
        _myQrcodeView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f10d" size:24 color:[UIColor qim_colorWithHex:0x9e9e9e alpha:1.0f]]];
    }
    return _myQrcodeView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.contentView addSubview:self.avatarImage];
    [self.contentView addSubview:self.nickNameLabel];
    [self.contentView addSubview:self.signatureLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.showQRCode) {
        [self addSubview:self.myQrcodeView];
        self.myQrcodeView.centerY = self.avatarImage.centerY;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
