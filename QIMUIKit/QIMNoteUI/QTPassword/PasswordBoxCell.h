//
//  PasswordBoxCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/19.
//
//

#import <UIKit/UIKit.h>

@class QIMNoteModel;

@interface PasswordBoxCell : UITableViewCell

- (void)setQIMNoteModel:(QIMNoteModel *)model;

@property (nonatomic, assign) BOOL isSelect; //是否为可选的

- (void)setCellSelected:(BOOL)selected;

- (BOOL)isCellSelected;


@end
