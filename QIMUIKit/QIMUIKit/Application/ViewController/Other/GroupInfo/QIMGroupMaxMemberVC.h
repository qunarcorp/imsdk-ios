//
//  QIMGroupMaxMemberVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMGroupMaxMemberVCDelegate <NSObject>
@optional
- (void)setGroupMaxMember:(NSString *)maxMember;
@end
@interface QIMGroupMaxMemberVC : QTalkViewController
@property (nonatomic, weak) id<QIMGroupMaxMemberVCDelegate> delegate;
@property (nonatomic, strong) NSString *maxMember;
@end
