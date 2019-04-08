//
//  QIMChatBGImageDisplayCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#import "QIMCommonUIFramework.h"

#define kCellImageCount 3.0

@class QIMChatBGImageDisplayCell;
@protocol QIMChatBGImageDisplayCellDelegate <NSObject>

- (void)imageDisplayCell:(QIMChatBGImageDisplayCell *)cell didSelectedImageAtIndex:(NSInteger )index;

@end

@interface QIMChatBGImageDisplayCell : UITableViewCell

@property (nonatomic, assign)id<QIMChatBGImageDisplayCellDelegate> delegate;

+ (CGSize)getImageSize;

- (void)setImages:(NSArray *)images;

@end
