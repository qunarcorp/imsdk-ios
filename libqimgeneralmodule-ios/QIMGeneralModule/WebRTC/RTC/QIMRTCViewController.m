//
//  RTCViewController.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/5/23.
//
//

#import "QIMRTCViewController.h"
#import "QIMRTCSingleView.h"

@interface QIMRTCViewController ()

@end

@implementation QIMRTCViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
