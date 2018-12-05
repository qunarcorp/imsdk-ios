//
//  CTLabel.m
//  CoreTextTest
//
//  Created by admin on 12-11-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CTLabel.h"
#import "NSAttributedString+Attributes.h"
#import "CallPhoneTool.h"
#import "YLImageView.h"
#import "YLGIFImage.h"

#define OHAttributedLabel_WarnAboutKnownIssues 1

/////////////////////////////////////////////////////////////////////////////
// MARK: Private Utility methods

CGPoint CGPointFlipped(CGPoint point, CGRect bounds);
CGRect CGRectFlipped(CGRect rect, CGRect bounds);
NSRange NSRangeFromCFRange(CFRange range);
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin);
CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin);
BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range);
BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range);

/////////////////////////////////////////////////////////////////////////////
// MARK: -
/////////////////////////////////////////////////////////////////////////////


CTTextAlignment CTTextAlignmentFromUITextAlignment(NSTextAlignment alignment) {
	switch (alignment) {
		case NSTextAlignmentLeft: return kCTLeftTextAlignment;
		case NSTextAlignmentCenter: return kCTCenterTextAlignment;
		case NSTextAlignmentRight: return kCTRightTextAlignment;
		case UITextAlignmentJustify: return kCTJustifiedTextAlignment; /* special OOB value if we decide to use it even if it's not really standard... */
		default: return kCTNaturalTextAlignment;
	}
}

CTLineBreakMode CTLineBreakModeFromUILineBreakMode(NSLineBreakMode lineBreakMode) {
	switch (lineBreakMode) {
		case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
		case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
		case NSLineBreakByClipping: return kCTLineBreakByClipping;
		case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
		case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
		case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
		default: return 0;
	}
}

// Don't use this method for origins. Origins always depend on the height of the rect.
CGPoint CGPointFlipped(CGPoint point, CGRect bounds) {
	return CGPointMake(point.x, CGRectGetMaxY(bounds)-point.y);
}

CGRect CGRectFlipped(CGRect rect, CGRect bounds) {
	return CGRectMake(CGRectGetMinX(rect),
					  CGRectGetMaxY(bounds)-CGRectGetMaxY(rect),
					  CGRectGetWidth(rect),
					  CGRectGetHeight(rect));
}

NSRange NSRangeFromCFRange(CFRange range) {
	return NSMakeRange(range.location, range.length);
}

// Font Metrics: http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/FontHandling/Tasks/GettingFontMetrics.html
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin) {
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	CGFloat height = ascent + descent /* + leading */;
	
	return CGRectMake(lineOrigin.x,
					  lineOrigin.y - descent,
					  width,
					  height);
}

CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin) {
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
	CGFloat height = ascent + descent /* + leading */;
	
	CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
	
	return CGRectMake(lineOrigin.x + xOffset,
					  lineOrigin.y - descent,
					  width,
					  height);
}

BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range) {
	NSRange lineRange = NSRangeFromCFRange(CTLineGetStringRange(line));
	NSRange intersectedRange = NSIntersectionRange(lineRange, range);
	return (intersectedRange.length > 0);
}

BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range) {
	NSRange runRange = NSRangeFromCFRange(CTRunGetStringRange(run));
	NSRange intersectedRange = NSIntersectionRange(runRange, range);
	return (intersectedRange.length > 0);
}

@interface CTLabel(private)
-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx;
-(NSTextCheckingResult*)linkAtPoint:(CGPoint)pt;
-(NSMutableAttributedString*)attributedTextWithLinks;
-(void)resetTextFrame;
-(void)drawActiveLinkHighlightForRect:(CGRect)rect;
#if OHAttributedLabel_WarnAboutKnownIssues
-(void)warnAboutKnownIssues_CheckLineBreakMode;
-(void)warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth;
#endif
@end

