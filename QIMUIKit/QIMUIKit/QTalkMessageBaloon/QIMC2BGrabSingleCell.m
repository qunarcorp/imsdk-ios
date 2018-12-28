//
//  QIMC2BGrabSingleCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/10/25.
//

#import "QIMMsgBaloonBaseCell.h"
#import "QIMC2BGrabSingleCell.h"
#import "UIImageView+WebCache.h"
#import "QIMWebView.h"
#import "QIMJSONSerializer.h"
#import "NSAttributedString+Attributes.h"
#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kCellHeightCap      10
#define kBackViewCap        5
#define kMinTextWidth       30
#define kMinTextHeight      30

@implementation QIMC2BGrabSingleCell {
    UIView *_bgContentView;
    
    UIImageView *_headerImageView;
    UILabel *_titleLabel;       //title
    UILabel *_priceLabel;       //人均预算
    UILabel *_orderTimeLabel;   //下单时间
    UILabel *_remarkLabel;      //备注时间
    UIButton *_grabSingleButtton;    //抢单按钮
    UILabel *_priceStrLabel;
    UILabel *_typeLabel;
    Message *_c2BMessage;
}

+ (CGFloat)getCellHeight {
    return 220;
}

- (void)updateC2BGrabSingleFeedBack:(NSNotification *)notify {
    NSString *msgId = notify.object;
    if ([msgId isEqualToString:_c2BMessage.messageId] && [notify.userInfo objectForKey:@"message"]) {
        
        Message *msg = [notify.userInfo objectForKey:@"message"];
        NSString *c2BExtendInfo = msg.extendInformation;
        NSDictionary *c2BMsgDict = [[QIMJSONSerializer sharedInstance] deserializeObject:c2BExtendInfo error:nil];
        NSString *c2BMsgId = nil;
        NSString *btnDisplay = nil;
        BOOL c2BStatus = YES;
        NSString *dealId = nil;
        if (c2BMsgDict.count > 0) {
            c2BMsgId = [c2BMsgDict objectForKey:@"msgId"];
            btnDisplay = [c2BMsgDict objectForKey:@"btnDisplay"];
            c2BStatus = [[c2BMsgDict objectForKey:@"status"] boolValue];
            dealId = [c2BMsgDict objectForKey:@"dealId"];
        }
        if (btnDisplay) {
            self.btnDisplay = btnDisplay;
        }
        self.deadStatus = c2BStatus;
        if (dealId) {
            self.dealid = dealId;
        }
        [self refreshUI];
    }
}

