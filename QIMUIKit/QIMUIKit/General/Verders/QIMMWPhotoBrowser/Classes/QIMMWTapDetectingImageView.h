//
//  UIImageViewTap.h
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@protocol QIMMWTapDetectingImageViewDelegate;

@interface QIMMWTapDetectingImageView : UIImageView {}

@property (nonatomic, weak) id <QIMMWTapDetectingImageViewDelegate> tapDelegate;

@end

@protocol QIMMWTapDetectingImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end
