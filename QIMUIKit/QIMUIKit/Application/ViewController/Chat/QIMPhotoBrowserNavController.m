//
//  QIMPhotoBrowserNavController.m
//  qunarChatIphone
//
//  Created by 平 薛 on 15/6/12.
//
//

#import "QIMPhotoBrowserNavController.h"

@interface QIMPhotoBrowserNavController ()

@end

@implementation QIMPhotoBrowserNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    //    if ([self.topViewController isKindOfClass:[AddMovieViewController class]]) { // 如果是这个 vc 则支持自动旋转
    //        return YES;
    //    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    UIInterfaceOrientation orientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
        {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            orientation = UIInterfaceOrientationPortraitUpsideDown;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            orientation = UIInterfaceOrientationLandscapeLeft;
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
            break;
        default:
        {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
    }
    return orientation;
}

@end
