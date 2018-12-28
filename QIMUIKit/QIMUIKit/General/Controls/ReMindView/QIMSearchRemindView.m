//
//  QIMSearchRemindView.m
//  QIMUIKit
//
//  Created by lilu on 2018/12/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMSearchRemindView.h"
#import "QIMFastEntrance.h"
#import "QIMCommonCategories.h"
#import "QIMIconInfo.h"
#import "UIImage+QIMIconFont.h"

@interface QIMSearchRemindView ()

@end

@implementation QIMSearchRemindView

- (instancetype)initWithChatId:(NSString *)chatId withRealJid:(NSString *)realjid withChatType:(NSInteger)chatType {
    if (self = [super initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 160, 100, 160, 36)]) {
        self.backgroundColor = [UIColor whiteColor];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(18, 18)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        UIView *searchIconBackView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 26, 26)];
        searchIconBackView.backgroundColor = [UIColor qim_colorWithHex:0x5CC57F];
        searchIconBackView.layer.cornerRadius = 13;
        searchIconBackView.layer.masksToBounds = YES;
        [self addSubview:searchIconBackView];
        
        UIImageView *searchIconView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 21, 21)];
        searchIconView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f407" size:21 color:[UIColor whiteColor]]];
        [searchIconBackView addSubview:searchIconView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchIconBackView.right + 5, 8, 120, 20)];
        [textLabel setText:@"快速搜到你想找的"];
        [textLabel setTextColor:[UIColor qim_colorWithHex:0x212121]];
        [textLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:textLabel];
    }
    return self;
}

@end
