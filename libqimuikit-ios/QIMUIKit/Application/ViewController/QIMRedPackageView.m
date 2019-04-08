
#import "QIMRedPackageView.h"
#import "QIMWebView.h"
#import "QIMContactSelectionViewController.h"
static UIWindow *__redPackageWindow = nil;
static UIViewController *__redPackageVC = nil;
@interface QIMRedPackageView()<UIWebViewDelegate,QIMContactSelectionViewControllerDelegate,UIAlertViewDelegate>
@property (nonatomic,copy) NSString  * rId;
@end
@implementation QIMRedPackageView{
    UIWebView *_webView;
}

- (void)loadUrl:(NSString *)url{
//    NSURL *httpUrl = [NSURL fileURLWithPath:url];
//    NSURLRequest *request = [NSURLRequest requestWithURL:httpUrl];
//    [_webView loadRequest:request];
    NSURL *httpUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:httpUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [_webView loadRequest:request];
}

+ (void)showRedPackagerViewByUrl:(NSString *)url{
    if (__redPackageWindow == nil) {
        __redPackageWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        if ([[QIMKit sharedInstance] getIsIpad]) {
            __redPackageWindow.frame = CGRectMake(0, 0, [[UIScreen mainScreen] width], [[UIScreen mainScreen] height]);
        }
        [__redPackageWindow makeKeyAndVisible];
        [__redPackageWindow setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.5]];
        
        __redPackageVC = [[QTalkViewController alloc] init];
        [__redPackageVC.view setBackgroundColor:[UIColor clearColor]];
        if ([[QIMKit sharedInstance] getIsIpad]) {
            /*Comment by lilulucas.li
            IPAD_NAVViewController * nav = [[IPAD_NAVViewController alloc] initWithRootViewController:__redPackageVC];
            nav.navigationBarHidden = YES;
            [__redPackageWindow setRootViewController:nav];
             */
        }else{
            [__redPackageWindow setRootViewController:__redPackageVC];
        }
        QIMRedPackageView *redPackageView = [[QIMRedPackageView alloc] initWithFrame:CGRectMake(20, 20, __redPackageWindow.width-40, __redPackageWindow.height-40)];
        if ([[QIMKit sharedInstance] getIsIpad]) {
            redPackageView.frame = CGRectMake(([[UIScreen mainScreen] width] - ([[UIScreen mainScreen] height] - 40) * 2 / 3 - 40) / 2, 20, ([[UIScreen mainScreen] height] - 40) * 2 / 3, [[UIScreen mainScreen] height] - 40);
        }
        redPackageView.tag = 9999;
        [__redPackageVC.view addSubview:redPackageView];
        [redPackageView loadUrl:url];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [_webView reload];
    } else if (buttonIndex == 1) {
        [self close];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * urlStr = [[request URL] absoluteString];
    NSArray * components = [urlStr componentsSeparatedByString:@":"];
   if ([urlStr hasPrefix:@"qunartalk://"] && components.count > 1){
       if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//redpackge"]) {
           NSMutableDictionary * dictionaryQuery = [NSMutableDictionary dictionaryWithDictionary:[[[request URL] query] qim_dictionaryFromQueryComponents]];
           if (dictionaryQuery[@"content"]) {
               [[NSNotificationCenter defaultCenter] postNotificationName:WillSendRedPackNotification object:dictionaryQuery[@"content"]];
               [self close];
           }else if (dictionaryQuery[@"method"]){
               if ([dictionaryQuery[@"method"] isEqualToString:@"opul"]) {
                   self.rId = dictionaryQuery[@"rid"];
                   //open user list
                   QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
                   QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
                   controller.delegate = self;
                   [__redPackageVC presentViewController:nav animated:YES completion:^{
                       
                   }];
               }
           }
           return NO;
       }else if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//redpackage"]) {
           NSMutableDictionary * dictionaryQuery = [NSMutableDictionary dictionaryWithDictionary:[[[request URL] query] qim_dictionaryFromQueryComponents]];
           if (dictionaryQuery[@"content"]) {
               [[NSNotificationCenter defaultCenter] postNotificationName:WillSendRedPackNotification object:dictionaryQuery[@"content"]];
               [self close];
           }else if (dictionaryQuery[@"method"]){
               if ([dictionaryQuery[@"method"] isEqualToString:@"opul"]) {
                   self.rId = dictionaryQuery[@"rid"];
                   //open user list
                   QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
                   QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
                   controller.delegate = self;
                   [__redPackageVC presentViewController:nav animated:YES completion:^{
                       
                   }];
               }
           }
           return NO;
       } else if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//closeredpackage"]){
            [self close];
        }
        return NO;
   } else if ([urlStr hasPrefix:@"qunarchat://"] && components.count > 1) {
       if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//redpackage"]) {
           NSMutableDictionary * dictionaryQuery = [NSMutableDictionary dictionaryWithDictionary:[[[request URL] query] qim_dictionaryFromQueryComponents]];
           if (dictionaryQuery[@"content"]) {
               [[NSNotificationCenter defaultCenter] postNotificationName:WillSendRedPackNotification object:dictionaryQuery[@"content"]];
               [self close];
           }else if (dictionaryQuery[@"method"]){
               if ([dictionaryQuery[@"method"] isEqualToString:@"opul"]) {
                   self.rId = dictionaryQuery[@"rid"];
                   //open user list
                   QIMContactSelectionViewController *controller = [[QIMContactSelectionViewController alloc] init];
                   QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:controller];
                   controller.delegate = self;
                   [__redPackageVC presentViewController:nav animated:YES completion:^{
                       
                   }];
               }
           }
           return NO;
       } else if ([[[components objectAtIndex:1] lowercaseString] hasPrefix:@"//closeredpackage"]){
           [self close];
           return NO;
       }
       return NO;
   }
    return YES;
}

