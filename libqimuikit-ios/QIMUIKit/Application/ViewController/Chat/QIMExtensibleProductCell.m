//
//  QIMExtensibleProductCell.m
//  qunarChatIphone
//
//  Created by chenjie on 16/7/13.
//
//

#define kTitleIconWidth     25
#define kProductImageWidth  85
#define kTitleFontSize      15
#define kTitleColor         0x47C1D0
#define kContentFontSize    14
#define kContentColor       0x666666
#define kSeplineColor       0xCCCCCC
#define kContentLineHeight  23

#import "QIMMsgBaloonBaseCell.h"
#import "QIMJSONSerializer.h"
#import "QIMExtensibleProductCell.h"
#import "UIImageView+WebCache.h"
#import "QIMWebView.h"

@interface QCKeyValueView : UIView {
    UILabel     * _keyLabel;
    UILabel     * _valueLabel;
}

@end

@implementation QCKeyValueView

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value color:(UIColor *)color {
    if (self = [self init]) {
        _keyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _keyLabel.font = [UIFont systemFontOfSize:kContentFontSize];
        _keyLabel.textColor = [UIColor qim_colorWithHex:kContentColor alpha:1.0];
        _keyLabel.backgroundColor = [UIColor clearColor];
        _keyLabel.text = key;
        [self addSubview:_keyLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.font = [UIFont systemFontOfSize:kContentFontSize];
        _valueLabel.textColor = color?color:[UIColor qim_colorWithHex:kContentColor alpha:1.0];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.text = value;
        [self addSubview:_valueLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    _keyLabel.frame = CGRectMake(0, 0, 70, self.height);
    _valueLabel.frame = CGRectMake(_keyLabel.right, 0, self.width - _keyLabel.right, self.height);
}

@end

@interface QIMExtensibleProductCell () {
    
    UIView                  * _bgView;
    
    UIImageView             * _titleIcon;
    UILabel                 * _titleLabel;
    UIView                  * _sepLine;
    UIImageView             * _productImageView;
    NSMutableArray          * _contentViews;
    
    NSDictionary            * _productInfoDic;
}

@end

@implementation QIMExtensibleProductCell

+ (float)getCellHeightForProductInfo:(NSString *)infoStr {

    NSDictionary * proDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
    float height = 0;
    height = kTitleIconWidth + MAX(kProductImageWidth, kContentLineHeight * [proDic[@"descs"] count]);
    height += 60;
    return height;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundView = nil;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.borderColor = [UIColor qim_colorWithHex:kSeplineColor alpha:1.0].CGColor;
        _bgView.layer.borderWidth = 1.0;
        _bgView.layer.cornerRadius = 5.0;
        [self.contentView addSubview:_bgView];
        
        _titleIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_bgView addSubview:_titleIcon];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor qim_colorWithHex:kTitleColor alpha:1.0];
        [_bgView addSubview:_titleLabel];
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLine.backgroundColor = [UIColor qim_colorWithHex:kSeplineColor alpha:1.0];
        [_bgView addSubview:_sepLine];
        
        _productImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_bgView addSubview:_productImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
        [_bgView addGestureRecognizer:tap];
    }
    return self;
}

- (void)onClick{
    NSString * touchUrl = _productInfoDic[@"detailurl"];
    if (touchUrl.length > 0) {
        QIMWebView *webView = [[QIMWebView alloc] init];
        [webView setUrl:touchUrl];
        [self.owner.navigationController pushViewController:webView animated:YES];
    }
}

- (void)setProDcutInfoDic:(NSDictionary *)infoDic {
//    infoDic = @{@"titleimg":@"http://c.hiphotos.baidu.com/image/h%3D200/sign=43c5dc24ce5c10383b7ec9c28210931c/e1fe9925bc315c609e3db7d185b1cb1349547760.jpg",@"titletxt":@"可扩展的产品展示cell，四的计划是给对方赛旧的反应会是当否是打发啥的认同感",@"productimg":@"http://c.hiphotos.baidu.com/image/h%3D200/sign=43c5dc24ce5c10383b7ec9c28210931c/e1fe9925bc315c609e3db7d185b1cb1349547760.jpg",@"detailurl":@"http://www.baidu.com",@"descs":@[@{@"k":@"是打发按",@"v":@"就是个得分是东方红狗沙发阿萨德的撒",@"c":@"666666"},@{@"k":@"是打发按",@"v":@"就是个得分是东方红狗沙发阿萨德的撒",@"c":@"666666"},@{@"k":@"是打发按",@"v":@"就是个得分是东方红狗沙发阿萨德的撒",@"c":@"666666"},@{@"k":@"是打发按",@"v":@"就是个得分是东方红狗沙发阿萨德的撒阿萨德的撒啥的各环节",@"c":@"666666"}]};
    _productInfoDic = infoDic;
    
    [_titleIcon qim_setImageWithURL:[NSURL URLWithString:infoDic[@"titleimg"]] placeholderImage:[UIImage imageNamed:@"vacation"]];
    _titleLabel.text = infoDic[@"titletxt"];
    
    NSString * imageStr = infoDic[@"productimg"];
    if (imageStr.length) {
        [_productImageView qim_setImageWithURL:[NSURL URLWithString:imageStr]];
        [_bgView addSubview:_productImageView];
    }else{
        _productImageView.image = nil;
        [_productImageView removeFromSuperview];
    }
    
    for (UIView * view in _contentViews) {
        [view removeFromSuperview];
    }
    
    if (_contentViews) {
        [_contentViews removeAllObjects];
    }else {
        _contentViews = [NSMutableArray arrayWithCapacity:1];
    }
    
    NSArray * descs = infoDic[@"descs"];
    for (NSDictionary * itemDic in descs) {
        UIView * view =  [[QCKeyValueView alloc] initWithKey:itemDic[@"k"] value:itemDic[@"v"] color:[UIColor qim_colorWithHex:[itemDic[@"c"] integerValue] alpha:1.0]];
        [_bgView addSubview:view];
        [_contentViews addObject:view];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _bgView.frame = CGRectMake(15, 15, self.contentView.width - 30, self.contentView.height - 30);
    
    _titleIcon.frame = CGRectMake(10, 10, kTitleIconWidth, kTitleIconWidth);
    _titleLabel.frame = CGRectMake(_titleIcon.right + 5, _titleIcon.top, _bgView.width - _titleIcon.right - 15, kTitleIconWidth);
    
    _sepLine.frame = CGRectMake(_titleIcon.left, _titleIcon.bottom + 5, _titleLabel.right - _titleIcon.left, 0.5);
    
    BOOL hasProductImage = _productImageView.superview;
    if (hasProductImage) {
        _productImageView.frame = CGRectMake(_titleIcon.left, _sepLine.bottom + 10, kProductImageWidth, kProductImageWidth);
    }else {
        _productImageView.frame = CGRectMake(_titleIcon.left, _sepLine.bottom + 10, 0, 0);
    }
    
    float padding = _productImageView.top - 3;
    for (UIView * view in _contentViews) {
        [view setFrame:CGRectMake(_productImageView.right + 10, padding, _bgView.width - _productImageView.right - 15, kContentLineHeight)];
        padding += view.height;
    }

}

- (void)refreshUI {
    
}

@end
