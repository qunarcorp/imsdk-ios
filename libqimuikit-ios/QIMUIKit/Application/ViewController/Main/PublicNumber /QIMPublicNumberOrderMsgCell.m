//
//  QIMPublicNumberOrderMsgCell.m
//  qunarChatIphone
//
//  Created by admin on 15/11/4.
//
//

#import "QIMPublicNumberOrderMsgCell.h"
#import "QIMMenuImageView.h"
#import "QIMJSONSerializer.h"

#define kTitleFont ([UIFont boldSystemFontOfSize:18])
#define kIntroduceFont ([UIFont systemFontOfSize:14])
#define kCellCap        10
#define kBackgroundCap  15
#define kContentCap     12
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width) 

static double _screen_width = 0;

@interface PNOrderMsgButton : UIButton
@property (nonatomic, strong) NSString *operationUrl;
@end
@implementation PNOrderMsgButton
- (void)dealloc{
    [self setOperationUrl:nil];
}
@end

@interface PNOrderMsgContentView : UIView
@property (nonatomic, strong) NSArray *contentList;
- (void)refreshUI;
@end
@implementation PNOrderMsgContentView{
}
+ (CGFloat)getContentViewHeight:(NSArray *)contentList{
    CGFloat height = 0;
    for (NSDictionary *subDic in contentList) {
        NSString *subTitle = [[subDic objectForKey:@"sub_title"] stringByAppendingString:@":"];
        NSString *subContent = [subDic objectForKey:@"sub_content"];
        CGSize subTitleSize = [subTitle sizeWithFont:kIntroduceFont constrainedToSize:CGSizeMake(INT32_MAX, 16) lineBreakMode:NSLineBreakByCharWrapping];
        CGSize subContentSize = [subContent sizeWithFont:kIntroduceFont constrainedToSize:CGSizeMake(_screen_width-kBackgroundCap*2-kContentCap*2-subTitleSize.width, 40) lineBreakMode:NSLineBreakByTruncatingTail];
        height += subContentSize.height;
        if ([subDic isEqual:[contentList lastObject]] == NO) {
            height += 5;
        }
    }
    return height;
}

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setContentList:(NSArray *)contentList{
    _contentList = contentList;
    [self refreshUI];
}

- (void)refreshUI{
    [self removeAllSubviews];
    CGFloat height = 0;
    for (NSDictionary *subDic in self.contentList) {
        NSString *subTitle = [[subDic objectForKey:@"sub_title"] stringByAppendingString:@":"];
        NSString *subContent = [subDic objectForKey:@"sub_content"];
        CGSize subTitleSize = [subTitle sizeWithFont:kIntroduceFont constrainedToSize:CGSizeMake(INT32_MAX, 20) lineBreakMode:NSLineBreakByCharWrapping];
        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, subTitleSize.width, subTitleSize.height)];
        [subTitleLabel setBackgroundColor:[UIColor clearColor]];
        [subTitleLabel setFont:kIntroduceFont];
        [subTitleLabel setTextColor:[UIColor qtalkTextLightColor]];
        [subTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [subTitleLabel setNumberOfLines:0];
        [subTitleLabel setText:subTitle];
        [self addSubview:subTitleLabel];
        CGSize subContentSize = [subContent sizeWithFont:kIntroduceFont constrainedToSize:CGSizeMake(_screen_width-kBackgroundCap*2-kContentCap*2-subTitleSize.width, 40) lineBreakMode:NSLineBreakByTruncatingTail];
        UILabel *subContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(subTitleLabel.right, height, subContentSize.width, subContentSize.height)];
        [subContentLabel setBackgroundColor:[UIColor clearColor]];
        [subContentLabel setFont:kIntroduceFont];
        [subContentLabel setTextColor:[UIColor qtalkTextLightColor]];
        [subContentLabel setTextAlignment:NSTextAlignmentLeft];
        [subContentLabel setNumberOfLines:0];
        [subContentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [subContentLabel setText:subContent];
        [self addSubview:subContentLabel];
        height += subContentSize.height;
        if ([subDic isEqual:[self.contentList lastObject]] == NO) {
            height += 5;
        }
    }
    [self setHeight:height];
    [self setWidth:_screen_width - 20];
}

@end

@implementation QIMPublicNumberOrderMsgCell{
    
    QIMMenuImageView *_bgView;
    PNOrderMsgButton *_linkUrlButton;
    UILabel *_orderLabel;
    UILabel *_titleLabel;
    PNOrderMsgContentView *_pnContentView;
    UIView  *_lineView;
    UILabel *_promptLabel;
    UILabel *_operationLabel;
}

