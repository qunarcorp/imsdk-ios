//
//  QIMEmotionSpirits.h
//  qunarChatIphone
//
//  Created by admin on 15/8/24.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMEmotionSpirits : NSObject
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) int dataCount;
+ (QIMEmotionSpirits *)sharedInstance;

- (void)playQIMEmotionSpiritsWithMessage:(NSString *)message;

@end
