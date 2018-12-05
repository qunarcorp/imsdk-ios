//
//  SessionCell.h
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/15.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface SessionCell : UITableViewCell
@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak)  NSDictionary *infoDic;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL hasAtCell;
@property (nonatomic, assign) BOOL isSystem;
+ (CGFloat)getCellHeight;
- (void)refreshUI;
@end