- (void)close{
    [__redPackageWindow setHidden:YES];
    __redPackageWindow = nil;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
            NSString *ua = [[QIMWebView defaultUserAgent] stringByAppendingString:@" qunartalk-ios-client"];
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
        } else {
            NSString *ua = [[QIMWebView defaultUserAgent] stringByAppendingString:@" qunarchat-ios-client"];
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
        }
            _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
            [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
            [_webView.scrollView setShowsHorizontalScrollIndicator:NO];
            [_webView.scrollView setShowsVerticalScrollIndicator:NO];
            [_webView setScalesPageToFit:YES];
            [_webView setMultipleTouchEnabled:YES];
            [_webView setDelegate:self];
            [_webView setOpaque:NO];
            [_webView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_webView];
    }
    return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //修改服务器页面的meta的值
//    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, height=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width, webView.frame.size.height];
//    [webView stringByEvaluatingJavaScriptFromString:meta];
//    [webView setHidden:NO];
}

- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC groupChatVC:(QIMGroupChatVC *)vc{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        NSString * jsStr = [NSString stringWithFormat:@"relay_red_env('%@','%@','%@','%@');",[[[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b",self.rId] qim_getMD5] lowercaseString],@"qunartalk-ios",[[contactVC getSelectInfoDic] objectForKey:@"userId"],@""];
        [_webView stringByEvaluatingJavaScriptFromString:jsStr];
        [self close];
    });
}
- (void)contactSelectionViewController:(QIMContactSelectionViewController *)contactVC chatVC:(QIMChatVC *)vc{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * jsStr = [NSString stringWithFormat:@"relay_red_env('%@','%@','%@','%@');",[[[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b",self.rId] qim_getMD5] lowercaseString],@"qunartalk-ios",@"",[[contactVC getSelectInfoDic] objectForKey:@"userId"]];
        [_webView stringByEvaluatingJavaScriptFromString:jsStr];
        [self close];
    });
} 

@end
