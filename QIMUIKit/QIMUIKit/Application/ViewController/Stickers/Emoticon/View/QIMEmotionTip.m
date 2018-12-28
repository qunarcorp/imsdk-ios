//
//  QIMEmotionTip.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/8.
//

#import "QIMEmotionTip.h"
#import "UIImage+GIF.h"
#import "QIMCollectionFaceManager.h"
#import "QIMEmotionManager.h"

@interface QTalkShowAllEmojiTip ()

@property (nonatomic) UIImageView *backgroundImageView;

@property (nonatomic) UIImageView *imageView;

@property (nonatomic) UILabel *label;

@end

@implementation QTalkShowAllEmojiTip

+ (instancetype)sharedTip {
    static QTalkShowAllEmojiTip *tip;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(){
        tip = [[QTalkShowAllEmojiTip alloc] initWithFrame:CGRectMake(0, 0, 64, 92)];
    });
    return tip;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emoticon_keyboard_magnifier"]];
        [self addSubview:self.backgroundImageView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 42)/2, 4, 42, 42)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, CGRectGetWidth(self.frame), 20)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.textColor = [UIColor colorWithRed:109/255.0 green:109/255.0 blue:109/255.0 alpha:1];
        [self addSubview:self.label];
    }
    
    return self;
}

- (void)showTipOnCell:(QIMFaceViewCell *)cell {
    if (cell == _cell) return;
    _cell = cell;
    
    if (!_cell) {
        [self removeFromSuperview];
    }else {
        UIView *superView = _cell.superview.superview;
        [superView addSubview:self];
        
        CGPoint point = [_cell convertPoint:_cell.tipFloatPoint toView:superView];
        CGRect frame = self.frame;
        frame.origin.x = point.x - CGRectGetWidth(frame)/2;
        frame.origin.y = point.y - CGRectGetHeight(frame);
        self.frame = frame;
        self.imageView.image = [[QIMEmotionManager sharedInstance] getEmotionThumbIconWithImageStr:_cell.emojiPath BySize:CGSizeMake(FaceSize, FaceSize)];
        NSString * faceImagePath = [[[QIMEmotionManager sharedInstance] getEmotionImagePathListForPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]] objectAtIndex:cell.tag];
        NSString *shortCut = [[QIMEmotionManager sharedInstance] getEmotionShortCutForImagePath:faceImagePath withPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]];
        NSString *tipName = [[QIMEmotionManager sharedInstance] getEmotionTipNameForShortCut:shortCut withPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]];
        self.label.text = tipName;
    }
}

@end

typedef NS_ENUM(NSInteger, QTalkTipPositionType) {
    kQTalkTipPositionTypeLeft = 1,
    kQTalkTipPositionTypeMiddle,
    kQTalkTipPositionTypeRight
};


@interface QTalkGifEmojiTip ()

@property (nonatomic) UIImageView *leftBackgroundImageView;
@property (nonatomic) UIImageView *middleBackgroundImageView;
@property (nonatomic) UIImageView *rightBackgroundImageView;

@property (nonatomic) QTalkTipPositionType type;

@property (nonatomic) UIImageView *gifImageView;

@end

#pragma mark - GIF Tip

#define SIDE_BAR_WIDTH 30
#define MIDDLE_BAR_WIDTH 20
#define TOTAL_BAR_SIZE 148
#define ARROW_HEIGHT 10

@implementation QTalkGifEmojiTip

+ (instancetype)sharedTip {
    static QTalkGifEmojiTip *tip;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(){
        tip = [[QTalkGifEmojiTip alloc] initWithFrame:CGRectMake(0, 0, TOTAL_BAR_SIZE, TOTAL_BAR_SIZE + ARROW_HEIGHT)];
    });
    
    return tip;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.leftBackgroundImageView = [self imageWithResizbleImage:@"EmoticonBigTipsLeft"];
        self.middleBackgroundImageView = [self imageWithResizbleImage:@"EmoticonBigTipsMiddle"];
        self.rightBackgroundImageView = [self imageWithResizbleImage:@"EmoticonBigTipsRight"];
        
        _type = 0;
        
        CGFloat gap = 0.1 * TOTAL_BAR_SIZE;
        CGFloat gifWidth = 0.8 * TOTAL_BAR_SIZE;
        self.gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(gap, gap, gifWidth, gifWidth)];
        self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.gifImageView];
    }
    
    return self;
}

- (UIImageView *)imageWithResizbleImage:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat capWidth =  floorf(image.size.width / 2);
    CGFloat capHeight =  floorf(image.size.height / 2);
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, capWidth, capHeight, capWidth)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    [self addSubview:imageView];
    
    return imageView;
}


