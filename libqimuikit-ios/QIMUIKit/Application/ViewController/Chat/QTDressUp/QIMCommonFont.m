//
//  QIMCommonFontm
//  qunarChatIphone
//
//  Created by chenjie on 16/3/7.
//
//

#import "QIMCommonFont.h"

@interface QIMCommonFont ()

@property (nonatomic, copy) NSString *qTcurrentFontName;

@property (nonatomic, assign) float qtCurrentFontSize;

@end

@implementation QIMCommonFont

static QIMCommonFont * __commonFont = nil;

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __commonFont = [[QIMCommonFont alloc] init];
    });
    return __commonFont;
}

- (float)currentFontSize {
    
    if (_qtCurrentFontSize <= 8) {
        NSDictionary * infoDic = [[QIMKit sharedInstance] userObjectForKey:kCurrentFontInfo];
        if (infoDic == nil || infoDic[kCurrentFontSize] == nil) {
            _qtCurrentFontSize = FONT_SIZE;
        } else {
            _qtCurrentFontSize = [infoDic[kCurrentFontSize] floatValue];
        }
    }
    return _qtCurrentFontSize;
}

- (NSString *)currentFontName {
    if (!_qTcurrentFontName) {
        NSDictionary * infoDic = [[QIMKit sharedInstance] userObjectForKey:kCurrentFontInfo];
        if (infoDic == nil || [infoDic[kCurrentFontName] length] == 0) {
            _qTcurrentFontName = FONT_NAME;
        } else {
            _qTcurrentFontName = infoDic[kCurrentFontName];
        }
    }
    return _qTcurrentFontName;
}

- (void)setCurrentFontSize:(float)fontSize{
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary];
    NSDictionary *dic = [[QIMKit sharedInstance] userObjectForKey:kCurrentFontInfo];
    if (dic) {
        [infoDic setDictionary:dic];
    }
    _qtCurrentFontSize = fontSize;
    [infoDic setQIMSafeObject:[NSNumber numberWithFloat:fontSize] forKey:kCurrentFontSize];
    [[QIMKit sharedInstance] setUserObject:infoDic forKey:kCurrentFontInfo];
}

- (void)setCurrentFontName:(NSString *)fontName{
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary];
    NSDictionary *dic = [[QIMKit sharedInstance] userObjectForKey:kCurrentFontInfo];
    if (dic) {
        [infoDic setDictionary:dic];
    }
    [infoDic setQIMSafeObject:fontName forKey:kCurrentFontName];
    if (fontName) {
        self.currentFontName = fontName;
    }
    [[QIMKit sharedInstance] setUserObject:infoDic forKey:kCurrentFontInfo];
}

@end
