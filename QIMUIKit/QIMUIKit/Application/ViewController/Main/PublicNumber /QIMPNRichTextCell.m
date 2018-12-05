//
//  QIMPNRichTextCell.m
//  qunarChatIphone
//
//  Created by admin on 15/9/6.
//
//

#import "QIMPNRichTextCell.h"
#import "LvtuAutoImageView.h"
#import "QIMMenuImageView.h"
#import "QIMWebView.h"
#import "QIMJSONSerializer.h"

#define kTitleFont ([UIFont boldSystemFontOfSize:18])
#define kIntroduceFont ([UIFont systemFontOfSize:14])
#define kCellCap        10
#define kBackgroundCap  15
#define kContentCap     12
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kImageHeight 180

@interface PNRichTextButton : UIButton
@property (nonatomic, strong) NSString *linkUrl;
@end

@implementation PNRichTextButton
-(void)dealloc{
    [self setLinkUrl:nil];
}

@end

@implementation QIMPNRichTextCell{
    QIMMenuImageView *_bgView;
    PNRichTextButton *_linkUrlButton;
    UILabel *_titleLabel;
    UILabel *_dateLabel;
    LvtuAutoImageView *_imageView;
    UILabel *_introduceLabel;
    UIView *_lineView;
    UILabel *_readedAllLabel;
    UIImageView *_arrowImageView;
}

+ (CGFloat)getCellHeightByContent:(NSString *)content{
    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
    NSString *title = [dic objectForKey:@"title"];
//    NSString *dateTimeStr = [dic objectForKey:@"date"];
//    NSString *imageUrl = [dic objectForKey:@"imageurl"];
    NSString *introduce = [dic objectForKey:@"introduce"];
//    NSString *linkUrl = [dic objectForKey:@"linkurl"];
    
    CGFloat startY = kContentCap;
    CGSize titleSize = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(kScreenWidth - kBackgroundCap * 2 - kContentCap * 2, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    startY += titleSize.height + 5;
    startY += 12; // 时间
    startY += 8;
    startY += kImageHeight;
    startY += 10;
    CGSize introduceSize = [introduce sizeWithFont:kIntroduceFont constrainedToSize:CGSizeMake(kScreenWidth - kBackgroundCap * 2 - kContentCap * 2, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    startY += introduceSize.height;
    startY += 10;
    startY += 1;
    startY += 30;
    
    return startY + kCellCap;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _bgView = [[QIMMenuImageView alloc] initWithFrame:CGRectZero];
        [_bgView setUserInteractionEnabled:YES];
        [_bgView setBackgroundColor:[UIColor whiteColor]];
        [_bgView.layer setCornerRadius:5];
        [_bgView.layer setMasksToBounds:YES];
        [_bgView.layer setBorderColor:[UIColor qtalkSplitLineColor].CGColor];
        [_bgView.layer setBorderWidth:0.5];
        [self.contentView addSubview:_bgView];
        
        _linkUrlButton = [[PNRichTextButton alloc] initWithFrame:CGRectZero];
        [_linkUrlButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qtalkTableDefaultColor]] forState:UIControlStateHighlighted];
        [_linkUrlButton addTarget:self action:@selector(onLinkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_linkUrlButton];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:kTitleFont];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setNumberOfLines:0];
        [_bgView addSubview:_titleLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_dateLabel setBackgroundColor:[UIColor clearColor]];
        [_dateLabel setFont:kIntroduceFont];
        [_dateLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_dateLabel setTextAlignment:NSTextAlignmentLeft];
        [_bgView addSubview:_dateLabel];
        
        _imageView = [[LvtuAutoImageView alloc] initWithFrame:CGRectZero];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setBackgroundColor:[UIColor grayColor]];
        [_imageView setClipsToBounds:YES];
        [_bgView addSubview:_imageView];
        
        _introduceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_introduceLabel setBackgroundColor:[UIColor clearColor]];
        [_introduceLabel setFont:kIntroduceFont];
        [_introduceLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_introduceLabel setTextAlignment:NSTextAlignmentLeft];
        [_introduceLabel setNumberOfLines:0];
        [_bgView addSubview:_introduceLabel];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [_bgView addSubview:_lineView];
        
        _readedAllLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_readedAllLabel setBackgroundColor:[UIColor clearColor]];
        [_readedAllLabel setFont:[UIFont systemFontOfSize:12]];
        [_readedAllLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_readedAllLabel setTextAlignment:NSTextAlignmentLeft];
        [_readedAllLabel setText:@"阅读全文"];
        [_bgView addSubview:_readedAllLabel];
        
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
        [_bgView addSubview:_arrowImageView];
        
    }
    return self;
}

- (void)onLinkButtonClick:(PNRichTextButton *)sender{
    if ([self.delegate respondsToSelector:@selector(openWebUrl:)]) {
        [self.delegate openWebUrl:sender.linkUrl];
    }
}

- (void)refreshUI{
    
    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.content error:nil];
    NSString *title = [dic objectForKey:@"title"];
    NSString *dateTimeStr = [dic objectForKey:@"date"];
    NSString *imageUrl = [dic objectForKey:@"imageurl"];
    NSString *introduce = [dic objectForKey:@"introduce"];
    NSString *linkUrl = [dic objectForKey:@"linkurl"];
    
    [_bgView setFrame:CGRectMake(kBackgroundCap, kCellCap, kScreenWidth - kBackgroundCap * 2, 0)];
    //有背景图片则不画自定义颜色背景，否则画自定义颜色背景
    [_bgView setImage:[[UIImage alloc] init]];
    CGFloat startY = kContentCap;
    CGSize titleSize = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(kScreenWidth - kBackgroundCap * 2 - kContentCap * 2, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    [_titleLabel setText:title];
    [_titleLabel setFrame:CGRectMake(kContentCap, 10, titleSize.width, titleSize.height)];
    startY += titleSize.height + 5;
    [_dateLabel setText:dateTimeStr];
    [_dateLabel setFrame:CGRectMake(kContentCap, startY, 120, 12)];
    startY += 12; // 时间
    startY += 8; 
    [_imageView setImageURL:imageUrl];
    [_imageView setFrame:CGRectMake(kContentCap, startY, _bgView.width-kContentCap*2, kImageHeight)];
    startY += kImageHeight;
    startY += 10;
    CGSize introduceSize = [introduce sizeWithFont:kIntroduceFont constrainedToSize:CGSizeMake(kScreenWidth - kBackgroundCap * 2 - kContentCap * 2, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    [_introduceLabel setText:introduce];
    [_introduceLabel setFrame:CGRectMake(kContentCap, startY, introduceSize.width, introduceSize.height)];
    startY += introduceSize.height;
    startY += 10;
    [_lineView setFrame:CGRectMake(0, startY, _bgView.width, 1)];
    startY += 1;
    [_readedAllLabel setFrame:CGRectMake(10, startY+5, 200, 20)];
    [_arrowImageView setFrame:CGRectMake(_imageView.right-8, startY + 8.5, 8, 13)];
    startY += 30;
    
    [_bgView setHeight:startY];
    [_linkUrlButton setLinkUrl:linkUrl];
    [_linkUrlButton setFrame:CGRectMake(0, 0, _bgView.width, _bgView.height)];
    
}

@end
