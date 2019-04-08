//
//  QIMPushProductCell.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/26.
//
//

#import "QIMPushProductCell.h"
#import "UIImageView+WebCache.h"

@interface QIMPushProductCell ()
{
    UIImageView         * _productImageView;
    UILabel             * _typeLabel;
    UILabel             * _titleLabel;
    UILabel             * _tagLabel;
    UILabel             * _shopNameLabel;
    UILabel             * _priceLabel;
    UILabel             * _marketPriceLabel;
    
    UIView              * _typeBgView;
    UIView              * _bottomBgView;
    
    UIButton            * _sendBtn;
    
    UIView              * _sepLine;
    
    NSDictionary        * _infoDic;
}
@end

@implementation QIMPushProductCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _productImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _productImageView.contentMode = UIViewContentModeScaleAspectFill;
        _productImageView.clipsToBounds = YES;
        [self.contentView addSubview:_productImageView];
        
        _typeBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _typeBgView.backgroundColor = [UIColor qim_colorWithHex:0x00000000 alpha:0.3];
        _typeBgView.layer.cornerRadius = 10;
        [_productImageView addSubview:_typeBgView];
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.textColor = [UIColor whiteColor];
        _typeLabel.font = [UIFont systemFontOfSize:16];
        [_productImageView addSubview:_typeLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:21];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
        
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomBgView.backgroundColor = [UIColor qim_colorWithHex:0x000000 alpha:0.5];
        [_productImageView addSubview:_bottomBgView];
        
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagLabel.backgroundColor = [UIColor clearColor];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.font = [UIFont systemFontOfSize:16];
        [_productImageView addSubview:_tagLabel];
        
        
        _shopNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopNameLabel.backgroundColor = [UIColor clearColor];
        _shopNameLabel.textColor = [UIColor whiteColor];
        _shopNameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_shopNameLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont systemFontOfSize:17];
        _priceLabel.textColor = [UIColor redColor];
        [self.contentView addSubview:_priceLabel];
        
        _marketPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _marketPriceLabel.font = [UIFont systemFontOfSize:14];
        _marketPriceLabel.textColor = [UIColor qtalkTextLightColor];
        [self.contentView addSubview:_marketPriceLabel];
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.backgroundColor = [UIColor qtalkIconSelectColor];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(sendBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_sendBtn];
        
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLine.backgroundColor = [UIColor qtalkSplitLineColor];
        [self.contentView addSubview:_sepLine];
    }
    return self;
}

- (void)setCellInfo:(NSDictionary *)infoDic{
    _infoDic = [NSDictionary dictionaryWithDictionary:infoDic];
}

+ (CGFloat)getCellHeight{
    return 350;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //set values
    [_productImageView qim_setImageWithURL:[NSURL URLWithString:_infoDic[@"imageUrl"]] placeholderImage:nil];
    _typeLabel.text = _infoDic[@"type"];
    _titleLabel.text = _infoDic[@"title"];
    if ([_infoDic[@"tag"] isKindOfClass:[NSNull class]]) {
        _tagLabel.text = @"";
    }else{
        _tagLabel.text = _infoDic[@"tag"];
    }
    _priceLabel.text = _infoDic[@"price"];
    _marketPriceLabel.text = _infoDic[@"marketPrice"];
    _shopNameLabel.text = _infoDic[@"supplier"][@"shopName"];
    
    //rect frame
    CGSize size = [_typeLabel.text qim_sizeWithFontCompatible:_typeLabel.font];
    
    _productImageView.frame = CGRectMake(0, 0, self.contentView.width, 200);
    
    _typeBgView.frame = CGRectMake(-10, -10, size.width + 20, 30 + 10);
    _typeLabel.frame = CGRectMake(5, 0, size.width, 30);
    
    _titleLabel.frame = CGRectMake(15, _productImageView.bottom, self.contentView.width , 45);
    
    _bottomBgView.frame = CGRectMake(0, _productImageView.height - 30, _productImageView.width, 30);
    
    size = [_tagLabel.text qim_sizeWithFontCompatible:_tagLabel.font];
    _tagLabel.frame = CGRectMake(0, _productImageView.height - 30, size.width, 30);
    
    size = [_priceLabel.text qim_sizeWithFontCompatible:_priceLabel.font];
    
    _priceLabel.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, size.width, 20);
    
    size = [_marketPriceLabel.text qim_sizeWithFontCompatible:_marketPriceLabel.font];
    _marketPriceLabel.frame = CGRectMake(_priceLabel.right + 10, _titleLabel.bottom + 10, size.width, 15);
    
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:_marketPriceLabel.text];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, _marketPriceLabel.text.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor qim_colorWithHex:0x999999 alpha:1] range:NSMakeRange(0, _marketPriceLabel.text.length)];
    [_marketPriceLabel setAttributedText:attri];
    
    size = [_shopNameLabel.text qim_sizeWithFontCompatible:_shopNameLabel.font];
    _shopNameLabel.frame =  CGRectMake(_productImageView.width - size.width - 10, _productImageView.height - 30, size.width, 30);
    
    _sendBtn.frame = CGRectMake(0, self.contentView.height - 51, self.contentView.width, 50);
    
    _sepLine.frame = CGRectMake(0, self.contentView.height - 1, self.contentView.width, 0.5);
}


- (void)sendBtnHandle:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendBtnClickedForCell:)]) {
        [self.delegate sendBtnClickedForCell:self];
    }
}

@end
