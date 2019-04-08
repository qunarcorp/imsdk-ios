//
//  QIMRTCHeaderView.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/23.
//
//

#import "QIMRTCHeaderView.h"
#import "QIMKitPublicHeader.h"
#import "UIView+QIMExtension.h"

@interface QIMRTCHeaderView () {
    NSString *_userId;
    NSString *_userName;
}

@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UILabel    *nameLabel;

@end

static CGFloat kImageScale = 0.80f;

@implementation QIMRTCHeaderView

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * kImageScale)];
        _headerView.image = [self getHeaderImage];
        _headerView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _headerView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, CGRectGetWidth(self.frame), (1 - kImageScale) *CGRectGetHeight(self.frame))];
        _nameLabel.text = [self getUserName];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (instancetype)initWithinitWithFrame:(CGRect)frame userId:(NSString *)userId {
    self = [super initWithFrame:frame];
    if (self) {
        _userId = userId;
        self.userInteractionEnabled = YES;
        [self addSubview:self.headerView];
        [self addSubview:self.nameLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserHeaderView)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (NSString *)getUserName {
    
    NSString *name = nil;
    NSDictionary * userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:_userId];
    //备注
    NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:userInfo[@"XmppId"]];
    if (remarkName) {
        
        name = remarkName;
    } else {
        if (userInfo[@"Name"]) {
            name = userInfo[@"Name"];
        } else {
            name = _userId;
        }
    }
    return name;
}

- (UIImage *)getHeaderImage {
    NSData *imageData = [QIMKit defaultUserHeaderImage];
    return [UIImage imageWithData:imageData];
}


- (void)layoutSubviews {

}

- (void)clickUserHeaderView {
    if (self.rtcHeaderViewDidClickDelegate && [self.rtcHeaderViewDidClickDelegate respondsToSelector:@selector(didClickUserQIMRTCHeaderViewWithTag:)]) {
        [self.rtcHeaderViewDidClickDelegate didClickUserQIMRTCHeaderViewWithTag:self.tag];
    }
}

@end
