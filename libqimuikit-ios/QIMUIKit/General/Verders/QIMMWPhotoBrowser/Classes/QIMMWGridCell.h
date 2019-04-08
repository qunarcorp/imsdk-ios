//
//  QIMMWGridCell.h
//  QIMMWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import "QIMCommonUIFramework.h"
#import "QIMMWPhoto.h"
#import "QIMMWGridViewController.h"

@interface QIMMWGridCell : UICollectionViewCell {}

@property (nonatomic, weak) QIMMWGridViewController *gridController;
@property (nonatomic) NSUInteger index;
@property (nonatomic) id <QIMMWPhoto> photo;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) BOOL isSelected;

- (void)displayImage;

@end
