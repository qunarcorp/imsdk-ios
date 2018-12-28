//
//  QIMCommonUserInfoHeaderCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/26.
//

#import "QIMCommonUserInfoHeaderCell.h"

@interface QIMCommonUserInfoHeaderCell ()

@end

@implementation QIMCommonUserInfoHeaderCell

- (YLImageView *)avatarImage {
    if (!_avatarImage) {
        _avatarImage = [[YLImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 16, 50, 50)];
        _avatarImage.layer.masksToBounds = YES;
        _avatarImage.layer.cornerRadius = 25;
    }
    return _avatarImage;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.avatarImage];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
