//
//  QIMGroupPassworCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMGroupPassworCell.h"

@implementation QIMGroupPassworCell{
    UIView *_rootView;
    UILabel *_titleLabel;
    UILabel *_passwordLabel;
}

+ (CGFloat)getCellHeight{
    return 40;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [QIMGroupPassworCell getCellHeight])];
        [_rootView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_rootView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setText:@"密码"];
        [_rootView addSubview:_titleLabel];
        
        _passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.right + 10, 10, _rootView.width - _titleLabel.right - 10 - 30, 20)];
        [_passwordLabel setBackgroundColor:[UIColor clearColor]];
        [_passwordLabel setFont:[UIFont systemFontOfSize:14]];
        [_passwordLabel setTextColor:[UIColor spectralColorGrayDarkColor]];
        [_passwordLabel setTextAlignment:NSTextAlignmentRight];
        [_rootView addSubview:_passwordLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, _rootView.height - 0.5, _rootView.width - 10, 0.5)];
        [line setBackgroundColor:[UIColor qim_colorWithHex:0xd1d1d1 alpha:1]];
        [_rootView addSubview:line];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshUI{
    [_passwordLabel setText:self.password];
}

@end
