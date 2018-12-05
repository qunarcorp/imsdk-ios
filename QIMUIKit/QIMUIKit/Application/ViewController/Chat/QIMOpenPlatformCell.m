//
//  QIMOpenPlatformCell.m
//  qunarChatIphone
//
//  Created by admin on 16/4/18.
//
//

#import "QIMOpenPlatformCell.h"

#define kBackCap            10
#define kTagHeight              30
#define kTagCap                 10
#define kBottomButtonHeight     35

@implementation QIMOpenPlatformCell{
    
    UIView *_backView;
    
    UILabel *_tagLabel;
    UILabel *_timeLabel;
    UILabel *_contentLabel;
    UIButton *_bottomButton;
    UIView *_lineView;
}

+ (CGFloat)getCellHeightWithMessage:(Message *)message{
    NSDictionary *msgDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
    NSString *content = [msgDic objectForKey:@"detail"];
    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    return kBackCap + kTagHeight + kTagCap + contentSize.height + kTagCap + kBottomButtonHeight + 5;
}

- (void)updateBottomButtonState:(NSNotification *)notify{
    NSDictionary *msgDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    NSString *dealID = [msgDic objectForKey:@"id"];
    if ([dealID isEqualToString:notify.object]) {
        [self updateBottomButtonWithDealId:dealID];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBottomButtonState:) name:@"kUpdateOpenPlatormMsg" object:nil];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, 0)];
        [_backView setBackgroundColor:[UIColor whiteColor]];
        [_backView.layer setCornerRadius:5];
        [_backView setClipsToBounds:YES];
        [self.contentView addSubview:_backView];
        
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTagCap, kTagCap, 200, kTagHeight - kTagCap)];
        [_tagLabel setBackgroundColor:[UIColor clearColor]];
        [_tagLabel setFont:[UIFont systemFontOfSize:16]];
        [_tagLabel setTextColor:[UIColor qim_colorWithHex:0x41bbc4 alpha:1]];
        [_tagLabel setText:@"#标签#"];
        [_backView addSubview:_tagLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_backView.width - 90, 10, 80, 20)];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setFont:[UIFont systemFontOfSize:12]];
        [_timeLabel setTextColor:[UIColor qim_colorWithHex:0x999999 alpha:1]];
        [_timeLabel setText:@"0分钟前"];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        [_backView addSubview:_timeLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_tagLabel.left, _tagLabel.bottom + 10, _backView.width - _tagLabel.left * 2, 0)];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setFont:[UIFont systemFontOfSize:16]];
        [_contentLabel setTextColor:[UIColor qim_colorWithHex:0x333333 alpha:1]];
        [_contentLabel setText:@"我想去看看。"];
        [_contentLabel setNumberOfLines:0];
        [_backView addSubview:_contentLabel];
        
        _bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _contentLabel.bottom + 10, _backView.width, kBottomButtonHeight)];
        [_bottomButton setBackgroundColor:[UIColor clearColor]];
        [_bottomButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qim_colorWithHex:0x41bbc4 alpha:1]] forState:UIControlStateNormal];
        [_bottomButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_bottomButton setTitle:@"立即答复" forState:UIControlStateNormal];
        [_bottomButton addTarget:self action:@selector(onBottomClick:) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:_bottomButton];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _backView.width, 0.5)];
        [_lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [_backView addSubview:_lineView];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onBottomClick:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(QIMOpenPlatformCellClick:)]) {
        [self.delegate QIMOpenPlatformCellClick:self];
    }
}

- (void)updateBottomButtonWithDealId:(NSString *)dealId{
    QDDealState state = [[QIMKit sharedInstance] getDealIdState:dealId];
    switch (state) {
        case QDDealState_None:
        {
            [_bottomButton setTitle:@"立即答复" forState:UIControlStateNormal];
            [_bottomButton addTarget:self action:@selector(onBottomClick:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_bottomButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qim_colorWithHex:0x41bbc4 alpha:1]] forState:UIControlStateNormal];
        }
            break;
        case QDDealState_True:
        {
            [_bottomButton setTitle:@"已答复" forState:UIControlStateNormal];
            [_bottomButton removeTarget:self action:@selector(onBottomClick:)forControlEvents:UIControlEventTouchUpInside];
            [_bottomButton setTitleColor:[UIColor qim_colorWithHex:0x666666 alpha:1] forState:UIControlStateNormal];
            [_bottomButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qim_colorWithHex:0xffffff alpha:1]] forState:UIControlStateNormal];
        }
            break;
        case QDDealState_Faild:
        {
            [_bottomButton setTitle:@"已被抢答" forState:UIControlStateNormal];
            [_bottomButton removeTarget:self action:@selector(onBottomClick:)forControlEvents:UIControlEventTouchUpInside];
            [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_bottomButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qim_colorWithHex:0x94e0e9 alpha:1]] forState:UIControlStateNormal];
        }
            break;
        case QDDealState_TimeOut:
        {
            [_bottomButton setTitle:@"订单已过期" forState:UIControlStateNormal];
            [_bottomButton removeTarget:self action:@selector(onBottomClick:)forControlEvents:UIControlEventTouchUpInside];
            [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_bottomButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor qim_colorWithHex:0x94e0e9 alpha:1]] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)refreshUI{
    
//    "source": "东京问题",
//    "headurl": "http://qt.qunar.com/file/v2...",
//    "detail": "马桶盖子多少钱",
//    "dealid": "deal_xxx_yyy",
//    "dealurl": "http://qchat.qunar.com/deal.php?dealid=deal_xxx_yyy",
//    "timeout": "20"
    
    NSDictionary *msgDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    NSString *tagStr = [msgDic objectForKey:@"source"];
    NSString *msgStr = [msgDic objectForKey:@"detail"];
    NSString *dealId = [msgDic objectForKey:@"dealid"];
    [self updateBottomButtonWithDealId:dealId];
    [_tagLabel setText:tagStr];
    long long time = [[[NSString stringWithFormat:@"%lld",self.message.messageDate] substringToIndex:10] longLongValue];
    [_timeLabel setText:[[NSDate dateWithTimeIntervalSince1970:time] qim_timeIntervalDescription]];
    CGSize contentSize = [msgStr sizeWithFont:_contentLabel.font constrainedToSize:CGSizeMake(_contentLabel.width, INT32_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    [_contentLabel setFrame:CGRectMake(_contentLabel.left, _contentLabel.top, _contentLabel.width, contentSize.height)];
    [_contentLabel setText:msgStr];
    
    [_bottomButton setFrame:CGRectMake(_bottomButton.left, _contentLabel.bottom + 10, _bottomButton.width, _bottomButton.height)];
    
    [_backView setFrame:CGRectMake(_backView.left, _backView.top, _backView.width, _bottomButton.bottom)];
    [_lineView setFrame:CGRectMake(0, _bottomButton.top, _backView.width, 0.5)];
    
}

@end
