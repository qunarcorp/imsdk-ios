//
//  QIMSliderView.m
//  qunarChatIphone
//
//  Created by chenjie on 16/3/7.
//
//
#import "NSBundle+QIMLibrary.h"
#define kMinFlagText            [NSBundle qim_localizedStringForKey:@"font_size_small"];
#define kPlhdrFlagText          [NSBundle qim_localizedStringForKey:@"font_size_standard"];
#define kMaxFlagText            [NSBundle qim_localizedStringForKey:@"font_size_big"];

#define kPaddingToSide          30

#define kNumOfPoint             5

#define kScaleColorHex          0x6f6f6f

#define kFontAmp                2

#import "QIMSliderView.h"
#import "QIMCommonFont.h"

@interface QIMSliderView ()
{
    
    UILabel         * _minFlagLabel;
    UILabel         * _plhdrFlagLabel;
    UILabel         * _maxFlagLabel;
    UIView          * _tolView;
    UIImageView     * _iconFlagImgView;
    NSInteger         _lastIndex;
}

@end

@implementation QIMSliderView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpUI];
        float currentFontSize = [[QIMCommonFont sharedInstance] currentFontSize];
        _lastIndex = 0;
        [self setIconFlagToIndex:(NSInteger)((currentFontSize - FONT_SIZE + kFontAmp) / kFontAmp)];
    }
    return self;
}

- (void)setUpUI{
    float tolWidth = self.width - kPaddingToSide * 2;
    float perWidth = tolWidth / (kNumOfPoint - 1);
    if (_tolView == nil) {
        _tolView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingToSide, self.height / 2 + 20, tolWidth, 1)];
        _tolView.backgroundColor = [UIColor qim_colorWithHex:kScaleColorHex alpha:1.0];
        [self addSubview:_tolView];
        for (int i = 0; i < kNumOfPoint; i ++) {
            UIView * perView = [[UIView alloc] initWithFrame:CGRectMake(_tolView.left + perWidth * i, _tolView.top - 5, 0.5, 11)];
            perView.backgroundColor = [UIColor qim_colorWithHex:kScaleColorHex alpha:1.0];
            [self addSubview:perView];
        }
        if (_iconFlagImgView == nil) {
            _iconFlagImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            _iconFlagImgView.center = CGPointMake(_tolView.left, _tolView.center.y);
            _iconFlagImgView.image = [UIImage imageNamed:@"dynamicfontprogress"];
            [self addSubview:_iconFlagImgView];
        }
    }
    
    if (_minFlagLabel == nil) {
        _minFlagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _minFlagLabel.center = CGPointMake(_tolView.left, _tolView.top - 50);
        _minFlagLabel.backgroundColor = [UIColor clearColor];
        _minFlagLabel.font = [UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - kFontAmp];
        _minFlagLabel.textColor = [UIColor blackColor];
        _minFlagLabel.textAlignment = NSTextAlignmentCenter;
        _minFlagLabel.text = kMinFlagText;
        [self addSubview:_minFlagLabel];
    }
    
    if (_plhdrFlagLabel == nil) {
        _plhdrFlagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
        _plhdrFlagLabel.center = CGPointMake(_tolView.left + perWidth, _tolView.top - 50);
        _plhdrFlagLabel.backgroundColor = [UIColor clearColor];
        _plhdrFlagLabel.font = [UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize]];
        _plhdrFlagLabel.textColor = [UIColor blackColor];
        _plhdrFlagLabel.textAlignment = NSTextAlignmentCenter;
        _plhdrFlagLabel.text = kPlhdrFlagText;
        [self addSubview:_plhdrFlagLabel];
    }
    
    if (_maxFlagLabel == nil) {
        _maxFlagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _maxFlagLabel.center = CGPointMake(_tolView.left + perWidth * (kNumOfPoint - 1), _tolView.top - 50);
        _maxFlagLabel.backgroundColor = [UIColor clearColor];
        _maxFlagLabel.font = [UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] + (kNumOfPoint - 2) * kFontAmp];
        _maxFlagLabel.textColor = [UIColor blackColor];
        _maxFlagLabel.textAlignment = NSTextAlignmentCenter;
        _maxFlagLabel.text = kMaxFlagText;
        [self addSubview:_maxFlagLabel];
    }
}

- (void)setIconFlagToIndex:(NSInteger)index{
    if (index < kNumOfPoint) {
        if (_lastIndex == index) {
            return;
        }else{
            _lastIndex = index;
        }
        _iconFlagImgView.center = CGPointMake(_tolView.left + _tolView.width / (kNumOfPoint - 1) * index, _tolView.center.y);
        [[QIMCommonFont sharedInstance] setCurrentFontSize:FONT_SIZE + (index - 1) * kFontAmp];
        if (self.delegate && [self.delegate respondsToSelector:@selector(sliderView:didChangeSelectedValue:)]) {
            [self.delegate sliderView:self didChangeSelectedValue:index];
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    float perWidth = (_tolView.width / (kNumOfPoint - 1));
    NSInteger index = (NSInteger)((point.x - _tolView.left + perWidth / 2) / perWidth);
    [self setIconFlagToIndex:index];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    float perWidth = (_tolView.width / (kNumOfPoint - 1));
    NSInteger index = (NSInteger)((point.x - _tolView.left + perWidth / 2) / perWidth);
    [self setIconFlagToIndex:index];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}


-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

@end
