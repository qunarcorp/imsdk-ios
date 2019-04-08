//
//  QIMFaceViewDataSource.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMFaceViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *devideEmojiList;

+ (void)setInstanceCellIdentifier:(NSString *)cellIdentifier;

@end