- (void)setMessage:(Message *)message {
    
    _c2BMessage = message;
    NSDictionary *grabSingleDic = nil;
    if (message.extendInformation) {
        grabSingleDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
    } else {
        grabSingleDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
    }
    self.title = [grabSingleDic objectForKey:@"title"];
    self.deadUrl = [grabSingleDic objectForKey:@"dealUrl"];
    self.dealid = [grabSingleDic objectForKey:@"dealId"];
    self.btnDisplay = [grabSingleDic objectForKey:@"btnDisplay"];
    self.deadStatus = [[grabSingleDic objectForKey:@"status"] boolValue];
    NSDictionary *detailDic = [grabSingleDic objectForKey:@"detail"];
    self.budgetinfo = [detailDic objectForKey:@"budgetInfo"];
    self.orderTime = [detailDic objectForKey:@"orderTime"];
    self.remarks = [detailDic objectForKey:@"remarks"];
    NSString *getC2BMessageFeedBackStr = [[QIMKit sharedInstance] getC2BMessageFeedBackWithMsgId:message.messageId];
    NSDictionary *c2BMsgDict = nil;
    if (getC2BMessageFeedBackStr) {
        c2BMsgDict = [[QIMJSONSerializer sharedInstance] deserializeObject:getC2BMessageFeedBackStr error:nil];
        if (c2BMsgDict.count) {
            self.btnDisplay = [c2BMsgDict objectForKey:@"btnDisplay"];
            self.deadStatus = [c2BMsgDict objectForKey:@"status"];
            self.dealid = [c2BMsgDict objectForKey:@"dealId"];
        }
    }
    [self refreshUI];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateC2BGrabSingleFeedBack:) name:kNotificationC2BMessageFeedBackUpdate object:nil];
        [self setBackgroundColor:[UIColor clearColor]];
        _bgContentView = [[UIView alloc] initWithFrame:CGRectMake(20, 10, [UIScreen mainScreen].bounds.size.width - 40, [QIMC2BGrabSingleCell getCellHeight] - 20)];
        [_bgContentView setBackgroundColor:[UIColor whiteColor]];
        [_bgContentView setClipsToBounds:YES];
        [_bgContentView.layer setCornerRadius:5];
        [_bgContentView.layer setBorderWidth:0.5];
        [_bgContentView.layer setBorderColor:[UIColor qtalkSplitLineColor].CGColor];
        [self.contentView addSubview:_bgContentView];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, _bgContentView.width - 20, 36)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setNumberOfLines:0];
        [_bgContentView addSubview:_titleLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _titleLabel.bottom + 5, _bgContentView.width - 20, 20)];
        [_priceLabel setBackgroundColor:[UIColor clearColor]];
        [_priceLabel setFont:[UIFont systemFontOfSize:15]];
        [_priceLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_priceLabel setTextAlignment:NSTextAlignmentLeft];
        [_priceLabel setNumberOfLines:0];
        [_bgContentView addSubview:_priceLabel];
        
        
        _orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _priceLabel.bottom + 5, _bgContentView.width - 20, 20)];
        [_orderTimeLabel setBackgroundColor:[UIColor clearColor]];
        [_orderTimeLabel setFont:[UIFont systemFontOfSize:14]];
        [_orderTimeLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_orderTimeLabel setTextAlignment:NSTextAlignmentLeft];
        [_orderTimeLabel setNumberOfLines:0];
        [_bgContentView addSubview:_orderTimeLabel];
        
        _remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _orderTimeLabel.bottom + 5, _bgContentView.width - 20, 20)];
        [_remarkLabel setBackgroundColor:[UIColor clearColor]];
        [_remarkLabel setFont:[UIFont systemFontOfSize:14]];
        [_remarkLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_remarkLabel setTextAlignment:NSTextAlignmentLeft];
        [_remarkLabel setNumberOfLines:0];
        [_bgContentView addSubview:_remarkLabel];
        
        _grabSingleButtton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_grabSingleButtton setFrame:CGRectMake(10, _remarkLabel.bottom + 15, _bgContentView.width - 20, 50)];
        [_grabSingleButtton.layer setCornerRadius:5.0f];
        [_grabSingleButtton setBackgroundColor:[UIColor qunarBlueColor]];
        [_grabSingleButtton addTarget:self action:@selector(grabSingleClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bgContentView addSubview:_grabSingleButtton];
    }
    return self;
}

- (void)grabSingleClick:(id)sender {
    QIMWebView *webView = [[QIMWebView alloc] init];
    webView.url = self.deadUrl;
    [self.owner.navigationController pushViewController:webView animated:YES];
}

- (void)refreshUI {
    [_titleLabel setText:self.title];
    [_priceLabel setText:self.budgetinfo];
    [_orderTimeLabel setText:self.orderTime];
    [_remarkLabel setText:self.remarks];
    if (self.deadStatus) {
        [_grabSingleButtton setEnabled:NO];
        [_grabSingleButtton setBackgroundColor:[UIColor lightGrayColor]];
    } else {
        [_grabSingleButtton setBackgroundColor:[UIColor qunarBlueColor]];
        [_grabSingleButtton setEnabled:YES];
    }
    [_grabSingleButtton setTitle:self.btnDisplay forState:UIControlStateNormal];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
