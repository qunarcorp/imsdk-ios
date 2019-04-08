//
//  QIMWebView.h
//  qunarChatIphone
//
//  Created by xueping on 15/6/29.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMWebView : QTalkViewController
@property (nonatomic, copy) NSString *htmlString;
@property (nonatomic, copy) NSString *url; 
@property (nonatomic, assign) BOOL   navBarHidden;
@property (nonatomic, assign) BOOL   needAuth;
@property (nonatomic, assign) BOOL oldNavHidden;
@property (nonatomic, weak) id owner;
@property (nonatomic, assign) BOOL fromMsgList;
@property (nonatomic, assign) BOOL fromOrderManager;
@property (nonatomic, assign) BOOL fromRegPackage;
@property (nonatomic, assign) BOOL fromHistory;
@property (nonatomic, strong) NSString *fromUserId;
@property (nonatomic, assign) BOOL fromQiangDan;

+ (NSString *)defaultUserAgent;
@end
