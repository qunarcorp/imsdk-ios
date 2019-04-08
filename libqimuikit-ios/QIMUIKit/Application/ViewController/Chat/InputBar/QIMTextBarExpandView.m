//
//  QIMTextBarExpandView.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/9.
//
//

#define kItemWidth      54
#define kItemTagFrom    1000
#import "QIMMsgBaseVC.h"
#import "QIMTextBarExpandView.h"
#import "UserLocationViewController.h"
#import "QIMChatVC.h"  
#import "UIImageView+WebCache.h"
#import "NSBundle+QIMLibrary.h"
#import "UIApplication+QIMApplication.h"

static NSMutableDictionary *__trdExtendInfoDic = nil;

@interface QIMTextBarExpandView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *view;

@end

@implementation QIMTextBarExpandView
{
    UIScrollView            * _mainScrollView;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)addItems
{
    if ([[QIMKit sharedInstance] getMsgTextBarButtonInfoList].count) {
        [[QIMKit sharedInstance] removeAllExpandItems];
    }
//    if ([[QIMKit getLastUserName].lowercaseString isEqualToString:@"appstore"] == NO) {
        if (__trdExtendInfoDic == nil) {
            __trdExtendInfoDic = [[NSMutableDictionary alloc] init];
        }
        for (NSDictionary *trdEntendInfo in [[QIMKit sharedInstance] trdExtendInfo]) {
            NSString *trdEntendId = [trdEntendInfo objectForKey:@"trdextendId"];
            
            int client = [[trdEntendInfo objectForKey:@"client"] intValue];
            int support = [[trdEntendInfo objectForKey:@"support"] intValue];
            int scope = [[trdEntendInfo objectForKey:@"scope"] intValue];
            BOOL hasQchat = client & 1,hasQtalk = client & 2, hasSingle = support & 1,hasGroup = support & 2, hasVirtual = support & 4, hasConsult = support & 8, hasConsultServer = support & 16, hasPublicNumber = support & 32, hasNoMerchant = scope & 1,hasMerchant = scope & 2;
            int type = [[trdEntendInfo objectForKey:@"type"] intValue];
            NSString *title = [trdEntendInfo objectForKey:@"title"];
            [__trdExtendInfoDic setObject:trdEntendInfo forKey:trdEntendId];
            if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
                BOOL needShowForMerchant = ((hasNoMerchant &&![[QIMKit sharedInstance] isMerchant])||(hasMerchant &&[[QIMKit sharedInstance] isMerchant]));
                if (hasSingle && QIMTextBarExpandViewTypeSingle & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                if (hasGroup && QIMTextBarExpandViewTypeGroup & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                if (hasConsult && QIMTextBarExpandViewTypeConsult & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                
                if (needShowForMerchant && hasConsultServer && QIMTextBarExpandViewTypeConsultServer & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                if (hasVirtual && QIMTextBarExpandViewTypeRobot & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
            }
            if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
                if (hasSingle && QIMTextBarExpandViewTypeSingle & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                if (hasGroup && QIMTextBarExpandViewTypeGroup & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                if (hasConsult && QIMTextBarExpandViewTypeConsult & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                if (hasConsultServer && QIMTextBarExpandViewTypeConsultServer & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                if (hasVirtual && QIMTextBarExpandViewTypeRobot & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
                
                if (hasPublicNumber && QIMTextBarExpandViewTypePublicNumber & self.type) {
                    [[QIMKit sharedInstance] addMsgTextBarWithTrdInfo:trdEntendInfo];
                }
            }
        }
//    }
    if ([[QIMKit sharedInstance] trdExtendInfo].count <= 0) {
        [self defaultItems];
    }
}

- (void)defaultItems {
    
     [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_pic" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_album"] ForItemId:QIMTextBarExpandViewItem_Photo];
     
     [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_camera" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_camera"] ForItemId:QIMTextBarExpandViewItem_Camera];
    
     if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat & self.type == (QIMTextBarExpandViewTypeConsultServer)) {
     //快捷回复按钮只有在ConsultServer中展示
         [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_quickReply" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_quick_reply"] ForItemId:QIMTextBarExpandViewItem_QuickReply];
     }
     #if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {

         if (self.type & QIMTextBarExpandViewTypeSingle) {
//             [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_videoCall" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_videoCall"] ForItemId:QIMTextBarExpandViewItem_VideoCall];
         }
         if (self.type & QIMTextBarExpandViewTypeGroup) {
//             [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_videoCall" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_videoCall"] ForItemId:QIMTextBarExpandViewItem_VideoCall];
         }
    }
     #endif
    [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_location" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_position"] ForItemId:QIMTextBarExpandViewItem_Location];
    
     if (([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) && (self.type & (QIMTextBarExpandViewTypeNomal | QIMTextBarExpandViewTypeSingle | QIMTextBarExpandViewTypeGroup))) {
     //        [[QIMKit sharedInstance] addMsgTextBarWithImage:@"iconfont-fire" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_burn_after_reading"] ForItemType:QIMTextBarExpandViewItemType_BurnAfterReading pushVC:nil];
     }
     if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
         if (self.type & (QIMTextBarExpandViewTypeConsultServer)) {
         //转移会话按钮只有在ConsultServer中展示
             [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_transfer" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_move_chat"] ForItemId:QIMTextBarExpandViewItem_ChatTransfer];
         }
         [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_sendProduct" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_send_product"] ForItemId:QIMTextBarExpandViewItem_SendProduct];
     }
//    [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_red_pack" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_red_package"] ForItemId:QIMTextBarExpandViewItem_RedPack];
    
     if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
//         [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aa_collection_icon" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_aa"] ForItemId:QIMTextBarExpandViewItem_AACollection];
         [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_share_nameplate" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_share_card"] ForItemId:QIMTextBarExpandViewItem_ShareCard];
     }
    [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_folder" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_file"] ForItemId:QIMTextBarExpandViewItem_MyFiles];

     //ios 的发活动去掉吧，后台都快没了 by wz.wang 2017-12-06 15:42
     if (self.type & QIMTextBarExpandViewTypeGroup) {
         [[QIMKit sharedInstance] addMsgTextBarWithImage:@"aio_icons_group_activity" WithTitle:[NSBundle qim_localizedStringForKey:@"textbar_button_activity"] ForItemId:QIMTextBarExpandViewItem_SendActivity];
     }
}