@implementation CTLabel
@synthesize images;
@synthesize attributedText = _attributedText;
@synthesize automaticallyAddLinksForType;
@synthesize linkColor;
@synthesize highlightedLinkColor;
@synthesize underlineLinks;
@synthesize onlyCatchTouchesOnLinks;
@synthesize delegate;
@synthesize centerVertically;
@synthesize extendBottomToFit; 
@synthesize customLinks;
@synthesize frameRef = _frameRef;
static int theAutomaticallyAddLinksForType = 0;
static BOOL canOpenTelChecked = NO;
- (void)commonInit
{
	customLinks = [[NSMutableArray alloc] init];
    self.images = [NSMutableArray array];
	self.linkColor = [UIColor blueColor];
	self.highlightedLinkColor = [UIColor colorWithWhite:0.4 alpha:0.3];
	self.underlineLinks = YES;
	self.automaticallyAddLinksForType = NSTextCheckingTypeLink;

    if (!canOpenTelChecked) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:0"]]) {
            self.automaticallyAddLinksForType |= NSTextCheckingTypePhoneNumber;
            theAutomaticallyAddLinksForType |= NSTextCheckingTypePhoneNumber;
        }
        canOpenTelChecked = YES;
    }
    [self setAutomaticallyAddLinksForType:theAutomaticallyAddLinksForType];
    
	self.onlyCatchTouchesOnLinks = YES;
	self.userInteractionEnabled = YES;
	self.contentMode = UIViewContentModeRedraw;
	[self resetAttributedText];
}

- (id) initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	if (self != nil) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self != nil) {
		[self commonInit];
#if OHAttributedLabel_WarnAboutKnownIssues
		[self warnAboutKnownIssues_CheckLineBreakMode];
		[self warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth];
#endif
	}
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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

-(void)dealloc
{
    [self setImages:nil];
    [self setAttributedText:nil];
	[self resetTextFrame];
	self.linkColor = nil;
	self.highlightedLinkColor = nil;
	activeLink = nil;
    customLinks = nil;
    if (_frameRef) {
        CFRelease(_frameRef);
    }
}

#pragma mark - Link Method
-(void)addCustomLink:(NSURL*)linkUrl inRange:(NSRange)range {
	NSTextCheckingResult* link = [NSTextCheckingResult linkCheckingResultWithRange:range URL:linkUrl];
	[customLinks addObject:link];
	[self setNeedsDisplay];
}

-(void)removeAllCustomLinks {
	[customLinks removeAllObjects];
	[self setNeedsDisplay];
}

-(NSMutableAttributedString*)attributedTextWithLinks {
    return [self.attributedText mutableCopy];
	NSMutableAttributedString* str = [self.attributedText mutableCopy];
	if (str == nil && str.length <= 0) {
        return nil;
    }
	NSString* plainText = [str string];
	if (plainText && (self.automaticallyAddLinksForType > 0)) {
		NSError* error = nil;
		NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:self.automaticallyAddLinksForType error:&error];
		[linkDetector enumerateMatchesInString:plainText options:0 range:NSMakeRange(0,[plainText length])
									usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		 {
			 int32_t uStyle = self.underlineLinks ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone;
             UIColor* thisLinkColor = self.linkColor;
             if (delegate && [delegate respondsToSelector:@selector(colorForLink:underlineStyle:)]) {
                 thisLinkColor = [self.delegate colorForLink:result underlineStyle:&uStyle];
             }
			 if (thisLinkColor)
				 [str setTextColor:thisLinkColor range:[result range]];
			 if (uStyle>0)
				 [str setTextUnderlineStyle:uStyle range:[result range]];
		 }];
	}
	[customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 NSTextCheckingResult* result = (NSTextCheckingResult*)obj;
		 
		 int32_t uStyle = self.underlineLinks ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone;
		 UIColor* thisLinkColor = self.linkColor;
         if (delegate && [delegate respondsToSelector:@selector(colorForLink:underlineStyle:)]) {
             thisLinkColor = [self.delegate colorForLink:result underlineStyle:&uStyle];
         }
		 @try {
			 if (thisLinkColor)
				 [str setTextColor:thisLinkColor range:[result range]];
			 if (uStyle>0)
				 [str setTextUnderlineStyle:uStyle range:[result range]];
		 }
		 @catch (NSException * e) {
			 // Protection against NSRangeException
			 if ([[e name] isEqualToString:NSRangeException]) {
				 QIMVerboseLog(@"[CTLabel] exception: %@",e);
			 } else {
				 @throw;
			 }
		 }
	 }];
	return str;
}

