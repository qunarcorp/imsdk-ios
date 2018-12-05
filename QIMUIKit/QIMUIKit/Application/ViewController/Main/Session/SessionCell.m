//
//  SessionCell.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/15.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSDateFormatter  *__global_dateformatter;
#define NAME_LABEL_FONT     (FONT_SIZE - 1)  //名字字体
#define CONTENT_LABEL_FONT  (FONT_SIZE - 4)  //新消息字体,时间字体
#define COLOR_TIME_LABEL [UIColor blueColor] //时间颜色;
#import "SessionCell.h"
@implementation SessionCell{
    
    UIImageView *_headerView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    UILabel *_timeLabel;
    UIButton *_notReadNumButton;
    UILabel *_onLineLabel;
    //UIView * _lineView;
    UIImageView * _prefrenceImageView;
    
    
    
}

+ (CGFloat)getCellHeight{
    return 60;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[UIColor clearColor]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kMsgNotReadCountChange object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kUserStatusChange object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kNotificationMessageUpdate object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kGroupHeaderImageUpdate object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineState) name:kNotifyUserOnlineStateUpdate object:nil];
        
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [_headerView setImage:[UIImage imageNamed:@"singleHeaderDefault"]];
        _headerView.layer.masksToBounds = YES;
        _headerView.layer.cornerRadius  = 5;
        [_headerView setClipsToBounds:YES];
        [self.contentView addSubview:_headerView];
        
        _prefrenceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 35, 15, 15)];
        [_prefrenceImageView setHidden:YES];
        _prefrenceImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_prefrenceImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, [UIScreen mainScreen].bounds.size.width - 70, 20)];
        [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:NAME_LABEL_FONT]];
        [_nameLabel setTextColor:[UIColor spectralColorBlueColor]];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_nameLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.left, _nameLabel.bottom + 5, _nameLabel.width - 80, 16)];
        [_contentLabel setFont:[UIFont fontWithName:FONT_NAME size:CONTENT_LABEL_FONT]];
        [_contentLabel setTextColor:[UIColor grayColor]];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_contentLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, _contentLabel.frame.origin.y, 80, 16)];
        [_timeLabel setFont:[UIFont fontWithName:FONT_NAME size:CONTENT_LABEL_FONT]];
        [_timeLabel setTextColor:[UIColor grayColor]];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_timeLabel];
        
        _onLineLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 40, _contentLabel.frame.origin.y, 30, 16)];
        _onLineLabel.layer.cornerRadius = 5.0f;
        _onLineLabel.layer.masksToBounds = YES;
        [_onLineLabel setFont:[UIFont fontWithName:FONT_NAME size:CONTENT_LABEL_FONT]];
        [_onLineLabel setTextColor:[UIColor whiteColor]];
        [_onLineLabel setBackgroundColor:[UIColor blackColor]];
        _onLineLabel.hidden = YES;
        _onLineLabel.centerY = [SessionCell getCellHeight] / 2.0f;
        [self.contentView addSubview:_onLineLabel];

        _notReadNumButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width -30, 11, 16, 16)];
        [_notReadNumButton setUserInteractionEnabled:NO];
        [_notReadNumButton setBackgroundImage:[[UIImage qim_imageFromColor:[UIColor qunarRedColor]] stretchableImageWithLeftCapWidth:8 topCapHeight:8]  forState:UIControlStateNormal];
        [_notReadNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_notReadNumButton setBackgroundImage:[[UIImage qim_imageFromColor:[UIColor qunarRedColor]] stretchableImageWithLeftCapWidth:8 topCapHeight:8]  forState:UIControlStateHighlighted];
        
        [_notReadNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_notReadNumButton.titleLabel setFont:[UIFont systemFontOfSize:9]];
        [_notReadNumButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_notReadNumButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self.contentView addSubview:_notReadNumButton];
        _notReadNumButton.layer.cornerRadius = (_notReadNumButton.frame.size.width + 10) / 4;
        _notReadNumButton.layer.masksToBounds =YES;

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, [SessionCell getCellHeight]-1, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [lineView setBackgroundColor:[UIColor spectralColorGrayColor]];
        [self.contentView addSubview:lineView];
        
        self.hasAtCell = NO;
        
    }
    return self;
}

- (void)updateCell:(NSNotification *)notify{
    NSString *userId = [notify object];
    
    if ([userId isEqualToString:self.jid]) {
        [self refreshUI];
    }
}

