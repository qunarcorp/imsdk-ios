//
//  QIMPublicNumberCardCommonCell.m
//  qunarChatIphone
//
//  Created by admin on 15/8/27.
//
//

#import "QIMPublicNumberCardCommonCell.h"

@implementation QIMPublicNumberCardCommonCell{
    UILabel *_titleLabel;
    UILabel *_descLabel;
    UIView  *_lineView;
}

+ (CGFloat)getCellHeightByInfo:(NSString *)info{
    
    CGSize size = [info sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 100 - 30, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    if (size.height < 20) {
        size.height = 20;
    }
    return size.height + 20;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_titleLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 8, [UIScreen mainScreen].bounds.size.width - 100 - 30, 0)];
        [_descLabel setBackgroundColor:[UIColor clearColor]];
        [_descLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [_descLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_descLabel setTextAlignment:NSTextAlignmentLeft];
        [_descLabel setNumberOfLines:0];
        [self.contentView addSubview:_descLabel];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(_titleLabel.left, 0, [[UIScreen mainScreen] bounds].size.width - _titleLabel.left, 0.5)];
        [_lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [self.contentView addSubview:_lineView];
        
    }
    return self;
}

- (void)refreshUI{
    
    [_titleLabel setText:self.title];
    
    CGSize size = [self.info sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 100 - 30, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    if (size.height < 20) {
        size.height = 20;
    }
    [_descLabel setHeight:size.height];
    [_descLabel setText:self.info];
    
    [_lineView setTop:size.height + 19.5];
    [_descLabel setTextAlignment:self.infoTextAlignment];
}

@end
