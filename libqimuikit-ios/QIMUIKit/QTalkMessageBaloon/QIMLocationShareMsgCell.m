//
//  QIMLocationShareMsgCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//
#define kQIMLocationShareMsgCellHeight    150
#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMinTextWidth       30
#define kMinTextHeight      30

#import "QIMMsgBaloonBaseCell.h"
#import "UIApplication+QIMApplication.h"
#import "QIMJSONSerializer.h"
#import "QIMLocationShareMsgCell.h"
#import "UserLocationViewController.h"
#import "UIImageView+WebCache.h"
#import "ShapedImageView.h"

@interface QIMLocationShareMsgCell()<QIMMenuImageViewDelegate>
{
    ShapedImageView     * _imageView;
    UILabel         * _titleLabel;
}
@end

@implementation QIMLocationShareMsgCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType
{
    return kQIMLocationShareMsgCellHeight + 20 + (chatType == ChatType_GroupChat ? 20 : 0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _imageView = [[ShapedImageView alloc] initWithImage:[UIImage imageNamed:@"map_located"]];
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.backgroundColor = [UIColor clearColor];
        //        [self.contentView addSubview:_titleLabel];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [_imageView addGestureRecognizer:tap];
    }
    return self;
}

- (void)refreshUI
{
    self.selectedBackgroundView.frame = CGRectMake(0, 0, 30, self.contentView.height);
    
    self.backView.message = self.message;
    if (self.message.extendInformation) {
        self.message.message = self.message.extendInformation;
    }
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
    _titleLabel.text = [infoDic objectForKey:@"adress"];
    
    UIImage * localImage = [UIImage imageWithData:[[QIMKit sharedInstance] getFileDataFromUrl:infoDic[@"fileUrl"] forCacheType:QIMFileCacheTypeColoction]];
    if (localImage) {
        _imageView.image = localImage;
    }else if ([infoDic[@"fileUrl"] length] > 0){
        NSString  * imageUrlStr = [NSString stringWithFormat:@"%@/%@",[QIMKit sharedInstance].qimNav_InnerFileHttpHost,infoDic[@"fileUrl"]];
        [_imageView qim_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"map_located"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [[QIMKit sharedInstance] saveFileData:UIImageJPEGRepresentation(image, 1.0) withFileName:nil forCacheType:QIMFileCacheTypeColoction];
        }];
    }else{
        _imageView.image = [UIImage imageNamed:@"map_located"];
    }
    
    float backWidth = 215;
    float backHeight = kQIMLocationShareMsgCellHeight;
    
    [self setBackViewWithWidth:backWidth WihtHeight:backHeight];
    [super refreshUI];
    switch (self.message.messageDirection) {
        case MessageDirection_Received:
        {
//            [self.backView setMenuActionTypeList:@[@(MA_Repeater), @(MA_Delete) /*@(MA_ReplyMsg) , @(MA_Favorite)*/]];
//            CGRect frame = {{kBackViewCap + (self.chatType == ChatType_GroupChat ? self.HeadView.width + 10: 0),kCellHeightCap / 2.0 + self.nameLabel.bottom},{backWidth,backHeight}};
//            [self.backView setFrame:frame];
            [self.backView setImage:[[UIImage alloc] init]];
            
            _titleLabel.frame = CGRectMake(kBackViewCap + self.backView.left + 10, self.backView.top + 5, self.backView.width - 60 - 20, 60);
            _imageView.frame = CGRectMake(self.HeadView.width + kBackViewCap + 2, self.backView.top + 2, self.backView.width - kBackViewCap, self.backView.height - 4);
            _imageView.direction = ShapedImageViewDirectionLeft;
            [_imageView setup];
        }
            break;
        case MessageDirection_Sent:
        {
//            NSMutableArray * menuList = [NSMutableArray arrayWithArray:@[@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete)/*, @(MA_Favorite)*/]];
//            [self.backView setMenuActionTypeList:menuList];
//
//            CGRect frame = {{self.frameWidth - kBackViewCap - backWidth,kBackViewCap},{backWidth,backHeight}};
//            [self.backView setFrame:frame];
            
            [self.backView setImage:[[UIImage alloc] init]];
            
            //            _imageView.frame = CGRectMake(self.backView.left + 5, self.backView.top + 5, 60, 60);
            _imageView.frame = CGRectMake(self.backView.left, self.backView.top + 1, self.backView.width -2, self.backView.height - 2);
            _imageView.direction = ShapedImageViewDirectionRight;
            [_imageView setup];
            _titleLabel.frame = CGRectMake(_imageView.right + 5, 10, self.backView.width - _imageView.width - 20, 60);
        }
            break;
        default:
            break;
    }
    
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
