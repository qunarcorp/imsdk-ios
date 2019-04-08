//
//  QIMGroupPassworVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMGroupPassworVCDelegate <NSObject>
@optional
- (void)setGroupPassword:(NSString *)password;
@end
@interface QIMGroupPassworVC : QTalkViewController
@property (nonatomic, weak) id<QIMGroupPassworVCDelegate> delegate;
@property (nonatomic, strong) NSString *password;
@end
