//
//  ShapedImageView.h
//  JJTest
//
//  Created by chenjie on 16/1/4.
//  Copyright © 2016年 chenjie. All rights reserved.
//

#import "QIMCommonUIFramework.h"

typedef enum {
    ShapedImageViewDirectionLeft,
    ShapedImageViewDirectionRight,
}ShapedImageViewDirection;

@interface ShapedImageView : UIImageView

@property (nonatomic,assign) ShapedImageViewDirection   direction;

- (void)setup;

@end
