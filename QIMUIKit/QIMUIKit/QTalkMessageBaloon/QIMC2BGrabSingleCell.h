//
//  QIMC2BGrabSingleCell.h
//  qunarChatIphone
//
//  Created by QIM on 2017/10/25.
//

@class QIMMsgBaloonBaseCell;

@interface QIMC2BGrabSingleCell : QIMMsgBaloonBaseCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *dealid;
@property (nonatomic, strong) NSString *deadUrl;
@property (nonatomic, strong) NSString *budgetinfo;
@property (nonatomic, strong) NSString *orderTime;
@property (nonatomic, strong) NSString *remarks;
@property (nonatomic, strong) NSString *btnDisplay;
@property (nonatomic, weak) UIViewController *owner;

@property (nonatomic, assign) BOOL deadStatus;

+ (CGFloat)getCellHeight;

- (void)setMessage:(Message *)message;

- (void)refreshUI;

@end
