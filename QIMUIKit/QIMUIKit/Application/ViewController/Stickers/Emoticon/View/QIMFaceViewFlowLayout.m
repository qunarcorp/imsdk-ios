//
//  QIMFaceViewFlowLayout.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "QIMFaceViewFlowLayout.h"

@implementation QIMFaceViewFlowLayout

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

@end
