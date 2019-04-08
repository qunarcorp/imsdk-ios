//
//  QIMDaysmatterManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/19.
//

#import "QIMDaysmatterManager.h"
#import "QIMJSONSerializer.h"

@interface QIMDaysmatterManager ()

@end

static QIMDaysmatterManager *_daysmatter = nil;
@implementation QIMDaysmatterManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _daysmatter = [[QIMDaysmatterManager alloc] init];
    });
    return _daysmatter;
}

- (void)getDaysmatterFromRemote {
    NSString *destUrl = @"http://beta.daysmatter.com/app/idays/on_this_day?lang=zh-hans&is_widget=1&app_ver=61&os_lang=";
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request startSynchronous];
    NSError *error = request.error;
    if ([request responseStatusCode] == 200 && !error) {
        NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        QIMVerboseLog(@"请求回来的DaysMatter数据为： %@", resultDic);
    }
}

@end
