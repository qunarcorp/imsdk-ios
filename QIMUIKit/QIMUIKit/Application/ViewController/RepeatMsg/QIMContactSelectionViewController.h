//
//  QIMContactSelectionViewController.h
//  qunarChatIphone
//
//  Created by may on 15/7/7.
//
//

#import "QIMCommonUIFramework.h"

@class QIMGroupChatVC,QIMChatVC;
@class QIMContactSelectionViewController;
@protocol QIMContactSelectionViewControllerDelegate <NSObject>
@optional
- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC groupChatVC:(QIMGroupChatVC *)vc;
- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC chatVC:(QIMChatVC *)vc;

@end

@interface QIMContactSelectionViewController : QTalkViewController
@property (nonatomic, weak) id<QIMContactSelectionViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL ExternalForward;
@property (nonatomic, strong) Message *message;
@property (nonatomic, strong) NSArray *messageList;

@property (nonatomic, assign) BOOL      isTransfer;//是否是会话转移

- (NSDictionary *)getSelectInfoDic;

@end
