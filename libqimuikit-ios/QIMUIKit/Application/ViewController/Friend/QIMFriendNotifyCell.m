//
//  QIMFriendNotifyCell.m
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMFriendNotifyCell.h"

@implementation QIMFriendNotifyCell{
    UIImageView *_headerImageView;
    UILabel *_nameLabel;
    UILabel *_descLabel;
    UIButton *_openationButton;
}
+ (CGFloat)getCellHeight{
    return 60;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        _headerImageView.image = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
        [_headerImageView setClipsToBounds:YES];
        [_headerImageView.layer setCornerRadius:20];
        [self.contentView addSubview:_headerImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headerImageView.right+10, 10, self.width - _headerImageView.right - 10 - 80, 20)];
        [_nameLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setFont:[UIFont systemFontOfSize:16]];
        [_nameLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [self.contentView addSubview:_nameLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headerImageView.right+10, 30, self.width - _headerImageView.right - 10 - 80, 20)];
        [_descLabel setBackgroundColor:[UIColor clearColor]];
        [_descLabel setFont:[UIFont systemFontOfSize:14]];
        [_descLabel setTextColor:[UIColor qtalkTextLightColor]];
        [self.contentView addSubview:_descLabel];

        _openationButton = [[UIButton alloc] initWithFrame:CGRectMake(_nameLabel.right + 10, 15, 60, 30)];
        [_openationButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_openationButton setBackgroundColor:[UIColor clearColor]];
        [_openationButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_openationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_openationButton setTitleColor:[UIColor qtalkTextLightColor] forState:UIControlStateDisabled];
        [_openationButton setTitle:@"已同意" forState:UIControlStateNormal];
        [_openationButton setBackgroundImage:[UIImage imageNamed:@"AV_Check_start_button_normal@2x"] forState:UIControlStateNormal];
        [_openationButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor clearColor]] forState:UIControlStateDisabled];
        [_openationButton addTarget:self action:@selector(onAgreeClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_openationButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_nameLabel.left, [QIMFriendNotifyCell getCellHeight]-0.5, [UIScreen mainScreen].bounds.size.width-_nameLabel.left, 0.5)];
        [lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [self.contentView addSubview:lineView];
        
    }
    return self;
}

- (void)onAgreeClick{
    if ([self.delegate respondsToSelector:@selector(agreeAddFriendWihtUserInfoDic:)]) {
        [self.delegate agreeAddFriendWihtUserInfoDic:self.userDic];
    }
}

- (void)refreshUI{
    NSString *jid = [self.userDic objectForKey:@"XmppId"];
    NSString *name = [self.userDic objectForKey:@"Name"];
    NSString *descInfo = [self.userDic objectForKey:@"DescInfo"];
    [_nameLabel setText:name];
    [_descLabel setText:descInfo];
    /*
    UIImage * headImage = [[QIMKit sharedInstance] getUserHeaderImageByUserId:jid?jid:@""];
    if (headImage) {
        [_headerImageView setImage:headImage];
    }
    */
    [_headerImageView qim_setImageWithJid:jid];
    int state = [[self.userDic objectForKey:@"State"] intValue];
    switch (state) {
        case 0:
        {
            [_openationButton setTitle:@"同意" forState:UIControlStateNormal];
            [_openationButton setEnabled:YES];
        }
            break;
        case 1:
        {
            [_openationButton setTitle:@"已同意" forState:UIControlStateDisabled];
            [_openationButton setEnabled:NO];
        }
            break;
        case 2:
        {
            [_openationButton setTitle:@"已拒绝" forState:UIControlStateDisabled];
            [_openationButton setEnabled:NO];
        }
            break;
        default:
            break;
    }
}

@end
