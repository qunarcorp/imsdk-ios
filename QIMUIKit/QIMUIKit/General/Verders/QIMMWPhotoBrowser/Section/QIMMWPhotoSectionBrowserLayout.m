//
//  QIMMWPhotoSectionBrowserLayout.m
//  QIMUIKit
//
//  Created by lilu on 2018/12/12.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMMWPhotoSectionBrowserLayout.h"

@implementation QIMMWPhotoSectionBrowserLayout

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = CGSizeMake(SCREEN_WIDTH / 4.0, SCREEN_WIDTH / 4.0);
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        self.headerReferenceSize=CGSizeMake(SCREEN_WIDTH, 30);//头视图的大小
        self.sectionHeadersPinToVisibleBounds = YES;
    }
    return self;
}

@end
