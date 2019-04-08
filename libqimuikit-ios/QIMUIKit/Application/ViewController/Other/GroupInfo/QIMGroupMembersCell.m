//
//  QIMGroupMembersCell.m
//  qunarChatIphone
//
//  Created by chenjie on 15/11/17.
//
//

#import "QIMGroupMembersCell.h"
#import "YLImageView.h"
#import "QIMCommonFont.h"
#import "NSBundle+QIMLibrary.h"

#define kImageWidth     50

@interface QIMGroupMembersCell ()
{
    UILabel         * _titleLabel;
    UILabel         * _countLabel;
    NSArray         * _items;
    NSInteger         _onlineMemCount;
}

@end

@implementation QIMGroupMembersCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutSubviews) name:kUserHeaderImgUpdate object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initUI
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-2];
    _titleLabel.textColor = [UIColor qtalkTextLightColor];
    [self.contentView addSubview:_titleLabel];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
    _countLabel.textColor = [UIColor spectralColorGrayColor];
    [self.contentView addSubview:_countLabel];
    
}


- (void)setCount:(NSInteger)count
{
    _countLabel.text = [NSString stringWithFormat:@"%@ 人",@(count).description];
}

- (void)setItems:(NSArray *)items
{
    if (items && [items isKindOfClass:[NSArray class]]) {
        _items = [NSArray arrayWithArray:items];
    }
}

- (NSInteger)getOnlineMenmbersCount
{
    return _onlineMemCount;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIView * view in self.contentView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    _titleLabel.text = [NSBundle qim_localizedStringForKey:@"group_member"];
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(INT32_MAX, 22) lineBreakMode:NSLineBreakByCharWrapping];
    _titleLabel.frame = CGRectMake(15, 10, size.width, 22);
    
    _countLabel.frame = CGRectMake(_titleLabel.right + 5, _titleLabel.bottom - 17, self.contentView.width - 10 - _titleLabel.right - 5, 17);
    
    _titleLabel.font = [UIFont boldSystemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
    _countLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize]-4];
    
    float startX = 10;
    
    for (NSDictionary * itemDic in _items) {
        NSString *xmppId = [itemDic objectForKey:@"xmppjid"];
//        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:xmppId];
        /*
        NSString *name = [itemDic objectForKey:@"name"];
        UIImage *headerImage = [[QIMKit sharedInstance] getUserHeaderImageByName:name];
        if (headerImage.images.count) {
            if (headerImage.images[0] && ![headerImage.images[0] isKindOfClass:[NSNull class]]) {
                headerImage = headerImage.images[0];
            }
        }
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByName:name];
        */
        /*
        UIImage *headerImage = [[QIMKit sharedInstance] getUserHeaderImageByUserId:xmppId];
        if (headerImage.images.count) {
            if (headerImage.images[0] && ![headerImage.images[0] isKindOfClass:[NSNull class]]) {
                headerImage = headerImage.images[0];
            }
        }
        */
        //判断用户在线状态
        /*
        BOOL isUserOnline = [[QIMKit sharedInstance] isUserOnline:xmppId];
        if (!isUserOnline) {
            headerImage = [headerImage qim_grayImage];
        }
         */
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(startX, _titleLabel.bottom + 10, kImageWidth, kImageWidth);
        imageView.layer.cornerRadius = kImageWidth / 2.0;
        imageView.clipsToBounds = YES;
        [imageView qim_setImageWithJid:xmppId];
        [self.contentView addSubview:imageView];
        startX += kImageWidth + 10;
        if (startX > self.contentView.width - (10 + kImageWidth) * 2) {
            break;
        }
    }
    //add
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mqz_add_picture"]];
    imageView.frame = CGRectMake(startX, _titleLabel.bottom + 10, kImageWidth, kImageWidth);
    imageView.layer.cornerRadius = kImageWidth / 2.0;
    imageView.userInteractionEnabled = YES;
    [self.contentView addSubview:imageView];
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [imageView addGestureRecognizer:tap];
}


- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupMembersCell:handleForGes:)]) {
        [self.delegate groupMembersCell:self handleForGes:tap];
    }
}

@end
