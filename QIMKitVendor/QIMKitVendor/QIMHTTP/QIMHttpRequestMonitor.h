//
//  QIMHttpRequestMonitor.h
//  qunarChatIphone
//
//  Created by may on 16/4/12.
//
//

#import <Foundation/Foundation.h>

@interface QIMHttpRequestMonitor : NSObject

+ (instancetype) sharedInstance;

- (void) runblock:(dispatch_block_t) block;

- (void) syncRunBlock:(dispatch_block_t) block url:(NSString *) url;

- (void) runblock:(dispatch_block_t) block url:(NSString *) url;

@end
