//
//  QIMPublicNumberNoticeCell.h
//  qunarChatIphone
//
//  Created by admin on 15/11/4.
//
//

#import "QIMCommonUIFramework.h"

@protocol PNNoticeCellDelegate <NSObject>
@optional
- (void)openWebUrl:(NSString *)url;
@end
@interface QIMPublicNumberNoticeCell : UITableViewCell
@property (nonatomic, strong) NSString *content;
@property (nonatomic, weak) id<PNNoticeCellDelegate> delegate;
+ (CGFloat)getCellHeightByContent:(NSString *)content;
- (void)refreshUI;
@end
