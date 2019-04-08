//
//  QIMBusiNoticeMemberCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/13.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMBusiNoticeMemberCell : UITableViewCell

@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *headerUrl;
@property (nonatomic, assign) int  notReadCount;
@property (nonatomic, assign) BOOL onLine;
@property (nonatomic, assign) int  nlevel;


-(void) setStatus:(BOOL)bValue;

- (void) refrash;

//- (void) setExpanded:(BOOL)flag;

-(void)initSubControls;

@end
