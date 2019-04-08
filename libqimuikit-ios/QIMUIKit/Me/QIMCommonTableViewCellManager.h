//
//  QIMCommonTableViewCellManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "QIMCommonUIFramework.h"

#define QCBlankLineCellHeight       20.0f
#define QCMineProfileCellHeight     79.0f
#define QCMineOtherCellHeight       44.0f
#define QCMineSectionHeaderHeight   20.0f
#define QCMineMinSectionHeight      0.00001f

@class QIMCommonTableViewCellData;
@class QIMUserInfoModel;
@class GroupModel;
@class QCGroupModel;
@interface QIMCommonTableViewCellManager : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;
@property (nonatomic) NSArray<NSArray<QIMCommonTableViewCellData *> *> *dataSource;
@property (nonatomic, strong) NSArray *dataSourceTitle;
@property (nonatomic, strong) QIMUserInfoModel *model;
@property (nonatomic, strong) QCGroupModel *groupModel;

@end
