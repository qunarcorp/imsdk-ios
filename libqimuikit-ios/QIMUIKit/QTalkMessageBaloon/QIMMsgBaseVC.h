//
//  QIMMsgBaseVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMMsgBaseVCDelegate <NSObject>
@optional
- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType;
@end

@interface QIMMsgBaseVC : QTalkViewController
@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, assign) id<QIMMsgBaseVCDelegate> delegate;
@end
