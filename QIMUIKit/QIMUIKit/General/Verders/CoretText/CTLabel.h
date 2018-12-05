//
//  CTLabel.h
//  CoreTextTest
//
//  Created by admin on 12-11-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <CoreText/CoreText.h>

#define UITextAlignmentJustify ((UITextAlignment)kCTJustifiedTextAlignment)

@protocol CTLabelDelegate;

@interface CTLabel : UILabel{
    //!< Internally mutable, but externally immutable copy access only
    NSMutableAttributedString *_attributedText;
	CTFrameRef textFrame;
	CGRect drawingRect;
	NSMutableArray* customLinks;
	NSTextCheckingResult* activeLink;
	CGPoint touchStartPoint;
}
@property (nonatomic, retain)  NSArray              *customLinks;
@property (nonatomic, retain)  NSMutableArray       *images;
@property (nonatomic, retain)  NSMutableArray       *imagesRect;
//!< Use this instead of the "text" property inherited from UILabel to set and get text
@property (nonatomic, copy)    NSAttributedString   *attributedText;
//!< Defaults to NSTextCheckingTypeLink, + NSTextCheckingTypePhoneNumber if "tel:" scheme supported
@property (nonatomic, assign)  uint64_t   automaticallyAddLinksForType;
//!< Defaults to [UIColor blueColor]. See also OHAttributedLabelDelegate
@property (nonatomic, retain)  UIColor              *linkColor;
//[UIColor colorWithWhite:0.2 alpha:0.5]
@property (nonatomic, retain)  UIColor              *highlightedLinkColor;
//!< Defaults to YES. See also CTLabelDelegate
@property (nonatomic, assign)  BOOL                 underlineLinks;
//!< If YES, pointInside will only return YES if the touch is on a link. If NO, pointInside will always return YES (Defaults to NO)
@property (nonatomic, assign)  BOOL                 onlyCatchTouchesOnLinks;
@property (nonatomic, assign)  IBOutlet id<CTLabelDelegate> delegate;
@property (nonatomic, assign)  BOOL                 centerVertically;
//!< Allows to draw text past the bottom of the view if need. May help in rare cases (like using Emoji)
@property (nonatomic, assign)  BOOL                 extendBottomToFit; 

@property (nonatomic) CTFramesetterRef frameRef;

//!< rebuild the attributedString based on UILabel's text/font/color/alignment/... properties
- (void)resetAttributedText;

- (CGSize)sizeThatFits:(CGSize)size;
- (void)addCustomLink:(NSURL*)linkUrl inRange:(NSRange)range;
- (void)removeAllCustomLinks;
- (void)setAttString:(NSAttributedString *)string withImages:(NSArray*)imgs;
- (void)attachImagesWithFrame:(CTFrameRef)frame withImages:(NSArray *)imags withContext:(CGContextRef) ctx;
- (NSInteger)indexForCellImagesAtLocation:(CGPoint)location;

@end

@protocol CTLabelDelegate <NSObject>
@optional
-(BOOL)attributedLabel:(CTLabel*)ctLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo;
//!< Combination of CTUnderlineStyle and CTUnderlineStyleModifiers
-(UIColor*)colorForLink:(NSTextCheckingResult*)linkInfo underlineStyle:(int32_t*)underlineStyle;

-(void)openURL:(NSURL *)url;

@end
