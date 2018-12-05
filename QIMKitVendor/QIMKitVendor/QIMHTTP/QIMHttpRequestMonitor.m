//
//  QIMHttpRequestMonitor.m
//  qunarChatIphone
//
//  Created by may on 16/4/12.
//
//

#import "QIMHttpRequestMonitor.h"
#import "QIMPublicRedefineHeader.h"

static const uint8_t thread_count = 4;

@interface QIMHttpRequestMonitor () {
    dispatch_queue_t _threads[thread_count];
    long long _requestCount;
}


@end


@implementation QIMHttpRequestMonitor

+ (instancetype)sharedInstance {
    static QIMHttpRequestMonitor *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[QIMHttpRequestMonitor alloc] init];
    });
    return monitor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestCount = 0;
        for (int i = 0; i < thread_count; ++i) {
            NSString *threadname = [NSString stringWithFormat:@"http thread No.%d", i];
            _threads[i] = dispatch_queue_create([threadname UTF8String], DISPATCH_QUEUE_SERIAL);
        }
    }
    return self;
}

- (void)runblock:(dispatch_block_t)block {
    _requestCount++;

    int pos = (int) (_requestCount % thread_count);
    QIMVerboseLog(@"request count is %lld, selected the %d threads...", _requestCount, pos);
    dispatch_async(_threads[pos], block);
}

- (void)syncRunBlock:(dispatch_block_t)block url:(NSString *)url {
    _requestCount++;
    int pos = 0;

    NSURL *urlPath = [NSURL URLWithString:url];

    if (urlPath) {
        NSMutableString *urlHash = [NSMutableString stringWithFormat:@"%@%@",
                                                                     [urlPath host],
                                                                     [urlPath relativePath]];

        //
        // 为老版本的图做个补偿
        if ([[urlPath relativePath] isEqualToString:@"/cgi-bin/get_file.pl"]) {
            //
            // 拆下query
            NSString *query = [urlPath query];
            if (query) {
                NSArray *parameters = [query componentsSeparatedByString:@"&"];
                for (NSString *item in parameters) {
                    NSArray *value = [item componentsSeparatedByString:@"="];
                    if ([value count] == 2) {
                        NSString *key = [value objectAtIndex:0];
                        if ([key isEqualToString:@"file"] ||
                                [key isEqualToString:@"fileurl"] ||
                                [key isEqualToString:@"md5"]) {
                            [urlHash appendString:[NSString stringWithFormat:@"?file=%@",
                                                                             [value objectAtIndex:1]]];
                            break;
                        }
                    }
                }
            }
        }
        pos = [urlHash hash] % thread_count;
    } else
        pos = (int) (_requestCount % thread_count);

    QIMVerboseLog(@"request count is %lld, selected the %d threads...", _requestCount, pos);
    dispatch_sync(_threads[pos], block);
}

- (void)runblock:(dispatch_block_t)block url:(NSString *)url {
    _requestCount++;
    int pos = 0;
//    hash(url)
    NSURL *urlPath = [NSURL URLWithString:url];

    if (urlPath) {
        NSMutableString *urlHash = [NSMutableString stringWithFormat:@"%@%@",
                                                                     [urlPath host],
                                                                     [urlPath relativePath]];

        //
        // 为老版本的图做个补偿
        if ([[urlPath relativePath] isEqualToString:@"/cgi-bin/get_file.pl"]) {
            //
            // 拆下query
            NSString *query = [urlPath query];
            if (query) {
                NSArray *parameters = [query componentsSeparatedByString:@"&"];
                for (NSString *item in parameters) {
                    NSArray *value = [item componentsSeparatedByString:@"="];
                    if ([value count] == 2) {
                        NSString *key = [value objectAtIndex:0];
                        if ([key isEqualToString:@"file"] ||
                                [key isEqualToString:@"fileurl"] ||
                                [key isEqualToString:@"md5"]) {
                            [urlHash appendString:[NSString stringWithFormat:@"?file=%@",
                                                                             [value objectAtIndex:1]]];
                            break;
                        }
                    }
                }
            }
        }

        pos = [urlHash hash] % thread_count;
    } else
        pos = (int) (_requestCount % thread_count);

    QIMVerboseLog(@"request count is %lld, selected the %d threads...", _requestCount, pos);
    dispatch_async(_threads[pos], block);
}


@end
