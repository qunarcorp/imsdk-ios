//
//  QIMBaseSelectedTableViewCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/20.
//
//

#import "QIMBaseSelectedTableViewCell.h"
#import "QIMNoteUICommonFramework.h"

@interface QIMBaseSelectedTableViewCell ()
{
    BOOL _selected;
}

@end

@implementation QIMBaseSelectedTableViewCell

- (UIImageView *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_selectBtn setImage:[UIImage imageNamed:@"common_checkbox_no_44px"]];
    }
    return _selectBtn;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _selected = NO;
        [self.contentView addSubview:self.selectBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isSelect) {
        self.selectBtn.frame = CGRectMake(10, (self.contentView.height - 30) / 2, 24, 24);
    }else{
        self.selectBtn.frame = CGRectZero;
    }
}

- (void)setCellSelected:(BOOL)selected {
    _selected = selected;
    [self.selectBtn setImage:selected ? [UIImage imageNamed:@"common_checkbox_yes_44px"] : [UIImage imageNamed:@"common_checkbox_no_44px"]];
}

- (BOOL)isCellSelected {
    return _selected;
}


@end
