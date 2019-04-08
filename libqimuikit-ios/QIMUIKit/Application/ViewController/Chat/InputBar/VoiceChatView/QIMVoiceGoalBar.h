
#import "QIMCommonUIFramework.h"
#import <QuartzCore/QuartzCore.h>
#import "QIMVoiceGoalBarPercentLayer.h"


@interface QIMVoiceGoalBar : UIView {
    UIImage * thumb;
    QIMVoiceGoalBarPercentLayer *percentLayer;
    CALayer *thumbLayer;
}

@property (nonatomic, strong) UILabel *percentLabel;

- (void)setPercent:(int)percent animated:(BOOL)animated;

@end
