//
//  ShareLocationUserImageView.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/28.
//
//

#define kUserHeadBgWidth     63.0f
#define kUserHeadWidth       40.0f
#define kUserLocationWith    20.0f
#define kUserLoactionDirectionWidth  18.0f

#import "ShareLocationUserImageView.h"

@interface ShareLocationUserImageView()
{
    UIImageView         * _userHeadImgView;
    UIImageView         * _userHeadBgImgView;
    UIView              * _userLctBgView;
    UIImageView         * _userLctImgView;
    UIImageView         * _userLctDrctImgView;
    
    NSString            * _userId;
}
@end

@implementation ShareLocationUserImageView

-(instancetype)initWithUserId:(NSString *)userId{
    if (self = [super initWithFrame:CGRectMake(- kUserHeadBgWidth / 2, - kUserHeadBgWidth - kUserLoactionDirectionWidth / 2 - kUserLocationWith / 2, kUserHeadBgWidth, kUserHeadBgWidth + kUserLoactionDirectionWidth / 2 + kUserLocationWith)]) {
        self.clipsToBounds = NO;
        _userId = userId;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    if (_userHeadBgImgView == nil) {
        _userHeadBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kUserHeadBgWidth, kUserHeadBgWidth)];
        _userHeadBgImgView.image = [UIImage imageNamed:@"locationSharing_Member_bg"];
        [self addSubview:_userHeadBgImgView];
    }
    if (_userHeadImgView == nil) {
        _userHeadImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kUserHeadWidth, kUserHeadWidth)];
        _userHeadImgView.center = CGPointMake(kUserHeadBgWidth / 2 - 1, kUserHeadBgWidth / 2 - 3.5);
        _userHeadImgView.layer.cornerRadius = kUserHeadWidth / 2;
        _userHeadImgView.clipsToBounds = YES;
//        _userHeadImgView.image = [[QIMKit sharedInstance] getUserHeaderImageByUserId:_userId];
        [_userHeadImgView qim_setImageWithJid:_userId];
        [_userHeadBgImgView addSubview:_userHeadImgView];
    }
    
    if (_userLctBgView == nil) {
        _userLctBgView = [[UIView alloc] initWithFrame:CGRectMake((self.width - kUserLocationWith) / 2, self.height - kUserLocationWith - kUserLoactionDirectionWidth / 2, kUserLocationWith, kUserLocationWith + kUserLoactionDirectionWidth / 2)];
        _userLctBgView.layer.anchorPoint = CGPointMake(0.5, (kUserLoactionDirectionWidth / 2 + kUserLocationWith / 2) / _userLctBgView.height);
        [self addSubview:_userLctBgView];
    }
    
    if (_userLctImgView == nil) {
        _userLctImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _userLctBgView.height - kUserLocationWith, kUserLocationWith, kUserLocationWith)];
        if ([_userId isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
            _userLctImgView.image = [UIImage imageNamed:@"locationSharing_Icon_MySelf"];
        }else{
            _userLctImgView.image = [UIImage imageNamed:@"locationSharing_Icon_Friend"];
        }
        [_userLctBgView addSubview:_userLctImgView];
    }
    
    if (_userLctDrctImgView == nil) {
        _userLctDrctImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kUserLocationWith - kUserLoactionDirectionWidth) / 2, 0, kUserLoactionDirectionWidth, kUserLoactionDirectionWidth)];
        if ([_userId isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
            _userLctDrctImgView.image = [UIImage imageNamed:@"locationSharing_Icon_Myself_Heading"];
        }else{
            _userLctDrctImgView.image = [UIImage imageNamed:@"locationSharing_Icon_Friend_Heading"];
        }
        [_userLctBgView insertSubview:_userLctDrctImgView aboveSubview:_userLctImgView];
    }
    
}

- (void)updateDirectionTo:(double)degrees{
    //0 ~ 359.9
    double angle = degrees * (M_PI / 180.0);
    float   redius = kUserLocationWith / 2;
    [UIView animateWithDuration:.3 animations:^{
//        _userLctDrctImgView.center = CGPointMake(self.width / 2 + redius * sinf(angle), self.height - kUserLocationWith / 2 - redius * cosf(angle));
        _userLctBgView.transform = CGAffineTransformMakeRotation(angle);
    }];
}

@end
