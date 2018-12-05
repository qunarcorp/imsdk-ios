//
//  LineView.m
//  QunariPhone
//
//  Created by 姜琢 on 12-11-21.
//  Copyright (c) 2012年 Qunar.com. All rights reserved.
//

#import "LineView.h"

@implementation LineView

static CGFloat const kDashedLinesLength[] = {2.0f, 5.0f};
static NSInteger const kDefaultLineColor[] = {0x191919, 0x4a4a4a};
static NSInteger const kDefaultDottedLineColor[] = {0xd3dada, 0xbfc8c8};

// 创建
- (id)init
{
    if((self = [super init]) != nil)
    {
		_isVertical = NO;
		_isDotted = NO;
        
		
        [self setBackgroundColor:[UIColor clearColor]];
    }
	
    return self;
}

- (id)initWithFrame:(CGRect)frameInit
{
	if((self = [super initWithFrame:frameInit]) != nil)
    {
        [self setBackgroundColor:[UIColor clearColor]];
		
		_isVertical = NO;
		_isDotted = NO;
		_arrayColor = [NSArray arrayWithObjects:
					   [UIColor qim_colorWithHex:kDefaultLineColor[0] alpha:1.0f],
					   [UIColor qim_colorWithHex:kDefaultLineColor[1] alpha:1.0f],
					   nil];
		
        [self setBackgroundColor:[UIColor clearColor]];
    }
	
    return self;
}

- (id)initDottedWithFrame:(CGRect)frameInit
{
	if((self = [super initWithFrame:frameInit]) != nil)
    {
        [self setBackgroundColor:[UIColor clearColor]];
		
		_isVertical = NO;
		_isDotted = YES;
		_arrayColor = [NSArray arrayWithObjects:
					   [UIColor qim_colorWithHex:kDefaultDottedLineColor[0] alpha:1.0f],
					   [UIColor qim_colorWithHex:kDefaultDottedLineColor[1] alpha:1.0f],
					   nil];
		
        [self setBackgroundColor:[UIColor clearColor]];
		[[self layer] setMasksToBounds:YES];
    }
	
    return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
    [self setNeedsDisplay];
}

// 重写绘制
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
	if (_isVertical)
	{
		CGFloat LineWidth = rect.size.width / [_arrayColor count];
		CGFloat spaceXStart = LineWidth/2;
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextBeginPath(context);
		
		CGContextSetLineWidth(context, LineWidth);
		
		for (UIColor *color in _arrayColor)
		{
			CGContextSetStrokeColorWithColor(context, color.CGColor);
			
			if (_isDotted)
			{
				CGContextSetLineDash(context, 0, kDashedLinesLength, 2);
				CGContextMoveToPoint(context, spaceXStart, 0.0);
				
				// 绘制虚线到整数个位置, 优化UI效果
				CGContextAddLineToPoint(context, spaceXStart, (NSInteger)(rect.size.height / (kDashedLinesLength[0] + kDashedLinesLength[1])) * (kDashedLinesLength[0] + kDashedLinesLength[1]));
				
				CGContextStrokePath(context);
			}
			else
			{
				CGContextMoveToPoint(context, spaceXStart, 0.0);
				CGContextAddLineToPoint(context, spaceXStart, rect.size.height);
				
				CGContextStrokePath(context);
			}
			
			spaceXStart += LineWidth;
		}
	}
	else
	{
		CGFloat LineWidth = rect.size.height / [_arrayColor count];
		CGFloat spaceYStart = LineWidth/2;
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextBeginPath(context);
		
		// 绘制虚线到整数个位置, 优化UI效果
		CGContextSetLineWidth(context, LineWidth);
		
		for (UIColor *color in _arrayColor)
		{
			CGContextSetStrokeColorWithColor(context, color.CGColor);
			
			if (_isDotted)
			{
				CGContextSetLineDash(context, 0, kDashedLinesLength,2);
				CGContextMoveToPoint(context, 0.0, spaceYStart);
				CGContextAddLineToPoint(context, (NSInteger)(rect.size.width / (kDashedLinesLength[0] + kDashedLinesLength[1])) * (kDashedLinesLength[0] + kDashedLinesLength[1]), spaceYStart);
				
				CGContextStrokePath(context);
			}
			else
			{
				CGContextMoveToPoint(context, 0.0, spaceYStart);
				CGContextAddLineToPoint(context, rect.size.width, spaceYStart);
				
				CGContextStrokePath(context);
			}
			
			spaceYStart += LineWidth;
		}
	}
}

@end