+ (CGFloat)getCellHeightByContent:(NSString *)content{
    if (_screen_width == 0) {
        if ([[QIMKit sharedInstance] getIsIpad]) {
            _screen_width = [[UIScreen mainScreen] qim_rightWidth];
        } else {
            _screen_width = kScreenWidth;
        }
    }
    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
    CGFloat startY = kContentCap;
    startY += 18 + 5;
    NSString *title = [dic objectForKey:@"title"];
    NSArray *contentList = [dic objectForKey:@"content"];
    CGSize titleSize = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(_screen_width - kBackgroundCap * 2 - kContentCap * 2, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    startY += titleSize.height + 5;
    startY += [PNOrderMsgContentView getContentViewHeight:contentList];
    startY += 10;
    startY += 1;
    startY += 50;
    
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
        
        _linkUrlButton = [[PNOrderMsgButton alloc] initWithFrame:CGRectZero];
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
        
        _orderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_orderLabel setBackgroundColor:[UIColor clearColor]];
        [_orderLabel setFont:kIntroduceFont];
        [_orderLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_orderLabel setTextAlignment:NSTextAlignmentLeft];
        [_orderLabel setNumberOfLines:0];
        [_bgView addSubview:_orderLabel];
        
        _pnContentView = [[PNOrderMsgContentView alloc] init];
        [_bgView addSubview:_pnContentView];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [_bgView addSubview:_lineView];
        
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_promptLabel setBackgroundColor:[UIColor clearColor]];
        [_promptLabel setFont:[UIFont systemFontOfSize:12]];
        [_promptLabel setTextColor:[UIColor redColor]];
        [_promptLabel setTextAlignment:NSTextAlignmentLeft];
        [_promptLabel setText:@"现在去处理"];
        [_bgView addSubview:_promptLabel];
        
        _operationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_operationLabel setBackgroundColor:[UIColor clearColor]];
        [_operationLabel setFont:[UIFont systemFontOfSize:12]];
        [_operationLabel setTextColor:[UIColor blueColor]];
        [_operationLabel setTextAlignment:NSTextAlignmentRight];
        [_operationLabel setText:@"现在去处理"];
        [_bgView addSubview:_operationLabel];
        
    }
    return self;
}

- (void)onLinkButtonClick:(PNOrderMsgButton *)sender{
    if ([self.delegate respondsToSelector:@selector(openWebUrl:)]) {
        [self.delegate openWebUrl:sender.operationUrl];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QIMKit sharedInstance] updateMessageReadStateWithMsgId:self.message.messageId];
        });
        [self.message setReadTag:1];
        if (self.message.readTag == 0) {
            [_operationLabel setText:@"现在去处理"];
        } else {
            [_operationLabel setText:@"已处理"];
        }
    }
}

- (void)refreshUI{
    
    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    if (self.message.readTag == 0) {
        [_operationLabel setText:@"现在去处理"];
    } else {
        [_operationLabel setText:@"已处理"];
    }
    NSString *title = [dic objectForKey:@"title"];
    NSArray *contentList = [dic objectForKey:@"content"];
    NSString *linkUrl = [dic objectForKey:@"operation_url"];
    NSString *prompt = [dic objectForKey:@"prompt"];
    NSString *orderId = [dic objectForKey:@"order_id"];
    
    [_bgView setFrame:CGRectMake(kBackgroundCap, kCellCap, _screen_width - kBackgroundCap * 2, 0)];
    //有背景图片则不画自定义颜色背景，否则画自定义颜色背景
    [_bgView setImage:[[UIImage alloc] init]];
    
    CGFloat startY = kContentCap;
    CGSize titleSize = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(_screen_width - kBackgroundCap * 2 - kContentCap * 2, INT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    [_titleLabel setText:title];
    [_titleLabel setFrame:CGRectMake(kContentCap, startY, titleSize.width, titleSize.height)];
    startY += titleSize.height + 5;
    
    [_orderLabel setText:[NSString stringWithFormat:@"订单号:%@",orderId]];
    [_orderLabel setFrame:CGRectMake(kContentCap, startY, _screen_width -  kBackgroundCap * 2 - kContentCap * 2, 20)];
    startY += 18 + 5;
    [_pnContentView setContentList:contentList];
    [_pnContentView setLeft:0];
    [_pnContentView setTop:startY];
    startY += _pnContentView.height;
    startY += 10;
    [_lineView setFrame:CGRectMake(0, startY, _bgView.width, 1)];
    startY += 1;
    [_promptLabel setFrame:CGRectMake(10, startY+5,_bgView.width-10, 20)];
    [_promptLabel setText:prompt];
    [_operationLabel setFrame:CGRectMake(_bgView.width - 10 - 200, startY+20, 200, 20)];
    startY += 50;
    
    [_bgView setHeight:startY];
    [_linkUrlButton setOperationUrl:linkUrl];
    [_linkUrlButton setFrame:CGRectMake(0, 0, _bgView.width, _bgView.height)];
    
}

@end
