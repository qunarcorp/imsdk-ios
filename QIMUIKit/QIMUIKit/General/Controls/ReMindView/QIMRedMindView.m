//
//  QIMRedMindView.m
//  QIMUIKit
//
//  Created by lilu on 2018/12/17.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMRedMindView.h"

@implementation QIMRedMindView

- (instancetype)initWithBroView:(UIView *)broView withRemindNotificationName:(nonnull NSString *)notificationName {
    UIView *fatherView = broView.superview;
    self = [super initWithFrame:CGRectMake(broView.frame.origin.x + broView.frame.size.width - 8, 9, 5, 5)];
    if (self) {
        self.layer.cornerRadius = 2.5f;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor redColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRemoveRedMindView:) name:notificationName object:nil];
    }
    return self;
}

- (void)updateRemoveRedMindView:(NSNotification *)notify {
    [self removeFromSuperview];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
