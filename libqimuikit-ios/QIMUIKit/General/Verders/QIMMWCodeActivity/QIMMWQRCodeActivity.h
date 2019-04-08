//
//  QIMMWQRCodeActivity.h
//  QIMUIKit
//
//  Created by 李露 on 2018/6/27.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMMWPhotoBrowser.h"

@interface QIMMWQRCodeActivity : NSObject

@property (nonatomic, weak) QIMMWPhotoBrowser *fromPhotoBrowser;

+ (instancetype)sharedInstance;

- (BOOL)canPerformQRCodeWithImage:(UIImage *)image;

- (void)performActivity;

@end
