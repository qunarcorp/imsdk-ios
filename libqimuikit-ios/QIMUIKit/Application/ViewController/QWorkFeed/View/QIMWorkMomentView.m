//
//  QIMWorkMomentView.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/29.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentView.h"
#import "QIMWorkMomentImageListView.h"
#import "QIMWorkMomentLabel.h"
#import "QIMMarginLabel.h"

CGFloat maxFullContentHeight = 0;

@interface QIMWorkMomentView ()

// 头像
@property (nonatomic, strong) UIImageView *headImageView;
// 名称
@property (nonatomic, strong) UILabel *nameLab;
//组织架构Label
@property (nonatomic, strong) QIMMarginLabel *organLab;
//服务器IdLabel
@property (nonatomic, strong) UILabel *rIdLabe;
// 时间
@property (nonatomic, strong) UILabel *timeLab;
// 图片
@property (nonatomic, strong) QIMWorkMomentImageListView *imageListView;

//正文ContentLabel
@property (nonatomic, strong) QIMWorkMomentLabel *contentLabel;

@property (nonatomic, strong) QIMWorkMomentModel *moment;

@end

@implementation QIMWorkMomentView

- (instancetype)initWithFrame:(CGRect)frame withMomentModel:(QIMWorkMomentModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        _moment = model;
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 头像视图
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 43, 43)];
    _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headImageView.userInteractionEnabled = YES;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = _headImageView.width / 2.0f;
    _headImageView.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    _headImageView.layer.borderColor = [UIColor qim_colorWithHex:0xDFDFDF].CGColor;
    _headImageView.layer.borderWidth = 0.5f;
    [self addSubview:_headImageView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
    [_headImageView addGestureRecognizer:tapGesture];
    
    // 名字视图
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right + 8, _headImageView.top, 50, 20)];
    _nameLab.font = [UIFont boldSystemFontOfSize:15.0];
    _nameLab.textColor = [UIColor qim_colorWithHex:0x00CABE];
    _nameLab.backgroundColor = [UIColor clearColor];
    [self addSubview:_nameLab];
    _nameLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *nameTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickName:)];
    [_nameLab addGestureRecognizer:nameTapGesture];
    
    //组织架构视图
    _organLab = [[QIMMarginLabel alloc] init];
    _organLab.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F3];
    _organLab.font = [UIFont systemFontOfSize:11];
    _organLab.textColor = [UIColor qim_colorWithHex:0x999999];
    _organLab.textAlignment = NSTextAlignmentCenter;
    _organLab.layer.cornerRadius = 2.0f;
    _organLab.layer.masksToBounds = YES;
    _organLab.textAlignment = NSTextAlignmentCenter;
    [_organLab sizeToFit];
    [self addSubview:_organLab];
    
    _rIdLabe = [[UILabel alloc] init];
    _rIdLabe.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F3];
    _rIdLabe.font = [UIFont systemFontOfSize:11];
    _rIdLabe.textColor = [UIColor qim_colorWithHex:0x999999];
    _rIdLabe.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_rIdLabe];
    _rIdLabe.hidden = YES;
    
    // 正文视图
    _contentLabel = [[QIMWorkMomentLabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.linesSpacing = 1.0f;
    _contentLabel.characterSpacing = 0.0f;
    _contentLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    [self addSubview:_contentLabel];

    // 图片区
    _imageListView = [[QIMWorkMomentImageListView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageListView];
    
    // 时间视图
    _timeLab = [[UILabel alloc] init];
    _timeLab.textColor = [UIColor qim_colorWithHex:0xADADAD];
    _timeLab.font = [UIFont systemFontOfSize:13.0f];
    [_timeLab sizeToFit];
    [self addSubview:_timeLab];
    
    
    NSString *userId = [NSString stringWithFormat:@"%@@%@", self.moment.ownerId, self.moment.ownerHost];
    if (self.moment.isAnonymous == NO) {
        
        [_headImageView qim_setImageWithJid:userId];
        _nameLab.text = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
        _nameLab.textColor = [UIColor qim_colorWithHex:0x00CABE];
        [_nameLab sizeToFit];
        
        _organLab.frame = CGRectMake(self.nameLab.right + 5, self.nameLab.top, 66, 20);
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
        NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"";
        NSString *showDp = [[department componentsSeparatedByString:@"/"] objectAtIndex:2];
        _organLab.text = showDp ? [NSString stringWithFormat:@"%@", showDp] : @" 未知 ";
        [_organLab sizeToFit];
        [_organLab sizeThatFits:CGSizeMake(_organLab.width, _organLab.height)];
        _organLab.height = 20;
        
        _rIdLabe.frame = CGRectMake(self.organLab.right + 5, self.nameLab.top, 20, 20);
        _rIdLabe.text = [NSString stringWithFormat:@"%ld", self.moment.rId];
    } else {
        
        NSString *anonymousPhoto = self.moment.anonymousPhoto;
        NSString *anonymousName = self.moment.anonymousName;
        if (![anonymousPhoto qim_hasPrefixHttpHeader]) {
            anonymousPhoto = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], anonymousPhoto];
        }
        [_headImageView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
        _nameLab.text = anonymousName;
        _nameLab.textColor = [UIColor qim_colorWithHex:0x999999];
        [_nameLab sizeToFit];
        
        _organLab.hidden = YES;
        _rIdLabe.frame = CGRectMake(self.nameLab.right + 5, self.nameLab.top, 20, 20);
        _rIdLabe.text = [NSString stringWithFormat:@"%ld", self.moment.rId];
    }
    _nameLab.centerY = self.headImageView.centerY;
    _organLab.centerY = self.headImageView.centerY;
    _rIdLabe.centerY = self.headImageView.centerY;
    CGFloat bottom = self.headImageView.bottom;
    _contentLabel.text = self.moment.content.content;
    [_contentLabel sizeToFit];
    CGFloat textH = [_contentLabel getHeightWithWidth:SCREEN_WIDTH - self.nameLab.left - 20];
    [self.contentLabel setFrameWithOrign:CGPointMake(self.nameLab.left, bottom + 3) Width:(SCREEN_WIDTH - self.nameLab.left - 20)];
    self.contentLabel.height = textH;
    bottom = _contentLabel.bottom + 8;

    if (self.moment.content.imgList.count > 0) {
        _imageListView.momentContentModel = self.moment.content;
        _imageListView.origin = CGPointMake(self.nameLab.left, bottom + 5);
        [_imageListView setTapSmallImageView:^(QIMWorkMomentContentModel * _Nonnull momentContentModel, NSInteger currentTag) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSmallImage:WithCurrentTag:)]) {
                [self.delegate didClickSmallImage:self.moment WithCurrentTag:currentTag];
            }
        }];
        bottom = _imageListView.bottom;
    } else {
        
    }
    
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:([self.moment.createTime longLongValue]/1000)];
    _timeLab.text = [timeDate qim_timeIntervalDescription];
    _timeLab.frame = CGRectMake(self.contentLabel.left, bottom + 15, 60, 12);
    
    self.height = _timeLab.bottom + 15;
}

// 点击头像
- (void)clickHead:(UITapGestureRecognizer *)gesture {
    if (self.moment.isAnonymous == NO) {
        NSString *userId = [NSString stringWithFormat:@"%@@%@", self.moment.ownerId, self.moment.ownerHost];
        [QIMFastEntrance openUserCardVCByUserId:userId];
    }
}

- (void)clickName:(UITapGestureRecognizer *)tapGesture {
    if (self.moment.isAnonymous == NO) {
        NSString *userId = [NSString stringWithFormat:@"%@@%@", self.moment.ownerId, self.moment.ownerHost];
        [QIMFastEntrance openUserCardVCByUserId:userId];
    }
}

@end
