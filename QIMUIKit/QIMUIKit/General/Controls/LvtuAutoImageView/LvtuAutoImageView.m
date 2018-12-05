//
//  AutoImageView.m
//  QunarUGC
//
//  Created by Tianxiaorong on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LvtuAutoImageView.h"
#import "QIMDataController.h"

#define kNetworkTaskTimeOut					60

static NSMutableArray *__tempUrlQueue = nil;

@interface NSURLConnBlock : NSObject <NSURLConnectionDataDelegate>
{
}
@property (nonatomic, retain) NSMutableData *resultData;
@property (nonatomic, copy) void(^finishCallBackBlock)(NSDictionary *);
@property (nonatomic, copy) NSString *urlStr;

+(void)requestImageWithUrlStr:(NSString *)urlStr finishedCallBackBlock:(void(^)(NSDictionary *)) block;

@end

@implementation NSURLConnBlock

@synthesize resultData,finishCallBackBlock;
@synthesize urlStr;

+(void)requestImageWithUrlStr:(NSString *)urlStr finishedCallBackBlock:(void(^)(NSDictionary *)) block {

    NSURLConnBlock *urlConnBlock = [[NSURLConnBlock alloc] init];
    urlConnBlock.finishCallBackBlock = block;
    [urlConnBlock setUrlStr:urlStr];
    
    if (__tempUrlQueue == nil) {
        __tempUrlQueue = [[NSMutableArray alloc] init];
    }
    [__tempUrlQueue addObject:urlConnBlock];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kNetworkTaskTimeOut];
    
    // 发送网络请求
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
                                                         delegate:urlConnBlock
                                                 startImmediately:NO];
    [conn start];
}

// =============================================================================
// 代理函数
// =============================================================================
// 服务器错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (finishCallBackBlock) {
        finishCallBackBlock(nil);
    }
    [__tempUrlQueue removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(!self.resultData){
        
        NSMutableData *tempResultData = [[NSMutableData alloc] init];
        [self setResultData:tempResultData];
    }
//    else{
//        [self.resultData setLength:0];
//    }
    
    [self.resultData appendData:data];
}

// 数据接收结束
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (finishCallBackBlock) {
        
        NSDictionary *temConnDict = [[NSDictionary alloc] initWithObjectsAndKeys:self.resultData,@"ResultData",self.urlStr,@"UrlStr",nil];
        
        finishCallBackBlock(temConnDict);    
    }
    
    [__tempUrlQueue removeObject:self];
}

-(void)dealloc {

    [self setUrlStr:nil];
    [self setResultData:nil];
    [self setFinishCallBackBlock:nil];    
}

@end

@interface LvtuAutoImageView ()

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSMutableData *receivedData;					// 数据接收对象
@property (nonatomic, retain) UIActivityIndicatorView *activityView;        // loading
@property (nonatomic, retain) NSDictionary *urlConnDict;


@end

@implementation LvtuAutoImageView

@synthesize urlConnDict;

- (void)dealloc
{
    
    [self setUrlConnDict:nil];
//    [_imageURL release];
}
- (id)init
{
	if(self = [super init])
	{
		// 初始化数组
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [self setReceivedData:receivedData];
        
        UIActivityIndicatorView *activityViewTem = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityView setFrame:CGRectMake(self.bounds.size.width/2 - 10, self.bounds.size.height/2 - 10, 20, 20)];
        [activityViewTem setHidesWhenStopped:YES];
        
        [self addSubview:activityViewTem];
        [self setActivityView:activityViewTem];
        
        [_activityView startAnimating];
        [self setUserInteractionEnabled:YES];
		return self;
	}
	 
	return nil;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_activityView setFrame:CGRectMake(self.bounds.size.width/2 - 10, self.bounds.size.height/2 - 10, 20, 20)];
}

- (void)setImage:(UIImage *)image
{
    if (image)
    {
        [super setImage:image];
        [_activityView stopAnimating];
    }
    else
    {
        if (self.defaultImage) {
            [super setImage:self.defaultImage];
        } else {
            [super setImage:[UIImage imageNamed:@"newspaper_default"]];
        }
        [_activityView stopAnimating];
    }
    
}

-(void)setImageURL:(NSString *)imageURL
{
    
    [self setImage:self.defaultImage];
    
    if (imageURL) {
        
        _imageURL = imageURL;
        
        id image =  [[QIMDataController getInstance] getResourceImage:imageURL];
        if ([image isKindOfClass:[UIImage class]]) {
            [self setImage:image];
        }
        else
        {
            [_activityView startAnimating];
            
            
            [NSURLConnBlock requestImageWithUrlStr:imageURL finishedCallBackBlock:^(NSDictionary *dic){
                    
                UIImage *img = [[UIImage alloc] initWithData:[dic objectForKey:@"ResultData"]];
                
                if (img) {
                    
                    if ([self.imageURL isEqualToString:[dic objectForKey:@"UrlStr"]])
                        [self setImage:img];
                    
//                    [[DataController getInstance] addResource:[dic objectForKey:@"ResultData"] withKey:[dic objectForKey:@"UrlStr"]];
                    [[QIMDataController getInstance] saveResourceWithFileName:[dic objectForKey:@"UrlStr"] data:[dic objectForKey:@"ResultData"]];
                }
                else {
                    [self setImage:nil];
                    [[QIMDataController getInstance] addResource:[NSNull null] withKey:[dic objectForKey:@"UrlStr"]];
                }
            }];
            
//            _imageURL = [imageURL retain];
//            
//            // 创建请求对象
//            NSURL *url = [[NSURL alloc] initWithString:imageURL];
//            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
//                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                      timeoutInterval:kNetworkTaskTimeOut];
//            [url release];
//            
//            // 发送网络请求
//            NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request
//                                                                             delegate:self
//                                                                     startImmediately:NO];
//            NSDictionary *temConnDict = [[NSDictionary alloc] initWithObjectsAndKeys:conn,imageURL, nil];
//            [self setUrlConnDict:temConnDict];
//            [temConnDict release];
//            
//            [conn start];
//            [conn release];
//            [request release];
//            [_activityView startAnimating];
        }
    }
//    else
//    {
//        [self setImage:nil];
//    }
}
// =============================================================================
// 代理函数
// =============================================================================
// 服务器错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self setImage:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
        
    if (!_receivedData)
        _receivedData = [[NSMutableData alloc] init];
    else
        [_receivedData setLength:0];
    
    [_receivedData appendData:data];
}

// 数据接收结束
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
        // 生成图片
    UIImage *image = [[UIImage alloc] initWithData:_receivedData];
    if (image) {
        
        [[QIMDataController getInstance] addResource:_receivedData withKey:[[self.urlConnDict allKeys] objectAtIndex:0]];
        [self setImage:image];
    }
    else
    {
        [[QIMDataController getInstance] addResource:[NSNull null] withKey:[[self.urlConnDict allKeys] objectAtIndex:0]];
        [self setImage:nil];
    }
}
- (void)addTarget:(id)target action:(SEL)action
{
    while (self.gestureRecognizers && [self.gestureRecognizers count])
    {
        [self removeGestureRecognizer:[self.gestureRecognizers objectAtIndex:0]];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [self setUserInteractionEnabled:YES];
    self.target = target;
    self.action = action;
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_target && _action && [_target respondsToSelector:_action])
        {
            [_target performSelector:self.action withObject:self];
        }
    }
}


@end
