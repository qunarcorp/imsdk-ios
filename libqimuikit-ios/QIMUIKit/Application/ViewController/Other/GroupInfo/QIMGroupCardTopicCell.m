//
//  QIMGroupCardTopicCell.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/16.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMGroupCardTopicCell.h"
#import "QIMMenuView.h"
#import "QIMCommonFont.h"
#import "NSBundle+QIMLibrary.h"

@implementation QIMGroupCardTopicCell{
    UIView *_rootView;
    UILabel *_titleLabel;
    UILabel *_groupTopicLabel;
    
    QIMMenuView    * _menuView;
}

+ (CGFloat)getCellHeightWithTopic:(NSString *)topic{
    CGSize size = [topic sizeWithFont:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 6] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat height = 10 + 20 + size.height + (size.height>0?5:0) + 10;
    return height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        [_rootView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_rootView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 70, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setText:[NSBundle qim_localizedStringForKey:@"group_topic"]];
        [_rootView addSubview:_titleLabel];
        
        _groupTopicLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, _titleLabel.bottom + 5, _rootView.width - 20, 0)];
        [_groupTopicLabel setBackgroundColor:[UIColor clearColor]];
        [_groupTopicLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [_groupTopicLabel setTextColor:[UIColor blackColor]];
        [_groupTopicLabel setTextAlignment:NSTextAlignmentLeft];
        [_groupTopicLabel setNumberOfLines:0];
        [_rootView addSubview:_groupTopicLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, _rootView.height - 0.5, _rootView.width - 10, 0.5)];
        [line setBackgroundColor:[UIColor qtalkTableDefaultColor]];
        [_rootView addSubview:line];
        
        _menuView = [[QIMMenuView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_menuView];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshUI{
    _titleLabel.font = [UIFont boldSystemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
    _groupTopicLabel.font = [UIFont boldSystemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 6];
    CGSize size = [self.topic sizeWithFont:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 6] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    CGRect titleFrame = _groupTopicLabel.frame;
    titleFrame.size.height = size.height;
    [_groupTopicLabel setFrame:titleFrame];
    [_groupTopicLabel setText:self.topic];
    CGRect rootFrame = _rootView.frame;
    rootFrame.size.height = (size.height>0?_groupTopicLabel.bottom:_titleLabel.bottom) + 10;
    [_rootView setFrame:rootFrame];
    
    _menuView.coprText = self.topic;
    _menuView.frame = self.contentView.bounds;
}

@end
