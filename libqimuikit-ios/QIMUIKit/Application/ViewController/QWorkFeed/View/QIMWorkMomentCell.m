//
//  QIMWorkMomentCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentCell.h"
#import "QIMWorkMomentLabel.h"
#import "QIMMessageParser.h"
#import "QIMWorkMomentModel.h"
#import "QIMWorkMomentContentModel.h"
#import "QIMWorkMomentPicture.h"
#import "QIMWorkMomentImageListView.h"
#import <YYModel/YYModel.h>

// 最大高度限制
CGFloat maxLimitHeight = 0;

@interface QIMWorkMomentCell () {
    CGFloat _rowHeight;
}

@end

@implementation QIMWorkMomentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        [self setUPUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMomentDetail:) name:kNotifyReloadWorkFeedDetail object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMomentLike:) name:kNotifyReloadWorkFeedLike object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMomentUI:) name:kNotifyReloadWorkFeedCommentNum object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateMomentDetail:(NSNotification *)notify {
    NSDictionary *momentDic = notify.object;
    QIMWorkMomentModel *momentModel = [QIMWorkMomentModel yy_modelWithDictionary:momentDic];
    NSDictionary *contentModelDic = [[QIMJSONSerializer sharedInstance] deserializeObject:[momentDic objectForKey:@"content"] error:nil];
    QIMWorkMomentContentModel *conModel = [QIMWorkMomentContentModel yy_modelWithDictionary:contentModelDic];
    momentModel.content = conModel;
    momentModel.isFullText = self.moment.isFullText;
    if ([momentModel.momentId isEqualToString:self.moment.momentId]) {
        [self setMoment:momentModel];
    }
}

- (void)updateMomentLike:(NSNotification *)notify {
    NSDictionary *data = notify.object;
    NSString *postId = [data objectForKey:@"postId"];
    if ([postId isEqualToString:self.moment.momentId]) {
        self.moment.likeNum = [[data objectForKey:@"likeNum"] integerValue];
        self.moment.isLike = [[data objectForKey:@"isLike"] boolValue];
        [self updateLikeUI];
    }
}

- (void)updateMomentUI:(NSNotification *)notify {
    NSDictionary *data = notify.object;
    NSString *postId = [data objectForKey:@"postId"];
    if ([postId isEqualToString:self.moment.momentId]) {
        self.moment.commentsNum = [[data objectForKey:@"postCommentNum"] integerValue];
        [self updateCommentUI];
    }
}

