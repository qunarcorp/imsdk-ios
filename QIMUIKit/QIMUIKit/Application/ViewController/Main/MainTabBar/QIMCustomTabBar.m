
//  QIMCustomTabBar.m
//  FlyShow
//
//  Created by XXXX on 14-9-23.
//  Copyright (c) 2014年 Personal. All rights reserved.
//

#import "QIMCustomTabBar.h"
#import "UIImage+ImageEffects.h"

#define kItemButtonPirex        100011
#define kItemViewPirex          101

//默认颜色&高亮颜色
#define kTabBarNormalColor      [UIColor spectralColorDarkBlueColor]
#define kTabBarHighlightedColor [UIColor spectralColorBlueColor]

@interface CustomTabBarButton : UIButton
@property (nonatomic, assign) UILabel *barTitleLabel;
@property (nonatomic, assign) UILabel *badgeNumberLabel;
@end

@implementation CustomTabBarButton

//- (void)setHighlighted:(BOOL)highlighted{
//    [super setHighlighted:highlighted];
//    
//    [self.barTitleLabel setHighlighted:highlighted];
//}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self.barTitleLabel setHighlighted:selected];
}

@end

@interface QIMCustomTabBar(){
    
}

@end

@implementation QIMCustomTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor qim_colorWithHex:0xfafafa alpha:1.0];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:toolbar];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        [lineView setBackgroundColor:[UIColor spectralColorGrayColor]];
        [self addSubview:lineView];
        
        CGFloat buttonWidth = self.width / _itemCount;
        
        for (int i = 0 ; i < _itemCount ; i++ ) {
            
            UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth*i, 2, buttonWidth, self.height)];
            [tapView setBackgroundColor:[UIColor clearColor]];
            [tapView setTag:kItemViewPirex+i];
            [self addSubview:tapView];
            
            UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
            [singleTapGestureRecognizer setNumberOfTapsRequired:1];
            [tapView addGestureRecognizer:singleTapGestureRecognizer];
            
            UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
            [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
            [tapView addGestureRecognizer:doubleTapGestureRecognizer];
            
            UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            longGes.minimumPressDuration = 3.0;
            longGes.allowableMovement = 1000;
            [tapView addGestureRecognizer:longGes];
            
             [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
            CustomTabBarButton *itemButton = [[CustomTabBarButton alloc] initWithFrame:CGRectMake(buttonWidth*i, 2, buttonWidth, self.height)];
            [itemButton setTag:kItemButtonPirex+i];
            [itemButton addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
            [itemButton setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
            [self addSubview:itemButton];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, itemButton.height - 16, itemButton.width, 12)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 4-2]];
//            [label setTextColor:kTabBarNormalColor];
//            [label setHighlightedTextColor:kTabBarHighlightedColor];
            [itemButton setBarTitleLabel:label];
            [itemButton addSubview:label];
            
            
            UILabel *badgeNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake((buttonWidth / 2.0 + 5), 2, 22, 15)];
            [badgeNumberLabel setHidden:YES];
            [badgeNumberLabel.layer setCornerRadius:7];
            [badgeNumberLabel.layer setMasksToBounds:YES];
            [badgeNumberLabel setBackgroundColor:[UIColor redColor]];
            [badgeNumberLabel setTextColor:[UIColor whiteColor]];
            [badgeNumberLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [badgeNumberLabel setTextAlignment:NSTextAlignmentCenter];
            [itemButton setBadgeNumberLabel:badgeNumberLabel];
            [itemButton addSubview:badgeNumberLabel];
            
        }
        _selectedIndex = -1;
    }
    return self;
}

- (id)initWithItemCount:(NSUInteger)count WihtFrame:(CGRect)frame{
    _itemCount = count;
    self = [self initWithFrame:frame];
    if (self) {
        [self setSelectedIndex:0];
    }
    return self;
}

- (void)setBadgeNumber:(NSUInteger)bagdeNumber ByItemIndex:(NSUInteger)index showNumber:(BOOL)showNum{
    if (showNum) {
        [self setBadgeNumber:bagdeNumber ByItemIndex:index];
    }else{
        CustomTabBarButton *itemButton = (CustomTabBarButton *)[self viewWithTag:kItemButtonPirex+index];
        if (bagdeNumber > 0) {
            CGSize size = CGSizeMake(10, 10);
            [itemButton.badgeNumberLabel setWidth:size.width];
            [itemButton.badgeNumberLabel setHeight:size.height];
            [itemButton.badgeNumberLabel.layer setCornerRadius:size.width / 2];
            [itemButton.badgeNumberLabel setHidden:NO];
            [itemButton.badgeNumberLabel setText:@""];
        } else {
            [itemButton.badgeNumberLabel setHidden:YES];
        }
    }
}

- (void)setBadgeNumber:(NSUInteger)bagdeNumber ByItemIndex:(NSUInteger)index{
    CustomTabBarButton *itemButton = (CustomTabBarButton *)[self viewWithTag:kItemButtonPirex+index];
    if (bagdeNumber > 0) {
        
        NSString *countStr;

        if (bagdeNumber > 99) {
            
            countStr = [NSString stringWithFormat:@"99+"];
        } else {
            
            countStr = [NSString stringWithFormat:@"%lu",(unsigned long)bagdeNumber];
        }
        CGSize size = [countStr sizeWithFont:itemButton.badgeNumberLabel.font forWidth:INT32_MAX lineBreakMode:NSLineBreakByCharWrapping];
        CGFloat width = MAX(size.width + 6,itemButton.badgeNumberLabel.height);
        [itemButton.badgeNumberLabel setWidth:width];
        [itemButton.badgeNumberLabel setHidden:NO];
        [itemButton.badgeNumberLabel setText:countStr];
    } else {
        [itemButton.badgeNumberLabel setHidden:YES];
        [itemButton.badgeNumberLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)bagdeNumber]];
    }
}

