//
//  QIMNavPopTransition.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/12/6.
//
//

#import "QIMNavPopTransition.h"

@interface QIMNavPopTransition () <UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) id <UIViewControllerAnimatedTransitioning> transitionContext;

@end

@implementation QIMNavPopTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.backgroundColor = [UIColor qtalkTableDefaultColor];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.backgroundColor = [UIColor qtalkTableDefaultColor];
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [UIColor qtalkTableDefaultColor];
    [containerView addSubview:toVC.view];
    [containerView addSubview:fromVC.view];
    
    //动画效果
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    CGRect fromInitialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect toFinalFrame = [transitionContext finalFrameForViewController:toVC];
    fromVC.view.frame = fromInitialFrame;
    toVC.view.frame = toFinalFrame;
    [UIView animateWithDuration:duration animations:^{
        CGRect finalFrame = CGRectOffset(fromInitialFrame, 0, screenBounds.size.height);
        fromVC.view.frame = finalFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    //如果取消了就设置为NO，反之，设置为YES。如果添加了动画，这句代码在动画结束之后再调用
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}

@end
