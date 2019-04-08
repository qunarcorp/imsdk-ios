//
//  QIMNewMessageTagCell.m
//  qunarChatIphone
//
//  Created by admin on 16/5/6.
//
//

#import "QIMNewMessageTagCell.h"

@implementation QIMNewMessageTagCell{
    
    UILabel *_contentLabel;
    
}

+ (CGFloat)getCellHeight{
    return 24;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        NSString *content = @"以下是新消息";
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize contentSize = [content sizeWithFont:font forWidth:INT8_MAX lineBreakMode:NSLineBreakByCharWrapping];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat left = (screenWidth - contentSize.width)/2.0;
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, ([QIMNewMessageTagCell getCellHeight] - contentSize.height)/2.0, contentSize.width, contentSize.height)];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setFont:font];
        [_contentLabel setTextColor:[UIColor qim_colorWithHex:0x999999 alpha:1]];
        [_contentLabel setText:content];
        [self.contentView addSubview:_contentLabel];
        
        UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(10, ([QIMNewMessageTagCell getCellHeight] - 1)/2.0, left - 20, 1)];
        [leftLine setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [self.contentView addSubview:leftLine];
        
        UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(_contentLabel.right + 10, ([QIMNewMessageTagCell getCellHeight] - 1)/2.0, leftLine.width, 1)];
        [rightLine setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [self.contentView addSubview:rightLine];
        
    }
    return self;
}

- (void)refreshUI{
    
}

@end
