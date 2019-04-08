//
//  QIMWorkMessageCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/17.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMessageCell.h"
#import "QIMMarginLabel.h"

@interface QIMWorkMessageCell ()

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) QIMMarginLabel *organLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *contentImgPreview;

@property (nonatomic, strong) UILabel *contentPreLabel;

@end

@implementation QIMWorkMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectedBackgroundView = nil;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 头像视图
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 36, 36)];
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headerImageView.userInteractionEnabled = YES;
    _headerImageView.layer.masksToBounds = YES;
    _headerImageView.layer.cornerRadius = 20.0f;
    _headerImageView.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    _headerImageView.layer.borderColor = [UIColor qim_colorWithHex:0xDFDFDF].CGColor;
    _headerImageView.layer.borderWidth = 0.5f;
    [self.contentView addSubview:_headerImageView];
    
    // 名字视图
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerImageView.right + 10, 0, 50, 20)];
    _nameLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _nameLabel.textColor = [UIColor qim_colorWithHex:0x00CABE];
    _nameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_nameLabel];
    
    //组织架构视图
    _organLabel = [[QIMMarginLabel alloc] init];
    _organLabel.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F3];
    _organLabel.font = [UIFont systemFontOfSize:11];
    _organLabel.textColor = [UIColor qim_colorWithHex:0x999999];
    _organLabel.textAlignment = NSTextAlignmentCenter;
    _organLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_organLabel];
    
    // 正文视图
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    _contentLabel.numberOfLines = 0;
    [_contentLabel sizeToFit];
    _contentLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_contentLabel];

    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor qim_colorWithHex:0xADADAD];
    [self.contentView addSubview:_timeLabel];
    
    _contentImgPreview = [[UIImageView alloc] init];
    _contentImgPreview.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    _contentImgPreview.layer.cornerRadius = 4.0f;
    _contentImgPreview.layer.masksToBounds = YES;
    [self.contentView addSubview:_contentImgPreview];
    [_contentImgPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(56);
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    _contentPreLabel = [[UILabel alloc] init];
    _contentPreLabel.backgroundColor = [UIColor qim_colorWithHex:0xFFFFFF];
    _contentPreLabel.numberOfLines = 0;
    _contentPreLabel.textColor = [UIColor qim_colorWithHex:0x999999];
    _contentPreLabel.font = [UIFont systemFontOfSize:13];
    _contentPreLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _contentPreLabel.layer.cornerRadius = 4.0f;
    _contentPreLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:_contentPreLabel];
    [_contentPreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(56);
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
}

