//
//  DataController.h
//  qunarChatIphone
//
//  Created by wangshihai on 15/2/6.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface QIMDataController : NSObject

+ (QIMDataController *)getInstance;

-(void)save;

-(void)deleteResourceWithFileName:(NSString *)fileName;

- (void)saveResourceWithFileName:(NSString *)fileName data:(NSData *)data;

- (NSData *)getResourceData:(NSString *)key;

- (UIImage *)getResourceImage:(NSString *)key;

- (void)addResource:(id)resource withKey:(NSString *)key;

- (NSString *)getSourcePath:(NSString *)fileName;

- (void) removeAllImage;

- (long long) sizeofImagePath;

@end
