//
//  QIMDaysmatterManager.h
//  qunarChatIphone
//
//  Created by QIM on 2018/3/19.
//

#import "QIMCommonUIFramework.h"

@interface QIMDaysmatterManager : NSObject

+ (instancetype)sharedInstance;

- (void)getDaysmatterFromRemote;

@end
