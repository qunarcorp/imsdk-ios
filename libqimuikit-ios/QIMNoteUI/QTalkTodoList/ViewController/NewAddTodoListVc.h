//
//  NewAddTodoListVc.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/27.
//
//

#import <UIKit/UIKit.h>
#import "QIMNoteModel.h"

@interface NewAddTodoListVc : UIViewController

- (void)setEdited:(BOOL)edited;

- (void)setTodoListModel:(QIMNoteModel *)model;

@end
