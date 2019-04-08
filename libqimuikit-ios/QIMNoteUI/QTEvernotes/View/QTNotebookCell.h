//
//  QTNotebookCell.h
//  qunarChatIphone
//
//  Created by lihuaqi on 2017/9/21.
//
//

#import <UIKit/UIKit.h>
@class QIMNoteModel;
@interface QTNotebookCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
-(void)refreshCellWithModel:(QIMNoteModel *)model;
@end
