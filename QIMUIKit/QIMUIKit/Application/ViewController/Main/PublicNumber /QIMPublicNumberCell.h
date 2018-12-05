//
//  QIMPublicNumberCell.h
//  qunarChatIphone
//
//  Created by admin on 15/8/26.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMPublicNumberCell : UITableViewCell
@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *publicNumberId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *headerSrc;
@property (nonatomic, assign) PublicNumberMsgType msgType;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) long long msgDateTime;
+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end
