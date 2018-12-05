//
//  QIMNavPushTransition.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/12/6.
//
//

#import "QIMNavPushTransition.h"

@interface QIMNavPushTransition () <UIViewControllerAnimatedTransitioning>
@property(nonatomic,strong) id<UIViewControllerContextTransitioning>transitionContext;
@end

@implementation QIMNavPushTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.45f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.backgroundColor = [UIColor qtalkTableDefaultColor];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.backgroundColor = [UIColor qtalkTableDefaultColor];
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [UIColor qtalkTableDefaultColor];
    [containerView addSubview:fromVC.view];
    [containerView addSubview:toVC.view];
    
    //动画效果
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);
    [UIView animateWithDuration:duration animations:^{
        toVC.view.frame = finalFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    //如果取消了就设置为NO，反之，设置为YES。如果添加了动画，这句代码在动画结束之后再调用
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    //去除mask
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
}

@end
