//
//  QIMWorkMomentUserIdentityCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/11.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentUserIdentityCell.h"

@interface QIMWorkMomentUserIdentityCell ()

@end

@implementation QIMWorkMomentUserIdentityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.layer.cornerRadius = 10.0f;
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setUserIdentitySelected:(BOOL)selected {
    if (selected == YES) {
        [self.imageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:21 color:[UIColor qim_colorWithHex:0x00CABE]]]];
    } else {
        [self.imageView setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e337" size:21 color:[UIColor qim_colorWithHex:0xE4E4E4]]]];
    }
}

@end
