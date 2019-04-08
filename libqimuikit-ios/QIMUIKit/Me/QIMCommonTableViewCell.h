//
//  QIMCommonTableViewCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "QIMCommonUIFramework.h"
#define TABLE_VIEW_CELL_DEFAULT_FONT_SIZE 17

#define TABLE_VIEW_CELL_LEFT_MARGIN 20

#define TABLE_VIEW_CELL_DEFAULT_HEIGHT 44

typedef NS_ENUM(NSInteger, QIMCommonTableViewCellStyle) {
    kQIMCommonTableViewCellStyleDefault = UITableViewCellStyleDefault,
    kQIMCommonTableViewCellStyleValue1 = UITableViewCellStyleValue1,
    kQIMCommonTableViewCellStyleValue2 = UITableViewCellStyleValue2,
    kQIMCommonTableViewCellStyleSubtitle = UITableViewCellStyleSubtitle,
    
    kQIMCommonTableViewCellStyleValueCenter = 1000,
    kQIMCommonTableViewCellStyleValueLeft,
    kQIMCommonTableViewCellStyleContactList,
    kQIMCommonTableViewCellStyleContactSearchList
};


typedef NS_ENUM(NSInteger, QIMCommonTableViewCellAccessoryType) {
    kQIMCommonTableViewCellAccessoryNone = UITableViewCellAccessoryNone,
    kQIMCommonTableViewCellAccessoryDisclosureIndicator = UITableViewCellAccessoryDisclosureIndicator,
    kQIMCommonTableViewCellAccessoryDetailDisclosureButton = UITableViewCellAccessoryDetailDisclosureButton,
    kQIMCommonTableViewCellAccessoryCheckmark = UITableViewCellAccessoryCheckmark,
    kQIMCommonTableViewCellAccessoryDetailButton = UITableViewCellAccessoryDetailButton,
    
    kQIMCommonTableViewCellAccessorySwitch,
    kQIMCommonTableViewCellAccessoryText,
};

@interface QIMCommonTableViewCell : UITableViewCell

@property (nonatomic) QIMCommonTableViewCellAccessoryType accessoryType_LL;

+ (instancetype)cellWithStyle:(QIMCommonTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (BOOL)isSwitchOn;

- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated;

- (void)addSwitchTarget:(id)object tag:(NSUInteger)type action:(nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (NSString *)rightTextValue;

- (void)setRightTextValue:(NSString *)value;

@end
