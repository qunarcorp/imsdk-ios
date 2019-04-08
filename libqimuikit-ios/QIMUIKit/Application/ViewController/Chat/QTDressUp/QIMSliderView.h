//
//  QIMSliderView.h
//  qunarChatIphone
//
//  Created by chenjie on 16/3/7.
//
//

#import "QIMCommonUIFramework.h"

@class QIMSliderView;
@protocol QIMSliderViewDelegate <NSObject>

- (void)sliderView:(QIMSliderView *)slider didChangeSelectedValue:(NSInteger)index;

@end

@interface QIMSliderView : UIView

@property (nonatomic,assign) id<QIMSliderViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame;

@end
