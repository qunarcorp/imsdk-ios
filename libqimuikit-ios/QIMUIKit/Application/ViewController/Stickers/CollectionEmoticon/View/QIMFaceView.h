//
//  QIMFaceView.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "QIMCommonUIFramework.h"

#define kEmotionFaceNumPerLine 8
#define kEmotionFaceLines 3

@protocol QIMFaceViewDelegate <NSObject>
//@optional

/*
 * 点击表情代理
 * @param faceName 表情对应的名称
 * @param del      是否点击删除
 *
 */
- (void)didSelecteFace:(NSString *)faceName andIsSelecteDelete:(BOOL)del;

- (void)pageControlHandlde:(NSInteger)pageIndex;

@end

@interface QIMFaceView : UICollectionView 

/**
 *  数组长度，即是pageControl的个数
 */
@property (nonatomic, assign, readonly) NSInteger pages;

/**
 *  初始化表情页面
 *
 *  @param frame  大小
 *  @param layout 布局
 *
 */
+ (instancetype)FaceViewWithFrame:(CGRect)frame WithShowAll:(BOOL)showAll WithPKId:(NSString *)pkId;

@property (nonatomic, weak) id <QIMFaceViewDelegate> faceViewDelegate;

@end
