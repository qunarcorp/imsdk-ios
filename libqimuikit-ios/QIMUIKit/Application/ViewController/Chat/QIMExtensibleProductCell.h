//
//  QIMExtensibleProductCell.h
//  qunarChatIphone
//
//  Created by chenjie on 16/7/13.
//
//

#import "QIMCommonUIFramework.h"

@class QIMMsgBaloonBaseCell;
@interface QIMExtensibleProductCell : QIMMsgBaloonBaseCell

@property (nonatomic, strong) UIViewController *owner;

+ (float)getCellHeightForProductInfo:(NSString *)infoStr;

- (void)setProDcutInfoDic:(NSDictionary *)infoDic;

- (void)refreshUI;

@end
