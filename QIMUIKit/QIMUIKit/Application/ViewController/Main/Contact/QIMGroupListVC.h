//
//  QIMGroupListVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/3.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMGroupListVCDelegate <NSObject>
@optional
- (void)selectGroupWithJid:(NSString *)jid;
@end
@interface QIMGroupListVC : QTalkViewController
@property (nonatomic, weak) id<QIMGroupListVCDelegate> delegate;
@end
