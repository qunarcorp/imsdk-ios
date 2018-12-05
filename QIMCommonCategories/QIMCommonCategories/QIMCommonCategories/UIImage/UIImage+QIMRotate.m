//
//  UIImage+rotate.m
//  weibosdk
//
//  Created by Minwen Yi on 3/23/12.
//  Copyright 2012 Tencent. All rights reserved.
//

#import "UIImage+QIMRotate.h"

@implementation UIImage (QIMRotate)

-(UIImage*)qim_rotateImage:(UIImageOrientation)orient
{
	CGRect			bnds = CGRectZero;
	UIImage*		   copy = nil;
	CGContextRef	  ctxt = nil;
	CGRect			rect = CGRectZero;
	CGAffineTransform  tran = CGAffineTransformIdentity;
	bnds.size = self.size;
	rect.size = self.size;
	//CLog("%s, %d", __FUNCTION__, orient);
	switch (orient)
	{
		case UIImageOrientationUp:
			return self;
		case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
		case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, degreesToRadians(180.0));
			break;
		case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
		case UIImageOrientationLeft: {
			//CGFloat wd = bnds.size.width;
//			bnds.size.width = bnds.size.height;
//			bnds.size.height = wd;
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, degreesToRadians(-90.0));
		}
			break;
		case UIImageOrientationLeftMirrored: {
			//CGFloat wd = bnds.size.width;
//			bnds.size.width = bnds.size.height;
//			bnds.size.height = wd;
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, degreesToRadians(-90.0));
		}
			break;
		case UIImageOrientationRight: {
			CGFloat wd = bnds.size.width;
			bnds.size.width = bnds.size.height;
			bnds.size.height = wd;
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, degreesToRadians(90.0));
		}
			break;
		case UIImageOrientationRightMirrored: {
			//CGFloat wd = bnds.size.width;
//			bnds.size.width = bnds.size.height;
//			bnds.size.height = wd;
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, degreesToRadians(90.0));
		}
			break;
		default:
			// orientation value supplied is invalid
			assert(false);
			return nil;
	}
	UIGraphicsBeginImageContext(rect.size);
	ctxt = UIGraphicsGetCurrentContext();
	switch (orient)
	{
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			CGContextScaleCTM(ctxt, -1.0 * (rect.size.width / rect.size.height), 1.0 * (rect.size.height / rect.size.width));
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
		default:
			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
	}
	CGContextConcatCTM(ctxt, tran);
	CGContextDrawImage(ctxt, rect, self.CGImage);
	copy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return copy;
}

- (UIImage *)qim_grayImage{
//    const int ALPHA = 0;
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    int x_origin = 0;
    int y_to = height;
    
    for(int y = 0; y < y_to; y++) {
        for(int x = x_origin; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                uint32_t gray = (299 * rgbaPixel[RED] + 587 * rgbaPixel[GREEN] + 114* rgbaPixel[BLUE]) / 1000;
                //                uint32_t gray = rgbaPixel[GREEN];
                // set the pixels to gray
                rgbaPixel[RED] = gray;
                rgbaPixel[GREEN] = gray;
                rgbaPixel[BLUE] = gray;
        }
        
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:self.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;

}

// Reference: http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
- (UIImage *)qim_partialImageWithPercentage:(float)percentage vertical:(BOOL)vertical grayscaleRest:(BOOL)grayscaleRest {
    const int ALPHA = 0;
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);

    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    int x_origin = vertical ? 0 : width * percentage;
    int y_to = vertical ? height * (1.f -percentage) : height;
    
    for(int y = 0; y < y_to; y++) {
        for(int x = x_origin; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            if (grayscaleRest) {
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                uint32_t gray = (299 * rgbaPixel[RED] + 587 * rgbaPixel[GREEN] + 114* rgbaPixel[BLUE]) / 1000;
                //                uint32_t gray = rgbaPixel[GREEN];
                // set the pixels to gray
                rgbaPixel[RED] = gray;
                rgbaPixel[GREEN] = gray;
                rgbaPixel[BLUE] = gray;
            }
            else {
                rgbaPixel[ALPHA] = 0;
                rgbaPixel[RED] = 0;
                rgbaPixel[GREEN] = 0;
                rgbaPixel[BLUE] = 0;
            }
        }
    }
    
    
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:215.0/255 green:197.0/255 blue:19.0/255 alpha:0.2].CGColor);
    CGContextFillRect(context,  CGRectMake(0, 0, width, height));
    
    UIImage *maskImage = [UIImage imageNamed:@"sample_photo_old_1"];
    CGFloat maskWidth = width;
    CGFloat maskHeight = width / 294.0 * 140.0;
    CGContextDrawImage(context, CGRectMake((width - maskWidth)/2.0, (height - maskHeight)/2.0, maskWidth , maskHeight), [maskImage CGImage]);
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:self.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}


@end