- (void)updateOnlineState{
    if (!self.isGroup) {
        [self refreshUI];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
}

- (NSAttributedString *)decodeMsg:(NSString *)msg{
    NSMutableAttributedString *attStr = nil;
    if (msg &&  [msg isKindOfClass:[NSString class]]) {
        NSUInteger startLoc = 0;
        int index = 0;
        NSString * lastStr = @"";
        attStr = [[NSMutableAttributedString alloc] init];
//        NSString *regulaStr = @"\\[obj type=\"(.*?)\" value=\"(.*?)\" width=(.*?) height=(.*?)\\]";
        
        NSString *regulaStr = @"\\[obj type=\"(.*?)\" value=\"(.*?)\"( width=(.*?) height=(.*?))?\\]";
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *arrayOfAllMatches = [regex matchesInString:msg options:0 range:NSMakeRange(0, [msg length])];
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
            NSRange firstRange  =  [match rangeAtIndex:1];
            NSString *type = [msg substringWithRange:firstRange];
            NSRange secondRange =  [match rangeAtIndex:2];
            NSString *value = [msg substringWithRange:secondRange];
            NSUInteger len = match.range.location - startLoc;
            NSString *tStr = [msg substringWithRange:NSMakeRange(startLoc, len)];
            [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:tStr]];
            if ([type isEqualToString:@"image"]) {
                [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"[图片]"]];
            } else if ([type isEqualToString:@"emoticon"]) {
                [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"[表情]"]];
            } else if ([type isEqualToString:@"url"]){
                NSAttributedString *attStr1 = [[NSAttributedString alloc] initWithString:value attributes:@{NSForegroundColorAttributeName:[UIColor blueColor ]}];
                [attStr appendAttributedString:attStr1];
            }
            startLoc = match.range.location + match.range.length ;
            if (index == arrayOfAllMatches.count - 1) {
                lastStr = [msg substringFromIndex:(match.range.location + match.range.length)];
                [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:lastStr]];
            }
            index++;
        }
        if (arrayOfAllMatches.count <= 0) {
            [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:msg]];
        }
    }
    return attStr;
}

