//
//  QIMCustomPopManager.m
//  QIMUIVendorKit
//
//  Created by 李露 on 11/7/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMCustomPopManager.h"
#import "QIMCustomPresentationController.h"

@implementation QIMCustomPopManager

+ (void)showPopVC:(UIViewController *)popVc withRootVC:(UIViewController *)rootVc {
    // For presentations which will use a custom presentation controllerd,
    // it is possible for that presentation controller to also be the
    // transitioningDelegate.  This avoids introducing another object
    // or implementing <UIViewControllerTransitioningDelegate> in the
    // source view controller.
    //
    // transitioningDelegate does not hold a strong reference to its
    // destination object.  To prevent presentationController from being
    // released prior to calling -presentViewController:animated:completion:
    // the NS_VALID_UNTIL_END_OF_SCOPE attribute is appended to the declaration.
    QIMCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    
    presentationController = [[QIMCustomPresentationController alloc] initWithPresentedViewController:popVc presentingViewController:rootVc];
    
    popVc.transitioningDelegate = presentationController;
    [rootVc presentViewController:popVc animated:YES completion:nil];
}

@end
