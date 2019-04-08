//
//  QIMHistoryMsgListViewController.h
//  qunarChatIphone
//
//  Created by chenjie on 16/1/7.
//
//

#import "QIMCommonUIFramework.h"

@class QIMHistoryMsgListViewController;

@protocol QIMHistoryMsgListViewControllerDelegate <NSObject>

- (void)QIMHistoryMsgListViewController:(QIMHistoryMsgListViewController *)vc didSelectedText:(NSString *)text;

@end

@interface QIMHistoryMsgListViewController : QTalkViewController

@property (nonatomic,assign) id <QIMHistoryMsgListViewControllerDelegate> delegate;

@end
