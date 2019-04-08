//
//  QIMPGroupSelectionCell.h
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/17.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMPGroupSelectionCell : UITableViewCell

@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *headerUrl;
@property (nonatomic, assign) int  notReadCount;
@property (nonatomic, assign) BOOL onLine;
@property (nonatomic, assign) int  nlevel;


- (void)setStatus:(BOOL)bValue;

- (void)setSelectedEnabled:(BOOL)enabled;

- (void)refrash;

- (void)initSubControls;

@end
