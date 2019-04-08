//
//  QIMEmotionsDownloadCell.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#import "QIMEmotionsDownloadCell.h"
#import "UIImageView+WebCache.h"
#import "QIMProgressHUD.h"
#import "QIMEmotionManager.h"

@interface QIMEmotionsDownloadCell ()

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

//按钮
@property (nonatomic, strong) UIButton *downloadBtn;

@end

@implementation QIMEmotionsDownloadCell

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
        [self.contentView addSubview:self.downloadBtn];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:kEmotionListUpdateNotification object:nil];
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

- (UIButton *)downloadBtn {
    
    if (!_downloadBtn) {
        
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadBtn setBackgroundColor:[UIColor whiteColor]];
        [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        _downloadBtn.layer.cornerRadius = 3.0f;
        _downloadBtn.layer.masksToBounds = YES;
        [_downloadBtn.layer setBorderColor:[UIColor qtalkIconSelectColor].CGColor];
        [_downloadBtn.layer setBorderWidth:1.0f];
        [_downloadBtn addTarget:self action:@selector(actionBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadBtn;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _iconView.frame = CGRectMake(10, (self.contentView.height - 35) / 2, 35, 35);
    
    _titleLabel.frame = CGRectMake(_iconView.right + 10, 10, self.contentView.width - _iconView.right - 20 - 80, 30);
    
    _descLabel.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, _titleLabel.width, 20);
    
    _downloadBtn.frame = CGRectMake(self.contentView.width - 80, (self.contentView.height - 30) / 2, 70, 30);
    
    switch (_state) {
        case EmotionStateDownload:
        {
            [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
            [_downloadBtn.layer setBorderColor:[UIColor qtalkIconSelectColor].CGColor];
            [_downloadBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
            [_downloadBtn setEnabled:YES];
        }
            break;
        case EmotionStateUpdate:
        {
            [_downloadBtn setTitle:@"更新" forState:UIControlStateNormal];
            [_downloadBtn.layer setBorderColor:[UIColor qtalkIconSelectColor].CGColor];
            [_downloadBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
            [_downloadBtn setEnabled:YES];
        }
            break;
        case EmotionStateDone:
        {
            [_downloadBtn setTitle:@"已下载" forState:UIControlStateNormal];
            [_downloadBtn.layer setBorderColor:[UIColor qtalkSplitLineColor].CGColor];
            [_downloadBtn setTitleColor:[UIColor qtalkSplitLineColor] forState:UIControlStateNormal];
            [_downloadBtn setEnabled:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)setEmotionState:(EmotionState )state{
    _state = state;
}

- (void)actionBtnHandle:(UIButton *)sender{
    if (_state == EmotionStateDownload) {
        
//        [[QIMEmotionManager sharedInstance] downloadEmotionForPkId:_pkID fileName:_pkID];
        [[QIMProgressHUD sharedInstance] showProgressHUDWithTest:@"正在下载..."];
        [[QIMEmotionManager sharedInstance] downloadEmotionForPkId:_pkID loadUrl:_loadURL];
        [self.downloadBtn setTitle:@"下载..." forState:UIControlStateDisabled];
        [self.downloadBtn setEnabled:NO];
    }
//    else if(_state == EmotionStateDone){
//        [[QIMEmotionManager sharedInstance] removeEmotionPkgForPkId:_pkID];
//        [_actionBtn setTitle:@"移除..." forState:UIControlStateDisabled];
//        [_actionBtn setEnabled:NO];
//    }
}


#pragma mark - Download emotion zip finish

- (void)downloadFinish:(id)sender{
    
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
