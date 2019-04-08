//
//  QTalkSessionView.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 16/7/20.
//
//

#import "QIMCommonUIFramework.h"
@class QIMMainVC;

@interface QTalkSessionView : UIView

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, assign) BOOL needUpdateNotReadList;

- (instancetype)initWithFrame:(CGRect)frame withRootViewController:(QIMMainVC *)rootVc;

- (void)prepareNotReaderIndexPathList;

- (void)scrollToNotReadMsg;

- (void)sessionViewWillAppear;

- (void)updateOtherPlatFrom:(BOOL)flag;

- (void)updateSessionHeaderViewWithShowNetWorkBar:(BOOL)showNetWorkBar;

- (UIViewController *)sessionViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)sessionViewTitleDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
