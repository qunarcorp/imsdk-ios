//
//  QIMInputPopView.h
//  qunarChatIphone
//
//  Created by chenjie on 15/9/22.
//
//

#import "QIMCommonUIFramework.h"

@class QIMInputPopView;

@protocol QIMInputPopViewDelegate <NSObject>

- (void)inputPopView:(QIMInputPopView *)view willBackWithText:(NSString *)text;

- (void)cancelForQIMInputPopView:(QIMInputPopView *)view;

@end

@interface QIMInputPopView : UIView

@property (nonatomic,assign) id<QIMInputPopViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setTitle:(NSString *)title;

- (void)showInView:(UIView *)superView;

@end
