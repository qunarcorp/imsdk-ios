//
//  QTalkSearchViewManager.m
//  qunarChatIphone
//
//  Created by wangyu.wang on 2016/11/28.
//
//

#import "QTalkSearchRNView.h"
#import "QTalkSearchViewManager.h"
#import "QIMNavPopTransition.h"

@interface QTalkSearchViewManager () <UINavigationControllerDelegate>


@end


@implementation QTalkSearchViewManager


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBack) name:kNotify_RN_QTALK_SEARCH_GO_BACK object:nil];
    
    QTalkSearchRNView *reactView = [[QTalkSearchRNView alloc] initWithFrame:self.view.bounds];
    [reactView setOwnerVC:self];
    
    [reactView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    
    [self.view addSubview:reactView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(setCancelMotion:)]) {
        [(QIMNavController *)self.navigationController setCancelMotion:YES];
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(setCancelMotion:)]) {
        [(QIMNavController *)self.navigationController setCancelMotion:NO];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)goBack{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[self dismissViewControllerAnimated:YES completion:nil];
    self.navigationController.delegate = self;
    [self.navigationController popViewControllerAnimated:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        return (id<UIViewControllerAnimatedTransitioning>)[[QIMNavPopTransition alloc] init];
    }
    //返回nil则使用默认的动画效果
    return nil;
}

- (void)dealloc {
    self.navigationController.delegate = nil;
}

@end
