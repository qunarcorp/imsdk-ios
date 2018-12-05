//
//  QIMImageClipView.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/7.
//
//

typedef enum {
    QIMImageClipViewTransformUp,
    QIMImageClipViewTransformLeft,
    QIMImageClipViewTransformDown,
    QIMImageClipViewTransformRight,
} QIMImageClipViewTransformType;

#import "QIMCommonUIFramework.h"

@class QIMImageClipView;

@protocol QIMImageClipViewDelegate <NSObject>

- (void)imageClipView:(QIMImageClipView *)imageClipView didChangedByClipRect:(CGRect)rect;

@end

@interface QIMImageClipView : UIView
{
    UIImageView *imgView;
    CGRect cliprect;
    CGColorRef grayAlpha;
    CGPoint touchPoint;
    float   imageToViewScale;
}

@property (nonatomic,assign)id<QIMImageClipViewDelegate> delegate;
@property (nonatomic,assign) QIMImageClipViewTransformType transformType;

- (id)initWithFrame:(CGRect)frame imageView:(UIImage *)image;

- (UIImage*)getClipImage;
- (UIImage*)getClipImageForOriginalImage:(UIImage *)originalImage;

- (void) resetClipRectWithImage : (UIImage *)image;

@end