- (void)setAccessibilityIdentifier:(NSString *)accessibilityIdentifier ByItemIndex:(NSUInteger)index{
    
    CustomTabBarButton *itemButton = (CustomTabBarButton *)[self viewWithTag:kItemButtonPirex+index];    
    itemButton.accessibilityIdentifier = accessibilityIdentifier;
}

- (void)setTitle:(NSString *)title ByItemIndex:(NSUInteger)index{
    
    CustomTabBarButton *itemButton = (CustomTabBarButton *)[self viewWithTag:kItemButtonPirex+index];
    [itemButton.barTitleLabel setText:title];
}

- (void)setNormalTitleColor:(UIColor *)titleColor ByItemIndex:(NSUInteger)index{
    
    CustomTabBarButton *itemButton = (CustomTabBarButton *)[self viewWithTag:kItemButtonPirex+index];
    [itemButton.barTitleLabel setTextColor:titleColor];
}

- (void)setSelectedTitleColor:(UIColor *)titleColor ByItemIndex:(NSUInteger)index{
    
    CustomTabBarButton *itemButton = (CustomTabBarButton *)[self viewWithTag:kItemButtonPirex+index];
    [itemButton.barTitleLabel setHighlightedTextColor:titleColor];
}


- (void)setNormalImage:(UIImage *)image ByItemIndex:(NSUInteger)index{
    
    UIButton *itemButton = (UIButton *)[self viewWithTag:kItemButtonPirex+index];
    [itemButton setImage:image forState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)image ByItemIndex:(NSUInteger)index{
    UIButton *itemButton = (UIButton *)[self viewWithTag:kItemButtonPirex+index];
    [itemButton setImage:image forState:UIControlStateSelected];
    [itemButton setImage:image forState:UIControlStateHighlighted];
}

- (void)setNormalBgImage:(UIImage *)image ByItemIndex:(NSUInteger)index{
    
    UIButton *itemButton = (UIButton *)[self viewWithTag:kItemButtonPirex+index];
    [itemButton setBackgroundImage:image forState:UIControlStateNormal];
    
}

- (void)setSelectedBgImage:(UIImage *)image ByItemIndex:(NSUInteger)index{
    
    UIButton *itemButton = (UIButton *)[self viewWithTag:kItemButtonPirex+index];
    [itemButton setBackgroundImage:image forState:UIControlStateSelected];
    [itemButton setBackgroundImage:image forState:UIControlStateHighlighted];
    
}

- (void)singleTap:(UITapGestureRecognizer *)tap{
    NSInteger index = tap.view.tag-kItemViewPirex;
    if (index == 0) {
        CustomTabBarButton *tabBarButton = (CustomTabBarButton *)[self viewWithTag:index+kItemButtonPirex];
        CGPoint point = tabBarButton.badgeNumberLabel.center;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, point.x-4, point.y);
        CGPathAddLineToPoint(path, NULL, point.x + 4, point.y);
        CGPathAddLineToPoint(path, NULL, point.x - 3, point.y);
        CGPathAddLineToPoint(path, NULL, point.x + 3, point.y);
        CGPathAddLineToPoint(path, NULL, point.x - 2, point.y);
        CGPathAddLineToPoint(path, NULL, point.x + 2, point.y);
        CGPathAddLineToPoint(path, NULL, point.x - 1, point.y);
        CGPathAddLineToPoint(path, NULL, point.x + 1, point.y);
        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        pathAnimation.calculationMode = kCAAnimationPaced;
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.removedOnCompletion = YES;
        pathAnimation.duration = 0.5;
        pathAnimation.repeatCount = 1;
        pathAnimation.path = path;
        CGPathRelease(path);
        pathAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [tabBarButton.badgeNumberLabel.layer removeAllAnimations];
        [tabBarButton.badgeNumberLabel.layer addAnimation:pathAnimation
                                                   forKey:@"moveTheSquare"];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(customTabBar:doubleClickIndex:)]) {
        NSInteger index = tap.view.tag-kItemViewPirex;
        [self.delegate customTabBar:self doubleClickIndex:index];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longGesture {
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(customTabBar:longPressAtIndex:)]) {
            NSInteger index = longGesture.view.tag-kItemViewPirex;
            [self.delegate customTabBar:self longPressAtIndex:index];
        }
    } else {
    }
}

- (void)onItemClick:(UIButton *)button{
    [self setSelectedIndex:button.tag - kItemButtonPirex animated:YES];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated{
//    if (self.selectedIndex == selectedIndex) {
//        return;
//    }
    UIButton *oldButton = (UIButton *)[self viewWithTag:kItemButtonPirex+_selectedIndex];
    [oldButton setSelected:NO];
    [oldButton setUserInteractionEnabled:YES];
    _selectedIndex = selectedIndex;
    UIButton *newButton = (UIButton *)[self viewWithTag:kItemButtonPirex+_selectedIndex];
    [newButton setSelected:YES];
    [newButton setUserInteractionEnabled:NO];
    
    if ([self.delegate respondsToSelector:@selector(customTabBar:didSelectIndex:)]) {
        [self.delegate customTabBar:self didSelectIndex:_selectedIndex];
    }
    
    if (animated) {
        //  动画效果
        
    } else {
        
        
    }
    
}

@end
