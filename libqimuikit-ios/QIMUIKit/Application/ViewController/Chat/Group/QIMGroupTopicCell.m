//
//  QIMGroupTopicCell.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/16.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMGroupTopicCell.h"

@implementation QIMGroupTopicCell{
    
    UILabel *_topicLable;
    
}

+ (CGFloat)getCellHeightWihtTopic:(NSString *)topic{
    CGSize size = [topic sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 100, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return size.height + 30;
}

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType{
    CGSize size = [message.message sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 100, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return size.height + 30;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
        
        _topicLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, [UIScreen mainScreen].bounds.size.width - 100, 0)];
        [_topicLable setBackgroundColor:[UIColor qim_colorWithHex:0xe5e5e5 alpha:1]];
        [_topicLable setFont:[UIFont systemFontOfSize:12]];
        [_topicLable setTextColor:[UIColor grayColor]];
        [_topicLable setTextAlignment:NSTextAlignmentCenter];
        [_topicLable.layer setBorderWidth:1];
        [_topicLable.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [_topicLable.layer setCornerRadius:10];
        [_topicLable setNumberOfLines:0];
        [_topicLable setClipsToBounds:YES];
        [self.contentView addSubview:_topicLable];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshUI{
    
    CGSize size = [self.message.message sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(_topicLable.width, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    CGRect topicFrame = _topicLable.frame;
    topicFrame.size.height = size.height + 20;
    topicFrame.size.width = size.width + 20;
    [_topicLable setFrame:topicFrame];
    [_topicLable setText:self.message.message];
}

@end
