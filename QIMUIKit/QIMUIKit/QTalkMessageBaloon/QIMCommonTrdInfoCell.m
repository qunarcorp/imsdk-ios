//
//  QIMCommonTrdInfoCell.m
//  qunarChatIphone
//
//  Created by admin on 16/5/17.
//
//
#import "QIMMsgBaloonBaseCell.h"
#import "QIMCommonTrdInfoCell.h"
#import "UIImageView+WebCache.h"
#import "QIMJSONSerializer.h"

#define kCommonTrdInfoCellWidth       IS_Ipad ? ([UIScreen mainScreen].qim_rightWidth  * 3.2 / 5) : ([UIScreen mainScreen].bounds.size.width * 3.4/5)

@implementation QIMCommonTrdInfoCell{
    UILabel         * _titleLabel;
    YLImageView     * _imageView;
    UILabel         * _descLabel;
}

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType{
    NSString * infoStr = message.extendInformation.length <= 0 ? message.message : message.extendInformation;
    NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
    bool showas667 = [[infoDic objectForKey:@"showas667"] boolValue];
    if (message.messageType == QIMMessageType_CommonTrdInfoPer || showas667) {
        NSString *desc = [infoDic objectForKey:@"desc"];
        CGSize descSize = [desc qim_sizeWithFontCompatible:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.60 - 20, MAXFLOAT)];
        return 110 + MAX(descSize.height, 20);
    } else {
        
        NSString *title = [infoDic objectForKey:@"title"];
        CGSize titleSize = [title qim_sizeWithFontCompatible:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.60 - 20, 40)];
        if (titleSize.height <= 30) {
            return 100;
        }
        return 110;
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
        [self.backView setMenuActionTypeList:@[]];
        
        _imageView = [[YLImageView alloc] initWithFrame:CGRectZero];
        [_imageView.layer setCornerRadius:5];
        [_imageView setClipsToBounds:YES];
        [self.backView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
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

-(void)refreshUI {
    self.selectedBackgroundView.frame = self.contentView.frame;
    NSString * infoStr = self.message.extendInformation.length <= 0 ? self.message.message : self.message.extendInformation;
    NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
    CGFloat cellHeight = [QIMCommonTrdInfoCell getCellHeightWihtMessage:self.message chatType:self.chatType];
    CGFloat cellWidth = kCommonTrdInfoCellWidth;
    [self.backView setMessage:self.message];
    [self setBackViewWithWidth:cellWidth WihtHeight:cellHeight - 10];
    float imgWidth = 40;
    
    CGFloat titleLeft = (self.message.messageDirection == MessageDirection_Sent) ? 15 : 25;
    NSString *title = [infoDic objectForKey:@"title"];
    NSString *desc = [infoDic objectForKey:@"desc"];
    NSString *linkUrl = [infoDic objectForKey:@"linkurl"];
    [_titleLabel setText:title.length > 0 ? title : linkUrl];
    [_descLabel setText:desc.length > 0 ? desc : @"点击查看全文"];
    [_descLabel setNumberOfLines:0];
    NSString * imgStr = [infoDic objectForKey:@"img"];
    if ([imgStr isKindOfClass:[NSString class]]) {
        [_imageView qim_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[QIMKit defaultCommonTrdInfoImage]];
    } else{
        [_imageView setImage:[QIMKit defaultCommonTrdInfoImage]];
    }
    CGSize titleSize = [_titleLabel.text qim_sizeWithFontCompatible:_titleLabel.font constrainedToSize:CGSizeMake(self.backView.width - titleLeft - 10, 40)];
    [_titleLabel setFrame:CGRectMake(titleLeft, 10, titleSize.width, titleSize.height)];
    
    _imageView.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, imgWidth, imgWidth);
    if (self.message.messageType == QIMMessageType_CommonTrdInfoPer || [[infoDic objectForKey:@"showas667"] boolValue]) {
        _descLabel.frame = CGRectMake(_imageView.right + 5 , _titleLabel.bottom + 5, self.backView.width - _imageView.right - 15, self.backView.height - (_titleLabel.bottom + 5) - 10);
    }else {
        _descLabel.frame = CGRectMake(_imageView.right + 5, _titleLabel.bottom + 5, self.backView.width - _imageView.right - 5 - 15, self.backView.height - ( _titleLabel.bottom + 5) - 10);
    }
    _imageView.centerY = _descLabel.centerY;
    [self.backView setBubbleBgColor:[UIColor whiteColor]];
    [super refreshUI];
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        case MessageDirection_Sent: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
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
