
//
//  QIMUserTableViewCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/17.
//

#import "QIMUserTableViewCell.h"
#import "QIMCommonFont.h"

@interface QIMUserTableViewCell ()

@property (nonatomic, strong) YLImageView *headerView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, copy) NSString *jid;

@property (nonatomic, copy) NSString *name;

@end

@implementation QIMUserTableViewCell

+ (CGFloat)getCellHeightForDesc:(NSString *)desc{
    CGSize size = [desc qim_sizeWithFontCompatible:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 6] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10 - 50 - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    return [[QIMCommonFont sharedInstance] currentFontSize] + size.height + 30;
}

#pragma mark - setter and getter

- (void)setUserInfoDic:(NSDictionary *)userInfoDic {
    if (userInfoDic) {
        _userInfoDic = userInfoDic;
        self.jid = [userInfoDic objectForKey:@"XmppId"];
        self.name = [userInfoDic objectForKey:@"Name"];
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.jid];
        if (remarkName) {
            self.name = remarkName;
        }
        if (!self.name) {
            self.name = [self.userInfoDic objectForKey:@"UserId"];
        }
    }
}

- (YLImageView *)headerView {
    if (!_headerView) {
        _headerView = [[YLImageView alloc] initWithFrame:CGRectMake(kQTalkUserCellHeaderLeftMargin, kQTalkUserCellHeaderTopMargin, kQTalkUserCellHeaderWidth, kQTalkUserCellHeaderHeight)];
        _headerView.layer.cornerRadius = kQTalkUserCellHeaderWidth / 2.0f;
        _headerView.layer.masksToBounds = YES;
    }
    return _headerView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerView.right + kQTalkUserCellNameLabelLeftMargin, kQTalkUserCellHeaderTopMargin, 150, kQTalkUserCellHeaderHeight)];
        _nameLabel.textColor = [UIColor qtalkTextBlackColor];
        _nameLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
    }
    return _nameLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headerView];
        [self.contentView addSubview:self.nameLabel];
//        self.headerView.centerY = self.contentView.centerY;
//        self.nameLabel.centerY = self.contentView.centerY;
    }
    return self;
}

- (void)registerNSNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:kUsersVCardInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:kMarkNameUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader) name:kUserHeaderImgUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader) name:kUserStatusChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader) name:kNotifyUserOnlineStateUpdate object:nil];
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - NSNotification

- (void)refreshHeader {
    
    NSString *jid = [self.userInfoDic objectForKey:@"XmppId"];
//    [self.headerView setImage:[[QIMKit sharedInstance] getUserHeaderImageByUserId:jid]];
    [self.headerView qim_setImageWithJid:jid];
}

- (void)refreshUI {
    [self refreshHeader];
    self.nameLabel.text = self.name;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