- (void)setNoticeMsgModel:(QIMWorkNoticeMessageModel *)noticeMsgModel {
    _noticeMsgModel = noticeMsgModel;
    NSLog(@"noticeMsgModel : %@", noticeMsgModel);
    
    NSString *userFrom = noticeMsgModel.userFrom;
    NSString *userFromHost = noticeMsgModel.userFromHost;
    BOOL fromIsAnonymous = noticeMsgModel.fromIsAnonymous;
    if (fromIsAnonymous) {
        
        NSString *fromAnonymousName = noticeMsgModel.fromAnonymousName;
        NSString *fromAnonymousPhoto = noticeMsgModel.fromAnonymousPhoto;
        if (![fromAnonymousPhoto qim_hasPrefixHttpHeader]) {
            fromAnonymousPhoto = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], fromAnonymousPhoto];
        }
        [self.headerImageView qim_setImageWithURL:[NSURL URLWithString:fromAnonymousPhoto]];

        self.nameLabel.text = fromAnonymousName;
        [self.nameLabel sizeToFit];
        self.nameLabel.centerY = self.headerImageView.centerY;
        
        NSString *toUser = noticeMsgModel.userTo;
        if (toUser.length > 0) {
            //回复的评论
            BOOL toIsAnonymous = noticeMsgModel.toIsAnonymous;
            if (toIsAnonymous) {
                //给匿名用户评论
                NSString *toAnonymousName = noticeMsgModel.toAnonymousName;
                self.contentLabel.text = [NSString stringWithFormat:@"回复 %@：%@", toAnonymousName, noticeMsgModel.content];
            } else {
                //给实名用户评论
                NSString *toUserId = [NSString stringWithFormat:@"%@@%@", noticeMsgModel.userTo, noticeMsgModel.userToHost ? noticeMsgModel.userToHost : [[QIMKit sharedInstance] getDomain]];
                NSString *userName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:toUserId];
                if ([toUserId isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
                    userName = @"我";
                }
                self.contentLabel.text = [NSString stringWithFormat:@"回复 %@：%@", userName, noticeMsgModel.content];
            }
        } else {
            //回复的帖子
            self.contentLabel.text = noticeMsgModel.content;
        }
    } else {
        NSString *userId = [NSString stringWithFormat:@"%@@%@", userFrom, userFromHost];
        if (userId.length > 0) {
            [self.headerImageView qim_setImageWithJid:userId];
            self.nameLabel.text = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userId];
            self.nameLabel.centerY = self.headerImageView.centerY;
            [self.nameLabel sizeToFit];

            NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userId];
            NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"";
            NSString *lastDp = [[department componentsSeparatedByString:@"/"] objectAtIndex:2];
            if(lastDp.length > 0) {
                self.organLabel.text = [NSString stringWithFormat:@"%@", lastDp];
                [self.organLabel sizeToFit];
                [self.organLabel sizeThatFits:CGSizeMake(self.organLabel.width, self.organLabel.height)];
                self.organLabel.frame = CGRectMake(self.nameLabel.right + 8, 0, 66, 20);
                self.organLabel.centerY = self.headerImageView.centerY;
            } else {
                self.organLabel.hidden = YES;
            }
        }
        
        NSString *toUser = noticeMsgModel.userTo;
        if (toUser.length > 0) {
            //回复的评论
            BOOL toIsAnonymous = noticeMsgModel.toIsAnonymous;
            if (toIsAnonymous) {
                //给匿名用户评论
                NSString *toAnonymousName = noticeMsgModel.toAnonymousName;
                self.contentLabel.text = [NSString stringWithFormat:@"回复 %@：%@", toAnonymousName, noticeMsgModel.content];
            } else {
                //给实名用户评论
                NSString *toUserId = [NSString stringWithFormat:@"%@@%@", noticeMsgModel.userTo, noticeMsgModel.userToHost ? noticeMsgModel.userToHost : [[QIMKit sharedInstance] getDomain]];
                NSString *userName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:toUserId];
                if ([toUserId isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
                    userName = @"我";
                }
                self.contentLabel.text = [NSString stringWithFormat:@"回复 %@：%@", userName, noticeMsgModel.content];
            }
        } else {
            //回复的帖子
            self.contentLabel.text = noticeMsgModel.content;
        }
    }
    self.contentLabel.frame = CGRectMake(self.nameLabel.left, self.headerImageView.bottom, SCREEN_WIDTH - 56 - 6 - self.headerImageView.right - 6, 30);
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:(noticeMsgModel.createTime/1000)];
    self.timeLabel.text = [timeDate qim_timeIntervalDescription];
    self.timeLabel.frame = CGRectMake(self.headerImageView.right + 6, self.contentLabel.bottom + 6, 100, 20);
    _noticeMsgModel.rowHeight = self.timeLabel.bottom + 15;
}

- (void)setContentModel:(QIMWorkMomentContentModel *)contentModel {
    _contentModel = contentModel;
    NSArray *imageList = contentModel.imgList;
    if (imageList.count > 0) {
        
        self.contentImgPreview.hidden = NO;
        self.contentPreLabel.hidden = YES;
        QIMWorkMomentPicture *imageModel = [imageList firstObject];
        NSString *imageUrl = imageModel.imageUrl;
        if (![imageUrl qim_hasPrefixHttpHeader]) {
            imageUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], imageUrl];
        } else {
            
        }
        [self.contentImgPreview qim_setImageWithURL:[NSURL URLWithString:imageUrl]];
    } else {
        self.contentImgPreview.hidden = YES;
        self.contentPreLabel.hidden = NO;
        NSString *content = contentModel.content;
        self.contentPreLabel.text = content;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
