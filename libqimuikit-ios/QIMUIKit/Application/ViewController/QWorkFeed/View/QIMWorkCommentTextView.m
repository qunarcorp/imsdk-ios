//
//  QIMWorkCommentTextView.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/10.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkCommentTextView.h"

@implementation QIMWorkCommentTextView

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    return CGRectMake(bounds.origin.x + 18, bounds.origin.y, bounds.size.width - 36, bounds.size.height);
}

@end
