//
//  QIMMyEmotionsManagerCell.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#import "QIMMyEmotionsManagerCell.h"
#import "UIImageView+WebCache.h"
#import "QIMProgressHUD.h"
#import "QIMEmotionManager.h"

@interface QIMMyEmotionsManagerCell ()

//表情包下载状态
@property (nonatomic, assign) EmotionState state;

//表情包PkID
@property (nonatomic, copy) NSString *pkID;

//表情包下载Url
@property (nonatomic, copy) NSString *loadURL;

//表情预览图
@property (nonatomic, strong) UIImageView *iconView;

//表情title
@property (nonatomic, strong) UILabel *titleLabel;

//表情描述label
@property (nonatomic, strong) UILabel *descLabel;

//移除按钮
@property (nonatomic, strong) UIButton *removeBtn;

@end

@implementation QIMMyEmotionsManagerCell

- (void)setEmotion:(QIMEmotion *)emotion {
    
    _emotion = emotion;
    
    [self.iconView qim_setImageWithURL:[NSURL URLWithString:emotion.thumb] placeholderImage:nil];
    self.titleLabel.text = emotion.name;
    self.descLabel.text = emotion.desc;
    self.pkID = emotion.pkgid;
    self.loadURL = emotion.file;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [UIView new];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.removeBtn];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeEmotionPackageFinish:) name:kEmotionListUpdateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter and getter

- (UIImageView *)iconView {
    
    if (!_iconView) {
        
        _iconView = [UIImageView new];
        _iconView.clipsToBounds = YES;
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    
    if (!_descLabel) {
        
        _descLabel = [UILabel new];
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.textColor = [UIColor grayColor];
    }
    return _descLabel;
}

- (UIButton *)removeBtn {
    if (!_removeBtn) {
        _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeBtn setBackgroundColor:[UIColor whiteColor]];
        [_removeBtn setTitle:@"移除" forState:UIControlStateNormal];
        [_removeBtn setTitleColor:[UIColor qtalkTextLightColor] forState:UIControlStateNormal];
        _removeBtn.layer.cornerRadius = 3.0f;
        _removeBtn.layer.masksToBounds = YES;
        [_removeBtn.layer setBorderColor:[UIColor qtalkSplitLineColor].CGColor];
        [_removeBtn.layer setBorderWidth:1.0f];
        [_removeBtn addTarget:self action:@selector(removeEmotionPackage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _removeBtn;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _iconView.frame = CGRectMake(10, (self.contentView.height - 35) / 2, 35, 35);
    
    _titleLabel.frame = CGRectMake(_iconView.right + 10, 10, self.contentView.width - _iconView.right - 20 - 80, 30);
    
    _descLabel.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, _titleLabel.width, 20);
    
    _removeBtn.frame = CGRectMake(self.contentView.width - 80, (self.contentView.height - 30) / 2, 70, 30);
}

- (void)removeEmotionPackage:(UIButton *)sender {
    [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:@"移除中..."];
    [[QIMEmotionManager sharedInstance] removeEmotionPkgForPkId:self.pkID];
}

#pragma mark - Remove emotion zip finish

- (void)removeEmotionPackageFinish:(id)sender{
    
    [[QIMProgressHUD sharedInstance] closeHUD];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
