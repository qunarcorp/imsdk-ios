//
//  QIMGroupViewCell.h
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/10.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMGroupViewCell : UITableViewCell

@property (nonatomic, copy) NSString * groupID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *headerUrl;
@property (nonatomic, assign) int  notReadCount;
@property (nonatomic, assign) BOOL onLine;

+ (float)getCellHeightForGroupName:(NSString *)groupName;
- (void) refresh;
@end
