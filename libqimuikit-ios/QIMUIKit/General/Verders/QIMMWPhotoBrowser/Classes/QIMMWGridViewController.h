//
//  QIMMWGridViewController.h
//  QIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import "QIMCommonUIFramework.h"
#import "QIMMWPhotoBrowser.h"

@interface QIMMWGridViewController : UICollectionViewController {}

@property (nonatomic, assign) QIMMWPhotoBrowser *browser;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) CGPoint initialContentOffset;

- (void)adjustOffsetsAsRequired;

@end
