//
//  QIMColorfulBubbleCell.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#define kSubViewTagFrom 10000

#import "QIMColorfulBubbleCell.h"

@interface QIMColorfulBubbleCell()
{
    NSMutableArray          * _imageViews;
}

@end

@implementation QIMColorfulBubbleCell

- (void)setBubbles:(NSArray *)bubbles
{
    if (!_imageViews) {
        _imageViews = [NSMutableArray arrayWithCapacity:1];
    }else{
        [_imageViews removeAllObjects];
    }
    for (UIImage * image in bubbles) {
        
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.tag = kSubViewTagFrom + [bubbles indexOfObject:image];
        bgView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:bgView];
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [bgView addSubview:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [bgView addGestureRecognizer:tap];
        
        [_imageViews addObject:imageView];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    NSInteger i = 0;
    float width = (self.contentView.width - (_imageViews.count + 1) * 10) / _imageViews.count;
    float heght = 10;
    for (UIImageView * imageView in _imageViews) {
        heght = width / imageView.image.size.width * imageView.image.size.height;
        imageView.superview.frame = CGRectMake(10 * (i + 1) + width * i, 10, width, heght);
        imageView.frame = CGRectMake(0, 0, width / 2, heght / 2);
        imageView.center = imageView.superview.center;
        i ++;
    }
}

- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorfulBubbleCell:didSelectedBubbleAtIndex:)]) {
        [self.delegate colorfulBubbleCell:self didSelectedBubbleAtIndex:(NSInteger)(tap.view.tag - kSubViewTagFrom)];
    }
}

@end
