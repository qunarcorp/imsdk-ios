//
//  QIMFriendTitleListCell.m
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMFriendTitleListCell.h"
#import "QIMCommonFont.h"

@interface QIMFriendTitleListCell(){
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_descLabel;
}

@end

@implementation QIMFriendTitleListCell

+ (CGFloat)getCellHeight{
    return [[QIMCommonFont sharedInstance] currentFontSize] + 22;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 10, 10)];
        [_imageView setImage:[UIImage imageNamed:@"buddy_header_arrow@2x"]];
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, self.width - 35 - 100, 20)];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 2]];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [self.contentView addSubview:_titleLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 90, 10, 80, 20)];
        [_descLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_descLabel setTextAlignment:NSTextAlignmentRight];
        [_descLabel setFont:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 4]];
        [_descLabel setTextColor:[UIColor qtalkTextLightColor]];
        [self.contentView addSubview:_descLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [self.contentView addSubview:lineView];
    }
    return self;
}


- (void)refresh {
    
    _titleLabel.frame = CGRectMake(35, 0, self.width - 35 - 100, [self.class getCellHeight]);
    _titleLabel.font = [UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
    
    _descLabel.frame = CGRectMake(self.width - 90, 0, 80, [self.class getCellHeight]);
    _descLabel.font = [UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
    
    [_titleLabel setText:self.title];
    [_descLabel setText:self.desc]; 
}


- (void)setExpanded:(BOOL)flag{
    _expanded = flag;
    if (_expanded) {
        [UIView animateWithDuration:0.1 animations:^{
            _imageView.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            _imageView.transform = CGAffineTransformIdentity;;
        }];
    }
}

@end
