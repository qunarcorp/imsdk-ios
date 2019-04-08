//
//  QIMPublicNumberCardVC.h
//  qunarChatIphone
//
//  Created by admin on 15/8/27.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMPublicNumberCardVC : QTalkViewController

@property (nonatomic, strong) NSString *jid;

@property (nonatomic, strong) NSString *publicNumberId;

@property (nonatomic, assign) BOOL notConcern; //是否未关注  YES 未关注  NO 已关注

@property (nonatomic, assign) BOOL fromChatVC;

@property (nonatomic, strong) NSDictionary *publicRobotDic;

@end
