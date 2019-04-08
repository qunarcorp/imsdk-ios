//
//  QIMProductInfoCell.m
//  Vacation
//
//  Created by admin on 16/1/19.
//  Copyright © 2016年 Qunar.com. All rights reserved.
//
#import "QIMMsgBaloonBaseCell.h"
#import "QIMProductInfoCell.h"
#import "UIImageView+WebCache.h"
#import "QIMWebView.h"
//#import "NSAttributedString+Attributes.h"
#import "QIMIconInfo.h"

#define QIMProductInfoWidth 245
#define QIMProductInfoHeight 150
#define QIMProductInfoImageWidth 40

@implementation QIMProductInfoCell {
    
    UIImageView *_headerImageView;
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
    UILabel *_priceStrLabel;
    UIImageView *_platFormIconView;
    UILabel *_platFormLabel;
    UILabel *_lineView;
}

+ (CGFloat)getCellHeight{
    return QIMProductInfoHeight + 25;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frameWidth = [UIScreen mainScreen].bounds.size.width;

        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_headerImageView setClipsToBounds:YES];
        [_headerImageView.layer setCornerRadius:2.5];
        [self.backView addSubview:_headerImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setText:@"春节专享北京奢华五星酒店套餐！多套餐任选！开源"];
        [self.backView addSubview:_titleLabel];
        
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_subTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_subTitleLabel setFont:[UIFont systemFontOfSize:13]];
        [_subTitleLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_subTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [_subTitleLabel setText:@"春节专享北京奢华五星酒店套餐！多套餐任选！开源"];
        [self.backView addSubview:_subTitleLabel];
        
        _priceStrLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_priceStrLabel setBackgroundColor:[UIColor clearColor]];
        [_priceStrLabel setFont:[UIFont systemFontOfSize:13]];
        [_priceStrLabel setTextColor:[UIColor orangeColor]];
        [_priceStrLabel setTextAlignment:NSTextAlignmentLeft];
        [_priceStrLabel setNumberOfLines:0];
        [_priceStrLabel setText:@"¥00.00"];
        [self.backView addSubview:_priceStrLabel];
    
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor qim_colorWithHex:0x9E9E9E];
        _lineView.contentMode   = UIViewContentModeBottom;
        _lineView.clipsToBounds = YES;
        [self.backView addSubview:_lineView];
        
        _platFormIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _platFormIconView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e189" size:15 color:[UIColor qunarBlueColor]]];
        [self.backView addSubview:_platFormIconView];
        
        _platFormLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _platFormLabel.text = @"去哪儿网App";
        _platFormLabel.font = [UIFont systemFontOfSize:9];
        _platFormLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [self.backView addSubview:_platFormLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
        [self.backView addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)onClick{
    if (self.touchUrl.length > 0) {
        [QIMFastEntrance openWebViewForUrl:self.touchUrl showNavBar:YES];
    }
}

- (void)refreshUI{

    [self.backView setMessage:self.message];
    [self setBackViewWithWidth:QIMProductInfoWidth WihtHeight:QIMProductInfoHeight];
    [_headerImageView qim_setImageWithURL:[NSURL URLWithString:self.headerUrl] placeholderImage:[UIImage imageNamed:@"v_aroundTravel_default"]];
    [_titleLabel setText:self.title];
    [_subTitleLabel setText:self.subTitle];
    
    NSMutableAttributedString *priceStr = [[NSMutableAttributedString alloc] init];
    [priceStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"¥" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor orangeColor]}]];
    NSString *price = [NSString stringWithFormat:@"%d",self.priceStr.intValue];
    [priceStr appendAttributedString:[[NSAttributedString alloc] initWithString:price attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSForegroundColorAttributeName:[UIColor orangeColor]}]];
    [priceStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}]];
    if (self.priceStr.length > price.length) { 
        [priceStr appendAttributedString:[[NSAttributedString alloc] initWithString:[self.priceStr substringFromIndex:price.length] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor grayColor]}]];
    }
    
    [_priceStrLabel setAttributedText:priceStr];
    CGFloat leftOffset = (self.message.messageDirection == MessageDirection_Sent) ? 15 : 20;
    _titleLabel.frame = CGRectMake(leftOffset, 10, self.backView.width - leftOffset - 10, 60);
    _headerImageView.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, QIMProductInfoImageWidth, QIMProductInfoImageWidth);

    _subTitleLabel.frame = CGRectMake(_headerImageView.right + 10, _titleLabel.bottom + 5, self.backView.width - _headerImageView.right - 20 , 20);
    _priceStrLabel.frame = CGRectMake(_headerImageView.right + 10, _subTitleLabel.bottom + 5, self.backView.width - _headerImageView.right - 20, 20);
    _lineView.frame =  (self.message.messageDirection == MessageDirection_Sent) ? CGRectMake(leftOffset - 15, self.backView.height - 18, QIMProductInfoWidth - leftOffset + 5.0f, 0.5f) : CGRectMake(leftOffset - 10, self.backView.height - 18, QIMProductInfoWidth - leftOffset + 10.0f, 0.5f);
    _platFormIconView.frame = CGRectMake(_lineView.left + 10, _lineView.bottom + 1.5f, 15, 15);
    _platFormLabel.frame = CGRectMake(_platFormIconView.right + 5, _lineView.bottom, QIMProductInfoWidth, 18);

    [self.backView setBubbleBgColor:[UIColor whiteColor]];
    [super refreshUI];
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end
