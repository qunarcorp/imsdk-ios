//
//  LocationShareMsgCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//
#define kQIMShareLocationChatCellHeight    40
#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMinTextWidth       30
#define kMinTextHeight      30

#import "QIMMsgBaloonBaseCell.h"
#import "QIMJSONSerializer.h"
#import "QIMShareLocationChatCell.h"
#import "UserLocationViewController.h"
#import "UIImageView+WebCache.h"
#import "UIApplication+QIMApplication.h"

@interface QIMShareLocationChatCell()<QIMMenuImageViewDelegate>
{
    UIImageView     * _imageView;
    UILabel         * _titleLabel;
}
@end

@implementation QIMShareLocationChatCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType
{
    return kQIMShareLocationChatCellHeight + 20 + 20;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationSharing_Icon_Location_Main"]];
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = @"我发起了位置共享";
        [self.contentView addSubview:_titleLabel];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
//        [_imageView addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)refreshUI
{    
    self.backView.message = self.message;
    
    float backWidth = 170;
    float backHeight = kQIMShareLocationChatCellHeight;
    
    switch (self.message.messageDirection) {
        case MessageDirection_Received:
        {
            _titleLabel.textColor = [UIColor blackColor];
            CGRect frame = {{kBackViewCap + self.HeadView.width,kCellHeightCap / 2.0 + self.nameLabel.bottom},{backWidth,backHeight}};
            [self.backView setFrame:frame];
            [self.backView setImage:[QIMMsgBaloonBaseCell leftBallocImage]];
            
            _imageView.frame = CGRectMake(kBackViewCap + self.backView.left + 5, self.backView.top + 5, 30, 30);
            _titleLabel.frame = CGRectMake(_imageView.right , self.backView.top, self.backView.width - 40 - 10, self.backView.height);
            _titleLabel.textColor = [UIColor qim_leftBallocFontColor];
        }
            break;
        case MessageDirection_Sent:
        {
            _titleLabel.textColor = [UIColor whiteColor];
            CGRect frame = {{self.frameWidth - kBackViewCap - backWidth,kBackViewCap},{backWidth,backHeight}};
            [self.backView setFrame:frame];
            
            [self.backView setImage:[QIMMsgBaloonBaseCell rightBallcoImage]];
            
//            _imageView.frame = CGRectMake(self.backView.left + 5, self.backView.top + 5, 60, 60);
            _titleLabel.frame = CGRectMake(self.backView.left + 10, 5, self.backView.width - 40 - 10, self.backView.height);
            _imageView.frame = CGRectMake(_titleLabel.right, self.backView.top + 5, 30, 30);
            _titleLabel.textColor = [UIColor qim_rightBallocFontColor];
        }
            break;
        default:
            break;
    }
    [super refreshUI];
}

- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    if (self.owerViewController) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
        UserLocationViewController * userLocationVC = [[UserLocationViewController alloc] initWithCoordinate:CLLocationCoordinate2DMake([[infoDic objectForKey:@"latitude"] doubleValue],[[infoDic objectForKey:@"longitude"] doubleValue])];
        userLocationVC.dispalyAdr = infoDic[@"adress"];
        userLocationVC.dispalyName = infoDic[@"name"];
        if ([[QIMKit sharedInstance] getIsIpad]){
            [[[UIApplication sharedApplication] visibleViewController] presentViewController:userLocationVC animated:YES completion:nil];
//            [[[[UIApplication sharedApplication].delegate window] rootViewController] presentViewController:userLocationVC animated:YES completion:nil];
        }else{
            [self.owerViewController presentViewController:userLocationVC animated:YES completion:nil];
        }
    }
}

@end

