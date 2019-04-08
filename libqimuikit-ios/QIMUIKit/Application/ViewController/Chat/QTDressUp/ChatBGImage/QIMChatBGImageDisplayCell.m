//
//  QIMChatBGImageDisplayCell.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#define kImageViewTagFrom 10000

#import "QIMChatBGImageDisplayCell.h"

static CGSize kChatBGImageSize;

@interface QIMChatBGImageDisplayCell()
{
    NSMutableArray  * _imageViews;
}

@end

@implementation QIMChatBGImageDisplayCell

+ (CGSize)getImageSize{
    if (kChatBGImageSize.width <= 0) {
        float width = ([UIScreen mainScreen].bounds.size.width - (kCellImageCount + 1) * 10) / kCellImageCount;
        float height = width / [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.height;
        kChatBGImageSize.width = width;
        kChatBGImageSize.height = height;
    }
    return kChatBGImageSize;
}

-(void)setImages:(NSArray *)images
{
    if (!_imageViews) {
        _imageViews = [NSMutableArray arrayWithCapacity:1];
    }else{
        [_imageViews removeAllObjects];
    }
    for (__strong UIImage * image in images) {
        UIImageView * imageView = nil;
        if ([image isKindOfClass:[NSString class]]) {
            imageView = [[UIImageView alloc] initWithImage:nil];
        }else{
            imageView = [[UIImageView alloc] initWithImage:image];
        }
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = kImageViewTagFrom + [images indexOfObject:image];
        imageView.userInteractionEnabled = YES;
        imageView.backgroundColor = [UIColor qim_colorWithHex:0xebecef alpha:1];
        [self.contentView addSubview:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [imageView addGestureRecognizer:tap];
        
        [_imageViews addObject:imageView];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    NSInteger i = 0;
    float width = ([UIScreen mainScreen].bounds.size.width- (_imageViews.count + 1) * 10) / _imageViews.count;
    float heght = width / [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.height;
    for (UIImageView * imageView in _imageViews) {
        imageView.frame = CGRectMake(10 * (i + 1) + width * i, 10, width, heght);
        i ++;
    }
}

- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDisplayCell:didSelectedImageAtIndex:)]) {
        [self.delegate imageDisplayCell:self didSelectedImageAtIndex:(NSInteger)(tap.view.tag - kImageViewTagFrom)];
    }
}

@end