-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx {
	__block NSTextCheckingResult* foundResult = nil;
	__block BOOL needCheck = YES;
	NSString* plainText = [self.attributedText string];
	if (plainText && (self.automaticallyAddLinksForType > 0)) {
		NSError* error = nil;
		NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:self.automaticallyAddLinksForType error:&error];
            QIMVerboseLog(@"..%@",@([linkDetector numberOfCaptureGroups]));
		[linkDetector enumerateMatchesInString:plainText options:0 range:NSMakeRange(0,[plainText length])
									usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		 {
			 NSRange r = [result range];
			 if (NSLocationInRange(idx, r)) {
				 foundResult = result;
				 *stop = YES;
                 needCheck = NO;
			 }
		 }];
		if (foundResult) return foundResult;
	}
	if (needCheck) {
        [customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger aidx, BOOL *stop)
         {
             NSRange r = [(NSTextCheckingResult*)obj range];
             if (NSLocationInRange(idx, r)) {//链接字体位置和长度
                 foundResult = obj;
                 *stop = YES;
             }
         }];
    }
	return foundResult;
}

-(NSTextCheckingResult*)linkAtPoint:(CGPoint)point {
	static const CGFloat kVMargin = 5.f;
	if (!CGRectContainsPoint(CGRectInset(drawingRect, 0, -kVMargin), point)) return nil;
	
	CFArrayRef lines = CTFrameGetLines(textFrame);
	if (!lines) return nil;
	CFIndex nbLines = CFArrayGetCount(lines);
	NSTextCheckingResult* link = nil;
	
	CGPoint origins[nbLines];
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
	
	for (int lineIndex=0 ; lineIndex<nbLines ; ++lineIndex) {
		// this actually the origin of the line rect, so we need the whole rect to flip it
		CGPoint lineOriginFlipped = origins[lineIndex];
		
		CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
		CGRect lineRectFlipped = CTLineGetTypographicBoundsAsRect(line, lineOriginFlipped);
		CGRect lineRect = CGRectFlipped(lineRectFlipped, CGRectFlipped(drawingRect,self.bounds));
		
		lineRect = CGRectInset(lineRect, 0, -kVMargin);
		if (CGRectContainsPoint(lineRect, point)) {
			CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(lineRect),
												point.y-CGRectGetMinY(lineRect));
			CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
			link = ([self linkAtCharacterIndex:idx]);
			if (link) return link;
		}
	}
	return nil;
}


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	// never return self. always return the result of [super hitTest..].
	// this takes userInteraction state, enabled, alpha values etc. into account
	UIView *hitResult = [super hitTest:point withEvent:event];
	
	// don't check for links if the event was handled by one of the subviews
	if (hitResult != self) {
		return hitResult;
	}
	if ([customLinks count] <= 0) {
        return nil;
    } else{
        if (self.onlyCatchTouchesOnLinks) {
            BOOL didHitLink = ([self linkAtPoint:point] != nil);
            if (!didHitLink) {
                // not catch the touch if it didn't hit a link
                return nil;
            }
        }
        return hitResult;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([customLinks count] <= 0) {
        return;
    }
    
	UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	
	activeLink = [self linkAtPoint:pt];
	touchStartPoint = pt;
	
	// we're using activeLink to draw a highlight in -drawRect:
	[self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([customLinks count] <= 0) {
        return;
    }
	UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	
	NSTextCheckingResult *linkAtTouchesEnded = [self linkAtPoint:pt];
	
	BOOL closeToStart = (fabs(touchStartPoint.x - pt.x) < 10 && fabs(touchStartPoint.y - pt.y) < 10);
    
	// we can check on equality of the ranges themselfes since the data detectors create new results
	if (activeLink && (NSEqualRanges(activeLink.range,linkAtTouchesEnded.range) || closeToStart)) {
		BOOL openLink = (self.delegate && [self.delegate respondsToSelector:@selector(attributedLabel:shouldFollowLink:)])
		? [self.delegate attributedLabel:self shouldFollowLink:activeLink] : YES;
		if (openLink){
            if ([self.delegate respondsToSelector:@selector(openURL:)]) {
                [self.delegate openURL:activeLink.URL];
            }else{
                [[UIApplication sharedApplication] openURL:activeLink.URL];
            }
        }else{
            NSString  *telphone= [NSString stringWithFormat:@"tel://%@",activeLink.phoneNumber];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:telphone]])
            {
                [[CallPhoneTool sharedInstance] CallPhone:[NSString stringWithFormat:@"%@",activeLink.phoneNumber]];
            }
            else
            { 
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"当前设备不支持打电话" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                alertView = nil;
                
            }
        }
	}
	
	activeLink = nil;
	[self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	activeLink = nil;
	[self setNeedsDisplay];
}

