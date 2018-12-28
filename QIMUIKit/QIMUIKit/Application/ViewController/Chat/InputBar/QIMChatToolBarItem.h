
#import "QIMCommonUIFramework.h"

typedef NS_ENUM(NSInteger, BarItemKind){
    kBarItemVoice,
    kBarItemFace,
    kBarItemMore,
    kBarItemSwitchBar
};

@interface QIMChatToolBarItem : NSObject

@property (nonatomic, copy) NSString *normalStr;
@property (nonatomic, copy) NSString *highLStr;
@property (nonatomic, copy) NSString *selectStr;
@property (nonatomic, assign) BarItemKind itemKind;

+ (instancetype)barItemWithKind:(BarItemKind)itemKind normal:(NSString*)normalStr high:(NSString *)highLstr select:(NSString *)selectStr;

@end
