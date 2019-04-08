//
//  QIMFileManagerCell.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/24.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMFileManagerCell : UITableViewCell

- (void)setCellMessage:(Message *)message;

@property (nonatomic,assign) BOOL isSelect;//是否是可选的

- (void)setCellSelected : (BOOL)selected;
- (BOOL)isCellSelected;

@end
