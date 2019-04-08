//
//  QIMImageDoodleView.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/8.
//
//

#import "QIMImageDoodleView.h"

@interface QIMImageDoodleView ()
{
    CGPoint previousPoint;
    CGPoint currentPoint;
    
}
@property (nonatomic, strong) UIImage * viewImage;
@end

@implementation QIMImageDoodleView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.viewImage drawInRect:self.bounds];
}

#pragma mark - setter methods
- (void)setDrawingMode:(DrawingMode)drawingMode
{
    _drawingMode = drawingMode;
}

#pragma mark - Private methods
- (void)initialize
{
    currentPoint = CGPointMake(0, 0);
    previousPoint = currentPoint;
    
    _drawingMode = DrawingModeNone;
    
    _selectedColor = [UIColor blackColor];
}

- (void)eraseLine
{
    UIGraphicsBeginImageContext(CGSizeMake((int)self.bounds.size.width, (int)self.bounds.size.height));
    [self.viewImage drawInRect:CGRectMake(0, 0, (int)self.width, (int)self.height)];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), previousPoint.x, previousPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    previousPoint = currentPoint;
    
    [self setNeedsDisplay];
}


- (void)drawLineNew
{
    UIGraphicsBeginImageContext(CGSizeMake((int)self.bounds.size.width, (int)self.bounds.size.height));
    [self.viewImage drawInRect:CGRectMake(0, 0, (int)self.width, (int)self.height)];
    QIMVerboseLog(@"%f,%f",self.bounds.origin.x,self.bounds.origin.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.selectedColor.CGColor);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), previousPoint.x, previousPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    previousPoint = currentPoint;
    
    [self setNeedsDisplay];
}

- (void)handleTouches
{
    if (self.drawingMode == DrawingModeNone) {
        // do nothing
    }
    else if (self.drawingMode == DrawingModePaint) {
        [self drawLineNew];
    }
    else
    {
        [self eraseLine];
    }
}

#pragma mark - Touches methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    previousPoint = p;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentPoint = [[touches anyObject] locationInView:self];
    
    [self handleTouches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentPoint = [[touches anyObject] locationInView:self];
    
    [self handleTouches];
}

-(UIImage *)getDoodleImage
{
    return self.viewImage;
}


- (void)clean
{
    self.viewImage = nil;
    [self setNeedsDisplay];
}
@end
