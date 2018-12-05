
/**
 *  可以完全定制，控件只是为了演示效果
 */

#import "QIMCommonUIFramework.h"

typedef void (^SWITCHACTION) ();

@interface QIMOfficialAccountToolbar : UIView

@property (nonatomic, copy) SWITCHACTION switchAction;

@end
