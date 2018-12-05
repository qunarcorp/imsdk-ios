//
//  QIMQRCodeViewDisplayController.m
//  qunarChatIphone
//
//  Created by qitmac000301 on 15/4/17.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//
#import "QIMQRCodeViewDisplayController.h"
#import "QRCodeGenerator.h"
#import "QIMContactSelectionViewController.h"
#import "QIMGroupChatVC.h"
#import "QIMChatVC.h"
#import "NSBundle+QIMLibrary.h"

@protocol QCActivityToFriendDelegate <NSObject>
@optional
- (void)performActivity;
@end

@interface QCActivityToFriend : UIActivity
@property (nonatomic, weak) id<QCActivityToFriendDelegate> delegate;
@end
@implementation QCActivityToFriend
+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"QTalk.WebView.ToFriend";
}

- (NSString *)activityTitle {
    return [NSBundle qim_localizedStringForKey:@"common_send_friend"];
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"Action_Share"];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}
- (void) performActivity {
    if ([self.delegate respondsToSelector:@selector(performActivity)]) {
        [self.delegate performActivity];
    }
}
- (void)prepareWithActivityItems:(NSArray *)activityItems {
}
- (UIViewController *)activityViewController{
    return nil;
}
@end

@interface QIMQRCodeViewDisplayController()<QCActivityToFriendDelegate,QIMContactSelectionViewControllerDelegate>{
    UIView *_backView;
    BOOL    _navBarHidden;
}
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@end

@implementation QIMQRCodeViewDisplayController

-(UIImage*)convertViewToImage:(UIView*)v{
    UIGraphicsBeginImageContext(v.bounds.size);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)chatVC:(QIMChatVC *)vc{
    //Comment by lilulucas.li 10.18
//    [vc willSendImageData:UIImageJPEGRepresentation([self convertViewToImage:_backView], 0.8)];
}

- (void)groupChatVC:(QIMGroupChatVC *)vc{
    [vc sendImageData:UIImageJPEGRepresentation([self convertViewToImage:_backView], 0.8)];
}

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC chatVC:(QIMChatVC *)vc{
    //Comment by lilulucas.li 10.18
//    [vc willSendImageData:UIImageJPEGRepresentation([self convertViewToImage:_backView], 0.8)];
}

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC groupChatVC:(QIMGroupChatVC *)vc{ 
    [vc sendImageData:UIImageJPEGRepresentation([self convertViewToImage:_backView], 0.8)];
}

- (void)performActivity{
    QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
    QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
    [controller setDelegate:self];
    [[self navigationController] presentViewController:nav animated:YES completion:^{
    }];
}

- (void)onMoreClick{
    NSMutableArray *items = [NSMutableArray arrayWithObject:[self convertViewToImage:_backView]];
    QCActivityToFriend *toFriend = [[QCActivityToFriend alloc] init];
    [toFriend setDelegate:self];
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[toFriend]];
    [self.activityViewController setExcludedActivityTypes:@[UIActivityTypeMail]];
    typeof(self) __weak weakSelf = self;
    [self.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        weakSelf.activityViewController = nil;
    }];
    [self presentViewController:self.activityViewController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _navBarHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:_navBarHidden animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor qim_colorWithHex:0xf1f1f1 alpha:1];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonicon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(onMoreClick)];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    _backView = [[UIView alloc]initWithFrame:CGRectMake(40, (self.view.height-self.view.frame.size.width - 20)/2.0, self.view.frame.size.width - 80, self.view.frame.size.width - 20)];
    _backView.backgroundColor = [UIColor qim_colorWithHex:0xeaeaea alpha:1];
    [_backView.layer setBorderColor:[UIColor qim_colorWithHex:0xd1d1d1 alpha:1].CGColor];
    [_backView.layer setBorderWidth:0.5];
    [_backView.layer setCornerRadius:5];
    [_backView.layer setMasksToBounds:YES];
    [self.view addSubview:_backView];
    
    UIImageView *QRCodeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, _backView.frame.size.width - 40, _backView.frame.size.width - 40)];
    [_backView addSubview:QRCodeImageView];
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, _backView.height - 60, _backView.width, 60)];
    [infoView setBackgroundColor:[UIColor whiteColor]];
    [_backView addSubview:infoView];
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    [icon.layer setCornerRadius:5];
    [icon.layer setMasksToBounds:YES];
    [infoView addSubview:icon];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 10, icon.top, _backView.frame.size.width - icon.right - 10, 20)];
    nameLabel.font = [UIFont boldSystemFontOfSize:14];
    [nameLabel setTextColor:[UIColor qim_colorWithHex:0x333333 alpha:1]];
    [infoView addSubview:nameLabel];

    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.left, nameLabel.bottom, nameLabel.width, nameLabel.height)];
    infoLabel.font = [UIFont boldSystemFontOfSize:12];
    [infoLabel setTextColor:[UIColor qim_colorWithHex:0x999999 alpha:1]];
    [infoView addSubview:infoLabel];
    
    switch (self.QRtype) {
        case QRCodeType_GroupQR:
        {
            [infoLabel setText:[NSBundle qim_localizedStringForKey:@"qrcode_tips_group"]];
            nameLabel.text = self.name;
            icon.image = [[QIMKit sharedInstance] getGroupImageFromLocalByGroupId:self.jid];
            QRCodeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"qtalk://group?id=%@",self.jid] imageSize:QRCodeImageView.bounds.size.width];
            [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"group_qr_code"]];
        }
            break;
        case QRCodeType_UserQR:
        {
            [infoLabel setText:[NSBundle qim_localizedStringForKey:@"qrcode_tips_user"]];
            nameLabel.text = self.name;
            icon.image = [[QIMImageManager sharedInstance] getUserHeaderImageByUserId:[[QIMKit sharedInstance] getLastJid]];
            QRCodeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"qtalk://user?id=%@",self.jid] imageSize:QRCodeImageView.bounds.size.width];
            [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"myself_tab_qrcode"]];
        }
            break;
        case QRCodeType_RobotQR:
        {
            
            [infoLabel setText:[NSBundle qim_localizedStringForKey:@"qrcode_tips_public_number"]];
            nameLabel.text = self.name;
            NSDictionary *cardDic = [[QIMKit sharedInstance] getPublicNumberCardByJid:[NSString stringWithFormat:@"%@@%@",self.jid,[[QIMKit sharedInstance] getDomain]]];
            NSString *headerSrc = [cardDic objectForKey:@"HeaderSrc"];
            icon.image = [[QIMKit sharedInstance] getPublicNumberHeaderImageByFileName:headerSrc];
            NSString *url = [NSString stringWithFormat:@"qtalk://robot?id=%@&type=robot",self.jid];
            QRCodeImageView.image = [QRCodeGenerator qrImageForString:url imageSize:QRCodeImageView.bounds.size.width];
            [self.navigationItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"qrcode_@_qrcode", @"%@的二维码"),self.name]];
        }
            break;
        case QRCodeType_ClientNav: {
            [infoLabel setText:NSLocalizedString(@"qrcode_tips_client_nav", nil)];
            nameLabel.text = self.name;
            icon.image = [UIImage imageNamed:@"setup_38x38_"];
            NSString *url = [NSString stringWithFormat:@"%@",self.jid];
            QRCodeImageView.image = [QRCodeGenerator qrImageForString:url imageSize:QRCodeImageView.bounds.size.width];
            [self.navigationItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"qrcode_@_qrcode", @"%@的二维码"),self.name]];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)goBack
{
//    [VCController popVCAnimated:YES];
}
@end
