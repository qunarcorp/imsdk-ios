
#import "QIMCommonUIFramework.h"

@class QTalkTextView;
@protocol QTalkTextViewDelegate <UITextViewDelegate>

- (void)textViewDeleteBackward:(QTalkTextView *)textView;

@end

@interface QTalkTextView : UITextView

@property(nonatomic ,weak) id<QTalkTextViewDelegate> delegate;

@property (nonatomic, copy) NSString * placeHolder;

@property (nonatomic, strong) UIColor * placeHolderTextColor;

- (NSUInteger)numberOfLinesOfText;

@end
