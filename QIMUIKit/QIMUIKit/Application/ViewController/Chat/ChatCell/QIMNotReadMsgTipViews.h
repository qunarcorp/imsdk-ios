//
//  QIMNotReadMsgTipViews.h
//  qunarChatIphone
//
//  Created by admin on 16/5/6.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMNotReadMsgTipViewsDelegate <NSObject>
@optional
- (void)moveToFirstNotReadMsg;
@end

@interface QIMNotReadMsgTipViews : UIView
@property (nonatomic, weak) id<QIMNotReadMsgTipViewsDelegate> notReadMsgDelegate;
- (instancetype)initWithNotReadCount:(int)notReadCount;
@end
