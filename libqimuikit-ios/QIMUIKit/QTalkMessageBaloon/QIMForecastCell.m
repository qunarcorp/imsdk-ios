//
//  QIMForecastCell.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/1/12.
//
//

#import "QIMMsgBaloonBaseCell.h"
#import "QIMForecastCell.h"
#import "QIMJSONSerializer.h"
#import "UIImageView+WebCache.h"

@implementation QIMForecastCell {
    UILabel         * _titleLabel;
    YLImageView     * _imageView;
    UILabel         * _descLabel;
}

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType{
    NSString * infoStr = message.extendInformation.length <= 0 ? message.message : message.extendInformation;
    NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
    bool showas667 = [[infoDic objectForKey:@"showas667"] boolValue];
    if (message.messageType == QIMMessageType_Forecast || showas667) {
        NSString *desc = [infoDic objectForKey:@"desc"];
        CGSize descSize = [desc qim_sizeWithFontCompatible:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.65 - 20, MAXFLOAT)];
        return (chatType == ChatType_GroupChat && message.messageDirection == MessageDirection_Received ? 115 : 90)  + MAX(descSize.height, 20) ;
    }else{
        return chatType == ChatType_GroupChat && message.messageDirection == MessageDirection_Received ? 115 : 90 ;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView* view = [[UIView alloc]initWithFrame:self.contentView.frame];
        view.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView = view;
        
        self.frameWidth = [UIScreen mainScreen].bounds.size.width;
//        [self initBackViewAndHeaderName];
        [self.backView setMenuActionTypeList:@[]];
        
        _imageView = [[YLImageView alloc] initWithFrame:CGRectZero];
        [_imageView.layer setCornerRadius:5];
        [_imageView setClipsToBounds:YES];
        [self.backView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        //        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLabel.textColor = [UIColor qtalkTextBlackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleLabel setNumberOfLines:2];
        [self.backView addSubview:_titleLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.textColor = [UIColor qtalkTextLightColor];
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.numberOfLines = 0;
        [self.backView addSubview:_descLabel];
                
    }
    return self;
}

-(void)refreshUI{
    
    self.selectedBackgroundView.frame = self.contentView.frame;
    
    NSString * infoStr = self.message.extendInformation.length <= 0 ? self.message.message : self.message.extendInformation;
    NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
    NSMutableArray * menuList = [NSMutableArray arrayWithArray:@[@(MA_Repeater) /*, @(MA_Favorite)*/, @(MA_ToWithdraw), @(MA_ReplyMsg)]];
    [self.backView setMenuActionTypeList:menuList];
    
    CGFloat cellHeight = [QIMForecastCell getCellHeightWihtMessage:self.message chatType:self.chatType];
    CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width * 0.65;
//    if (self.chatType == ChatType_GroupChat && self.message.messageDirection == MessageDirection_Received) {
//        [self setBackViewWithWidth:cellWidth WihtHeight:cellHeight - 35];
//    } else {
//        [self setBackViewWithWidth:cellWidth WihtHeight:cellHeight - 10];
//    }
    float imgWidth = 60;
    if (self.message.messageDirection == MessageDirection_Received) {
        _imageView.frame = CGRectMake(25, 10, imgWidth, imgWidth);
    } else {
        _imageView.frame = CGRectMake(10, 10, imgWidth, imgWidth);
    }
    [self.backView setMessage:self.message];
    [self setBackViewWithWidth:cellWidth WihtHeight:cellHeight];
    switch (self.message.messageDirection) {
        case MessageDirection_Received:
        {
            [self.backView setImage:nil];
            _titleLabel.frame = CGRectMake(self.backView.left + 15, self.backView.top + 10, self.backView.width - 25, 25);
        }
            break;
        case MessageDirection_Sent:
        {
            [self.backView setImage:nil];
            _titleLabel.frame = CGRectMake(self.backView.left + 5, self.backView.top + 10, self.backView.width - 25, 25);
        }
            break;
        default:
            break;
    }
    [self.backView setBubbleBgColor:[UIColor whiteColor]];
    NSString *title = [infoDic objectForKey:@"title"];
    NSString *desc = [infoDic objectForKey:@"desc"];
    NSString *linkUrl = [infoDic objectForKey:@"linkurl"];
    [_titleLabel setText:title.length>0?title:linkUrl];
    [_descLabel setText:desc.length>0?desc:@"点击查看全文"];
    NSString * imgStr = [infoDic objectForKey:@"img"];
    if ([imgStr isKindOfClass:[NSString class]]) {
        [_imageView qim_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[QIMKit defaultCommonTrdInfoImage]];
    }else{
        [_imageView setImage:[QIMKit defaultCommonTrdInfoImage]];
    }
    CGSize titleSize = [_titleLabel.text qim_sizeWithFontCompatible:_titleLabel.font constrainedToSize:CGSizeMake(self.backView.width - _imageView.right - 5 - 10, 40)];
    
    if (self.message.messageType == QIMMessageType_CommonTrdInfoPer || [[infoDic objectForKey:@"showas667"] boolValue]) {
        [_titleLabel setFrame:CGRectMake(_imageView.right + 5, _imageView.top + (imgWidth - titleSize.height) / 2, titleSize.width, titleSize.height)];
        _descLabel.frame = CGRectMake(_imageView.left , _imageView.bottom + 5, self.backView.width - _imageView.left - 10, self.backView.height - ( _imageView.bottom + 5) - 10);
    }else {
        [_titleLabel setFrame:CGRectMake(_imageView.right + 5, 10, titleSize.width, titleSize.height)];
        _descLabel.frame = CGRectMake(_imageView.right + 5, _titleLabel.bottom + 5, self.backView.width - _imageView.right - 5 - 10, self.backView.height - ( _titleLabel.bottom + 5) - 10);
    }
    [super refreshUI];

}

@end
