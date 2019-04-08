//
//  QIMQRCodeCell.h
//  qunarChatIphone
//
//  Created by qitmac000301 on 15/4/17.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMQRCodeCell : UITableViewCell
@property (nonatomic, retain) NSString *Detail;
+ (CGFloat)getCellHeight;

- (void)refreshUI;
@end
