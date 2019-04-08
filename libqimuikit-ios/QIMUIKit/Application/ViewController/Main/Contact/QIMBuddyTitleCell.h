//
//  QIMBuddyTitleCell.h
//  qunarChatIphone
//
//  Created by wangshihai on 15/1/4.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMBuddyTitleCell : UITableViewCell

@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *headerUrl;
@property (nonatomic, assign) int  notReadCount;
@property (nonatomic, assign) BOOL onLine;
@property (nonatomic, assign) BOOL isParentRoot;
@property (nonatomic, assign) int  nLevel;

-(void) initSubControls;

- (void) refresh;

- (void) setExpanded:(BOOL)flag;
@end