#pragma mark = drawing text

-(void)resetTextFrame {
	if (textFrame) {
		CFRelease(textFrame);
		textFrame = NULL;
	}
}

- (void)drawTextInRect:(CGRect)aRect
{
    [self removeAllSubviews];
	if (_attributedText) {
        NSMutableAttributedString *attributedText = [_attributedText mutableCopy];
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		
		// flipping the context to draw core text
		// no need to flip our typographical bounds from now on
		CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.0f, -1.0f));
		
		if (self.shadowColor) {
			CGContextSetShadowWithColor(ctx, self.shadowOffset, 0.0, self.shadowColor.CGColor);
		}
		
//		NSMutableAttributedString* attrStrWithLinks = [self attributedTextWithLinks];
		if (self.highlighted && self.highlightedTextColor != nil) {
			[attributedText setTextColor:self.highlightedTextColor];
		}
        if (_frameRef == nil) {
            _frameRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
        }
        //CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
        drawingRect = self.bounds;
        if (self.centerVertically || self.extendBottomToFit) {
            CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(_frameRef,CFRangeMake(0,0),NULL,CGSizeMake(drawingRect.size.width,CGFLOAT_MAX),NULL);
            if (self.extendBottomToFit) {
                CGFloat delta = MAX(0.f , ceilf(sz.height - drawingRect.size.height)) + 10 /* Security margin */;
                drawingRect.origin.y -= delta;
                drawingRect.size.height += delta;
            }
            if (self.centerVertically) {
                drawingRect.origin.y -= (drawingRect.size.height - sz.height)/2;
            }
        }
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, drawingRect);
        [self resetTextFrame];
        textFrame = CTFramesetterCreateFrame(_frameRef,CFRangeMake(0,attributedText.length), path, NULL);
        CTFrameDraw(textFrame, ctx);
        if ([self.images count]) {
            [self attachImagesWithFrame:textFrame withImages:self.images withContext:ctx];
        }
        CGPathRelease(path);
		
		// draw highlights for activeLink
		if (activeLink) {
			[self drawActiveLinkHighlightForRect:drawingRect];
		}
		
		
		CGContextRestoreGState(ctx);
        [self setFont:[UIFont systemFontOfSize:14.0]];
	} else {
		[super drawTextInRect:aRect];
	}
}

-(void)drawActiveLinkHighlightForRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y));
	[self.highlightedLinkColor setFill];
	
	NSRange activeLinkRange = activeLink.range;
	
	CFArrayRef lines = CTFrameGetLines(textFrame);
	CFIndex lineCount = CFArrayGetCount(lines);
	CGPoint lineOrigins[lineCount];
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), lineOrigins);
	for (CFIndex lineIndex = 0; lineIndex < lineCount; lineIndex++) {
		CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
		
		if (!CTLineContainsCharactersFromStringRange(line, activeLinkRange)) {
			continue; // with next line
		}
		
		// we use this rect to union the bounds of successive runs that belong to the same active link
		CGRect unionRect = CGRectZero;
		
		CFArrayRef runs = CTLineGetGlyphRuns(line);
		CFIndex runCount = CFArrayGetCount(runs);
		for (CFIndex runIndex = 0; runIndex < runCount; runIndex++) {
			CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
			
			if (!CTRunContainsCharactersFromStringRange(run, activeLinkRange)) {
				if (!CGRectIsEmpty(unionRect)) {
					CGContextFillRect(ctx, unionRect);
					unionRect = CGRectZero;
				}
				continue; // with next run
                
			}
			
			CGRect linkRunRect = CTRunGetTypographicBoundsAsRect(run, line, lineOrigins[lineIndex]);
			linkRunRect = CGRectIntegral(linkRunRect);		// putting the rect on pixel edges
			linkRunRect = CGRectInset(linkRunRect, -1, -1);	// increase the rect a little
			if (CGRectIsEmpty(unionRect)) {
				unionRect = linkRunRect;
			} else {
				unionRect = CGRectUnion(unionRect, linkRunRect);
			}
		}
		if (!CGRectIsEmpty(unionRect)) {
			CGContextFillRect(ctx, unionRect);
			//unionRect = CGRectZero;
		}
	}
	CGContextRestoreGState(ctx);
}

