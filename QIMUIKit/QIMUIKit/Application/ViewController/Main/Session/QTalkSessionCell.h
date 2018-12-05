//
//  QTalkSessionCell.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 16/7/20.
//
//

#import "QIMCommonUIFramework.h"

@protocol QIMSessionScrollDelegate <NSObject>

- (void)deleteSession:(NSIndexPath *)indexPath;
- (void)stickySession:(NSIndexPath *)indexPath;

@end

@interface QTalkSessionCell : UITableViewCell

@property (nonatomic, weak) id <QIMSessionScrollDelegate> sessionScrollDelegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) NSDictionary *infoDic;

@property (nonatomic, copy) NSString *combineJid;

@property (nonatomic, assign) ChatType chatType;

@property (nonatomic, copy) NSString *bindId;

@property (nonatomic, weak) UITableView *containingTableView;

@property (nonatomic, assign) BOOL hasAtCell;

@property (nonatomic, strong) UITableViewRowAction *deleteBtn;  //右滑删除会话

@property (nonatomic, strong) UITableViewRowAction *stickyBtn;  //右滑置顶会话

@property (nonatomic, assign) int notReadCount;

@property (nonatomic, assign) BOOL firstRefresh;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end

@interface NSMutableArray (SWUtilityButtons)

- (void)addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title;
- (void)addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon;

@end
