//
//  QIMPublicNumberNoticeCell.m
//  qunarChatIphone
//
//  Created by admin on 15/11/4.
//
//

#import "QIMPublicNumberNoticeCell.h"
#import "QIMJSONSerializer.h"
#import "QIMMenuImageView.h"

#define kTitleFont ([UIFont boldSystemFontOfSize:18])
#define kIntroduceFont ([UIFont systemFontOfSize:14])
#define kCellCap        10
#define kBackgroundCap  15
#define kContentCap     12
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kImageHeight 180

static double _screen_width = 0;

@interface PNNoticeButton : UIButton
@property (nonatomic, strong) NSString *linkUrl;
@end

@implementation PNNoticeButton
- (void)dealloc{
    [self setLinkUrl:nil];
}
@end

@interface QIMPublicNumberNoticeCell ()

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) QIMMenuImageView *bgView;
@property (nonatomic, strong) PNNoticeButton *linkUrlButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *introduceLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *readedAllLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation QIMPublicNumberNoticeCell

- (CGFloat)cellWidth {
    if ([[QIMKit sharedInstance] getIsIpad]) {
        _cellWidth = [[UIScreen mainScreen] qim_rightWidth];
    } else {
        _cellWidth = kScreenWidth;
    }
    _screen_width = _cellWidth;
    return _cellWidth;
}

+ (CGFloat)getCellHeightByContent:(NSString *)content{
    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
    NSString *title = [dic objectForKey:@"title"];
//    NSString *dateTimeStr = [dic objectForKey:@"date"];
//    NSString *imageUrl = [dic objectForKey:@"imageurl"];
    NSString *introduce = [dic objectForKey:@"content"];
//    NSString *linkUrl = [dic objectForKey:@"linkurl"];
    
    CGFloat startY = kContentCap;
    CGSize titleSize = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(_screen_width - kBackgroundCap * 2 - kContentCap * 2, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    startY += titleSize.height + 5; 
//    startY += 10;
    if ([introduce isKindOfClass:[NSString class]] == NO) {
        introduce = @"UnKnow";
    }
    CGSize introduceSize = [introduce sizeWithFont:kIntroduceFont constrainedToSize:CGSizeMake(_screen_width - kBackgroundCap * 2 - kContentCap * 2, 40) lineBreakMode:NSLineBreakByCharWrapping];
    startY += introduceSize.height;
    startY += 10;
    startY += 1;
    startY += 30;
    
    return startY + kCellCap;
}

- (QIMMenuImageView *)bgView {
    if (!_bgView) {
        _bgView = [[QIMMenuImageView alloc] initWithFrame:CGRectMake(kBackgroundCap, kCellCap, self.cellWidth - kBackgroundCap * 2, 0)];
        [_bgView setUserInteractionEnabled:YES];
        [_bgView setBackgroundColor:[UIColor whiteColor]];
        [_bgView.layer setCornerRadius:5];
        [_bgView.layer setMasksToBounds:YES];
        [_bgView.layer setBorderColor:[UIColor qtalkSplitLineColor].CGColor];
        [_bgView.layer setBorderWidth:0.5];
        //有背景图片则不画自定义颜色背景，否则画自定义颜色背景
        [_bgView setImage:[[UIImage alloc] init]];
    }
    return _bgView;
}

- (PNNoticeButton *)linkUrlButton {
    if (!_linkUrlButton) {
        _linkUrlButton = [[PNNoticeButton alloc] initWithFrame:CGRectZero];
        [_linkUrlButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qtalkTableDefaultColor]] forState:UIControlStateHighlighted];
        [_linkUrlButton addTarget:self action:@selector(onLinkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _linkUrlButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:kTitleFont];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setNumberOfLines:0];
    }
    return _titleLabel;
}

- (UILabel *)introduceLabel {
    if (!_introduceLabel) {
        _introduceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_introduceLabel setBackgroundColor:[UIColor clearColor]];
        [_introduceLabel setFont:kIntroduceFont];
        [_introduceLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_introduceLabel setTextAlignment:NSTextAlignmentLeft];
        [_introduceLabel setNumberOfLines:0];
    }
    return _introduceLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
    }
    return _lineView;
}

- (UILabel *)readedAllLabel {
    if (!_readedAllLabel) {
        _readedAllLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_readedAllLabel setBackgroundColor:[UIColor clearColor]];
        [_readedAllLabel setFont:[UIFont systemFontOfSize:12]];
        [_readedAllLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_readedAllLabel setTextAlignment:NSTextAlignmentLeft];
        [_readedAllLabel setText:@"查看全文"];
    }
    return _readedAllLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
    }
    return _arrowImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView addSubview:self.bgView];
        
        [self.bgView addSubview:self.linkUrlButton];
        [self.bgView addSubview:self.titleLabel];
        [self.bgView addSubview:self.introduceLabel];
        [self.bgView addSubview:self.lineView];
        [self.bgView addSubview:self.readedAllLabel];
        [self.bgView addSubview:self.arrowImageView];
        
    }
    return self;
}

- (void)onLinkButtonClick:(PNNoticeButton *)sender{
    if ([self.delegate respondsToSelector:@selector(openWebUrl:)]) {
        [self.delegate openWebUrl:sender.linkUrl];
    }
}

- (void)refreshUI{
    
    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.content error:nil];
    NSString *title = [dic objectForKey:@"title"];
    NSString *introduce = [dic objectForKey:@"content"];
    NSString *linkUrl = [dic objectForKey:@"linkurl"];
    
    CGFloat startY = kContentCap;
    CGSize titleSize = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(self.cellWidth - kBackgroundCap * 2 - kContentCap * 2, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    [self.titleLabel setFrame:CGRectMake(kContentCap, 10, titleSize.width, titleSize.height)];
    [self.titleLabel setText:title];
    startY += titleSize.height + 5;
//    startY += 10;
    if ([introduce isKindOfClass:[NSString class]] == NO) {
        introduce = @"UnKnow";
    }
    CGSize introduceSize = [introduce sizeWithFont:kIntroduceFont constrainedToSize:CGSizeMake(self.cellWidth - kBackgroundCap * 2 - kContentCap * 2, 40) lineBreakMode:NSLineBreakByCharWrapping];
    [self.introduceLabel setText:introduce];
    [self.introduceLabel setFrame:CGRectMake(kContentCap, startY, introduceSize.width, introduceSize.height)];
    startY += introduceSize.height;
    startY += 10;
    [self.lineView setFrame:CGRectMake(0, startY, self.bgView.width, 1)];
    startY += 1;
    [self.readedAllLabel setFrame:CGRectMake(10, startY+5, 200, 20)];
    [self.arrowImageView setFrame:CGRectMake(self.bgView.width-18, startY + 8.5, 8, 13)];
    startY += 30;
    
    [self.bgView setHeight:startY];
    [self.linkUrlButton setLinkUrl:linkUrl];
    [self.linkUrlButton setFrame:CGRectMake(0, 0, self.bgView.width, self.bgView.height)];
}

@end