- (CGSize)sizeThatFits:(CGSize)size {
	NSMutableAttributedString* attrStrWithLinks = [self attributedTextWithLinks];
	if (!attrStrWithLinks) return CGSizeZero;
	return [attrStrWithLinks sizeConstrainedToSize:size fitRange:NULL];
}

#pragma mark - Setters/Getters
-(void)resetAttributedText {
	NSMutableAttributedString* mutAttrStr = [NSMutableAttributedString attributedStringWithString:self.text];
	[mutAttrStr setFont:self.font];
	[mutAttrStr setTextColor:self.textColor];
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[mutAttrStr setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	self.attributedText = mutAttrStr;
}

-(NSAttributedString*)attributedText {
	if (!_attributedText) {
		[self resetAttributedText];
	}
	return [_attributedText copy]; // immutable autoreleased copy
}

-(void)setAttString:(NSAttributedString *)string withImages:(NSMutableArray *)imgs
{
    self.images = imgs;
    //QIMVerboseLog(@"count %d",[self.images count]);
    [self setAttributedText:string];
}

-(void)attachImagesWithFrame:(CTFrameRef)f withImages:(NSMutableArray *)imags withContext:(CGContextRef) ctx//inColumnView:(OHAttributedLabel*)col
{
    //drawing images
    NSArray *lines = (NSArray *)CTFrameGetLines(f); //1
    
    NSMutableArray *imgs = [NSMutableArray array];
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins); //2
    
    int imgIndex = 0; //3
    NSDictionary* nextImage = [imags objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];
    
    //find images for the current column
//    CFRange frameRange = CTFrameGetVisibleStringRange(f); //4
//    while ( imgLocation < frameRange.location ) {
//        imgIndex++;
//        if (imgIndex>=[imags count]) return; //quit if no images for this column
//        nextImage = [imags objectAtIndex:imgIndex];
//        imgLocation = [[nextImage objectForKey:@"location"] intValue];
//    }
    
    if (!_imagesRect) {
        _imagesRect = [NSMutableArray arrayWithCapacity:1];
    }else{
        [_imagesRect removeAllObjects];
    }
    
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) { //5
        CTLineRef line = (__bridge CTLineRef)lineObj;
        
        for (id runObj in (NSArray *)CTLineGetGlyphRuns(line)) { //6
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            
            if ( runRange.location <= imgLocation && runRange.location+runRange.length > imgLocation ) { 
	            CGRect runBounds;
	            CGFloat ascent;//height above the baseline
	            CGFloat descent;//height below the baseline
	            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
	            runBounds.size.height = ascent + descent;
                
	            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL) + 1; //9
	            runBounds.origin.x = origins[lineIndex].x  + xOffset;
	            runBounds.origin.y = origins[lineIndex].y;
	            runBounds.origin.y -= descent;
                //QIMVerboseLog(@"name %@",[nextImage objectForKey:@"fileName"]);
                BOOL isEmotion = [[nextImage objectForKey:@"Emotion"] boolValue];
                BOOL isGif = [[nextImage objectForKey:@"IsGif"] boolValue];
                id existsImage = [nextImage objectForKey:@"image"];
                if (isEmotion) {
                    CGPathRef pathRef = CTFrameGetPath(f); //10
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                    
                    if (existsImage) {
                        [imgs addObject: //11
                         @{
                           @"path" : [nextImage objectForKey:@"fileName"]?[nextImage objectForKey:@"fileName"]:@"",
                           @"rect" : NSStringFromCGRect(imgBounds),
                           @"type" : @"normal",
                           @"image" : existsImage,
                           }
                         //                     , NSStringFromCGRect(imgBounds), nil]
                         ];
                    } else {
                        [imgs addObject: //11
                         @{
                           @"path" : [nextImage objectForKey:@"fileName"]?[nextImage objectForKey:@"fileName"]:@"",
                           @"rect" : NSStringFromCGRect(imgBounds),
                           @"type" : @"normal",
                           }
                         //                     , NSStringFromCGRect(imgBounds), nil]
                         ];
                    }
                } else if (isGif){
                    CGPathRef pathRef = CTFrameGetPath(f); //10
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                    
                    id myimg = [nextImage objectForKey:@"receiveImage"];
                    
                    if (myimg) {
                        [imgs addObject: //11
                         @{@"path" : [nextImage objectForKey:@"fileName"]?[nextImage objectForKey:@"fileName"]:@"",
                           @"rect" : NSStringFromCGRect(imgBounds),
                           @"image" : myimg,
                           @"type" : @"gif",
                           }
                         ];
                    } else {
                        [imgs addObject: //11
                         @{
                           @"path" : [nextImage objectForKey:@"fileName"]?[nextImage objectForKey:@"fileName"]:@"",
                           @"rect" : NSStringFromCGRect(imgBounds),
                           @"type" : @"gif",
                           }
                         ];
                    }
                    
//                    imgBounds.origin.y = imgBounds.origin.y - origins[lineIndex].y + origins[lines.count - 1 - lineIndex].y;
                    //文字链接图片混排图片frame不准BUG
//                    if (self.customLinks.count) {
//                        imgBounds.origin.y = ([lines count] > 1) ?   MAX(0, imgBounds.origin.y - imgBounds.size.height + [[QIMCommonFont sharedInstance] currentFontSize] - 4) : 2;
//                    }
//                    imgBounds.origin.y = ([lines count] > 1) ?   MAX(0, imgBounds.origin.y - imgBounds.size.height + [[QIMCommonFont sharedInstance] currentFontSize] - 4) : 2;
//                    UIView *localView = [[UIView alloc] initWithFrame:imgBounds];
//                    [localView setBackgroundColor:[UIColor redColor]];
//                    [self addSubview:localView];
                    
//                    [_imagesRect addObject:localView];
                    
                } else {
                    
                    if ([nextImage objectForKey:@"image"]) {
                        
                        CGPathRef pathRef = CTFrameGetPath(f); //10
                        CGRect colRect = CGPathGetBoundingBox(pathRef);
                        CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                        [imgs addObject: //11
                         @{@"image" : [nextImage objectForKey:@"image"],
                           @"rect" : NSStringFromCGRect(imgBounds),
                           @"type" : @"image",
                           }
                         //                     [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds), nil]
                         ];
                    } else {
                        NSString *path = [nextImage objectForKey:@"fileName"];
                        
                        UIImage *img = [UIImage qim_animatedImageWithAnimatedGIFData:[[QIMKit sharedInstance] getFileDataFromUrl:path width:100 height:150 forCacheType:QIMFileCacheTypeColoction]];
                        
                        if (img == nil) {
                            img = [UIImage qim_animatedImageWithAnimatedGIFURL:[NSURL URLWithString:[nextImage objectForKey:@"filePath"]]];
                        }
                        if (img == nil) {
                            img = [UIImage imageWithData:[[QIMKit sharedInstance] getFileDataFromUrl:[nextImage objectForKey:@"fileName"] width:100 height:150 forCacheType:QIMFileCacheTypeColoction]];
                        }
                        if (img == nil) {
                            img = [UIImage imageNamed: [nextImage objectForKey:@"fileName"]];
                        }
                        if (!img && [[nextImage objectForKey:@"fileName"] isEqualToString:@"imageData"]) {
                            img = [nextImage objectForKey:@"receiveImage"];
                        }
                        CGPathRef pathRef = CTFrameGetPath(f); //10
                        CGRect colRect = CGPathGetBoundingBox(pathRef);
                        CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                        if (img) {
                            [imgs addObject: //11
                             @{@"image" : img,
                               @"rect" : NSStringFromCGRect(imgBounds),
                               @"type" : @"image",
                               }
                             //                     [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds), nil]
                             ];
                            
                        } else {
                            [imgs addObject: //11
                             @{
                               @"rect" : NSStringFromCGRect(imgBounds),
                               @"type" : @"image",
                               }
                             //                     [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds), nil]
                             ];
                            
                        }
                    }
                    
                    
                    
//                    imgBounds.origin.y = imgBounds.origin.y - origins[lineIndex].y + origins[lines.count - 1 - lineIndex].y;
                    //文字链接图片混排图片frame不准BUG
//                    if (self.customLinks.count) {
//                        imgBounds.origin.y = ([lines count] > 1) ?   MAX(0, imgBounds.origin.y - imgBounds.size.height + [[QIMCommonFont sharedInstance] currentFontSize] - 4) : 2;
//                    }
//                    imgBounds.origin.y = ([lines count] > 1) ?   MAX(0, imgBounds.origin.y - imgBounds.size.height + [[QIMCommonFont sharedInstance] currentFontSize] - 4) : 2;
//                    UIView *localView = [[UIView alloc] initWithFrame:imgBounds];
//                    [localView setBackgroundColor:[UIColor redColor]];
//                    [self addSubview:localView];
                    
//                    [_imagesRect addObject:localView];
                }
                
//                UIImage *img = [UIImage imageNamed: [nextImage objectForKey:@"fileName"] ];
                //QIMVerboseLog(@"img %@",img);
               
                //load the next image //12
                imgIndex++;
                if (imgIndex < [self.images count]) {
                    nextImage = [self.images objectAtIndex: imgIndex];
                    imgLocation = [[nextImage objectForKey: @"location"] intValue];
                }
                
            }
        }
        lineIndex++;
    }
    
    if ([lines count] == 0 && [images count]>0) {
        
    }
    
    for (NSDictionary* imageData in imgs)
    {
        if (imageData.count < 2) {
            return;
        }
        
        CGRect imgBounds = CGRectFromString([imageData objectForKey:@"rect"]);
        imgBounds.origin.y = self.height - imgBounds.origin.y - imgBounds.size.height + 3;
        YLImageView *imageView = [[YLImageView alloc] initWithFrame:imgBounds];
        [self addSubview:imageView];
        
        UIImage *image = [imageData objectForKey:@"image"];
        if (image) {
//            [imageView setHidden:NO];
//            [self.layer removeAllAnimations];
            
            [imageView setImage:image];
        } else {
//            [imageView setHidden:YES];
//            [imageView setImage:[YLGIFImage imageWithContentsOfFile:[imageData objectForKey:@"path"]]];
//            CABasicAnimation* rotationAnimation;
//            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
//            rotationAnimation.duration = 0.5;
//            rotationAnimation.cumulative = YES;
//            rotationAnimation.repeatCount = HUGE_VALF;
//            
//            [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        }
        
        if ([imageView image])
            [_imagesRect addObject:imageView];

        

        

//        
//        id value = [imageData objectAtIndex:0];
//        CGRect imgBounds = CGRectFromString([imageData objectAtIndex:1]);
//        if ([value isKindOfClass:[NSString class]]) {
//            imgBounds.origin.y = self.height - imgBounds.origin.y - imgBounds.size.height + 3;
//            YLImageView *imageView = [[YLImageView alloc] initWithFrame:imgBounds];
//            [self addSubview:imageView];
////            imageView.image = [YLGIFImage imageNamed:value];
////            if (!imageView.image) {
//            //
//            // 写的太飘逸了我了个去。。。
//            UIImage * image = [imageData objectAtIndex:2];
//            
//            imageView.image = image;//[YLGIFImage imageWithContentsOfFile:value];
////            }
//        } else {
//            UIImage* img = [imageData objectAtIndex:0];
//            imgBounds.origin.y -= 3;
//            CGContextDrawImage(ctx, imgBounds, img.CGImage);
//        }
    }
    
}

