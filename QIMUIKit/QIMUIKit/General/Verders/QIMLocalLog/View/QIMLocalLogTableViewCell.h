//
//  QIMLocalLogTableViewCell.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/10.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMLocalLogTableViewCell : UITableViewCell

- (void)setLogFileDict:(NSDictionary *)logFileDict;

@property (nonatomic, assign) BOOL isSelect; //是否为可选的

- (void)setCellSelected:(BOOL)selected;

- (BOOL)isCellSelected;

@end
