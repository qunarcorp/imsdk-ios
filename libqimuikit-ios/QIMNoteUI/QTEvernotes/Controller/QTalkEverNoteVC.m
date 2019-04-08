//
//  KCHtmlEditorVC.m
//  Noob2017
//
//  Created by lihuaqi on 2017/9/18.
//  Copyright © 2017年 lihuaqi. All rights reserved.
//

#import "QTalkEverNoteVC.h"
#import "QIMNoteModel.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "QIMNoteManager.h"
#import "SCLAlertView.h"
#import <WebKit/WebKit.h>
#import "QIMNoteUICommonFramework.h"
#import "QIMPublicRedefineHeader.h"

@interface QTalkEverNoteVC () <UIWebViewDelegate,WKNavigationDelegate>
@property(nonatomic, copy) NSString *rootHtmlPath;
@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) UITextField *titleTF;//笔记标题
@property(nonatomic, strong) UIButton *addBtn;//第一次新建，保存
@property(nonatomic, strong) UIButton *rightBtn;//之后保存或者编辑状态切换
@property(nonatomic, strong) WKWebView *myWebView;
@end

@implementation QTalkEverNoteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    _rootHtmlPath = [[[NSBundle qimBundleWithClassName:@"CKEditor" BundleName:@"CKEditor"] resourcePath] stringByAppendingString:@"/vendor/ckeditor/samples/"];
    _rootHtmlPath = [[[NSBundle mainBundle] pathForResource:@"CKEditor" ofType:@"bundle"] stringByAppendingString:@"/vendor/ckeditor/samples/"];
    _rootHtmlPath = [[NSBundle mainBundle] pathForResource:@"CKEditor5" ofType:@"bundle"];
    
    BOOL isDirectory = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_rootHtmlPath isDirectory:&isDirectory]) {
        QIMVerboseLog(@"CKEditor _rootHtmlPath FileExistsAtPath");
    }

    [self topbar];
    
    [self createUI];
    
    if (self.everNoteType == ENUM_EverNote_TypeNew) {
        [_addBtn setHidden:NO];
        [_rightBtn setHidden:YES];
    }else {
        [_addBtn setHidden:YES];
        [_rightBtn setHidden:NO];
    }
}

- (void)topbar {
    _titleTF = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    _titleTF.placeholder = @"输入标题";
    _titleTF.text = self.evernoteSModel.qs_title?self.evernoteSModel.qs_title:@"";
    _titleTF.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = _titleTF;
    
    UIView *btnsView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 50, 25)];
    
    _addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _addBtn.frame = CGRectMake(0,0, 50, 25);
    _addBtn.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [_addBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_addBtn addTarget:self action:@selector(newAction) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:_addBtn];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(0,0, 50, 25);
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [_rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_rightBtn setTitle:@"保存" forState:UIControlStateSelected];
    [_rightBtn setTitleColor:[UIColor qim_colorWithHex:0x22B573 alpha:1.0] forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor qim_colorWithHex:0x22B573 alpha:1.0] forState:UIControlStateSelected];
    _rightBtn.adjustsImageWhenHighlighted = NO;
    [_rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:_rightBtn];
    
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:btnsView];
    self.navigationItem.rightBarButtonItem = rightButton;
}

//新建笔记
- (void)newAction {
    if (_titleTF.text.length == 0) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.horizontalButtons = YES;
        alert.shouldDismissOnTapOutside = YES;
        alert.customViewColor = [UIColor qim_colorWithHex:0x22B573 alpha:1.0];
        [alert showNotice:@"温馨提示" subTitle:@"笔记标题不能为空" closeButtonTitle:@"Done" duration:1.0f];
        return;
    }else if (_titleTF.text.length > 100) {
        _titleTF.text = [_titleTF.text substringFromIndex:100];
    }
    [_addBtn setHidden:YES];
    [_rightBtn setHidden:NO];
    [self saveOrUpdate];
    [self refreshCKEditorWithReadOnly:YES];
}

//保存笔记或者编辑笔记
- (void)rightBtnAction:(UIButton *)btn {
    if (_titleTF.text.length==0) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.horizontalButtons = YES;
        alert.shouldDismissOnTapOutside = YES;
        alert.customViewColor = [UIColor qim_colorWithHex:0x22B573 alpha:1.0];
        [alert showNotice:@"温馨提示" subTitle:@"笔记标题不能为空" closeButtonTitle:@"Done" duration:1.0f];
        return;
    }
    btn.selected = !btn.selected;
    if (btn.selected == YES) {
        [self refreshCKEditorWithReadOnly:NO];
    }else {
        [self saveOrUpdate];
        [self refreshCKEditorWithReadOnly:YES];
    }
}

