//
//  QIMSwitchAccountView.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/8.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMSwitchAccountViewDelegate <NSObject>

- (void)swicthAccountWithAccount:(NSDictionary *)accountDict;

@end

@interface QIMSwitchAccountView : UIView

- (instancetype)initWithFrame:(CGRect)frame WithAccounts:(NSMutableArray *)accounts;

@property (nonatomic, weak) id <QIMSwitchAccountViewDelegate> delegate;

@end
