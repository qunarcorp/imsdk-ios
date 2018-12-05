//
//  QIMCollectionEmotionEditorViewFlowLayout.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/14.
//
//

#import "QIMCollectionEmotionEditorViewFlowLayout.h"

@implementation QIMCollectionEmotionEditorViewFlowLayout

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        CGFloat cellHeight = [UIScreen mainScreen].bounds.size.width / kEmotionItemColumnNum;
        CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width / kEmotionItemColumnNum;
        // 水平间隔
        self.minimumInteritemSpacing = 0;

        // 上下垂直间隔
        self.minimumLineSpacing = kEmotionItemLineSpacing;
        
        self.itemSize = CGSizeMake(cellWidth, cellHeight);
    }
    return self;
}

@end
