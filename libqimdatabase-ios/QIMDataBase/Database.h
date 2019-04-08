//
//  Database.h
//  GSensorTest
//
//  Created by Grandia May on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

//
//#ifdef
//#define AUTORELEASEPOOL_BEGIN NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//#define AUTORELEASEPOOL_END   [pool drain];
//#else
//#define AUTORELEASEPOOL_BEGIN @autoreleasepool {
//#define AUTORELEASEPOOL_END   };
//#endif

@class Database;
@class DatabaseOperator;

@protocol QSDatabaseProtocol <NSObject>

@required
- (void) setDbOperator:(DatabaseOperator*) op;
- (BOOL) createDb:(Database *) database;
- (BOOL) updateDbFromOldVersion:(long long) oldVersion
                   toNewVersion:(long long) newVersion
                  usingDatabase:(Database*) database;
@optional
- (void) afterDbCreation:(Database*) database;

@end

@interface SQLiteStatement : NSObject {
    void     *_object;
    Database *_database;
}

- (void) bindParameter:(int) pos withValue:(id) value;
- (BOOL) execute;

@end


@interface DataReader : NSObject {
    
    void        *_object;
    Database    *_database;
}

- (int)getColCount;
- (NSString *)getColumnName:(UInt32)column;
- (id) objectForColumnIndex:(UInt32) column;
- (id) objectForColumnName:(NSString*)columnName;
- (BOOL) read;
- (int) count;
@end


@interface Database : NSObject {
    dispatch_queue_t _runningQueue;
    void        *_database;
    NSString    *_path;
}

- (dispatch_queue_t) getCurrentQueue;

- (BOOL) open:(NSString*) filePath usingCurrentThread:(BOOL) usingCurrentThread;
- (BOOL)close;
- (BOOL) checkExistsOnTable:(NSString*) tableName withColumn:(NSString *) columnName;
- (DataReader*) executeReader:(NSString*) sqlName withParameters:(NSArray *) parameters;
- (void) execCommand:(NSString *) command;
- (BOOL) executeNonQuery:(NSString *)sqlName withParameters:(NSArray*) params;
- (BOOL) executeBulkInsert:(NSString *)sqlName withParameters:(NSArray*) params;
- (void) dbCheckpoint;

@end


typedef void(^DatabaseFunction)(Database *database);

@interface DatabaseOperator : NSObject {
    Database *_database;
}

- (id)initWithDatabase:(Database *) database;
- (void) usingTransaction:(DatabaseFunction) transaction;
- (void) syncUsingTransaction:(DatabaseFunction) trans;
- (void) usingTransaction:(DatabaseFunction)transaction withComplate:(dispatch_block_t) end;

- (void) beginWithoutTransaction:(DatabaseFunction) func withComplate:(dispatch_block_t) func2;
- (void) syncWithoutTransaction:(DatabaseFunction) func;

@end


@interface DatabaseManager : NSObject {
    NSMutableDictionary *_databaseMapping;
}

+(DatabaseOperator *) GetInstance:(NSString *) filePath;
+(BOOL) OpenByFullPath:(NSString *) dbFilePath;
+(BOOL)CloseByFullPath:(NSString *)dbFilePath;
@end
