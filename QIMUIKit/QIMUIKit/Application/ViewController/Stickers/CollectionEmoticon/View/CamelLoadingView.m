//
//  CamelLoadingView.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 16/7/11.
//  Copyright © 2016年 Qunar-lu. All rights reserved.
//

#import "CamelLoadingView.h"
#import "YLGIFImage.h"

@interface CamelLoadingView ()

@property (nonatomic, strong) UIImageView *loadingView;

@property (nonatomic, strong) UIImageView *backView;

@property (nonatomic, strong) UIView *maskView;

@end

@implementation CamelLoadingView

- (void)setImage:(UIImage *)image {
    if (image) {
        self.loadingView.image = image;
    }
}

- (UIImageView *)loadingView {
    
    if (!_loadingView) {
        _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, self.width * 0.5, self.width * 0.5)];
        _loadingView.centerX = self.centerX - 5;
        _loadingView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"camel" ofType:@"gif"];
        NSURL *url = [NSURL fileURLWithPath:path];
        _loadingView.image = [UIImage qim_animatedImageWithAnimatedGIFURL:url];
    }
    return _loadingView;
}

- (UIImageView *)backView {
    
    if (!_backView) {
        
        _backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width * 0.7, self.width * 0.7)];
        _backView.center = CGPointMake(self.centerX, self.centerY + 20);
        _backView.image = [UIImage imageNamed:@"background"];
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 12.0;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = NSNotFound;
        [_backView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    return _backView;
}

- (UIView *)maskView {
    
    if (!_maskView) {
        
        CGFloat y = CGRectGetMinY(_backView.frame);
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, y + 30, self.width, self.height)];
        _maskView.backgroundColor = [UIColor whiteColor];
    }
    return _maskView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.backView];
        [self addSubview:self.maskView];
        [self addSubview:self.loadingView];
    }
    return self;
}

@end
