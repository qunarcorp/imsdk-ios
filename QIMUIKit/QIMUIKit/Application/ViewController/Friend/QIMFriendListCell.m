//
//  QIMFriendListCell.m
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//

#import "QIMFriendListCell.h"
#import "QIMCommonFont.h"

@interface QIMFriendListCell ()

@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *descInfo;

@property (nonatomic, strong) YLImageView *headerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descInfoLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *notReadNumButton;

@end

@implementation QIMFriendListCell

+ (CGFloat)getCellHeightForDesc:(NSString *)desc{
    CGSize size = [desc qim_sizeWithFontCompatible:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 6] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10 - 50 - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    return [[QIMCommonFont sharedInstance] currentFontSize] + size.height + 30;
}

- (YLImageView *)headerView {
    if (!_headerView) {
        _headerView = [[YLImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    }
    return _headerView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerView.right + 10, 10, self.width - 30 - self.headerView.right - 10, 20)];
        [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
        [_nameLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
    }
    return _nameLabel;
}

- (UILabel *)descInfoLabel {
    if (!_descInfoLabel) {
        _descInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headerView.right + 10, 30, self.width - 30 - _headerView.right - 10, 20)];
        [_descInfoLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 6]];
        [_descInfoLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_descInfoLabel setBackgroundColor:[UIColor clearColor]];
        _descInfoLabel.numberOfLines = 0;
    }
    return _descInfoLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView= [[UIView alloc] initWithFrame:CGRectMake(_nameLabel.left, [QIMFriendListCell getCellHeightForDesc:[self.userInfoDic objectForKey:@"DescInfo"]]-0.5, [UIScreen mainScreen].bounds.size.width-_nameLabel.left, 0.5)];
        [_lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
    }
    return _lineView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
        [self registerNotification];
    }
    return self;
}

- (void)setupUI {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.descInfoLabel];
}

- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:kUsersVCardInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:kMarkNameUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader) name:kUserHeaderImgUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader) name:kUserStatusChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader) name:kNotifyUserOnlineStateUpdate object:nil];

}

- (void)refreshHeader {
    
    NSString *jid = [self.userInfoDic objectForKey:@"XmppId"];
    _headerView.frame = CGRectMake(10, ([self.class getCellHeightForDesc:[self.userInfoDic objectForKey:@"DescInfo"]] - 50) / 2, 50, 50);
    /*
    UIImage *headerImage = [[QIMKit sharedInstance] getUserHeaderImageByUserId:jid];
    if (![[QIMKit sharedInstance] isUserOnline:jid]) {
        headerImage = [headerImage qim_grayImage];
    }
    [self.headerView setImage:headerImage];
    */
    [self.headerView qim_setImageWithJid:jid];
}

- (void)refreshUI{
    
    self.name = [self.userInfoDic objectForKey:@"Name"];
    self.jid = [self.userInfoDic objectForKey:@"XmppId"];
    self.descInfo = [self.userInfoDic objectForKey:@"DescInfo"];
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.jid];
    if (remarkName) {
        self.name = remarkName;
    }
    if (!self.name.length) {
        self.name = [self.userInfoDic objectForKey:@"UserId"];
    }
    
    self.nameLabel.frame = CGRectMake(self.headerView.right + 10, 10, [UIScreen mainScreen].bounds.size.width - 10 - self.headerView.right - 10, [[QIMCommonFont sharedInstance] currentFontSize] + 2);
    self.nameLabel.font = [UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
    
    CGSize size = [_descInfo qim_sizeWithFontCompatible:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 6] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10 - 50 - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    self.descInfoLabel.frame = CGRectMake(self.headerView.right + 10, self.nameLabel.bottom + 5, [UIScreen mainScreen].bounds.size.width - 10 - self.headerView.right - 10, size.height + 2);
    self.descInfoLabel.font = [UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 6];
    
    self.lineView.frame = CGRectMake(self.nameLabel.left, [QIMFriendListCell getCellHeightForDesc:[self.userInfoDic objectForKey:@"DescInfo"]]-1, [UIScreen mainScreen].bounds.size.width-self.nameLabel.left, 0.5);
    
    [self refreshHeader];
    [self.nameLabel setText:self.name];
    [self.descInfoLabel setText:self.descInfo];
    [self.lineView setHidden:self.isLast];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
