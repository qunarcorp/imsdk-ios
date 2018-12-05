//
//  QIMGroupViewCell.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/10.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMGroupViewCell.h"
#import "QIMCommonFont.h"

@implementation QIMGroupViewCell
{
    UIImageView *_headerView;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    UIButton *_notReadNumButton;
    UIImageView * _prefrenceImageView;
    
}

+ (float)getCellHeightForGroupName:(NSString *)groupName{
    CGSize size = [groupName qim_sizeWithFontCompatible:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize]] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10 - 60 - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    return MAX(size.height + 22, 60);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kGroupHeaderImageUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kGroupNickNameChanged object:nil];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [_headerView setImage:[UIImage imageNamed:@"singleHeaderDefault"]];
        _headerView.layer.masksToBounds = YES;
        _headerView.layer.cornerRadius  = _headerView.height / 2.0;
        _headerView.layer.borderWidth   = 1;
        _headerView.layer.borderColor   = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:_headerView];
        
        _prefrenceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 35, 15, 15)];
        
        _prefrenceImageView.layer.masksToBounds = YES;
        _prefrenceImageView.layer.cornerRadius  = 5.0f;
        _prefrenceImageView.layer.borderWidth   = 1.0f;
        [self.contentView addSubview:_prefrenceImageView];
        
        [_prefrenceImageView setHidden:YES];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 280, 40)];
        [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        [_nameLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        _nameLabel.numberOfLines = 0;
        [self.contentView addSubview:_nameLabel];
        
        _notReadNumButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width -30, 11, 16, 16)];
        [_notReadNumButton setUserInteractionEnabled:NO];
        [_notReadNumButton setBackgroundImage:[[UIImage qim_imageFromColor:[UIColor qunarRedColor]] stretchableImageWithLeftCapWidth:8 topCapHeight:8]  forState:UIControlStateNormal];
        [_notReadNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_notReadNumButton setBackgroundImage:[[UIImage qim_imageFromColor:[UIColor qunarRedColor]] stretchableImageWithLeftCapWidth:8 topCapHeight:8]  forState:UIControlStateHighlighted];
        
        [_notReadNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_notReadNumButton setHidden:YES];
        [_notReadNumButton.titleLabel setFont:[UIFont systemFontOfSize:9]];
        [_notReadNumButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_notReadNumButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self.contentView addSubview:_notReadNumButton];
        _notReadNumButton.layer.cornerRadius = (_notReadNumButton.frame.size.width + 10) / 4;
        _notReadNumButton.layer.masksToBounds =YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)updateCell:(NSNotification *)notify {
    NSArray *groupIds = [notify object];
    if ([groupIds containsObject:self.groupID]) {
        NSDictionary *cardDic = [[QIMKit sharedInstance] getGroupCardByGroupId:self.groupID];
        self.userName = [cardDic objectForKey:@"Name"];
        if (self.userName == nil) {
            [self setUserName:self.groupID];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refresh];
        });
    }
}

- (void)refresh {
    
    _headerView.frame = CGRectMake(5, ([self.class getCellHeightForGroupName:self.userName] - 40) / 2,  40, 40);
    _headerView.layer.cornerRadius = _headerView.width / 2;
    _nameLabel.frame = CGRectMake(_headerView.right + 10, 0, [UIScreen mainScreen].bounds.size.width - _headerView.right - 10 - 10, [self.class getCellHeightForGroupName:self.userName]);
    _nameLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize]];
    [_nameLabel setText:self.userName];
    UIImage * headImage = [[QIMKit sharedInstance] getGroupImageFromLocalByGroupId:self.groupID];
    [_headerView setImage:headImage];
//    if ([self.groupID containsString:self.userName]) {
//        [[QIMKit sharedInstance] updateGroupCardByGroupId:self.groupID];
//    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor spectralColorLightColor].CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 1, rect.size.width, 0.2));
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
