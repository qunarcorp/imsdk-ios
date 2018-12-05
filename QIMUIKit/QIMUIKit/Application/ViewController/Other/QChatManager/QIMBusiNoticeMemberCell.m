//
//  QIMBusiNoticeMemberCell.m
//  qunarChatIphone
//
//  Created by admin on 15/11/13.
//
//

#import "QIMBusiNoticeMemberCell.h"
#import "QRadioButton.h"
#import "YLImageView.h"

#define XPOS        40

@interface QIMBusiNoticeMemberCell()<QRadioButtonDelegate>
{
    YLImageView *_headerView;
    UILabel *_nameLabel;
    UILabel *_descLabel;
    UILabel *_contentLabel;
    UIButton *_notReadNumButton;
    UIView * _lineView;
    YLImageView * _prefrenceImageView;
    QRadioButton * _raidoBtn;
    
    BOOL _isExpand;
    
    
}
@end

@implementation QIMBusiNoticeMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)refrash {
    
    CGFloat addtionWidth  = self.nlevel * 20; 
    _raidoBtn = [[QRadioButton alloc] initWithDelegate:self groupId:_jid];
    
    [self.contentView addSubview:_raidoBtn];
    
    _raidoBtn.frame = CGRectMake(addtionWidth , 10, 80, 40);
    
    
    _raidoBtn.groupId = _jid;
    
    [_raidoBtn setTitle:@"" forState:UIControlStateNormal];
    [_raidoBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_raidoBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    
    
    [_nameLabel setText:self.userName];
    
    NSDictionary * userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:_jid];
    _descLabel.text = [userInfo valueForKey:@"DescInfo"];
    
    [_headerView qim_setImageWithJid:_jid];
    /*
    UIImage * headImage = [[QIMKit sharedInstance] getUserHeaderImageByUserId:_jid];
    if (headImage) {
        [_headerView setImage:headImage];
    }
     */
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

- (void)didSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId {
    QIMVerboseLog(@"did selected radio:%@ groupId:%@", radio.titleLabel.text, groupId);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_PERSON_TO_GROUP" object:groupId];
}

- (void)didUnSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DELETE_PERSON_TO_GROUP" object:groupId];
}
-(void) setStatus:(BOOL)bValue
{
    
    [_raidoBtn setChecked:bValue];
}



-(void)initSubControls{
    
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat addtionWidth  = self.nlevel * 15;
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    _headerView = [[YLImageView alloc] initWithFrame:CGRectMake(10+XPOS+addtionWidth, 10, 40, 40)];
    _headerView.image = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
    _headerView.layer.masksToBounds = YES;
    _headerView.layer.cornerRadius  = 5.0f;
    _headerView.layer.borderWidth   = 0.01f;
    [self.contentView addSubview:_headerView];
    
    _prefrenceImageView = [[YLImageView alloc] initWithFrame:CGRectMake(35+XPOS+addtionWidth, 35, 15, 15)];
    
    _prefrenceImageView.layer.masksToBounds = YES;
    _prefrenceImageView.layer.cornerRadius  = 5.0f;
    _prefrenceImageView.layer.borderWidth   = 0.01f;
    [self.contentView addSubview:_prefrenceImageView];
    
    [_prefrenceImageView setHidden:YES];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70+XPOS+addtionWidth, 10, 200, 17)];
    [_nameLabel setFont:[UIFont systemFontOfSize:14]];
    [_nameLabel setTextColor:[UIColor blackColor]];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_nameLabel];
    
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.left, _nameLabel.bottom + 3, self.contentView.width - _nameLabel.left - 10, 30)];
    _descLabel.font = [UIFont fontWithName:FONT_NAME size:(FONT_SIZE - 6)];
    _descLabel.textColor = [UIColor grayColor];
    _descLabel.numberOfLines = 0;
    [self.contentView addSubview:_descLabel];
    
    _lineView = [[UIView alloc] init];
    [_lineView setFrame:CGRectMake(15,_headerView.frame.origin.y  + 50, self.frame.size.width, 0.5)];
    [_lineView setBackgroundColor:[UIColor qim_colorWithHex:0xc7ced4 alpha:1.0]];
    [self.contentView addSubview:_lineView];
}
@end
