//
//  QIMGroupNameCell.h
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/16.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMGroupNameCell : UITableViewCell

@property (nonatomic, strong) NSString *name;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end
