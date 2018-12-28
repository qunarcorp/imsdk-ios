//
//  QIMEmotionView.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/6.
//

#import "QIMCommonUIFramework.h"

typedef enum {
    QTalkEmotionTypeShowAll = 0,
    QTalkEmotionTypeNormal,
    QTalkEmotionTypeCollection,
} QTalkEmotionType;

@protocol QIMEmotionViewDelegate <NSObject>

- (void)didSelectShowAllEmotion:(NSString *)faceName andIsSelectDelete:(BOOL)del;

- (void)didSelectNormalEmotion:(NSString *)faceName;

- (void)changePageControlIndex:(NSInteger)pageIndex;

@end

/*
 Emotion / Collection表情包两边边缘间隔
 */
#define kEmotionFaceEdgeDistance 10

/*
 Emotion / Collection表情包上下边缘间隔
 */
#define kEmotionFaceEdgeInterVal 10

#define IsWidescreen ([UIScreen mainScreen].bounds.size.width > 320 ? 1 : 0)
/**
 Emotion / Collection表情包列数
 */
#define kEmotionFaceNumPerLine (4 + IsWidescreen)

/**
 Emotion / Collection表情包行数
 */
#define kEmotionFaceLines 2

/**
 Emotion / Collection表情size
 */
#define kEmotionFaceItemWidth 60

/*
 ShowAllEmotion&Collection表情包两边边缘间隔
 */
#define kShowAllEmotionFaceEdgeDistance 3

/*
 ShowAllEmotion&Collection表情包上下边缘间隔
 */
#define kShowAllEmotionFaceEdgeInterVal 5

/**
 ShowAllEmotion&Collection表情包列数
 */
#define kShowAllEmotionFaceNumPerLine 8

/**
 ShowAllEmotion&Collection表情包行数
 */
#define kShowAllEmotionFaceLines 3

#define kShowAllImageFacePageViewItemWidth (80)

@interface QIMEmotionView : UICollectionView

@property (nonatomic, weak) id <QIMEmotionViewDelegate> emotionViewDelegate;
@property (nonatomic, assign) QTalkEmotionType emotionType;
@property (nonatomic, assign) NSInteger totalPageIndex;

- (void)reloadCollectionFaceView;
+ (instancetype)qtalkEmotionCollectionViewWithFrame:(CGRect)frame WithPkid:(NSString *)packageId;

@end
