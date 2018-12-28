
#import "QIMChatToolBarItem.h"

@implementation QIMChatToolBarItem

+ (instancetype)barItemWithKind:(BarItemKind)itemKind normal:(NSString*)normalStr high:(NSString *)highLstr select:(NSString *)selectStr
{
    return [[[self class] alloc] initWithItemKind:itemKind normal:normalStr high:highLstr select:selectStr];
}


- (instancetype)initWithItemKind:(BarItemKind)itemKind normal:(NSString*)normalStr high:(NSString *)highLstr select:(NSString *)selectStr
{
    if (self = [super init]) {
        self.itemKind = itemKind;
        self.normalStr = normalStr;
        self.highLStr = highLstr;
        self.selectStr = selectStr;
    }
    return self;
}

@end