- (void)refreshCKEditorWithReadOnly:(BOOL)isReadOnly {
    
    if (isReadOnly) {
        QIMVerboseLog(@"只读模式");
        NSString *jsStr = [NSString stringWithFormat:@"setCKEditor5ReadOnly('%@')", @(YES)];
        NSString *filePath = [NSBundle qim_myLibraryResourcePathWithClassName:@"CKEditor5" BundleName:@"CKEditor5" pathForResource:@"CKEditor5Display" ofType:@"html"];
        
        //    NSString *filePath = [_rootHtmlPath stringByAppendingString:@"indexiPhoneDisplay.html"];
        NSMutableString *htmlString = [[NSMutableString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSString *content = self.evernoteSModel.qs_content? self.evernoteSModel.qs_content : @"";
        [htmlString replaceOccurrencesOfString:@"[CONTENT]" withString:content options:NSCaseInsensitiveSearch range:NSMakeRange(0, htmlString.length)];
        if (filePath) {
            [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:filePath]];
        }
        
    } else {
        NSString *filePath = [NSBundle qim_myLibraryResourcePathWithClassName:@"CKEditor5" BundleName:@"CKEditor5" pathForResource:@"CKEditor5Edit" ofType:@"html"];
        //    NSString *filePath = [_rootHtmlPath stringByAppendingString:@"indexiPhone.html"];
        NSMutableString *htmlString = [[NSMutableString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSString *content = self.evernoteSModel.qs_content? self.evernoteSModel.qs_content : @"";
        [htmlString replaceOccurrencesOfString:@"[CONTENT]" withString:content options:NSCaseInsensitiveSearch range:NSMakeRange(0, htmlString.length)];
        if (filePath) {
            [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:filePath]];
        }
    }
}

- (void)createUI {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    [self refreshCKEditorWithReadOnly:!(self.everNoteType == ENUM_EverNote_TypeNew)];
}

//保存和更新笔记
- (void)saveOrUpdate {
    JSContext *context=[_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    NSString *content = (NSString *)[context evaluateScript:@"getData()"];
    
    NSString *text = (NSString *)[context evaluateScript:@"getText()"];
    NSString *introduceText = [NSString stringWithFormat:@"%@",text];
    if (introduceText.length>0) {
        introduceText = [introduceText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }

    if (self.evernoteSModel) {
        [self.evernoteSModel setQs_title:[NSString stringWithFormat:@"%@",_titleTF.text]];
        [self.evernoteSModel setQs_introduce:[NSString stringWithFormat:@"%@",introduceText]];
        [self.evernoteSModel setQs_content:[NSString stringWithFormat:@"%@",content]];
        [self.evernoteSModel setQs_type:0];
    }
    
    if (self.everNoteType == ENUM_EverNote_TypeNew) {
        [[QIMNoteManager sharedInstance] saveNewQTNoteSubItem:self.evernoteSModel];
    }else {
        [[QIMNoteManager sharedInstance] updateToRemoteSubWithSubModel:self.evernoteSModel];
    }
}

- (BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *requestUrl = request.URL;
    NSString *urlStr = [requestUrl absoluteString];
    QIMVerboseLog(@"request:%@",urlStr);
    if ([urlStr qim_hasPrefixHttpHeader]) {
        
    } else {
        if ([requestUrl.path isEqualToString:[_rootHtmlPath stringByAppendingString:@"uploadEvernoteImage"]]) {
            //request.getParameter("CKEditorFuncNum");
            JSContext *context=[_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
            NSString *content = (NSString *)[context evaluateScript:@"getData()"];
        }else {
            
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *js = @"function imgAutoFit() { \
    var imgs = document.getElementsByTagName('img'); \
    for (var i = 0; i < imgs.length; ++i) {\
    var img = imgs[i];   \
    img.style.maxWidth = %f;   \
    } \
    }";
    js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width - 20];
    
    [webView stringByEvaluatingJavaScriptFromString:js];
    [webView stringByEvaluatingJavaScriptFromString:@"imgAutoFit()"];
}

#pragma WKWebView代理方法
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSString *js = @"function imgAutoFit() { \
    var imgs = document.getElementsByTagName('img'); \
    for (var i = 0; i < imgs.length; ++i) {\
    var img = imgs[i];   \
    img.style.maxWidth = %f;   \
    } \
    }";
    
    js = [NSString stringWithFormat:js,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width-15];
    
    [webView evaluateJavaScript:js completionHandler:nil];
    
    [webView evaluateJavaScript:@"imgAutoFit()"completionHandler:nil];
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    QIMVerboseLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    QIMVerboseLog(@"%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
