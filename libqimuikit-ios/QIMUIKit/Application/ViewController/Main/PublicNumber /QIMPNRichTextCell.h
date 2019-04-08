//
//  QIMPNRichTextCell.h
//  qunarChatIphone
//
//  Created by admin on 15/9/6.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMPNRichTextCellDelegate <NSObject>
@optional
- (void)openWebUrl:(NSString *)url;
@end

@interface QIMPNRichTextCell : UITableViewCell
@property (nonatomic, weak) id<QIMPNRichTextCellDelegate> delegate;
@property (nonatomic, strong) NSString *content;

+ (CGFloat)getCellHeightByContent:(NSString *)content;

- (void)refreshUI;

@end
