//
//  QIMBusiNoticeTitleCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/13.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMBusiNoticeTitleCell : UITableViewCell

@property (nonatomic, copy) NSString *jid;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *headerUrl;
@property (nonatomic, assign) int  notReadCount;
@property (nonatomic, assign) BOOL onLine;
@property (nonatomic, assign) BOOL isParentRoot;
@property (nonatomic, assign) int  nLevel;
@property (nonatomic, assign) BOOL isSelected;

-(void) initSubControls;
- (void) refresh;
- (void) setExpanded:(BOOL)flag;
@end