- (NSInteger)indexForCellImagesAtLocation:(CGPoint)location
{
    if ([_imagesRect count] == 1) {
        return 0;
    }
    
    NSInteger i = 0;
    float currentY = 0;
    for (UIView * view in _imagesRect) {
        CGRect rect = view.frame;
        if (rect.size.height < 20) {
            rect.origin.y = MAX(rect.origin.y, currentY);
            rect.size.height = 20;
        }
        currentY = MAX(currentY, rect.origin.y + rect.size.height);
        if (CGRectContainsPoint(rect, location)) {
            return i;
        }
        i ++;
    }
    return -1;
}

//- (NSInteger)indexForCellImagesAtLocation:(CGPoint)location
//{
//    NSInteger i = 0;
//    for (UIView * view in _imagesRect) {
//        if (CGRectContainsPoint(view.frame, location)) {
//            return i;
//        }
//        i ++;
//    }
//    return -1;
//}

-(void)setAttributedText:(NSAttributedString*)newAttributedText {
	_attributedText = [newAttributedText mutableCopy];
//	[self removeAllCustomLinks];
	[self setNeedsDisplay];
}

/////////////////////////////////////////////////////////////////////////////

-(void)setText:(NSString *)text {
	NSString* cleanedText = [[text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]
							 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[super setText:cleanedText]; // will call setNeedsDisplay too
	[self resetAttributedText];
}
-(void)setFont:(UIFont *)font {
	[_attributedText setFont:font];
	[super setFont:font]; // will call setNeedsDisplay too
}
-(void)setTextColor:(UIColor *)color {
	[_attributedText setTextColor:color];
	[super setTextColor:color]; // will call setNeedsDisplay too
}
-(void)setTextAlignment:(NSTextAlignment)alignment {
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(alignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	[super setTextAlignment:alignment]; // will call setNeedsDisplay too
}
-(void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	
	[super setLineBreakMode:lineBreakMode]; // will call setNeedsDisplay too
	
#if OHAttributedLabel_WarnAboutKnownIssues
	[self warnAboutKnownIssues_CheckLineBreakMode];
#endif	
}
-(void)setCenterVertically:(BOOL)val {
	centerVertically = val;
	[self setNeedsDisplay];
}

-(void)setAutomaticallyAddLinksForType:(NSTextCheckingTypes)types {
	automaticallyAddLinksForType = types;
	[self setNeedsDisplay];
}

-(void)setExtendBottomToFit:(BOOL)val {
	extendBottomToFit = val;
	[self setNeedsDisplay];
}

#pragma mark - UILabel unsupported features/known issues warnings
#if OHAttributedLabel_WarnAboutKnownIssues
-(void)warnAboutKnownIssues_CheckLineBreakMode {
	BOOL truncationMode = (self.lineBreakMode == NSLineBreakByTruncatingHead)
	|| (self.lineBreakMode == NSLineBreakByTruncatingMiddle)
	|| (self.lineBreakMode == NSLineBreakByTruncatingTail);
	if (truncationMode) {
		QIMVerboseLog(@"[OHAttributedLabel] Warning: \"UILineBreakMode...Truncation\" lineBreakModes not yet fully supported by CoreText and OHAttributedLabel");
		QIMVerboseLog(@"                    (truncation will appear on each paragraph instead of the whole text)");
		QIMVerboseLog(@"                    This is a known issue (Help to solve this would be greatly appreciated).");
		QIMVerboseLog(@"                    See https://github.com/AliSoftware/OHAttributedLabel/issues/3");
	}
}
-(void)warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth {
	if (self.adjustsFontSizeToFitWidth) {
		QIMVerboseLog(@"[OHAttributedLabel] Warning: \"adjustsFontSizeToFitWidth\" property not supported by CoreText and OHAttributedLabel! This property will be ignored.");
	}	
}
-(void)setAdjustsFontSizeToFitWidth:(BOOL)value {
	[super setAdjustsFontSizeToFitWidth:value];
	[self warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth];
}

-(void)setNumberOfLines:(NSInteger)nbLines {
	QIMVerboseLog(@"[OHAttributedLabel] Warning: the numberOfLines property is not yet supported by CoreText and OHAttributedLabel. (this property is ignored right now)");
	QIMVerboseLog(@"                    This is a known issue (Help to solve this would be greatly appreciated).");
	QIMVerboseLog(@"                    See https://github.com/AliSoftware/OHAttributedLabel/issues/34");
    
	[super setNumberOfLines:nbLines];
}
#endif

@end
