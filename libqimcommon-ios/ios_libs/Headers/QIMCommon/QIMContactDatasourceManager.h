//
//  QIMContactDatasourceManager.h
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/30.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMContactDatasourceManager : NSObject {
    NSMutableArray * _mergeRootBranch;
    
    NSMutableDictionary * _unmergeBranchDict;
}

+(QIMContactDatasourceManager *)getInstance;

-(void)expandBranchAtIndex:(NSInteger)index;

-(void)collapseBranchAtIndex:(NSInteger)index;

-(void)createUnMeregeDataSource;

-(NSArray *)QtalkDataSourceItem;

@end
