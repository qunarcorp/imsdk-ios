//
//  UICollectionEmotionPanView.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/18.
//
//

#import "QIMCommonUIFramework.h"

@class QIMCollectionEmotionPanView;

@protocol  QIMDragCellCollectionViewDelegate<UICollectionViewDelegate>

@required
/**
 *  当数据源更新的到时候调用，必须实现，需将新的数据源设置为当前tableView的数据源(例如 :_data = newDataArray)
 *  @param newDataArray   更新后的数据源
 */
- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray;

@optional

/**
 *  某个cell将要开始移动的时候调用
 *  @param indexPath      该cell当前的indexPath
 */
- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  某个cell正在移动的时候
 */
- (void)dragCellCollectionViewCellisMoving:(QIMCollectionEmotionPanView *)collectionView;
/**
 *  cell移动完毕，并成功移动到新位置的时候调用
 */
- (void)dragCellCollectionViewCellEndMoving:(QIMCollectionEmotionPanView *)collectionView;
/**
 *  成功交换了位置的时候调用
 *  @param fromIndexPath    交换cell的起始位置
 *  @param toIndexPath      交换cell的新位置
 */
- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol  QIMDragCellCollectionViewDataSource<UICollectionViewDataSource>


@required
/**
 *  返回整个CollectionView的数据，必须实现，需根据数据进行移动后的数据重排
 */
- (NSArray *)dataSourceArrayOfCollectionView:(QIMCollectionEmotionPanView *)collectionView;

@end

@interface QIMCollectionEmotionPanView : UICollectionView

@property (nonatomic, assign) id<QIMDragCellCollectionViewDelegate> qimDragDelegate;
@property (nonatomic, assign) id<QIMDragCellCollectionViewDataSource> qimDragDataSource;

@property (nonatomic, assign) BOOL isOpenMove;

/**长按多少秒触发拖动手势，默认1秒，如果设置为0，表示手指按下去立刻就触发拖动*/
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;
/**是否开启拖动到边缘滚动CollectionView的功能，默认YES*/
@property (nonatomic, assign) BOOL edgeScrollEable;
/**是否开启拖动的时候所有cell抖动的效果，默认YES*/
@property (nonatomic, assign) BOOL shakeWhenMoveing;
/**抖动的等级(1.0f~10.0f)，默认4*/
@property (nonatomic, assign) CGFloat shakeLevel;
/**是否正在编辑模式，调用xwp_enterEditingModel和xw_stopEditingModel会修改该方法的值*/
@property (nonatomic, assign, readonly, getter=isEditing) BOOL editing;

/**进入编辑模式，如果开启抖动会自动持续抖动，且不用长按就能出发拖动*/
- (void)QIM_enterEditingModel;

/**退出编辑模式*/
- (void)QIM_stopEditingModel;

@end
