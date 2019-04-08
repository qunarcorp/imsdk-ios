//
//  UITextView+QIMTextView.m
//  qunarChatIphone
//
//  Created by chenjie on 15/6/4.
//
//

#import "QIMTextView.h"

@implementation QIMTextView
@dynamic delegate;

- (void)setContentSize:(CGSize)contentSize
{
    CGSize oriSize = self.contentSize;
    [super setContentSize:contentSize];
    
    if (self.font == nil) {
        return;
    }
    
    if(oriSize.height != self.contentSize.height)
    {
        if (self.superview) {
            CGRect rect = self.superview.frame;
            self.superview.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height + MIN(self.contentSize.height, _maxLine * self.font.lineHeight) - MIN(oriSize.height, _maxLine * self.font.lineHeight));
        }
        CGRect newFrame = self.frame;
        if ([[QIMKit sharedInstance] getIsIpad]) {
            newFrame.origin.y  += newFrame.size.height - self.contentSize.height;
        } else {
            newFrame.size.height = MIN(self.contentSize.height, _maxLine * self.font.lineHeight);
        }
        self.frame = newFrame;
        if([self.delegate respondsToSelector:@selector(textView:heightChanged:)])
        {
            [self.delegate textView:self heightChanged:MIN(self.contentSize.height, _maxLine * self.font.lineHeight) - MIN(oriSize.height, _maxLine * self.font.lineHeight)];
        }
    }
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:)) {
        return YES;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        return YES;
    }
    return NO;
}
/*
-(void)copy:(id)sender{
    if (self.delegate  && [self.delegate respondsToSelector:@selector(textView:handleResponderAction:)]) {
        [self.delegate textView:self handleResponderAction:@selector(copy:)];
    }
}

-(void)cut:(id)sender{
    if (self.delegate  && [self.delegate respondsToSelector:@selector(textView:handleResponderAction:)]) {
        [self.delegate textView:self handleResponderAction:@selector(cut:)];
    }
}
 
-(void)paste:(id)sender{
    if (self.delegate  && [self.delegate respondsToSelector:@selector(textView:handleResponderAction:)]) {
        [self.delegate textView:self handleResponderAction:@selector(paste:)];
    }
} */
@end
