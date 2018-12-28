//
//  QIMIconInfo.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "QIMIconInfo.h"

@implementation QIMIconInfo

- (instancetype)initWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color {
    if (self = [super init]) {
        self.text = text;
        self.size = size;
        self.color = color;
    }
    return self;
}

+ (instancetype)iconInfoWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color {
    return [[QIMIconInfo alloc] initWithText:text size:size color:color];
}

@end
