//
//  QIMProgressHUD.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/1/14.
//
//

#import "QIMProgressHUD.h"
#import "MBProgressHUD.h"

@interface QIMProgressHUD ()

@property (nonatomic, strong) MBProgressHUD *progreeHUD;

@end

@implementation QIMProgressHUD

+ (QIMProgressHUD *)sharedInstance {
    static QIMProgressHUD *__progressHUD = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __progressHUD = [[QIMProgressHUD alloc] init];
    });
    return __progressHUD;
}

- (MBProgressHUD *)progreeHUD {
    if (!_progreeHUD) {
        _progreeHUD = [[MBProgressHUD alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _progreeHUD.minSize = CGSizeMake(120, 120);
        _progreeHUD.minShowTime = 1.0f;
        [_progreeHUD setLabelText:@""];
        [[UIApplication sharedApplication].keyWindow addSubview:_progreeHUD];
    }
    [_progreeHUD show:YES];
    return _progreeHUD;
}

- (void)showProgressHUDWithTest:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progreeHUD setDetailsLabelText:text];
        [self.progreeHUD show:YES];
    });
}

- (void)closeHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_progreeHUD) {
            [_progreeHUD hide:YES];
        }
    });
}

@end
