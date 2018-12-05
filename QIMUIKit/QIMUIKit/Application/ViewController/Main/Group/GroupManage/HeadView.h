
#import "QIMCommonUIFramework.h"
@class FriendGroup;

@protocol HeadViewDelegate <NSObject>

@optional
- (void)clickHeadViewWithSection:(NSInteger) secion;

@end

@interface HeadView : UITableViewHeaderFooterView

@property (nonatomic, strong) FriendGroup *friendGroup;

@property (nonatomic, assign) id<HeadViewDelegate> delegate;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) BOOL isOpened;

+ (instancetype)headViewWithTableView:(UITableView *)tableView;

- (void) setTitle:(NSString *) title online:(int) online count:(int) count;

@end
