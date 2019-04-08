//
//  QIMDatasourceItem.h
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/30.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMDatasourceItem : NSObject

@property(nonatomic, assign) BOOL isParentNode;

@property(nonatomic, copy) NSString * nodeName;

@property(nonatomic, copy) NSString * jid;

@property(nonatomic, strong) QIMDatasourceItem * parentNode;

@property(nonatomic, strong) NSMutableArray * childNodesArray;

@property(nonatomic, assign) BOOL isExpand;

@property(nonatomic, assign) NSInteger  nLevel;

-(void)addChildNodesItem:(QIMDatasourceItem *)childNodes;

-(NSMutableArray *)expand;

@end
