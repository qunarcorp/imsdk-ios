//
//  TextCellCaChe.h
//  feiliao
//
//  Created by lidong cao on 12-11-29.
//  Copyright (c) 2012年 feinno.com. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <CoreText/CoreText.h>

@interface TextCellCache :NSObject

@property(nonatomic, retain)NSAttributedString *attString;
@property(nonatomic, assign)CGSize textSize;
@property(nonatomic, assign)CGSize CellSize;
@property(nonatomic, retain)NSArray *images;
@property(nonatomic, retain)NSArray *linkArray;
@property(nonatomic, retain)UIImage *image;
@property(nonatomic) CTFramesetterRef frameRef;
@property(nonatomic, assign)long long date;
@property(nonatomic, assign)long currentNum;

@end
