//
//  QIMPNActionRichTextCell.m
//  qunarChatIphone
//
//  Created by admin on 15/9/6.
//
//

#import "QIMPNActionRichTextCell.h"
#import "LvtuAutoImageView.h"
#import "QIMJSONSerializer.h"

#define kSubtitleHeight 70
#define kMainTitleHeight 160
#define kCellCap        10
#define kBackgroundCap  15
#define kContentCap     12
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

@interface PNActionRichTextButton : UIButton
@property (nonatomic, strong) NSString *linkUrl;
@end
@implementation PNActionRichTextButton
- (void)dealloc{
    [self setLinkUrl:nil];
}
@end
@implementation QIMPNActionRichTextCell{
    UIView *_bgView;
    LvtuAutoImageView *_imageView;
    PNActionRichTextButton *_mainBgButton;
    UIView *_descBgView;
    UILabel *_descLabel;
    UIView *_subTitlsView;
}

+ (CGFloat)getCellHeightByContent:(NSString *)content{
    
    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
    CGFloat startY = 12 + kMainTitleHeight + 10;
    NSArray *subActionList = [dic objectForKey:@"subtitles"];
    startY += subActionList.count * kSubtitleHeight;
    startY += 5;
    return startY + kCellCap;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        [_bgView setBackgroundColor:[UIColor whiteColor]];
        [_bgView.layer setCornerRadius:5];
        [_bgView.layer setMasksToBounds:YES];
        [_bgView.layer setBorderColor:[UIColor qtalkSplitLineColor].CGColor];
        [_bgView.layer setBorderWidth:0.5];
        [self.contentView addSubview:_bgView];
        
        _mainBgButton = [[PNActionRichTextButton alloc] initWithFrame:CGRectZero];
        [_mainBgButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qtalkTableDefaultColor]] forState:UIControlStateHighlighted];
        [_mainBgButton addTarget:self action:@selector(onLinkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_mainBgButton];
        
        _imageView = [[LvtuAutoImageView alloc] initWithFrame:CGRectZero];
        [_imageView setClipsToBounds:YES];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setBackgroundColor:[UIColor grayColor]];
        [_bgView addSubview:_imageView];
        
        _descBgView = [[UIView alloc] initWithFrame:CGRectZero];
        [_descBgView setBackgroundColor:[UIColor qim_colorWithHex:0.75 alpha:1]];
        [_bgView addSubview:_descBgView];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_descLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_descLabel setTextColor:[UIColor whiteColor]];
        [_descLabel setTextAlignment:NSTextAlignmentLeft];
        [_descLabel setNumberOfLines:0];
        [_descBgView addSubview:_descLabel];
        
        _subTitlsView = [[UIView alloc] initWithFrame:CGRectZero];
        [_subTitlsView setBackgroundColor:[UIColor clearColor]];
        [_bgView addSubview:_subTitlsView];
        
    }
    return self;
}

- (void)onLinkButtonClick:(PNActionRichTextButton *)sender{
    if ([self.delegate respondsToSelector:@selector(openWebUrl:)]) {
        [self.delegate openWebUrl:sender.linkUrl];
    }
}

- (void)refreshUI{

    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.content error:nil];
    NSString *imageUrl = [dic objectForKey:@"imageurl"];
    NSString *introduce = [dic objectForKey:@"introduce"];
    NSString *linkUrl = [dic objectForKey:@"linkurl"];
    NSArray *subActionList = [dic objectForKey:@"subtitles"];
    
    [_bgView setFrame:CGRectMake(kBackgroundCap, kCellCap, kScreenWidth-kBackgroundCap*2, 0)];
    CGFloat startY = 12;
    [_imageView setImageURL:imageUrl];
    [_imageView setFrame:CGRectMake(kContentCap, startY, kScreenWidth - kBackgroundCap*2 - kContentCap*2, kMainTitleHeight)];
    CGSize introduceSize = [introduce sizeWithFont:_descLabel.font constrainedToSize:CGSizeMake(_imageView.width-20, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    [_descBgView setFrame:CGRectMake(_imageView.left, _imageView.bottom - introduceSize.height - 10, _imageView.width, introduceSize.height+10)];
    [_descLabel setText:introduce];
    [_descLabel setFrame:CGRectMake(10, 5, introduceSize.width, introduceSize.height)];
    
    [_mainBgButton setFrame:CGRectMake(0, 0, _bgView.width, _imageView.bottom+10)];
    [_mainBgButton setLinkUrl:linkUrl];
    
    [_subTitlsView removeAllSubviews];
    [_subTitlsView setFrame:CGRectMake(0, _imageView.bottom+10, _bgView.width, subActionList.count * kSubtitleHeight)];
    CGFloat subStartY = 5;
    for (NSDictionary *dic in subActionList) {
        NSString *iconUrl = [dic objectForKey:@"iconurl"];
        NSString *introduce = [dic objectForKey:@"introduce"];
        NSString *linkUrl = [dic objectForKey:@"linkurl"];
        CGFloat buttonHeight = [dic isEqual:subActionList.lastObject]?kSubtitleHeight+5:kSubtitleHeight;
        PNActionRichTextButton *subButton = [[PNActionRichTextButton alloc] initWithFrame:CGRectMake(0, subStartY-5, _subTitlsView.width, buttonHeight)];
        [subButton setLinkUrl:linkUrl];
        [subButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qtalkTableDefaultColor]] forState:UIControlStateHighlighted];
        [subButton addTarget:self action:@selector(onLinkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_subTitlsView addSubview:subButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, subStartY - 5, _bgView.width - 10, 0.5)];
        [lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [_subTitlsView addSubview:lineView];
        
        UILabel *introduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.left, subStartY, _imageView.width - kSubtitleHeight, kSubtitleHeight-10)];
        [introduceLabel setBackgroundColor:[UIColor clearColor]];
        [introduceLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [introduceLabel setNumberOfLines:2];
        [introduceLabel setFont:[UIFont systemFontOfSize:16]];
        [introduceLabel setText:introduce];
        [_subTitlsView addSubview:introduceLabel];
        
        LvtuAutoImageView *iconImageView = [[LvtuAutoImageView alloc] initWithFrame:CGRectMake(introduceLabel.right + 10, subStartY, kSubtitleHeight-10, kSubtitleHeight-10)];
        [iconImageView setClipsToBounds:YES];
        [iconImageView setBackgroundColor:[UIColor grayColor]];
        [iconImageView setImageURL:iconUrl];
        [_subTitlsView addSubview:iconImageView];
        
        subStartY += kSubtitleHeight;
    }
    
    [_bgView setHeight:_subTitlsView.bottom+5];
    
}

@end
