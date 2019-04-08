//
//  QIMMWPhotoSectionBrowserCollectionView.h
//  QIMUIKit
//
//  Created by lilu on 2018/12/12.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMMWPhotoSectionBrowserVC : UIViewController

@property (nonatomic, copy) NSString *xmppId;

@property (nonatomic, copy) NSString *realJid;

@property (nonatomic, assign) NSInteger chatType;

@end

NS_ASSUME_NONNULL_END
