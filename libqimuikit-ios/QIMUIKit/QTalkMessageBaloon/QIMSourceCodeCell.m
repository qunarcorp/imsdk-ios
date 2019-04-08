//
//  QIMSourceCodeCell.m
//  qunarChatIphone
//
//  Created by admin on 15/7/23.
//
//

#import "QIMMsgBaloonBaseCell.h"
#import "QIMSourceCodeCell.h"
#import "QIMSourceCodeVC.h"
#import "QIMFileIconTools.h"
#import "QIMWebView.h"
#import "QIMJSONSerializer.h"
#import <MMMarkdown/MMMarkdown.h>

#define kCellWidth      200
#define kCellHeight     70

@interface QIMSourceCodeCell()<QIMMenuImageViewDelegate>


@end

@implementation QIMSourceCodeCell{
    
    UIView          * _bgView;
    UIImageView     * _iconImageView;
    UILabel         * _iconLabel;
    UILabel         * _titleLabel;
    UILabel         * _contentLabel;
    
}


+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType{
    return kCellHeight + 20 + 20;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kCellHeight)];
        [self.backView addSubview:_bgView];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
        [_iconImageView.layer setCornerRadius:5];
        [_iconImageView.layer setMasksToBounds:YES];
        [_bgView addSubview:_iconImageView];
        _iconImageView.centerY = _bgView.centerY;

        _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _iconImageView.height - 12, _iconImageView.width, 12)];
        [_iconLabel setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.75]];
        [_iconLabel setTextColor:[UIColor whiteColor]];
        [_iconLabel setFont:[UIFont boldSystemFontOfSize:9]];
        [_iconLabel setTextAlignment:NSTextAlignmentCenter];
        [_iconLabel setText:@"代码段"];
        [_iconImageView addSubview:_iconLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( _iconImageView.right + 10, 10, kCellWidth - (_iconImageView.right + 10) - 10 , 18)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setNumberOfLines:2];
        [_bgView addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom , _titleLabel.width, kCellHeight - 10 - _titleLabel.bottom)];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setTextColor:[UIColor lightGrayColor]];
        [_contentLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [_contentLabel setTextAlignment:NSTextAlignmentLeft];
        [_contentLabel setNumberOfLines:2];
        [_contentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_bgView addSubview:_contentLabel];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [self.backView addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)downfileNotify:(NSNotification *)nofity{
    if ([self.message.messageId isEqualToString:nofity.object]) {
        [self refreshUI];
    }
}

#pragma mark - action

- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    if (self.message.messageType == QIMMessageType_Markdown) {
        NSError  *error;
        NSString *markdown  = self.message.message;
        if (markdown) {
            NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdown extensions:MMMarkdownExtensionsGitHubFlavored error:&error];
            // Returns @"<h1>Example</h1>\n<p>What a library!</p>"
            QIMWebView *webView = [[QIMWebView alloc] init];
            [webView setHtmlString:htmlString];
            [[self.owerViewController navigationController] pushViewController:webView animated:YES];
        }
    } else {
        if (self.owerViewController) {
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil];
            if (infoDic.count > 0) {
                QIMSourceCodeVC *codeVC = [[QIMSourceCodeVC alloc] init];
                [codeVC setSourceCodeDic:infoDic];
                [codeVC setMsgId:self.message.messageId];
                [[self.owerViewController navigationController] pushViewController:codeVC animated:YES];
            } else {
                QIMSourceCodeVC *codeVC = [[QIMSourceCodeVC alloc] init];
                [codeVC setSourceCodeDic:@{@"Code":self.message.message,@"CodeType":@"languare-objectivec"}];
                [[self.owerViewController navigationController] pushViewController:codeVC animated:YES];
            }
        }
    }
}



#pragma mark - ui
- (void)refreshUI{
    self.backView.message = self.message;
    float backWidth = kCellWidth + kBackViewCap + 2;
    float backHeight = kCellHeight + 1;
    [self setBackViewWithWidth:backWidth WihtHeight:backHeight];
    [super refreshUI];
    
    UIImage *image = [QIMFileIconTools getFileIconWihtExtension:@"txt"];
    [_iconImageView setImage:image];
    
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil];
    if (infoDic.count > 0) {
        NSString *codeType = [infoDic objectForKey:@"CodeType"];
        NSString *code = [infoDic objectForKey:@"Code"];
        
        [_titleLabel setText:[NSString stringWithFormat:@"%@",codeType]];
        [_contentLabel setText:code];
    } else if (self.message.messageType == QIMMessageType_Markdown) {
        [_titleLabel setText:@"Markdown"];
        [_contentLabel setText:self.message.message];
    } else {
        [_titleLabel setText:@"Source Code"];
        [_contentLabel setText:self.message.message];
    }
    
    if (self.message.messageDirection == MessageDirection_Received) {
        [_bgView setLeft:kBackViewCap+2];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_contentLabel setTextColor:[UIColor qtalkTextBlackColor]];
    } else {
        [_bgView setLeft:0];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_contentLabel setTextColor:[UIColor whiteColor]];
    }
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_Delete)]];
        }
            break;
        case MessageDirection_Sent: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete)]];
        }
            break;
        default:
            break;
    }
    if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
        [menuList addObject:@(MA_CopyOriginMsg)];
    }
    if ([[QIMKit sharedInstance] getIsIpad]) {
        [menuList removeAllObjects];
    }
    return menuList;
}

@end
