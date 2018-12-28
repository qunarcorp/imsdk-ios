//
//  PasswordCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/11.
//
//

#import <UIKit/UIKit.h>
#import "QIMBaseSelectedTableViewCell.h"

@class QIMNoteModel;
@interface PasswordCell : UITableViewCell

- (void)setQIMNoteModel:(QIMNoteModel *)model;

+ (CGFloat)getCellHeight;

@property (nonatomic, assign) BOOL isSelect; //是否为可选的

- (void)setCellSelected:(BOOL)selected;

- (BOOL)isCellSelected;


@end
