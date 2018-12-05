//
//  QIMCollectionEmotionEditorViewCell.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/14.
//
//

#define kEmotionItemTagFrom     1000
#define kImageViewCap           15

#import "QIMCommonUIFramework.h"

@class QIMCollectionEmotionEditorViewCell;
@protocol QIMCollectionEmotionEditorViewDelegate <NSObject>

- (void)collectionEmotionEditorCell:(QIMCollectionEmotionEditorViewCell *)cell didClickedItemAtIndex:(NSInteger)index selected:(BOOL)selected;

@end

@interface QIMCollectionEmotionEditorViewCell : UICollectionViewCell

@property (nonatomic,assign) id <QIMCollectionEmotionEditorViewDelegate> editDelegate;

/**
 *  收藏的表情List
 */

@property (nonatomic, copy) id emotionItem;

@property (nonatomic, assign) BOOL canSelect;

@property (nonatomic, assign) NSInteger section;

@end
