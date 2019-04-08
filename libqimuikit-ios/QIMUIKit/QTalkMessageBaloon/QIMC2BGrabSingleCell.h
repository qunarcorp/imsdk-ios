//
//  QIMC2BGrabSingleCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/10/25.
//

@class QIMMsgBaloonBaseCell;

@interface QIMC2BGrabSingleCell : QIMMsgBaloonBaseCell

//NSDictionary *dict = @{@"title":@"[抢单] 北京——三亚 2人 2017-09-24 出行", @"dealid":@"123456", @"deadUrl":@"https://qt.qunar.com/sharemsg/index.php", @"detail":@{@"budgetinfo": @"3422元-3444元",@"OrderTime": @"2017-09-21 14:20:31", @"Remarks":@"希望直飞 不需要中转"}};
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
