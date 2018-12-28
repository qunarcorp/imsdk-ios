//
//  QIMButton.h
//  QIMUIVendorKit
//
//  Created by 李露 on 11/9/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    QIMButtonImageAlignmentLeft = 0,
    QIMButtonImageAlignmentTop,
    QIMButtonImageAlignmentBottom,
    QIMButtonImageAlignmentRight,
} QIMButtonImageAlignment;

@interface QIMButton : UIButton

/**
 *  按钮中图片的位置
 */
@property(nonatomic,assign) QIMButtonImageAlignment imageAlignment;
/**
 *  按钮中图片与文字的间距
 */
@property(nonatomic,assign)CGFloat spaceBetweenTitleAndImage;

@end
