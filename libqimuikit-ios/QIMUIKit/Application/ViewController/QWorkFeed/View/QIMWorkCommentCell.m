//
//  QIMWorkCommentCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkCommentCell.h"
#import "QIMWorkMomentLabel.h"
#import "QIMMessageParser.h"
#import "QIMMarginLabel.h"
#import "QIMWorkCommentModel.h"

@implementation QIMWorkCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 头像视图
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 43, 43)];
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
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, _headImageView.top, 50, 20)];
    _nameLab.font = [UIFont boldSystemFontOfSize:15.0];
    _nameLab.textColor = [UIColor qim_colorWithHex:0x00CABE];
    _nameLab.backgroundColor = [UIColor clearColor];
    _nameLab.userInteractionEnabled = YES;
    [self.contentView addSubview:_nameLab];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
    [_nameLab addGestureRecognizer:tapGesture2];
    
    //组织架构视图
    _organLab = [[QIMMarginLabel alloc] init];
    _organLab.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F3];
    _organLab.font = [UIFont systemFontOfSize:11];
    _organLab.textColor = [UIColor qim_colorWithHex:0x999999];
    _organLab.textAlignment = NSTextAlignmentCenter;
    _organLab.layer.cornerRadius = 2.0f;
    _organLab.layer.masksToBounds = YES;
    _organLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_organLab];
    
    //点赞按钮
    _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0e7" size:24 color:[UIColor qim_colorWithHex:0x999999]]] forState:UIControlStateNormal];
    [_likeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0cd" size:24 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
    [_likeBtn setTitle:@"顶" forState:UIControlStateNormal];
    [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
    [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateSelected];
    _likeBtn.layer.cornerRadius = 13.5f;
    _likeBtn.layer.masksToBounds = YES;
    [_likeBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
    [_likeBtn addTarget:self action:@selector(didLikeComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_likeBtn];

    //回复名称
    _replyNameLabel = [[UILabel alloc] init];
    [_replyNameLabel setTextColor:[UIColor qim_colorWithHex:0x999999]];
    [_replyNameLabel setFont:[UIFont systemFontOfSize:15]];
    [self.contentView addSubview:_replyNameLabel];
    
    // 正文视图
    _contentLabel = [[QIMWorkMomentLabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.linesSpacing = 1.0f;
    _contentLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    [self.contentView addSubview:_contentLabel];
}

- (void)setCommentModel:(QIMWorkCommentModel *)commentModel {
    if (commentModel.commentUUID.length <= 0) {
        return;
    }
    _commentModel = commentModel;;
    BOOL isAnonymousComment = commentModel.isAnonymous;
    if (isAnonymousComment == NO) {
        
        //实名评论
        NSString *commentFromUserId = [NSString stringWithFormat:@"%@@%@", commentModel.fromUser, commentModel.fromHost];
//        QIMVerboseLog(@"commentFromUserId : %@ --- %@", commentFromUserId, commentModel.commentUUID);
        [_headImageView qim_setImageWithJid:commentFromUserId];
        _nameLab.text = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:commentFromUserId];
        [_nameLab sizeToFit];
        
        _organLab.frame = CGRectMake(self.nameLab.right + 5, self.nameLab.top, 66, 20);
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:commentFromUserId];
        NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"";
        NSString *lastDp = [[department componentsSeparatedByString:@"/"] objectAtIndex:2];
        if(lastDp.length > 0) {
            _organLab.text = [NSString stringWithFormat:@"%@", lastDp];
        } else {
            _organLab.hidden = YES;
        }
        [_organLab sizeToFit];
        [_organLab sizeThatFits:CGSizeMake(_organLab.width, _organLab.height)];
        _organLab.height = 20;
    } else {
        //匿名评论
        NSString *anonymousName = commentModel.anonymousName;
        NSString *anonymousPhoto = commentModel.anonymousPhoto;
        if (![anonymousPhoto qim_hasPrefixHttpHeader]) {
            anonymousPhoto = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], anonymousPhoto];
        }
        [self.headImageView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
        self.nameLab.text = anonymousName;
        self.nameLab.textColor = [UIColor qim_colorWithHex:0x999999];
        self.organLab.hidden = YES;
    }
    CGFloat rowHeight = 0;

    _nameLab.centerY = self.headImageView.centerY;
    _organLab.centerY = self.headImageView.centerY;

    BOOL isChildComment = (commentModel.parentCommentUUID.length > 0) ? YES : NO;
    BOOL toisAnonymous = commentModel.toisAnonymous;
    NSString *replayNameStr = @"";
    if (isChildComment) {
        if (toisAnonymous) {
            NSString *toAnonymousName = commentModel.toAnonymousName;
            replayNameStr = [NSString stringWithFormat:@"回复 %@：", toAnonymousName];
        } else {
            NSString *toUser = commentModel.toUser;
            NSString *toUserHost = commentModel.toHost;
            if (toUser.length > 0) {
                
            }
            NSString *toUserId = [NSString stringWithFormat:@"%@@%@", toUser, toUserHost];
            NSString *toUserName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:toUserId];
            replayNameStr = [NSString stringWithFormat:@"回复 %@：", toUserName];
        }
    } else {
        replayNameStr = [NSString stringWithFormat:@""];
    }

    NSString *likeString  = [NSString stringWithFormat:@"%@%@", replayNameStr, commentModel.content];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:likeString];
    [attributedText addAttributeFont:[UIFont systemFontOfSize:15]];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x999999], NSFontAttributeName:[UIFont systemFontOfSize:15]}
                            range:[likeString rangeOfString:replayNameStr]];
    
    _contentLabel.attributedText = attributedText;
    [self.contentLabel setFrameWithOrign:CGPointMake(self.nameLab.left, self.nameLab.bottom + 16) Width:(SCREEN_WIDTH - self.nameLab.left - 20)];
    rowHeight = self.contentLabel.bottom;
    _likeBtn.frame = CGRectMake(SCREEN_WIDTH - 70, 5, 60, 27);
    NSInteger likeNum = commentModel.likeNum;
    BOOL isLike = commentModel.isLike;
    if (isLike) {
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
    _likeBtn.centerY = self.headImageView.centerY;
    
    _commentModel.rowHeight = _contentLabel.bottom + 20;
}

- (void)didLikeComment:(UIButton *)sender {
    BOOL likeFlag = !sender.selected;
    [[QIMKit sharedInstance] likeRemoteCommentWithCommentId:self.commentModel.commentUUID withMomentId:self.commentModel.postUUID withLikeFlag:likeFlag withCallBack:^(NSDictionary *responseDic) {
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

// 点击头像
- (void)clickHead:(UITapGestureRecognizer *)gesture {
    if (self.commentModel.isAnonymous == NO) {
        NSString *userId = [NSString stringWithFormat:@"%@@%@", self.commentModel.fromUser, self.commentModel.fromHost];
        [QIMFastEntrance openUserCardVCByUserId:userId];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
