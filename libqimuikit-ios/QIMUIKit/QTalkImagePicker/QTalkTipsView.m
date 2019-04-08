//
//  QTalkTipsView.m
//  qunarChatIphone
//
//  Created by admin on 15/8/19.
//
//

#import "QTalkTipsView.h"

@implementation QTalkTipsView{
    
    UIImageView *_iconImageView;
    UILabel *_titleLabel;

}

+ (void)showTips:(NSString *)tips InView:(UIView *)view{
    QTalkTipsView *tipsView = [[QTalkTipsView alloc] initWithFrame:CGRectMake(0, 0, 240, 110)];
    [tipsView setCenter:CGPointMake(view.width / 2.0, view.height / 2.0 - 64)];
    [tipsView showTips:tips];
    [view addSubview:tipsView];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.85]];
        
        [self.layer setCornerRadius:10];
        
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_failed"]];
        [_iconImageView setOrigin:CGPointMake((self.width - _iconImageView.width) / 2.0,10)];
        [self addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _iconImageView.bottom+5, self.width - 20, self.height - _iconImageView.bottom - 5 - 10)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

- (void)showTips:(NSString *)tips{
    
    [_titleLabel setText:tips];
    
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1];
    
}

- (void)dismiss{
    [self removeFromSuperview];
}

- (void)dealloc{
    
}

@end
