//
//  QIMDatasourceItem.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/30.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMDatasourceItem.h"

@implementation QIMDatasourceItem

-(void)addChildNodesItem:(QIMDatasourceItem *)childNodes {
 
    if (self.childNodesArray == nil) {
     
        self.childNodesArray = [[NSMutableArray alloc] init];
    }
    
    [self.childNodesArray addObject:childNodes];
}

-(NSMutableArray *)expand {
    return self.childNodesArray;
}

@end
