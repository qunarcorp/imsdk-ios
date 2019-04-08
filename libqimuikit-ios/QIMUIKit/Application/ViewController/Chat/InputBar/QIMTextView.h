//
//  UITextView+QIMTextView.h
//  qunarChatIphone
//
//  Created by chenjie on 15/6/4.
//
//

#import "QIMCommonUIFramework.h"

@class QIMTextView;
@protocol QIMTextViewDelegate <NSObject>

- (void)textView:(QIMTextView *)textView heightChanged:(NSInteger)height;

- (void)textView:(QIMTextView *)textView handleResponderAction:(SEL)action;

@end


@interface QIMTextView : UITextView

@property (nonatomic,assign) NSInteger          maxLine;//最大行数
@property (weak, nonatomic) id<UITextViewDelegate, QIMTextViewDelegate> delegate;

@end
