//
//  UIViewTap.h
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@protocol QIMMWTapDetectingViewDelegate;

@interface QIMMWTapDetectingView : UIView {}

@property (nonatomic, weak) id <QIMMWTapDetectingViewDelegate> tapDelegate;

@end

@protocol QIMMWTapDetectingViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end
