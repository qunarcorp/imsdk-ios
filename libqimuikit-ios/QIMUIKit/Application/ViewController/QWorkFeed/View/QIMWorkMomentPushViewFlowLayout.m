//
//  QIMWorkMomentPushViewFlowLayout.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/3.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentPushViewFlowLayout.h"

@implementation QIMWorkMomentPushViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        // 水平间隔
        self.minimumInteritemSpacing = kEmotionItemLineSpacing;
        
        // 上下垂直间隔
        self.minimumLineSpacing = kEmotionItemLineSpacing;
    }
    return self;
}

@end
