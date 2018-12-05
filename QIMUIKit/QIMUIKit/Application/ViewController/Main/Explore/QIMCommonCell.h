//
//  QIMCommonCell.h
//  qunarChatIphone
//
//  Created by admin on 15/8/21.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMCommonCell : UITableViewCell
@property (nonatomic, strong) UIImage   *iconImage;
@property (nonatomic, strong) NSString  *title;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, assign) BOOL hasNotRead;
+ (CGFloat)getCellHeight;
- (void)refeshUI;

- (void)setHasNotRead:(BOOL)hasNotRead;
@end
