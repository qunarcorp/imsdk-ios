//
//  QTNoteCell.h
//  qunarChatIphone
//
//  Created by lihuaqi on 2017/9/21.
//
//

#import <UIKit/UIKit.h>
@class QIMNoteModel;
@interface QTNoteCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
-(void)refreshCellWithModel:(QIMNoteModel *)model;
@end
