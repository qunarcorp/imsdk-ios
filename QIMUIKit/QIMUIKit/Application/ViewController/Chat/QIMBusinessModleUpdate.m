//
//  QIMBusinessModleUpdate.m
//  qunarChatIphone
//
//  Created by admin on 16/5/20.
//
//

#import "QIMBusinessModleUpdate.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMJSONSerializer.h"
#import "QIMHTTPRequest.h"
#import "QIMHTTPClient.h"

@implementation QIMBusinessModleUpdate

+ (void)updateMicroTourModel{
    NSString *oldVersion = [[QIMKit sharedInstance] userObjectForKey:@"MicroTourModelVersion"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://touch.dujia.qunar.com/tour/qd/gnt.json?v=%@&p=ios&u=%@&tv=%@",[[QIMKit sharedInstance] AppBuildVersion],[[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],oldVersion]];
    
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:2];
    [requestHeader setObject:@"application/json; encoding=utf-8" forKey:@"Content-Type"];
    [requestHeader setObject:@"application/json" forKey:@"Accept"];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
    [request setTimeoutInterval:2];
    [request setHTTPRequestHeaders:requestHeader];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
            if (ret) {
                NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                NSString *version = [dataDic objectForKey:@"version"];
                NSString *template = [dataDic objectForKey:@"template"];
                if ( version && template.length > 0) {
                    [[QIMKit sharedInstance] setUserObject:version forKey:@"MicroTourModelVersion"];
                    NSString *modelFilePath = [[NSBundle mainBundle] pathForResource:@"QIMMicroTourRoot" ofType:@"html"];
                    [[template dataUsingEncoding:NSUTF8StringEncoding] writeToFile:modelFilePath atomically:YES];
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

@end
