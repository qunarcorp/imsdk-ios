//
//  QIMNavController.h
//  qunarChatIphone
//
//  Created by xueping on 15/6/29.
//
//

#import <UIKit/UIKit.h>

@interface UINavigationController(QTalk)
//- (void)popToViewControllor:(UIViewController *)popViewController ThenPush:(UIViewController *)toViewController animated:(BOOL)animated;
- (void)popToRootVCThenPush:(UIViewController *)toViewController animated:(BOOL)animated;
@end

@interface QIMNavController : UINavigationController

@property (nonatomic, assign) BOOL cancelMotion;

@end

@interface QTalkViewController : UIViewController

- (void)selfPopedViewController;

@end
