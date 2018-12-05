//
//  QIMNavBar.m
//  qunarChatIphone
//
//  Created by chenjie on 15/11/17.
//
//

#import "QIMNavBar.h"

#define kItemWidth      44

@interface QIMNavBar (){
    UIView              * _bgView;
    UILabel             * _titleView;
}

@end

@implementation QIMNavBar


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setNavBarBackgroundColor:(UIColor *)bgColor
{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        [self insertSubview:_bgView atIndex:0];
    }
    _bgView.backgroundColor = bgColor;
}

- (void)setNavBarLeftItem:(UIView *)item
{
    if (item) {
        [self setNavBarLeftItems:@[item]];
    }
}

- (void)setNavBarLeftItems:(NSArray *)items
{
    float xP = 0.0f;
    for (UIView * item in items) {
        item.frame = CGRectMake(xP, self.height - kItemWidth, kItemWidth, kItemWidth);
        xP += kItemWidth;
        [self addSubview:item];
    }
}

- (void)setNavBarRightItem:(UIView *)item
{
    if (item) {
        [self setNavBarRightItems:@[item]];
    }
}

- (void)setNavBarRightItems:(NSArray *)items
{
    float xP = self.width - kItemWidth;
    for (UIView * item in items) {
        item.frame = CGRectMake(xP, self.height - kItemWidth, kItemWidth, kItemWidth);
        xP -= kItemWidth;
        [self addSubview:item];
    }
}

- (void)setNavBarTitle:(NSString *)title
{
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - kItemWidth, self.width, kItemWidth)];
        _titleView.backgroundColor = [UIColor clearColor];
        [self insertSubview:_titleView atIndex:self.subviews.count >= 1 ? 1 : 0];
    }
    _titleView.text = title;
}

- (void)setNavBarTitleViewFont:(UIFont *)font
{
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - kItemWidth, self.width, kItemWidth)];
        _titleView.backgroundColor = [UIColor clearColor];
        [self insertSubview:_titleView atIndex:_bgView ? 1 : 0];
    }
    _titleView.font = font;
}

- (void)setNavBarTitleColor:(UIColor *)titleColor
{
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - kItemWidth, self.width, kItemWidth)];
        _titleView.backgroundColor = [UIColor clearColor];
        [self insertSubview:_titleView atIndex:self.subviews.count >= 1 ? 1 : 0];
    }
    _titleView.textColor = titleColor;
}

- (void)setNavBarBackgroundView:(UIView *)bgView
{
    _bgView = bgView;
    [self insertSubview:_bgView atIndex:0];
}

- (void)setNavBarBackgroundViewAlpha:(CGFloat)alpha
{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        [self insertSubview:_bgView atIndex:0];
    }
    _bgView.alpha = alpha;
}


@end
