//
//  QIMNavConfigSettingVC.h
//  qunarChatIphone
//
//  Created by admin on 16/3/29.
//
//

#import "QIMCommonUIFramework.h"

#define NavConfigSettingChanged @"NavConfigSettingChanged"
@interface QIMNavConfigSettingVC : QTalkViewController

- (void)setEditedNavDict:(NSDictionary *)navDict;

- (void)setAddedNavDict:(NSDictionary *)navDict;

@end