- (void)showTipOnCell:(UICollectionViewCell *)cell {
    if (cell == _cell) return;
    _cell = cell;
    
    if (!_cell) {
        self.gifImageView.image = nil;
        [self removeFromSuperview];
    }else {
        UIView *superView = _cell.superview.superview;
        [superView addSubview:self];
        
        CGPoint point = [_cell convertPoint:CGPointMake(CGRectGetWidth(_cell.frame)/2, 0) toView:superView];
        QTalkTipPositionType type = kQTalkTipPositionTypeMiddle;
        CGRect frame = self.frame;
        frame.origin.y = point.y - TOTAL_BAR_SIZE - ARROW_HEIGHT + 4;
        
        CGFloat _x = point.x - TOTAL_BAR_SIZE/2;
        if (_x < 0) {
            type = kQTalkTipPositionTypeLeft;
            point = [_cell convertPoint:CGPointMake(CGRectGetWidth(_cell.frame) * 0.45, 0) toView:superView];
            frame.origin.x = point.x - SIDE_BAR_WIDTH - MIDDLE_BAR_WIDTH /2;
            
        }else if (TOTAL_BAR_SIZE + _x > SCREEN_WIDTH) {
            type = kQTalkTipPositionTypeRight;
            point = [_cell convertPoint:CGPointMake(CGRectGetWidth(_cell.frame) * 0.55, 0) toView:superView];
            frame.origin.x = point.x + SIDE_BAR_WIDTH + MIDDLE_BAR_WIDTH /2 - TOTAL_BAR_SIZE;
            
        }else {
            type = kQTalkTipPositionTypeMiddle;
            frame.origin.x = _x;
        }
        
        self.frame = frame;
        
        [self updateBackgroundWithType:type];
        
        if ([cell isKindOfClass:[QIMFaceViewCell class]]) {
            QIMFaceViewCell *normalEmotionCell = (QIMFaceViewCell *)cell;
            NSData *gifData = [[QIMEmotionManager sharedInstance] getEmotionThumbIconDataWithImageStr:normalEmotionCell.emojiPath];
            self.gifImageView.image = [UIImage sd_animatedGIFWithData:gifData];
        } else if ([cell isKindOfClass:[QIMCollectionViewCell class]]) {
            QIMCollectionViewCell *collectionCell = (QIMCollectionViewCell *)cell;
            NSData *imageData = [NSData dataWithContentsOfFile:[[QIMCollectionFaceManager sharedInstance] getCollectionFaceEmojiLocalPathWithIndex:collectionCell.tag - 1]];
            if (!imageData.length) {
                imageData = [NSData dataWithContentsOfFile:[[QIMCollectionFaceManager sharedInstance] getSmallEmojiLocalPathWithIndex:collectionCell.tag - 1]];
            }
            self.gifImageView.image = [UIImage sd_animatedGIFWithData:imageData];
        }
    }
}

- (void)updateBackgroundWithType:(QTalkTipPositionType)type {
    if (_type == type) return;
    _type = type;
    
    if (_type == kQTalkTipPositionTypeLeft) {
        self.leftBackgroundImageView.frame = CGRectMake(0,0, SIDE_BAR_WIDTH, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.middleBackgroundImageView.frame = CGRectMake(SIDE_BAR_WIDTH, 0, MIDDLE_BAR_WIDTH,
                                                          TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.rightBackgroundImageView.frame = CGRectMake(SIDE_BAR_WIDTH + MIDDLE_BAR_WIDTH, 0, (TOTAL_BAR_SIZE -
                                                                                                SIDE_BAR_WIDTH - MIDDLE_BAR_WIDTH), TOTAL_BAR_SIZE + ARROW_HEIGHT);
    }else if (type == kQTalkTipPositionTypeMiddle) {
        CGFloat side = (TOTAL_BAR_SIZE - MIDDLE_BAR_WIDTH)/2;
        self.leftBackgroundImageView.frame = CGRectMake(0, 0, side, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.middleBackgroundImageView.frame = CGRectMake(side, 0, MIDDLE_BAR_WIDTH, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.rightBackgroundImageView.frame = CGRectMake(TOTAL_BAR_SIZE - side, 0, side, TOTAL_BAR_SIZE + ARROW_HEIGHT);
    }else if (type ==kQTalkTipPositionTypeRight) {
        CGFloat side = (TOTAL_BAR_SIZE - SIDE_BAR_WIDTH - MIDDLE_BAR_WIDTH);
        self.leftBackgroundImageView.frame = CGRectMake(0, 0, side, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.middleBackgroundImageView.frame = CGRectMake(side, 0, MIDDLE_BAR_WIDTH, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.rightBackgroundImageView.frame = CGRectMake(TOTAL_BAR_SIZE - SIDE_BAR_WIDTH, 0, SIDE_BAR_WIDTH,
                                                         TOTAL_BAR_SIZE + ARROW_HEIGHT);
    }
}

@end