- (void)refreshUI{
    UIImage * headImage = nil;
    NSString * countStr = nil;
    NSString *content = nil;
    NSString *message = [_infoDic objectForKey:@"content"];
    NSString *nickName = [_infoDic objectForKey:@"NickName"];
    
    if (self.isGroup) {
        
//        headImage = [[QIMKit sharedInstance] getGroupImageFromLocalByGroupId:self.jid];
        [_headerView qim_setImageWithJid:self.jid WithChatType:ChatType_GroupChat];
        int notReadCount = [[QIMKit sharedInstance] getNotReadMsgCountByJid:self.jid] ;
        if (notReadCount > 0) {
            if (notReadCount > 99) {
                countStr =@"99+";
            }
            else {
                countStr =[NSString stringWithFormat:@"%d",notReadCount];
            }
        }
        [_prefrenceImageView setHidden:YES];
        switch ([[_infoDic objectForKey:@"MsgType"] intValue]) {
            case QIMMessageType_File:
            {
                if ([[_infoDic objectForKey:@"MsgDirection"] intValue] == MessageDirection_Received) {
                    content = [NSString stringWithFormat:@"%@:[文件]", nickName];
                } else {
                    content = @"[文件]";
                }
            }
                break;
            case QIMMessageType_Image:
            {
                if ([[_infoDic objectForKey:@"MsgDirection"] intValue] == MessageDirection_Received) {
                    content = [NSString stringWithFormat:@"%@:[图片]", nickName];
                } else {
                    content = @"[图片]";
                }
            }
                break;
            case QIMMessageType_Text:
            case QIMMessageType_Shock:
            {
                
                if ([[_infoDic objectForKey:@"MsgDirection"] intValue] == MessageDirection_Received) {
                    content = [NSString stringWithFormat:@"%@:%@", nickName, message];
                } else {
                    content = message;
                }
            }
                break;
            case QIMMessageType_Topic:
            {
                content = [NSString stringWithFormat:@"%@更新了群公告", nickName];
            }
                break;
            default:
            {
                content = @"";
            }
                break;
        }
        
        [_nameLabel setText:self.name];
    } else if (self.isSystem) {
        
        int notReadCount = [[QIMKit sharedInstance] getNotReadMsgCountByJid:self.jid] ;
        if (notReadCount > 0) {
            if (notReadCount > 99) {
                countStr =@"99+";
            }
            else {
                countStr =[NSString stringWithFormat:@"%d",notReadCount];
            }
        }
        [_headerView setImage:[UIImage imageNamed:@"icon_speaker_h39"]];
        [_prefrenceImageView setHidden:YES];
        
        switch ([[_infoDic objectForKey:@"MsgType"] intValue]) {
            case QIMMessageType_File:
            {
                content = @"[文件]";
            }
                break;
            case QIMMessageType_Image:
            {
                content = @"[图片]";
            }
                break;
            case QIMMessageType_Text:
            case QIMMessageType_Shock:
            {
                
                content = message;
            }
                break;
            default:
            {
                content = @"";
            }
                break;
        }
        
        [_nameLabel setText:@"系统消息"];
    } else {
        
        int notReadCount = [[QIMKit sharedInstance] getNotReadMsgCountByJid:self.jid] ;
        if (notReadCount > 0) {
            if (notReadCount > 99) {
                countStr =@"99+";
            }
            else {
                countStr =[NSString stringWithFormat:@"%d",notReadCount];
            }
        }
        /*
        headImage = [[QIMKit sharedInstance] getUserHeaderImageByUserId:_jid];
        if (headImage.images.count) {
            if (headImage.images[0] && ![headImage.images[0] isKindOfClass:[NSNull class]]) {
                headImage = headImage.images[0];
            }
        }
        */
        [_headerView qim_setImageWithJid:_jid];
        if ([[QIMKit sharedInstance] isUserOnline:self.jid]) {
            if (self.hasAtCell) {
                _onLineLabel.text = @"在线";
                _onLineLabel.hidden = NO;
            }
        } else {
            _onLineLabel.text = @"";
            _onLineLabel.hidden = YES;
        }
        switch ([[QIMKit sharedInstance] getUserPrecenseStatus:self.jid]) {
            case UserPrecenseStatus_Away:
            {
                UIImage *image = [UIImage imageNamed:@"Header+Search_Away_Normal"];
                [_prefrenceImageView setHidden:NO];
                [_prefrenceImageView setImage:image];
            }
                break;
            case UserPrecenseStatus_Dnd:
            {
                UIImage *image = [UIImage imageNamed:@"Header+Search_Busy_Normal"];
                [_prefrenceImageView setHidden:NO];
                [_prefrenceImageView setImage:image];
                
            }
                break;
            default:
                [_prefrenceImageView setHidden:YES];
                break;
        }
        
        switch ([[_infoDic objectForKey:@"MsgType"] intValue]) {
            case QIMMessageType_File:
            {
                content = @"[文件]";
            }
                break;
            case QIMMessageType_Image:
            {
                content = @"[图片]";
            }
                break;
            case QIMMessageType_Text:
            case QIMMessageType_Shock:
            {
                
                content = message;
            }
                break;
            default:
            {
                content = @"";
            }
                break;
        }
        
        [_nameLabel setText:self.name];
    }
    
    long long  msgDate = [[_infoDic objectForKey:@"MsgDateTime"] intValue];
    if (msgDate > 0) {
        NSDate *  senddate = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        
        if (__global_dateformatter == nil) {
            __global_dateformatter = [[NSDateFormatter alloc] init];
            [__global_dateformatter setDateFormat:@"MM-dd HH:mm"];
        }
        
        BOOL isToday = [senddate qim_isToday];
        if (isToday) {
            NSString *  locationString=[__global_dateformatter stringFromDate:senddate];
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
            
            [__global_dateformatter setDateFormat:@"MM-dd HH:mm"];
            
            NSString *  locationString=[__global_dateformatter stringFromDate:senddate];
            NSAttributedString *timeStr = [[NSAttributedString alloc]initWithString:locationString];
            [_timeLabel setAttributedText:timeStr];
        }
    } else {
        [_timeLabel setText:@""];
    }
    
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    [ps setAlignment:NSTextAlignmentLeft];
    NSArray *atNickNames = [[QIMKit sharedInstance] getHasAtMeByJid:self.jid];
    if (atNickNames.count > 0) {
        NSDictionary * titleDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor qim_colorWithHex:0xff0000 alpha:1], NSForegroundColorAttributeName, ps, NSParagraphStyleAttributeName, nil];
        NSAttributedString *atStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"你被@了%lu次",(unsigned long)atNickNames.count] attributes:titleDic];
        [str appendAttributedString:atStr];
    }
    [str appendAttributedString:[self decodeMsg:content]];

    [_contentLabel setAttributedText:str];
    
//    [_headerView setImage:headImage];
    if (countStr.length > 0) {
        [_notReadNumButton setHidden:NO];
        CGSize size = [countStr sizeWithFont:_notReadNumButton.titleLabel.font constrainedToSize:CGSizeMake(INT64_MAX, 14) lineBreakMode:NSLineBreakByCharWrapping];
        CGRect frame = _notReadNumButton.frame;
        frame.size.width = size.width + 8 > 16? size.width + 8 : 16;
        [_notReadNumButton setFrame:frame];
        [_notReadNumButton setTitle:countStr forState:UIControlStateNormal];
    } else {
        [_notReadNumButton setHidden:YES];
    }
    
    [_notReadNumButton setCenterX:_headerView.right];
    
    [_notReadNumButton  setCenterY:_headerView.top];
    
    
  
    if (self.hasAtCell) {

        [_notReadNumButton setHidden:YES];
        
        [_contentLabel setHidden:YES];
        
        [_timeLabel   setHidden:YES];
    }
}

@end
