//
//  QIMGroupMaxMemberCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMGroupMaxMemberCell.h"
#import "NSBundle+QIMLibrary.h"

@implementation QIMGroupMaxMemberCell{
    UIView *_rootView;
    UILabel *_titleLabel;
    UILabel *_maxCountLabel;
}

+ (CGFloat)getCellHeight{
    return 40;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [QIMGroupMaxMemberCell getCellHeight])];
        [_rootView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_rootView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setText:[NSBundle qim_localizedStringForKey:@"myself_max_count"]];
        [_rootView addSubview:_titleLabel];
        
        _maxCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.right + 10, 10, _rootView.width - _titleLabel.right - 10 - 30, 20)];
        [_maxCountLabel setBackgroundColor:[UIColor clearColor]];
        [_maxCountLabel setFont:[UIFont systemFontOfSize:14]];
        [_maxCountLabel setTextColor:[UIColor spectralColorGrayDarkColor]];
        [_maxCountLabel setTextAlignment:NSTextAlignmentRight];
        [_rootView addSubview:_maxCountLabel];
        
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
    [_maxCountLabel setText:self.maxCount];
}

@end
