//
//  QTImageAssetView.m
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QTImageAssetView.h"

#import "QTImageAssetTapView.h"

#import "QTImageAssetViewController.h"

@interface NSDate (TimeInterval)

+ (NSDateComponents *)componetsWithTimeInterval:(NSTimeInterval)timeInterval;
+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval;

@end

@implementation NSDate (TimeInterval)

+ (NSDateComponents *)componetsWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:date1];
    
    unsigned int unitFlags =
    NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    return [calendar components:unitFlags
                       fromDate:date1
                         toDate:date2
                        options:0];
}

+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSDateComponents *components = [self.class componetsWithTimeInterval:timeInterval];
    NSInteger roundedSeconds = lround(timeInterval - (components.hour * 60) - (components.minute * 60 * 60));
    
    if (components.hour > 0)
    {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)roundedSeconds];
    }
    
    else
    {
        return [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)roundedSeconds];
    }
}

@end

@interface QTVideoTitleView : UILabel

@end

@implementation QTVideoTitleView

-(void)drawRect:(CGRect)rect{
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.8,
        0.0, 0.0, 0.0, 1.0
    };
    
    CGFloat locations [] = {0.0, 0.75, 1.0};
    
    CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGFloat height          = rect.size.height;
    CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
    
    CGSize titleSize        = [self.text sizeWithFont:self.font];
    [self.textColor set];
    [self.text drawAtPoint:CGPointMake(rect.size.width - titleSize.width - 2 , (height - 12) / 2)
                  forWidth:imageItemWidth
                  withFont:self.font
                  fontSize:12
             lineBreakMode:NSLineBreakByTruncatingTail
        baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    UIImage *videoIcon=[UIImage imageNamed:@"video_icon"];
    
    [videoIcon drawAtPoint:CGPointMake(2, (height - videoIcon.size.height) / 2)];
    
}

@end


@interface QTImageAssetView ()<QTImageAssetTapViewDelegate>

@property (nonatomic, strong) ALAsset *asset; 
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) QTVideoTitleView *videoTitle;
@property (nonatomic, retain) QTImageAssetTapView *tapAssetView;

@end

@implementation QTImageAssetView


static UIFont *titleFont = nil;

static CGFloat titleHeight;
static UIColor *titleColor;

+ (void)initialize
{
    titleFont       = [UIFont systemFontOfSize:12];
    titleHeight     = 20.0f;
    titleColor      = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                     = YES;
        self.isAccessibilityElement     = YES;
        self.accessibilityTraits        = UIAccessibilityTraitImage;
        
        _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:_imageView];
        
        _videoTitle=[[QTVideoTitleView alloc] initWithFrame:CGRectMake(0, self.height-20, self.width, titleHeight)];
        _videoTitle.hidden=YES;
        _videoTitle.font=titleFont;
        _videoTitle.textColor=titleColor;
        _videoTitle.textAlignment=NSTextAlignmentRight;
        _videoTitle.backgroundColor=[UIColor clearColor];
        [self addSubview:_videoTitle];
        
        _tapAssetView=[[QTImageAssetTapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _tapAssetView.delegate=self;
        [self addSubview:_tapAssetView];
    }
    
    return self;
}

- (void)bind:(ALAsset *)asset selectionFilter:(NSPredicate*)selectionFilter isSeleced:(BOOL)isSeleced
{
    self.asset=asset;
    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
    [_imageView setImage:image];
    
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        _videoTitle.hidden=NO;
        _videoTitle.text=[NSDate timeDescriptionOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
    }
    else{
        _videoTitle.hidden=YES;
    }
    
    _tapAssetView.disabled=![selectionFilter evaluateWithObject:asset]; 
    _tapAssetView.selected=isSeleced;
}

#pragma mark - ZYQTapAssetView Delegate

-(BOOL)shouldTap{
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(shouldSelectAsset:)]) {
        return [_delegate shouldSelectAsset:_asset];
    }
    return YES;
}

-(void)touchSelect:(BOOL)select{
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(tapSelectHandle:asset:)]) {
        [_delegate tapSelectHandle:select asset:_asset];
    }
}

@end
