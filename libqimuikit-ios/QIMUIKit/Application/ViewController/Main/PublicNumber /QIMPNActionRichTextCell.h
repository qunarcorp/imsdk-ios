//
//  QIMPNActionRichTextCell.h
//  qunarChatIphone
//
//  Created by admin on 15/9/6.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMPNActionRichTextCellDelegate <NSObject>
@optional
- (void)openWebUrl:(NSString *)url;
@end

@interface QIMPNActionRichTextCell : UITableViewCell
@property (nonatomic, weak) id<QIMPNActionRichTextCellDelegate> delegate;
@property (nonatomic, strong) NSString *content;

+ (CGFloat)getCellHeightByContent:(NSString *)content;

- (void)refreshUI;

@end
