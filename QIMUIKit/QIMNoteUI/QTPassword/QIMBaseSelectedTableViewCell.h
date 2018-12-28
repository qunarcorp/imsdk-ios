//
//  QIMBaseSelectedTableViewCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/20.
//
//

#import <UIKit/UIKit.h>

@interface QIMBaseSelectedTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *selectBtn;

@property (nonatomic, assign) BOOL isSelect; //是否为可选的

- (void)setCellSelected:(BOOL)selected;

- (BOOL)isCellSelected;

@end
