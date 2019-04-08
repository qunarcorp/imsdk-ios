//
//  QIMOpenPlatformCell.h
//  qunarChatIphone
//
//  Created by admin on 16/4/18.
//
//

#import "QIMCommonUIFramework.h"

@class QIMOpenPlatformCell;

@protocol QIMOpenPlatformCellDelegate <NSObject>
@optional
- (void)QIMOpenPlatformCellClick:(QIMOpenPlatformCell *)openPlatformCel;
@end

@interface QIMOpenPlatformCell : UITableViewCell
//@property (nonatomic, strong) NSString *tagStr;
//@property (nonatomic, strong) NSString *content;
//@property (nonatomic, assign) long long msgTime;
//@property (nonatomic, assign) NSString *linkUrl;
@property (nonatomic, strong) Message *message;
@property (nonatomic, weak) id<QIMOpenPlatformCellDelegate> delegate;
+ (CGFloat)getCellHeightWithMessage:(Message *)message;
- (void)refreshUI;
@end
