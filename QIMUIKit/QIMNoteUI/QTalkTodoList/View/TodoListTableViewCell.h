//
//  TodoListTableViewCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/31.
//
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class QIMNoteModel;
@interface TodoListTableViewCell : MGSwipeTableCell

- (void)setTodoListModel:(QIMNoteModel *)model;

@property (nonatomic, assign) BOOL unFinished;
@property (nonatomic, assign) BOOL hasOutOfDate;
@property (nonatomic, assign) BOOL hasCompleted;

- (void)refreshUI;

@end
