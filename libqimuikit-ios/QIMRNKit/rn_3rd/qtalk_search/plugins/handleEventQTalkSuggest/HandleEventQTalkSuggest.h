//
//  handleEventQTalkSuggest.h
//  qunarChatIphone
//
//  Created by wangyu.wang on 16/5/9.
//
//

#ifndef handleEventQTalkSuggest_h
#define handleEventQTalkSuggest_h

#import <React/RCTBridgeModule.h>
#import "QIMCommonUIFramework.h"

@interface  HandleEventQTalkSuggest: NSObject <RCTBridgeModule>

-(void) goUserCard:(NSString*) uri;
-(void) goGroupChat:(NSString*) uri ;
-(void) goFriends:(NSString*) uri;
-(void) goGroups:(NSString*) uri ;
-(void) goUnreadMessages:(NSString*) uri;
-(void) goPublicAccounts:(NSString*) uri ;
-(void) goWebView:(NSString*) uri showNavBar:(BOOL)showNavBar;
-(void) goSingleChat:(NSString*) uri;
-(void) goLookBackVCSingle:(NSString *)uri;
-(void) goLookBackVCGroup:(NSString *)uri;


@end

#endif /* handleEventQTalkSuggest_h */
