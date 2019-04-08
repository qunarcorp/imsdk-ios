//
//  QIMAddSomeCell.m
//  qunarChatIphone
//
//  Created by admin on 15/11/24.
//
//

#import "QIMAddSomeCell.h"
#import "YLImageView.h"

@implementation QIMAddSomeCell{

    YLImageView *_headerImageView;
    UILabel *_titleLabel;
    UILabel *_descLabel;
    UIView  *_lineView;
}

+ (CGFloat)getCellHeight{
    return 60;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        CGFloat headerWidth = [QIMAddSomeCell getCellHeight] - 10 * 2;
        _headerImageView = [[YLImageView alloc] initWithFrame:CGRectMake(10, 10, headerWidth, headerWidth)];
        [_headerImageView setClipsToBounds:YES];
        [_headerImageView.layer setCornerRadius:headerWidth / 2.0];
        [self.contentView addSubview:_headerImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headerImageView.right + 10, 10, self.width - 30 - _headerImageView.right - 10, 20)];
        [_titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_titleLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom, _titleLabel.width, _titleLabel.height)];
        [_descLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 6]];
        [_descLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_descLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_descLabel];
        
        _lineView= [[UIView alloc] initWithFrame:CGRectMake(_titleLabel.left, [QIMAddSomeCell getCellHeight]-0.5, [UIScreen mainScreen].bounds.size.width-_titleLabel.left, 0.5)];
        [_lineView setBackgroundColor:[UIColor qtalkSplitLineColor]];
        [self.contentView addSubview:_lineView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)refreshUI{
    
    NSString *name = [self.userInfoDic objectForKey:@"Name"];
    NSString *jid = [self.userInfoDic objectForKey:@"XmppId"];
    NSString *descInfo = [self.userInfoDic objectForKey:@"DescInfo"];
    CGFloat headerWidth = [QIMAddSomeCell getCellHeight] - 10 * 2;
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
    [_titleLabel setText:remarkName?remarkName:name];
    [_descLabel setText:descInfo];
    [_headerImageView qim_setImageWithJid:jid];
    /*
    __block UIImage * headImage = [[QIMKit sharedInstance] getUserHeaderImageByUserId:jid];
    if (!headImage) {
        NSString *iconUrl = [self.userInfoDic objectForKey:@"icon"];
        if (![iconUrl isKindOfClass:[NSNull class]]) {
            BOOL isHTTPRequest = [iconUrl qim_hasPrefixHttpHeader];
            if (!isHTTPRequest) {
                iconUrl = [NSString stringWithFormat:@"%@/%@",[QIMKit sharedInstance].qimNav_InnerFileHttpHost, iconUrl];
            }
            __block NSData *headImageData = [[QIMKit sharedInstance] getFileDataFromUrl:iconUrl width:headerWidth height:headerWidth  forCacheType:QIMFileCacheTypeColoction];
            if (!headImageData.length) {
                [[QIMKit sharedInstance] downloadImage:iconUrl width:headerWidth height:headerWidth forCacheType:QIMFileCacheTypeColoction complation:^(NSData *data) {
                    headImageData = data;
                    headImage = [UIImage imageWithData:headImageData];
                }];
            } else {
                headImage = [UIImage imageWithData:headImageData];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_headerImageView setImage:headImage];
    });
    */
}

@end
