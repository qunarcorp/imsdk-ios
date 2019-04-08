//
//  AutoImageView.h
//  QunarUGC
//
//  Created by Tianxiaorong on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface LvtuAutoImageView : UIImageView<NSURLConnectionDelegate>
{

}

@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) id info;
@property (nonatomic, retain) UIImage *defaultImage;

- (void)addTarget:(id)target action:(SEL)action;

@end