- (void)displayItems
{
    NSInteger i = 0;
    NSInteger page = 0;
    float  space = (self.width - kItemWidth * 4) / 5;
    
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_mainScrollView];
    }else{
        for (UIView * view in _mainScrollView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    NSArray * items = [[QIMKit sharedInstance] getMsgTextBarButtonInfoList];
    
    for (NSDictionary * itemDic in items) {
        NSString *trId = [itemDic objectForKey:@"trdextendId"];
        UIImageView *locationButton = [[UIImageView alloc] initWithFrame:CGRectMake(page * _mainScrollView.width + (space + kItemWidth) * (i % 4) + space, (i / 4) * (kItemWidth + 10 + 25) + 10, kItemWidth, kItemWidth)];
        NSString *icon = [itemDic objectForKey:@"icon"];
        [locationButton setAccessibilityIdentifier:trId];
        UIImage *defaultIcon = [UIImage imageNamed:@"textbar_common_icon"];
        if (icon.length > 0) {
            [locationButton qim_setImageWithURL:[NSURL URLWithString:[icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:defaultIcon];
        } else {
            NSString *imageName = [itemDic objectForKey:@"ImageName"];
            [locationButton setImage:[UIImage imageNamed:imageName]];
        }
        [locationButton setUserInteractionEnabled:YES];
        [_mainScrollView addSubview:locationButton];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(page * _mainScrollView.width + (space + kItemWidth) * (i % 4) + space - 10, locationButton.bottom + 5, kItemWidth + 20, 20)];
        titleLabel.text = [itemDic objectForKey:@"title"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor blackColor];
        [titleLabel setUserInteractionEnabled:YES];
        [titleLabel setAccessibilityIdentifier:trId];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemBtnHandle:)];
        [locationButton setAccessibilityIdentifier:trId];
        [locationButton addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemBtnHandle:)];
        [titleLabel setAccessibilityIdentifier:trId];
        [titleLabel addGestureRecognizer:tap2];
        [_mainScrollView addSubview:titleLabel];
        page = page + (i + 1) / (2 * 4);
        i = (i + 1) % (2 * 4);
    }
    _mainScrollView.contentSize = CGSizeMake((ceilf((float)(items.count) / 8.0) * _mainScrollView.width), _mainScrollView.height);
}


- (void)itemBtnHandle:(UITapGestureRecognizer *)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UIView *view = (UIView*) tap.view;
    NSString *sendId = [view accessibilityIdentifier];
    NSDictionary *trdDic = [[QIMKit sharedInstance] getExpandItemsForTrdextendId:sendId];
    NSString *trdId = [trdDic objectForKey:@"trdextendId"];
    NSArray *textBarOpenIds = @[QIMTextBarExpandViewItem_Photo, QIMTextBarExpandViewItem_Camera, QIMTextBarExpandViewItem_QuickReply];
    if ([textBarOpenIds containsObject:trdId] && self.delegate && [self.delegate respondsToSelector:@selector(didClickExpandItemForTrdextendId:)]) {
        //这里由TextBar打开
        [self.delegate didClickExpandItemForTrdextendId:trdId];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kExpandViewItemHandleNotification object:trdId];
        });
    }
}

#pragma mark - QIMMsgBaseVCDelegate

-(void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType
{
    
    //Comment by lilulucas.li 10.18
//    [(QIMChatVC *)self.parentVC sendMessage:message WithInfo:info ForMsgType:msgType];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger pageIndex = offsetX / self.width;
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScrollToIndex:)]) {
        
        [self.delegate scrollViewDidScrollToIndex:pageIndex];
    }
}

@end
