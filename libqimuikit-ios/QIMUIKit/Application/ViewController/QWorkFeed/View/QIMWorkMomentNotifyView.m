//
//  QIMWorkMomentNotifyView.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentNotifyView.h"

@interface QIMWorkMomentNotifyView ()

@property (nonatomic, strong) UIView *notifyBgView;

@property (nonatomic, strong) UILabel *unreadCountLabel;

@end

@implementation QIMWorkMomentNotifyView

- (instancetype)initWithNewMsgCount:(NSInteger)msgCount {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 54)];
    if (self) {
        self.backgroundColor = [UIColor qim_colorWithHex:0xF8F8F9];
        
        self.notifyBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 135, 34)];
        self.notifyBgView.backgroundColor = [UIColor whiteColor];
        self.notifyBgView.layer.cornerRadius = 17.0f;
        self.notifyBgView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
        self.notifyBgView.layer.shadowOffset = CGSizeMake(0,1);
        self.notifyBgView.layer.shadowOpacity = 1;
        self.notifyBgView.layer.shadowRadius = 10;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickNotifyView:)];
        [self.notifyBgView addGestureRecognizer:tapGesture];
        
        UIView *remindView = [[UIView alloc] initWithFrame:CGRectMake(15, 14, 6, 6)];
        remindView.backgroundColor = [UIColor qim_colorWithHex:0xFF5C28];
        remindView.layer.cornerRadius = 3.0f;
        remindView.layer.masksToBounds = YES;
        [self.notifyBgView addSubview:remindView];
        
        self.unreadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 10, 75, 14)];
        [self.unreadCountLabel setTextColor:[UIColor qim_colorWithHex:0x00CABE]];
        [self.unreadCountLabel setFont:[UIFont systemFontOfSize:14]];
        [self.unreadCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.notifyBgView addSubview:self.unreadCountLabel];
        
        UIImageView *disclosureIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(self.unreadCountLabel.right + 10, 11, 15, 15)];
        [disclosureIndicatorView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e42e" size:30 color:[UIColor qim_colorWithHex:0xBABABA]]]];
        [self.notifyBgView addSubview:disclosureIndicatorView];
        disclosureIndicatorView.centerY = self.notifyBgView.centerY;
        
        [self addSubview:self.notifyBgView];
        self.notifyBgView.center = self.center;
        self.notifyBgView.centerY = self.centerY;
    }
    return self;
}

- (void)setMsgCount:(NSInteger)msgCount {
    _msgCount = msgCount;
    [self.unreadCountLabel setText:[NSString stringWithFormat:@"%ld条新消息", msgCount]];
}

- (void)clickNotifyView:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickNotifyView)]) {
        [self.delegate didClickNotifyView];
    }
}

@end
