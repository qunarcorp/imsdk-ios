//
//  QIMMicroTourGuideVC.m
//  qunarChatIphone
//
//  Created by admin on 16/4/15.
//
//

#import "QIMMicroTourGuideVC.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "QIMChatVC.h"
#import "QIMJSONSerializer.h"
#import "QIMGroupChatVC.h"
#import "QIMWebView.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMMicroTourGuideVC ()<UIWebViewDelegate>{
    UIWebView *_msgWebView;
    NSMutableArray *_dataSource;
    BOOL _ready;
}

@end

@implementation QIMMicroTourGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataSource = [NSMutableArray array];
    NSArray *msgList = [[QIMKit sharedInstance] getPublicNumberMsgListById:self.userId WihtLimit:50 WithOffset:0];
    [_dataSource addObjectsFromArray:msgList]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageList:) name:kNotificationMessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageState:) name:@"kNotificationUpdateQDMessageState" object:nil];
    [self initWebView];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollToBottom{
    NSInteger height = [[_msgWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    [_msgWebView.scrollView scrollRectToVisible:CGRectMake(0, height - _msgWebView.frame.size.height, _msgWebView.width, _msgWebView.height) animated:YES];
}

- (void)updateMessageList:(NSNotification *)notify{
    NSString *userId = notify.object;
    if ([self.userId isEqualToString:userId]) {
        Message *msg = [notify.userInfo objectForKey:@"message"];
        [_dataSource addObject:msg];
        if (_ready) {
            [self initMessage:msg];
            [self scrollToBottom];
        }
    }
}

- (void)initMessage:(Message *)msg{
    switch (msg.messageType) {
        case QIMMessageType_Time:
        {
//            NSString *timeStr = [[NSDate dateWithTimeIntervalSince1970:msg.messageDate] formattedDateDescription];
//            [self appendTimeStemp:timeStr];
        }
            break;
        case QIMMessageType_MicroTourGuide:
        {
            NSString *element = [msg message];
            NSDictionary *contentDic = [[QIMJSONSerializer sharedInstance] deserializeObject:element error:nil];
            element = [contentDic objectForKey:@"htmlcontent"];
            if (element.length > 0) {
                NSString *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"htmlcontent":element,@"time":@([[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msg.messageDate] qim_timeIntervalSince1970InMilliSecond])}];
                [self appendHtmlElement:data];
            }
        }
            break;
        default:
            break;
    }
}

- (void)initWebView{
    
    NSString *ua = [[QIMWebView defaultUserAgent] stringByAppendingString:@" qunariphone"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent":ua}];
    
    _msgWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [_msgWebView setDelegate:self];
    [self.view addSubview:_msgWebView];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"QIMMicroTourRoot" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_msgWebView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    [self resgisterJSMethod];
    [self resgisterJSMethod];
//    [self appendTimeStemp:@"2016-06-03 08:30"];
    [self initDataSource];
    _ready = YES;
}

- (void)resgisterJSMethod{
    JSContext *context=[_msgWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"openNewSession"] = ^() {
        NSArray *args = [JSContext currentArguments];
        NSString *jid = [args.firstObject toString];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([jid rangeOfString:@"@conference"].location == NSNotFound) {
                [self openSingleChat:jid];
            } else {
                [self openGroupChat:jid];
            }
        });
    };
    context[@"openNewLink"] = ^() {
        NSArray *args = [JSContext currentArguments];
        NSString *url = [args.firstObject toString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openUrl:url];
        });
    };
    context[@"updateCardState"] = ^() {
        NSArray *args = [JSContext currentArguments];
        if (args.count >= 2) {
            NSString *msgId = args[0];
            NSString *state = args[1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateMessageWithMsgId:msgId WithState:state];
            });
        }
    };
}

- (void)updateMessageState:(NSNotification *)notify{
    if ([notify.object isEqualToString:self.userId]) {
        NSString *msgId = [notify.userInfo objectForKey:@"MsgId"];
        NSString *state = [notify.userInfo objectForKey:@"State"];
        [self updateMessageWithMsgId:msgId WithState:state];
    }
}

- (void)updateMessageWithMsgId:(NSString *)msgId WithState:(NSString *)state{
    JSContext *context=[_msgWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *jsFunctStr=[NSString stringWithFormat:@"updateMessage('%@','%@')",msgId,state];
    [context evaluateScript:jsFunctStr];
}

- (void)appendTimeStemp:(NSString *)timeStemp{
    JSContext *context=[_msgWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *jsFunctStr=[NSString stringWithFormat:@"appendTimeStemp('%@')",timeStemp];
    [context evaluateScript:jsFunctStr];
}

- (void)appendHtmlElement:(NSString *)element{
    JSContext *context=[_msgWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *jsFunctStr=[NSString stringWithFormat:@"pushMessage(%@)",[element stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]];
    [context evaluateScript:jsFunctStr];
}

- (void)initDataSource{
    for (Message *msg in _dataSource) {
        [self initMessage:msg];
    }
    [self scrollToBottom];
}

- (void)openSingleChat:(NSString *)jid{
    [QIMFastEntrance openSingleChatVCByUserId:jid];
    
    
//    NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByUserId:jid];
    /*
    NSDictionary *userInfoDic = [[QIMKit sharedInstance] getUserInfoByName:jid];
    if (userInfoDic == nil) {
        [[QIMKit sharedInstance] updateUserHeaderImageWithXmppId:jid];
        userInfoDic = [[QIMKit sharedInstance] getUserInfoByName:jid];
    } */
    /*
    if (userInfoDic) {
        NSString *xmppId = [userInfoDic objectForKey:@"XmppId"];
        NSString *name = [userInfoDic objectForKey:@"Name"];
        [[QIMKit sharedInstance] clearNotReadMsgByJid:xmppId];
        QIMChatVC * chatVC  = [[QIMChatVC alloc] init];
        [chatVC setStype:kSessionType_Chat];
        [chatVC setChatId:xmppId];
        [chatVC setName:name];
        [chatVC setTitle:name];
        [chatVC setChatType:ChatType_SingleChat];
        [self.navigationController popToRootVCThenPush:chatVC animated:YES];
    }
     */
}

- (void)openGroupChat:(NSString *)jid{
    NSDictionary *groupDic = [[QIMKit sharedInstance] getGroupCardByGroupId:jid];
    if (groupDic) {
        NSString *jid = [groupDic objectForKey:@"GroupId"];
        [QIMFastEntrance openGroupChatVCByGroupId:jid];
        /*
        NSString *name = [groupDic objectForKey:@"Name"];
        [[QIMKit sharedInstance] clearNotReadMsgByGroupId:jid];
        QIMGroupChatVC * chatGroupVC  =  [[QIMGroupChatVC alloc] init];
        [chatGroupVC setTitle:name];
        [chatGroupVC setChatId:jid];
        [self.navigationController popToRootVCThenPush:chatGroupVC animated:YES];
         */
    }
}

- (void)openUrl:(NSString *)url{
    QIMWebView *webView = [[QIMWebView alloc] init];
    [webView setUrl:url];
    [webView setFromQiangDan:YES];
    [webView setFromUserId:self.userId];
    [self.navigationController pushViewController:webView animated:YES];
}

@end
