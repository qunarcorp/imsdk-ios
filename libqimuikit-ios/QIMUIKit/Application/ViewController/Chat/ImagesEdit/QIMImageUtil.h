//
//  RootViewController.h
//  pictureProcess
//
//  Created by Ibokan on 12-9-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "QIMCommonUIFramework.h"

@interface QIMImageUtil : NSObject 

+ (UIImage *)imageWithImage:(UIImage*)inImage withColorMatrix:(const float*)f;

//图片旋转
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

+ (UIImage *)fixOrientation:(UIImage *)aImage rotation:(UIImageOrientation)orientation;

+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 subRect:(CGRect)rect;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end
