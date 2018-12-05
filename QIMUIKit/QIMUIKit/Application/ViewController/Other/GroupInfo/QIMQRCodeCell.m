//
//  QIMQRCodeCell.m
//  qunarChatIphone
//
//  Created by qitmac000301 on 15/4/17.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMQRCodeCell.h"
#import "QIMCommonFont.h"
#import "NSBundle+QIMLibrary.h"

@implementation QIMQRCodeCell
{
    UIView *_rootView;
    UILabel *_titleLabel;
    UILabel *_accountLabel;
    UIImageView *_QRicon;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
+ (CGFloat)getCellHeight{
    return [[QIMCommonFont sharedInstance] currentFontSize] + 32;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [QIMQRCodeCell getCellHeight])];
        [_rootView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_rootView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, _rootView.width - 60, _rootView.height - 10)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_titleLabel setText:[NSBundle qim_localizedStringForKey:@"group_qr_code"]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_rootView addSubview:_titleLabel];
        
        _QRicon = [[UIImageView alloc]initWithFrame:CGRectMake(_rootView.frame.size.width - 60, 12.5, _rootView.height - 25, _rootView.height - 25)];
        _QRicon.image = [UIImage imageNamed:@"QRCode"];
        [_rootView addSubview:_QRicon];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, _rootView.height - 0.5, _rootView.width - 10, 0.5)];
        [line setBackgroundColor:[UIColor qtalkTableDefaultColor]];
        [_rootView addSubview:line];
    }
    return self;
}




- (void)refreshUI{
    _titleLabel.font = [UIFont boldSystemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
    if (self.Detail.length > 0) {
        [_titleLabel setText:self.Detail];
    }
}

@end