- (void)setUPUI {
    
    // 头像视图
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 43, 43)];
    _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headImageView.userInteractionEnabled = YES;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = _headImageView.width / 2.0f;
    _headImageView.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    _headImageView.layer.borderColor = [UIColor qim_colorWithHex:0xDFDFDF].CGColor;
    _headImageView.layer.borderWidth = 0.5f;
    [self.contentView addSubview:_headImageView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
    [_headImageView addGestureRecognizer:tapGesture];
    
    // 名字视图
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right + 8, _headImageView.top, 50, 20)];
    _nameLab.font = [UIFont boldSystemFontOfSize:15.0];
    _nameLab.textColor = [UIColor qim_colorWithHex:0x00CABE];
    _nameLab.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_nameLab];
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
    [_organLab sizeToFit];
    _organLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_organLab];
    
    _rIdLabe = [[UILabel alloc] init];
    _rIdLabe.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F3];
    _rIdLabe.font = [UIFont systemFontOfSize:11];
    _rIdLabe.textColor = [UIColor qim_colorWithHex:0x999999];
    _rIdLabe.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_rIdLabe];
    _rIdLabe.hidden = YES;
    
    _controlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _controlBtn.frame = CGRectMake(SCREEN_WIDTH - 15 - 19, _nameLab.top, 19, 19);
    [_controlBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f1cd" size:28 color:[UIColor qim_colorWithHex:0x999999]]] forState:UIControlStateNormal];
    _controlBtn.centerY = _nameLab.centerY;
    [_controlBtn addTarget:self action:@selector(controlPanelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_controlBtn];
    
    _controlDebugBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _controlDebugBtn.frame = CGRectMake(_controlBtn.left - 30, _nameLab.top, 19, 19);
    [_controlDebugBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f1cd" size:28 color:[UIColor redColor]]] forState:UIControlStateNormal];
    _controlDebugBtn.centerY = _nameLab.centerY;
    [_controlDebugBtn addTarget:self action:@selector(controlDebugPanelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_controlDebugBtn];
    
    // 正文视图
    _contentLabel = [[QIMWorkMomentLabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.linesSpacing = 1.0f;
    _contentLabel.characterSpacing = 0.0f;
    _contentLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    _contentLabel.verticalAlignment = QCVerticalAlignmentBottom;
    [self.contentView addSubview:_contentLabel];

    // 查看'全文'按钮
    _showAllBtn = [[UIButton alloc]init];
    _showAllBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _showAllBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _showAllBtn.backgroundColor = [UIColor clearColor];
    [_showAllBtn setTitle:@"全文" forState:UIControlStateNormal];
    [_showAllBtn setTitleColor:[UIColor qim_colorWithHex:0xBFBFBF] forState:UIControlStateNormal];
    [_showAllBtn addTarget:self action:@selector(fullTextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_showAllBtn];
    
    // 图片区
    _imageListView = [[QIMWorkMomentImageListView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_imageListView];

    // 时间视图
    _timeLab = [[UILabel alloc] init];
    _timeLab.textColor = [UIColor qim_colorWithHex:0xADADAD];
    _timeLab.font = [UIFont systemFontOfSize:13.0f];
    [_timeLab sizeToFit];
    [self.contentView addSubview:_timeLab];
    
    //点赞按钮
    _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0e7" size:20 color:[UIColor qim_colorWithHex:0x999999]]] forState:UIControlStateNormal];
    [_likeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0cd" size:20 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
    [_likeBtn setTitle:@"顶" forState:UIControlStateNormal];
    [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
    [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateSelected];
    _likeBtn.layer.cornerRadius = 13.5f;
    _likeBtn.layer.masksToBounds = YES;
    [_likeBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
    _likeBtn.layer.borderWidth = 0.5f;
    _likeBtn.layer.borderColor = [UIColor qim_colorWithHex:0xDDDDDD].CGColor;
    [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
    [_likeBtn addTarget:self action:@selector(didLikeMoment:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_likeBtn];
    
    //评论按钮
    _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0ef" size:20 color:[UIColor qim_colorWithHex:0x999999]]] forState:UIControlStateNormal];
    [_commentBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0ef" size:20 color:[UIColor qim_colorWithHex:0x999999]]] forState:UIControlStateSelected];
    [_commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    [_commentBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
    [_commentBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateSelected];
    _commentBtn.layer.cornerRadius = 13.5f;
    _commentBtn.layer.masksToBounds = YES;
    [_commentBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
    _commentBtn.layer.borderWidth = 0.5f;
    _commentBtn.layer.borderColor = [UIColor qim_colorWithHex:0xDDDDDD].CGColor;
    [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
    [_commentBtn addTarget:self action:@selector(didAddComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_commentBtn];
    
    // 最大高度限制
    maxLimitHeight = (_contentLabel.font.lineHeight) * 6 - 1.0;
}

- (void)setMoment:(QIMWorkMomentModel *)moment {
    _moment = moment;
    [self.lineView removeFromSuperview];
    NSString *userId = [NSString stringWithFormat:@"%@@%@", moment.ownerId, moment.ownerHost];
    if ([userId isEqualToString:[[QIMKit sharedInstance] getLastJid]] && self.notShowControl == NO) {
        self.controlBtn.hidden = NO;
    } else {
        self.controlBtn.hidden = YES;
    }
    if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
        
        self.controlDebugBtn.hidden = NO;
    } else {
        self.controlDebugBtn.hidden = YES;
    }
    _showAllBtn.hidden = YES;
    if (moment.isAnonymous == NO) {
        
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
        _rIdLabe.text = [NSString stringWithFormat:@"%ld", moment.rId];
    } else {
        
        NSString *anonymousPhoto = moment.anonymousPhoto;
        NSString *anonymousName = moment.anonymousName;
        if (![anonymousPhoto qim_hasPrefixHttpHeader]) {
            anonymousPhoto = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], anonymousPhoto];
        }
        [_headImageView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
        _nameLab.text = anonymousName;
        _nameLab.textColor = [UIColor qim_colorWithHex:0x999999];
        [_nameLab sizeToFit];
        
        _organLab.hidden = YES;
        _rIdLabe.frame = CGRectMake(self.nameLab.right + 5, self.nameLab.top, 20, 20);
        _rIdLabe.text = [NSString stringWithFormat:@"%ld", moment.rId];
    }
    _nameLab.centerY = self.headImageView.centerY;
    _organLab.centerY = self.headImageView.centerY;
    _rIdLabe.centerY = self.headImageView.centerY;
    CGFloat bottom = self.headImageView.bottom;
    _contentLabel.text = moment.content.content;
    [_contentLabel sizeToFit];
    CGFloat textH = [_contentLabel getHeightWithWidth:SCREEN_WIDTH - self.nameLab.left - 20];
    if(self.alwaysFullText) {
        _showAllBtn.hidden = YES;
    } else {
        if (textH > maxLimitHeight) {
            if (!moment.isFullText) {
                textH = maxLimitHeight;
                [self.contentLabel setNumberOfLines:6];
                [self.showAllBtn setTitle:@"全文" forState:UIControlStateNormal];
            } else {
                [self.contentLabel setNumberOfLines:0];
                [self.showAllBtn setTitle:@"收起" forState:UIControlStateNormal];
            }
            _showAllBtn.hidden = NO;
        } else {
            [self.contentLabel setNumberOfLines:0];
        }
    }
    [self.contentLabel setFrameWithOrign:CGPointMake(self.nameLab.left, bottom + 3) Width:(SCREEN_WIDTH - self.nameLab.left - 20)];
//    self.contentLabel.height = textH;
    _showAllBtn.frame = CGRectMake(self.nameLab.left, _contentLabel.bottom + 5, 60, 20);
    if (_showAllBtn.hidden) {
        bottom = _contentLabel.bottom + 8;
        _rowHeight = self.contentLabel.bottom;
    } else {
        bottom = _showAllBtn.bottom + 8;
        _rowHeight = self.showAllBtn.bottom;
    }
    if (moment.content.imgList.count > 0) {
        _imageListView.momentContentModel = moment.content;
        _imageListView.origin = CGPointMake(self.nameLab.left, bottom + 5);
        [_imageListView setTapSmallImageView:^(QIMWorkMomentContentModel * _Nonnull momentContentModel, NSInteger currentTag) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSmallImage:WithCurrentTag:)]) {
                [self.delegate didClickSmallImage:self.moment WithCurrentTag:currentTag];
            }
        }];
        _rowHeight = _imageListView.bottom;
    } else {
        
    }
    
    [self updateLikeUI];
    [self updateCommentUI];
    
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:([moment.createTime longLongValue]/1000)];
    _timeLab.text = [timeDate qim_timeIntervalDescription];
    _timeLab.frame = CGRectMake(self.contentLabel.left, _rowHeight + 15, 60, 12);
    _timeLab.centerY = _commentBtn.centerY;
    _moment.rowHeight = self.commentBtn.bottom + 18;
}

- (void)updateLikeUI {
    _likeBtn.frame = CGRectMake(SCREEN_WIDTH - 15 - 70, _rowHeight + 15, 70, 27);
    NSInteger likeNum = self.moment.likeNum;
    if (self.moment.isLike) {
        _likeBtn.selected = YES;
        [_likeBtn setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateSelected];
    } else {
        _likeBtn.selected = NO;
        if (likeNum > 0) {
            [_likeBtn setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateNormal];
        } else {
            [_likeBtn setTitle:@"顶" forState:UIControlStateNormal];
        }
    }
}

- (void)updateCommentUI {
    _commentBtn.frame = CGRectMake(_likeBtn.left - 15 - 70, _rowHeight + 15, 70, 27);
    if (self.moment.commentsNum > 0) {
        [_commentBtn setTitle:[NSString stringWithFormat:@"%ld", self.moment.commentsNum] forState:UIControlStateNormal];
    } else {
        [_commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    }
}

- (void)setLikeActionHidden:(BOOL)likeActionHidden {
    _likeActionHidden = likeActionHidden;
    if (likeActionHidden == YES) {
        [self.likeBtn setHidden:YES];
    }
}

- (void)setCommentActionHidden:(BOOL)commentActionHidden {
    _commentActionHidden = commentActionHidden;
    if (commentActionHidden == YES) {
        [self.commentBtn setHidden:YES];
    }
}

#pragma mark - Action

//操作这条Moment
- (void)controlPanelClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didControlPanelMoment:)]) {
        [self.delegate didControlPanelMoment:self];
    }
}

- (void)controlDebugPanelClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didControlDebugPanelMoment:)]) {
        [self.delegate didControlDebugPanelMoment:self];
    }
}

//点击全文/收起
- (void)fullTextClicked:(UIButton *)sender {
    self.moment.isFullText = !self.moment.isFullText;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFullText:withFullText:)]) {
        [self.delegate didSelectFullText:self withFullText:self.moment.isFullText];
    }
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

- (void)didLikeMoment:(UIButton *)sender {
    BOOL likeFlag = !sender.selected;
    [[QIMKit sharedInstance] likeRemoteMomentWithMomentId:self.moment.momentId withLikeFlag:likeFlag withCallBack:^(NSDictionary *responseDic) {
        if (responseDic.count > 0) {
            NSLog(@"点赞成功");
            BOOL islike = [[responseDic objectForKey:@"isLike"] boolValue];
            NSInteger likeNum = [[responseDic objectForKey:@"likeNum"] integerValue];
            if (islike) {
                sender.selected = YES;
                [sender setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateSelected];
            } else {
                sender.selected = NO;
                if (likeNum > 0) {
                    [sender setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateNormal];
                } else {
                    [sender setTitle:@"顶" forState:UIControlStateNormal];
                }
            }
        } else {
            NSLog(@"点赞失败");
        }
    }];
}

- (void)didAddComment:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didAddComment:)]) {
        [self.delegate didAddComment:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
