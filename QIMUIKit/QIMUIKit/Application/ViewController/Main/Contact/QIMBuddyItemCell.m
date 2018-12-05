//
//  QIMBuddyItemCell.m
//  qunarChatIphone
//
//  Created by May on 14/11/20.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMBuddyItemCell.h"

@interface QIMBuddyItemCell () {
    UIImageView *_headerView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    UIButton *_notReadNumButton;
    UIView * _lineView;
    UIImageView * _prefrenceImageView;

}

@end

@implementation QIMBuddyItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initSubControls
{
    
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
        
    _headerView = [[UIImageView alloc] init];
    _headerView.layer.masksToBounds = YES;
    _headerView.layer.cornerRadius  = 20.0f;
    _headerView.layer.borderWidth   = 0.01f;
    [self.contentView addSubview:_headerView];
    
    _prefrenceImageView = [[UIImageView alloc] init];
    
    
    _prefrenceImageView.layer.masksToBounds = YES;
    _prefrenceImageView.layer.cornerRadius  = 5.0f;
    _prefrenceImageView.layer.borderWidth   = 0.01f;
    [self.contentView addSubview:_prefrenceImageView];
    [_prefrenceImageView setHidden:YES];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
    [_nameLabel setTextColor:[UIColor qtalkTextBlackColor]];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_nameLabel];
    
    _notReadNumButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -30, 11, 16, 16)];
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
    
}



- (void)refrash {
    
    
     CGFloat addtionWidth  = self.nLevel * 25;
    
    [_headerView setFrame:CGRectMake(addtionWidth + 10, 10, 40, 40)];
    
    [_prefrenceImageView setFrame:CGRectMake(addtionWidth + 35, 35, 15, 15)];
    
    [_nameLabel setFrame:CGRectMake(addtionWidth + 60, 10, 200, 20)];
    
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:_jid];
    [_nameLabel setText:remarkName?remarkName:self.userName];
    
    /*
    UIImage * headImage = [[QIMKit sharedInstance] getUserHeaderImageByUserId:_jid];
    if (headImage.images.count) {
        if (headImage.images[0] && ![headImage.images[0] isKindOfClass:[NSNull class]]) {
            headImage = headImage.images[0];
        }
    }
    //////////////////////////////////////////////////////////////////////////////////
    
    NSString *presence   = [[QIMKit sharedInstance] userOnlineStatus:_jid];
    if ([presence isEqualToString:@"online"]) {
        
    } else if ([presence isEqualToString:@"away"]){
        
    } else {
        headImage = [headImage qim_grayImage];
    }
       
    [_headerView setImage:headImage];
    */
    [_headerView qim_setImageWithJid:_jid];

    _notReadCount = [[QIMKit sharedInstance] getNotReadMsgCountByJid:_jid];
    if (_notReadCount > 0) {
        
        NSString * countStr = nil;
        if (_notReadCount > 99) {
            
            countStr =@"99+";
            [_notReadNumButton  setTitleEdgeInsets:UIEdgeInsetsMake(1, 4, 0, 0)];
        }
        else
        {
            countStr =[NSString stringWithFormat:@"%d",_notReadCount];
            
            if (_notReadCount > 9) {
                
                [_notReadNumButton setTitleEdgeInsets:UIEdgeInsetsMake(1, 2, 0, 0)];
            }
            else {
            
                [_notReadNumButton setTitleEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 0)];
            }
            
        }
        
        [_notReadNumButton setHidden:NO];
        CGSize size = [countStr sizeWithFont:_notReadNumButton.titleLabel.font constrainedToSize:CGSizeMake(INT64_MAX, 14) lineBreakMode:NSLineBreakByCharWrapping];
        CGRect frame = _notReadNumButton.frame;
        frame.size.width = size.width + 8 > 16? size.width + 8 : 16;
        [_notReadNumButton setFrame:frame];
        [_notReadNumButton setTitle:countStr forState:UIControlStateNormal];
    }
    else{
    
        [_notReadNumButton setHidden:YES];
    
    }
    
    switch ([[QIMKit sharedInstance] getUserPrecenseStatus:_jid]) {
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
    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor qim_colorWithHex:0xeaeaea alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(60, rect.size.height - 1, rect.size.width, 0.5));
}


@end
