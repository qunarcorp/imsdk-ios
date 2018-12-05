//
//  QIMPublicNumberCell.m
//  qunarChatIphone
//
//  Created by admin on 15/8/26.
//
//

#import "QIMPublicNumberCell.h"
#import "QIMJSONSerializer.h"

@implementation QIMPublicNumberCell{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
    UILabel *_contentLabel;
    UILabel *_timeLabel;
    NSDateFormatter *_global_dateformatter;
}

+ (CGFloat)getCellHeight{
    return 70;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [_iconImageView.layer setCornerRadius:5];
        [_iconImageView.layer setMasksToBounds:YES];
        [self.contentView addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconImageView.right+10, ([QIMPublicNumberCell getCellHeight]-20 - 18)/2.0, self.width - _iconImageView.right - 20, 20)];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, _titleLabel.width, 16)];
        [_contentLabel setFont:[UIFont fontWithName:FONT_NAME size:14]];
        [_contentLabel setTextColor:[UIColor qim_colorWithHex:0x888888 alpha:1]];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_contentLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 85, _titleLabel.bottom - 16, 75, 16)];
        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
        [_timeLabel setTextColor:[UIColor qim_colorWithHex:0xa1a1a1 alpha:1]];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_timeLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_titleLabel.left, [QIMPublicNumberCell getCellHeight]-0.5, self.width, 0.5)];
        [lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:lineView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshUI{
    [_titleLabel setText:self.name?self.name:self.publicNumberId];
    [_iconImageView setImage:[[QIMKit sharedInstance] getPublicNumberHeaderImageByFileName:self.headerSrc]];
    NSString *text = nil;
    switch (self.msgType) {
        case QIMMessageType_Text:
        {
            text = self.content;
        }
            break;
        case QIMMessageType_Consult:{
            NSDictionary *msgDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.content error:nil];
            NSString *tagStr = [msgDic objectForKey:@"source"];
            NSString *msgStr = [msgDic objectForKey:@"detail"];
            text = [NSString stringWithFormat:@"%@:%@",tagStr?tagStr:@"",msgStr];
        }
            break;
        default:
        {
            if (self.content.length > 0) {
                text = [[QIMKit sharedInstance] getMsgShowTextForMessageType:(QIMMessageType)self.msgType];
                if (text.length <= 0) {
                    text = @"你收到了一条消息。";
                }
            }
        }
            break;
    }
    [_contentLabel setText:text];
    
    long long  msgDate = self.msgDateTime;
    if (msgDate > 0) {
        NSDate *  senddate = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        
        if (_global_dateformatter == nil) {
            _global_dateformatter = [[NSDateFormatter alloc] init];
            [_global_dateformatter setDateFormat:@"MM-dd HH:mm"];
        }
        
        BOOL isToday = [senddate qim_isToday];
        if (isToday) {
            NSString *  locationString=[_global_dateformatter stringFromDate:senddate];
            locationString = [locationString substringFromIndex:6];
            NSInteger hour = [[locationString substringToIndex:2] integerValue];
            if (hour < 12) {
                NSAttributedString *timeStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",@"上午", locationString]];
                [_timeLabel setAttributedText:timeStr];
            } else {
                NSAttributedString *timeStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",@"下午", locationString]];
                [_timeLabel setAttributedText:timeStr];
            }
            
        } else {
            //            NSTimeInterval time = [date timeIntervalSince1970];
            
            [_global_dateformatter setDateFormat:@"MM-dd HH:mm"];
            
            NSString *  locationString=[_global_dateformatter stringFromDate:senddate];
            NSAttributedString *timeStr = [[NSAttributedString alloc]initWithString:[[locationString componentsSeparatedByString:@" "] objectAtIndex:0]];
            [_timeLabel setAttributedText:timeStr];
        }
    } else {
        [_timeLabel setText:@""];
    }

}

@end
