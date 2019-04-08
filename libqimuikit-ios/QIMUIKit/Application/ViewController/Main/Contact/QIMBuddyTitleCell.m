//
//  QIMBuddyTitleCell.m
//  qunarChatIphone
//
//  Created by wangshihai on 15/1/4.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMBuddyTitleCell.h"

@interface QIMBuddyTitleCell(){

    //UIImageView *_headerView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    UIButton *_notReadNumButton;
    UIView * _lineView;
    UIImageView * _prefrenceImageView;
    
    BOOL   _isExpand;
    
    CALayer * parentLayer;
}

//@property (nonatomic, retain) CALayer *parentLayer;

@end

@implementation QIMBuddyTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        parentLayer = [CALayer layer];
        [self.contentView.layer addSublayer:parentLayer];
    }
    return self;
}

-(void) initSubControls
{
    
//    [self removeAllSubviews];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    
    _prefrenceImageView = [[UIImageView alloc] init];
    _prefrenceImageView.layer.masksToBounds = YES;
    _prefrenceImageView.layer.cornerRadius  = 5.0f;
    _prefrenceImageView.layer.borderWidth   = 0.01f;
    [self.contentView addSubview:_prefrenceImageView];
    
    [_prefrenceImageView setHidden:YES];
    
    // _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(addionWidth + 70, 10, 200, 20)];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
    [_nameLabel setTextColor:[UIColor qtalkTextLightColor]];
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

- (void)refresh {
    [_nameLabel setText:self.userName];
    
    CGFloat addionWidth  = 22 * (self.nLevel-1);
    
    [_prefrenceImageView setFrame:CGRectMake(addionWidth + 35, 35, 15, 15)];
    
    [_nameLabel  setFrame:CGRectMake(addionWidth + 50, 10, 200, 20)];
    
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
    

    [parentLayer setFrame:CGRectMake(addionWidth+28, 8, 24, 24)];
    parentLayer.contents = (id)[UIImage imageNamed:@"triangleSmall"].CGImage;
    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor spectralColorLightColor].CGColor);
    CGContextStrokeRect(context, CGRectMake(12, rect.size.height - 1, rect.size.width, 0.2));
}


- (void) setExpanded:(BOOL)flag{
    if ( _isExpand!= flag) {
        _isExpand = flag;
        
        CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"transform"];
        [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [ani setDuration:0.2];
        [ani setRepeatCount:1.0];
        [ani setAutoreverses:NO];
        [ani setFillMode:kCAFillModeForwards];	//needed so animated object won't go back to its original value after animation
        [ani setRemovedOnCompletion:NO];		//needed so animated object won't go back to its original value after animation

        CATransform3D transform = _isExpand?CATransform3DRotate(parentLayer.transform, M_PI/2, 0, 0, 1.0):CATransform3DIdentity;
        [ani setToValue:[NSValue valueWithCATransform3D:transform]];
        
        NSString *animationKey = _isExpand?@"expandingTransform":@"collapsingTransform";
        [parentLayer addAnimation:ani forKey:animationKey];
    }
}

@end
