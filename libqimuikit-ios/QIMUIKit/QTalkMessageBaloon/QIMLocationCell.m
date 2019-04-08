//
//  QIMLocationCell.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/25.
//
//

#import "QIMLocationCell.h"

@interface QIMLocationCell ()
{
    UIView      * _sepLine;
    UIImageView * _flagImageView;
}
@end

@implementation QIMLocationCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _sepLine = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLine.backgroundColor = [UIColor qtalkSplitLineColor];
        [self.contentView addSubview:_sepLine];
        
        self.textLabel.font = [UIFont systemFontOfSize:15];
        
        self.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
        
        _flagImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _flagImageView.image = [UIImage imageNamed:@"locaton_checked"];
        [self.contentView addSubview:_flagImageView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.detailTextLabel.text.length == 0) {
        CGRect rect = self.textLabel.frame;
        rect.size.height += self.detailTextLabel.height;
        self.textLabel.frame = rect;
    }
    
    _sepLine.frame = CGRectMake(self.textLabel.left, self.contentView.height - 0.5, self.contentView.width - self.textLabel.left, 0.5);
    _flagImageView.frame = CGRectMake(self.contentView.width - 35, (self.contentView.height - 20) / 2, 20, 20);
}

- (void)setCellSelect:(BOOL)select{
    _flagImageView.hidden = !select;
}

@end
