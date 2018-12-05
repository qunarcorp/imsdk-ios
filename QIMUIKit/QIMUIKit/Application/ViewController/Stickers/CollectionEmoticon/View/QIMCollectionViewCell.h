//
//  QIMCollectionViewCell.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/6/1.
//
//

#import "QIMCommonUIFramework.h"
#import "QIMEmotionTipDelegate.h"

@interface QIMCollectionViewCell : UICollectionViewCell <QIMEmotionTipDelegate>

- (void)refreshUIWithFlag:(BOOL)flag ;

- (void)setRefreshCount:(BOOL)refreshed;

@end
