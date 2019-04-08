//
//  QIMWorkMomentPushCell.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/6.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentPushCell.h"

@interface QIMWorkMomentPushCell ()

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation QIMWorkMomentPushCell

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame) - 5 - 18, 5, 18, 18);
        _deleteBtn.layer.cornerRadius = 9;
        _deleteBtn.layer.masksToBounds = YES;
        [_deleteBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e33c" size:18 color:[UIColor qim_colorWithHex:0x000000 alpha:0.5]]] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(removePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (void)setCanDelete:(BOOL)canDelete {
    if (canDelete == NO) {
        self.deleteBtn.hidden = YES;
    } else {
        self.deleteBtn.hidden = NO;
        [self.contentView addSubview:self.deleteBtn];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
        self.canDelete = YES;
    }
    return self;
}

- (void)removePhoto:(id)sender {
    if (self.dDelegate && [self.dDelegate respondsToSelector:@selector(removeSelectPhoto:)]) {
        [self.dDelegate removeSelectPhoto:self];
    }
}

@end
