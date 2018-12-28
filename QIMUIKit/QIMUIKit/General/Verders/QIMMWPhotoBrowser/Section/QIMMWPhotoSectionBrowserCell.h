//
//  QIMMWPhotoSectionBrowserCell.h
//  QIMUIKit
//
//  Created by lilu on 2018/12/12.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QIMMWPhoto.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QIMMWTypePhoto,
    QIMMWTypeGif,
    QIMMWTypeVideo,
} QIMMWType;

@class QIMMWPhotoSectionBrowserCell;

@protocol QIMMWPhotoSectionBrowserChooseDelegate <NSObject>

- (void)selectedQIMMWPhotoSectionBrowserChoose:(QIMMWPhoto *)photo;

- (void)deSelectedQIMMWPhotoSectionBrowserChoose:(QIMMWPhoto *)photo;

@end

@interface QIMMWPhotoSectionBrowserCell : UICollectionViewCell

@property (nonatomic, strong) NSURL *thumbUrl;

@property (nonatomic, assign) BOOL reloaded;

@property (nonatomic, assign) QIMMWType type;

@property (nonatomic, assign) NSString *videoDuration;

@property (nonatomic, assign) BOOL shouldChooseFlag;

@property (nonatomic, strong) QIMMWPhoto *photo;

@property (nonatomic, weak) id <QIMMWPhotoSectionBrowserChooseDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
