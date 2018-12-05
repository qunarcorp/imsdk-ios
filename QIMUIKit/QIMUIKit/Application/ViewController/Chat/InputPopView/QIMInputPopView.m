//
//  QIMInputPopView.m
//  qunarChatIphone
//
//  Created by chenjie on 15/9/22.
//
//

#import "QIMInputPopView.h"

#define kPaddingToSide      30
#define kSubViewWidth       ([UIScreen mainScreen].bounds.size.width - kPaddingToSide * 2)
#define kTitleLabelHeight   30
#define kTextViewHeight     170
#define kBtnHeight          30

@interface QIMInputPopView ()
{
    UILabel         * _titleLabel;
    UIView          * _bgView;
    UIView          * _subViewBgView;
    UITextView      * _textView;
    UIButton        * _cancelBtn,
                    * _confirmBtn;
    UIView          * _lineView;
}

@end

@implementation QIMInputPopView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.userInteractionEnabled = YES;
        
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.7;
        _bgView.userInteractionEnabled = YES;
        [self addSubview:_bgView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [_bgView addGestureRecognizer:tap];
        
        _subViewBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _subViewBgView.backgroundColor = [UIColor whiteColor];
        _subViewBgView.userInteractionEnabled = YES;
        [self addSubview:_subViewBgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textColor = [UIColor qunarBlueColor];
        [_subViewBgView addSubview:_titleLabel];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = [UIColor qunarGrayColor];
        [_subViewBgView addSubview:_textView];
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor qunarBlueColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_subViewBgView addSubview:_cancelBtn];
        
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor qunarBlueColor] forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_subViewBgView addSubview:_confirmBtn];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor qunarTextGrayColor];
        [_subViewBgView addSubview:_lineView];
    }
    return self;
}

- (void)cancelBtnHandle:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelForQIMInputPopView:)]) {
        [self.delegate cancelForQIMInputPopView:self];
    }
    [self close];
}

- (void)confirmBtnHandle:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputPopView:willBackWithText:)]) {
        [self.delegate inputPopView:self willBackWithText:_textView.text];
    }
    [self close];
}

- (void)tapHandle:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelForQIMInputPopView:)]) {
        [self.delegate cancelForQIMInputPopView:self];
    }
    [self close];
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)showInView:(UIView *)superView
{
    self.frame = superView.bounds;
    [superView addSubview:self];
}

- (void)layoutSubviews
{
    _bgView.frame = self.bounds;
    
    _titleLabel.frame = CGRectMake(0, 20, kSubViewWidth, kTitleLabelHeight);
    
    _textView.frame = CGRectMake(0, _titleLabel.bottom + 10, kSubViewWidth, kTextViewHeight);
    
    _cancelBtn.frame = CGRectMake(10, _textView.bottom + 10, (kSubViewWidth - 10 * 3) / 2.0f, kBtnHeight);
    _confirmBtn.frame = CGRectMake(10 * 2 + (kSubViewWidth - 10 * 3) / 2.0f + 0.5, _textView.bottom + 10, (kSubViewWidth - 10 * 3) / 2.0f, kBtnHeight);
    
    _subViewBgView.frame = CGRectMake(kPaddingToSide, 0, kSubViewWidth, _confirmBtn.bottom - _titleLabel.top + _titleLabel.frame.origin.y + 10);
    
    _subViewBgView.center = CGPointMake(self.center.x, self.height + _subViewBgView.height / 2);
    _lineView.frame = CGRectMake(_cancelBtn.right, _textView.bottom, 0.5, kBtnHeight + 20);
    [UIView animateWithDuration:0.5
                     animations:^{
                         _subViewBgView.center = CGPointMake(self.center.x, self.center.y - 130);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    if (![_textView isFirstResponder]) {
        [_textView becomeFirstResponder];
    }
}

- (void)close
{
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         _subViewBgView.center = CGPointMake(self.center.x, self.height + _subViewBgView.height / 2);
                     }
                     completion:^(BOOL finished) {
                         if ([_textView isFirstResponder]) {
                             [_textView resignFirstResponder];
                         }
                         [self removeFromSuperview];
                         
                     }];
}



@end
