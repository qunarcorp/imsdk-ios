//
//  QIMBuddyItemCell.h
//  qunarChatIphone
//
//  Created by May on 14/11/20.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMBuddyItemCell : UITableViewCell

@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *headerUrl;
@property (nonatomic, assign) int  notReadCount;
@property (nonatomic, assign) BOOL onLine;
@property (nonatomic, assign) BOOL isParentRoot;
@property (nonatomic, assign) NSInteger nLevel;

-(void)initSubControls;

- (void) refrash;

@end
