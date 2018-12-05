//
//  TextCellCaChe.m
//  feiliao
//
//  Created by lidong cao on 12-11-29.
//  Copyright (c) 2012年 feinno.com. All rights reserved.
//

#import "TextCellCaChe.h"

@implementation TextCellCache

@synthesize attString;
@synthesize textSize;
@synthesize CellSize;
@synthesize images;
@synthesize linkArray;
@synthesize image;
@synthesize frameRef = _frameRef;

- (void)setFrameRef:(CTFramesetterRef)frameRef
{
    if (frameRef) {
        if (_frameRef) {
            CFRelease(_frameRef);
            _frameRef = CFRetain(frameRef);
        }else{
            _frameRef = CFRetain(frameRef);
        }
    }else{
        if (_frameRef) {
            CFRelease(_frameRef);
            _frameRef = NULL;
        }
    }
}

- (void)dealloc
{
    [self setLinkArray:nil];
    [self setImages:nil];
    [self setImage:nil];
    attString = nil;
    if (_frameRef) {
        CFRelease(_frameRef);
    }
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"TextCellCache { \r"];
    [str appendFormat:@"attString = %@,\r",attString];
    [str appendFormat:@"images = %@,\r",images];
    [str appendFormat:@"image = %@ \r",image];
    [str appendFormat:@"textSize = %@",NSStringFromCGSize(textSize)];
    [str appendFormat:@"CellSize = %@",NSStringFromCGSize(CellSize)];
    [str appendFormat:@"}\r"];
    return str;
}

@end
