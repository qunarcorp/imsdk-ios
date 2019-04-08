//
//  Database.m
//  GSensorTest
//
//  Created by Grandia May on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Database.h"

#ifndef SINGLETON_INST
#define SINGLETON_INST(YourClass)   + (YourClass *)sharedInstance \
{ \
static YourClass *sharedInstance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
sharedInstance = [[YourClass alloc] init]; \
}); \
return sharedInstance; \
}
#endif


#define DatabaseAssert( _exp_ ) if ( !_exp_ ) [NSException raise:@"NSDatabaseException" format:@""];

#define DatabaseAssertWithError( _exp_, arg ) if ( !_exp_ ) [NSException raise:@"NSDatabaseException" format:@"[DATABASE ERROR] \r\n%@", arg];
#define DatabaseAssertWithErrorAndDB( _exp_, arg, database ) if ( !_exp_ ) [NSException raise:@"NSDatabaseException" format:@"[DATABASE ERROR] \r\n%@\r\n%@", arg, sqlite3_errmsg(_database)];

static void add_some_sql_log(NSString *sql);

#ifdef DEBUG
#   define ADD_LOG(e) add_some_sql_log(e)
NSMutableDictionary *__global__sql_dic__ = nil;

static void add_some_sql_log(NSString *sql) {
    return;
    if (__global__sql_dic__ == nil)
        __global__sql_dic__ = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSNumber *number = [__global__sql_dic__ objectForKey:sql];
    if (number) {
        number = [NSNumber numberWithLongLong:([number longLongValue] + 1)];
    } else {
        number = [NSNumber numberWithLongLong:0];
    }
    [__global__sql_dic__ setObject:number forKey:sql];
}

#else
#   define ADD_LOG(e) /**/
#endif

#pragma mark - DataReader method

@interface DataReader(Private)
- (id) initWithStmt:(sqlite3_stmt*)stmt withDatabase:(Database*) db;
- (void) dealloc;
@end


@implementation DataReader(Private)
- (void)dealloc {
    if (dispatch_get_current_queue() != [_database getCurrentQueue]) {
    }
    
    sqlite3_stmt *stmt = (sqlite3_stmt*)_object;
    if (stmt)
        sqlite3_finalize(stmt);
    [_database release];
    [super dealloc];
}

- (id)initWithStmt:(sqlite3_stmt *)stmt withDatabase:(Database *)db {
    self = [super init];
    if (self) {
        _object     = stmt;
        _database   = [db retain];
    }
    return self;
}
@end


@implementation SQLiteStatement

- (void)bindParameter:(int)pos withValue:(id)value {
}

- (BOOL)execute {
    return NO;
}

@end


@implementation DataReader

- (int)getColCount {
    sqlite3_stmt *stmt = (sqlite3_stmt*)_object;
    return sqlite3_column_count(stmt);
}

- (NSString *)getColumnName:(UInt32)column {
    sqlite3_stmt *stmt = (sqlite3_stmt*)_object;
    return [NSString stringWithCString:sqlite3_column_name(stmt, column) encoding:NSUTF8StringEncoding];
}

- (id)objectForColumnName:(NSString *)columnName {
    id value = nil;
    @try {
        sqlite3_stmt *stmt = (sqlite3_stmt*)_object;
        int column = -1;
        int count = sqlite3_column_count(stmt);
        
        if (count) {
            for (int i = 0; i < count; ++i) {
                if (strcmp([columnName UTF8String], sqlite3_column_name(stmt, i)) == 0) {
                    column = i;
                    break;
                }
            }
        }
        
        if (column == -1)
            return nil;
        
        switch (sqlite3_column_type(stmt, column)) {
            case SQLITE_INTEGER: {
                value = [[NSNumber alloc] initWithLongLong:sqlite3_column_int64(stmt, column)];
                break;
            }
            case SQLITE_FLOAT: {
                value = [[NSNumber alloc] initWithDouble:sqlite3_column_double(stmt, column)];
                break;
            }
            case SQLITE_TEXT: {
                const char *txt = (const char*) sqlite3_column_text(stmt, column);
                if (!txt)    txt = "";
                value = [[NSString alloc] initWithUTF8String:txt];
                break;
            }
            case SQLITE_BLOB: {
                int size = sqlite3_column_bytes(stmt, column);
                NSMutableData *data = [[NSMutableData alloc] initWithLength:size];
                memcpy([data mutableBytes],sqlite3_column_blob(stmt, column), size);
                value = data;
                break;
            }
            case SQLITE_NULL: {
                value = nil;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"getValueByName cast a Error! %@ at %@", exception, [exception callStackSymbols]);
    } @finally {
        return [value autorelease];
    }
}

- (id)objectForColumnIndex:(UInt32)column {
    id value = nil;
    @try {
        sqlite3_stmt *stmt = (sqlite3_stmt*)_object;
        switch (sqlite3_column_type(stmt, column)) {
            case SQLITE_INTEGER: {
                value = [[NSNumber alloc] initWithLongLong:sqlite3_column_int64(stmt, column)];
                break;
            }
            case SQLITE_FLOAT: {
                value = [[NSNumber alloc] initWithDouble:sqlite3_column_double(stmt, column)];
                break;
            }
            case SQLITE_TEXT: {
                const char *txt = (const char*) sqlite3_column_text(stmt, column);
                if (!txt)    txt = "";
                value = [[NSString alloc] initWithUTF8String:txt];
                break;
            }
            case SQLITE_BLOB: {
                int size = sqlite3_column_bytes(stmt, column);
                NSMutableData *data = [[NSMutableData alloc] initWithLength:size];
                memcpy([data mutableBytes],sqlite3_column_blob(stmt, column), size);
                value = data;
                break;
            }
            case SQLITE_NULL: {
                value = nil;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"getValueByNumber cast a Error! %@ at %@", exception, [exception callStackSymbols]);
    }
    @finally {
        return [value autorelease];
    }
}

- (int)count {
    sqlite3_stmt *stmt = (sqlite3_stmt*)_object;
    if (stmt) {
        int count = 0;
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            count = sqlite3_column_int(stmt, 0);
            break;
        }
        return count;
    }
    return -1;
}

- (BOOL)read {
    sqlite3_stmt *stmt = (sqlite3_stmt*)_object;
    if (stmt) {
        int ret = sqlite3_step(stmt);
        return (ret == SQLITE_ROW);
    }
    return NO;
}

@end

#pragma mark - Database Method

@interface Database(Private)

- (id)init;
- (void)dealloc;
- (void*) dbInstance;
@end


@implementation Database(Private)

-(void)dealloc {
    if (_path)
        [_path release];
    [self close];
    dispatch_release(_runningQueue);
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        _database = nil;
        _path = nil;
        sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
        sqlite3_config(SQLITE_CONFIG_MEMSTATUS, false);
    }
    return self;
}

- (void*) dbInstance {
    return _database;
}

@end

@interface Database (CheckParameters)

- (BOOL) setParameters:(sqlite3_stmt *)stmt
        withParameters:(NSArray*) parameters;

@end

@implementation Database (CheckParameters)

- (BOOL) setParameters:(sqlite3_stmt *)stmt
        withParameters:(NSArray*) parameters {
    
    BOOL succeeded = NO;
    
    int count = sqlite3_bind_parameter_count(stmt);
    if ((parameters == nil || [parameters count] == 0) && count == 0)
        return YES;
    
    @try {
        if (parameters == nil || [parameters count] == 0)
            [NSException raise:@"NSCheckParameterException" format:@"参数为空。默认情况下不允许。"];
        if (count != [parameters count])
            [NSException raise:@"NSCheckParameterException" format:@"参数错误，需要 %d 个参数， 但传入了 %lu 个参数", count, (unsigned long)[parameters count]];
        
        int rc = 0;
        int inc = 1;
        int index = 0;
        
        for (int i = 0; i < count; ++i) {
            id obj = [parameters objectAtIndex:i];
            index = i + inc;
            if ((!obj) || ([obj isKindOfClass:[NSString class]] && [((NSString*)obj) isEqualToString:@":NULL"]))
                rc = sqlite3_bind_null(stmt, index);
            else if ([obj isKindOfClass:[NSData class]])
                rc = (int)sqlite3_bind_blob(stmt, index, [obj bytes], (int)[obj length], SQLITE_TRANSIENT);
            else if ([obj isKindOfClass:[NSNumber class]]) {
                if (strcmp([obj objCType], @encode(long long)) == 0)
                    rc = sqlite3_bind_int64(stmt, index, [obj longLongValue]);
                else if (strcmp([obj objCType], @encode(int)) == 0)
                    rc = sqlite3_bind_int(stmt, index, [obj intValue]);
                else if (strcmp([obj objCType], @encode(double)) == 0)
                    rc = sqlite3_bind_double(stmt, index, [obj doubleValue]);
                else
                    rc = sqlite3_bind_text(stmt, index, [[obj description] UTF8String], -1, SQLITE_TRANSIENT);
            } else
                rc = sqlite3_bind_text(stmt, index, [[obj description] UTF8String], -1, SQLITE_TRANSIENT);
            
            if (rc != SQLITE_OK)
                [NSException raise:@"" format:@""];
        }
        succeeded = YES;
    } @catch (NSException *exception) {
        [exception raise];
    } @finally {
        return succeeded;
    }
}

@end

@implementation Database

- (dispatch_queue_t)getCurrentQueue {
    return _runningQueue;
}

- (BOOL)open:(NSString *)filePath usingCurrentThread:(BOOL)usingCurrentThread {
    if (filePath != nil && [filePath length] > 0)
        _path = [filePath retain];
    if (usingCurrentThread)
        _runningQueue = dispatch_get_current_queue();
    else {
        _runningQueue = dispatch_queue_create("sqlite3_queue", nil);
    }
    
    __block int rc = 0;
    dispatch_sync(_runningQueue, ^{
        rc = sqlite3_open([filePath UTF8String], (sqlite3**)&_database);
        sqlite3_config(SQLITE_CONFIG_MULTITHREAD);  //开启多线程
        sqlite3_config(SQLITE_CONFIG_MEMSTATUS, 0);  //关闭内存统计
        sqlite3_exec(_database, [@"PRAGMA locking_mode = exclusive;" UTF8String], NULL, NULL, NULL);
        sqlite3_exec(_database, [@"PRAGMA journal_mode = WAL;" UTF8String], NULL, NULL, NULL);
        sqlite3_exec(_database, [@"PRAGMA synchronous = OFF;" UTF8String], NULL, NULL, NULL);
    });
    
    return rc == SQLITE_OK;
}

- (BOOL)close {
    __block int rc = 0;
    dispatch_sync(_runningQueue, ^{
        rc = sqlite3_close(_database);
    });
    return rc == SQLITE_OK;
}

- (void) execCommand:(NSString *) command {
    ADD_LOG(command);
    if (command == nil || [command length] <= 0) {
        NSLog(@"execCommand and sqlName is nil");
    } else {
        @autoreleasepool {
            @try {
                int status = sqlite3_exec(_database, [command UTF8String], NULL, NULL, NULL);
                if (status != SQLITE_OK)
                {
                    NSLog(@"execCommand %@ Result : %d  - [%s]", command, status, sqlite3_errmsg(_database));
                }
            } @catch (NSException *exception) {
                
                //                NSLog(@"executeNonQuery:withParameters: cast an Error! \nSQL:%@\nandObjs:%@\n%@ at %@\n%s",
                //                           sqlName,
                //                           params,
                //                           exception,
                //                           [exception callStackSymbols],
                //                           (_database ? sqlite3_errmsg(_database) : ""));
            } @finally {
            }
        }
    }
}


- (DataReader *)executeReader:(NSString *)sqlName
               withParameters:(NSArray *)params {
    
    ADD_LOG(sqlName);
    
    if (sqlName == nil || [sqlName length] <= 0) {
        NSLog(@"executeReader and sqlName is nil");
        return nil;
    }
    sqlite3_stmt *stmt = nil;
    
    @autoreleasepool {
        @try {
            int ret = sqlite3_prepare_v2(_database, [sqlName UTF8String], -1, &stmt, nil);
            if (ret != SQLITE_OK)
                NSLog(@"%s, ON\n%@\nWith\n%@", (_database ? sqlite3_errmsg(_database) : ""), sqlName, params);
            DatabaseAssert(ret == SQLITE_OK && stmt);
            DatabaseAssert([self setParameters:stmt withParameters:params]);
        } @catch (NSException *exception) {
            NSLog(@"executeReader:withParameters: cast a %s Error! \nSQL:%@\nandObjs:%@\n%@ at %@",
                  (_database ? sqlite3_errmsg(_database) : ""),
                  sqlName,
                  params,
                  exception,
                  [exception callStackSymbols]);
            
            if (stmt)
                sqlite3_finalize(stmt);
            return nil;
        } @finally {
        }
    }
    return [[[DataReader alloc] initWithStmt:stmt withDatabase:self] autorelease];
}


- (DataReader *)executeReader:(NSString *)sqlName, ... {
    sqlite3_stmt *stmt = nil;
    @autoreleasepool {
        @try {
            va_list args;
            va_start(args, sqlName);
            NSString* sql = [[NSString alloc] initWithFormat:sqlName arguments:args];
            va_end(args);
            DatabaseAssert(sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK);
            [sql release];
        } @catch (NSException *exception) {
            return nil;
        } @finally {
        }
    }
    return [[[DataReader alloc] initWithStmt:stmt withDatabase:self] autorelease];
}


- (BOOL) executeBulkInsert:(NSString *)sqlName withParameters:(NSArray*) params {
    ADD_LOG(sqlName);
    BOOL succeeded = NO;
    if (sqlName == nil || [sqlName length] <= 0) {
        NSLog(@"executeNonQuery and sqlName is nil");
    } else {
        @autoreleasepool {
            sqlite3_stmt *stmt = nil;
            @try {
                if (!((sqlite3_prepare_v2(_database, [sqlName UTF8String], -1, &stmt, nil) == SQLITE_OK) && stmt))
                    [NSException raise:@"NSDatabaseException" format:@""];
                for (NSArray *perParams in params) {
                    DatabaseAssert([self setParameters:stmt withParameters:perParams]);
                    DatabaseAssert(sqlite3_step(stmt) == SQLITE_DONE);
                    sqlite3_reset(stmt);
                }
                succeeded = YES;
            } @catch (NSException *exception) {
                NSLog(@"executeNonQuery:withParameters: cast an Error! \nSQL:%@\nandObjs:%@\n%@ at %@\n%s",
                      sqlName,
                      params,
                      exception,
                      [exception callStackSymbols],
                      (_database ? sqlite3_errmsg(_database) : ""));
            } @finally {
                if (stmt) {
                    sqlite3_clear_bindings(stmt);
                    sqlite3_reset(stmt);
                    sqlite3_finalize(stmt);
                }
            }
        }
    }
    return succeeded;
}

- (void)dbCheckpoint {
    sqlite3_wal_checkpoint(_database, NULL);
}

- (BOOL) executeNonQuery:(NSString *)sqlName withParameters:(NSArray*) params {
    ADD_LOG(sqlName);
    BOOL succeeded = NO;
    if (sqlName == nil || [sqlName length] <= 0) {
        NSLog(@"executeNonQuery and sqlName is nil");
    } else {
        @autoreleasepool {
            sqlite3_stmt *stmt = nil;
            @try {
                if (!((sqlite3_prepare_v2(_database, [sqlName UTF8String], -1, &stmt, nil) == SQLITE_OK) && stmt))
                    [NSException raise:@"NSDatabaseException" format:@""];
                DatabaseAssert([self setParameters:stmt withParameters:params]);
                DatabaseAssert(sqlite3_step(stmt) == SQLITE_DONE);
                succeeded = YES;
            } @catch (NSException *exception) {
                NSLog(@"executeNonQuery:withParameters: cast an Error! \nSQL:%@\nandObjs:%@\n%@ at %@\n%s",
                      sqlName,
                      params,
                      exception,
                      [exception callStackSymbols],
                      (_database ? sqlite3_errmsg(_database) : ""));
            } @finally {
                if (stmt) {
                    sqlite3_clear_bindings(stmt);
                    sqlite3_reset(stmt);
                    sqlite3_finalize(stmt);
                }
            }
        }
    }
    return succeeded;
}

- (BOOL) checkExistsOnTable:(NSString*) tableName withColumn:(NSString *) columnName {
    BOOL isExists = NO;
    if (tableName && columnName) {
        sqlite3_stmt *stmt = nil;
        @autoreleasepool {
            @try {
                NSString *sql = [NSString stringWithFormat:@"select %@ from %@;", columnName, tableName];
                if(sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK)
                    isExists = YES;
            } @catch (NSException *exception) {
            } @finally {
                if (stmt) {
                    sqlite3_clear_bindings(stmt);
                    sqlite3_reset(stmt);
                    sqlite3_finalize(stmt);
                }
            }
        }
    }
    return isExists;
}

//-(BOOL)checkColumnExists
//{
//    BOOL columnExists = NO;
//
//    sqlite3_stmt *selectStmt;
//
//    const char *sqlStatement = "select yourcolumnname from yourtable";
//    if(sqlite3_prepare_v2(yourDbHandle, sqlStatement, -1, &selectStmt, NULL) == SQLITE_OK)
//        columnExists = YES;
//
//    return columnExists;
//}


- (void) asyncExecuteNonQuery:(NSString *) sql
               withParameters:(NSArray*) parameters
                   onFinished:(void(^)(BOOL)) callback {
    if (_database == nil) {
        if (callback)
            callback(NO);
        return;
    }
    
    void (^myCallback)(BOOL)        = [callback copy];
    __block NSString *sqlName       = [sql retain];
    __block NSArray *params         = [parameters retain];
    dispatch_queue_t current_thread = dispatch_get_current_queue();
    
    @autoreleasepool {
        dispatch_async(_runningQueue, ^{
            BOOL succeeded = [self executeNonQuery:sqlName withParameters:params];
            dispatch_async(current_thread, ^{
                if (myCallback)
                    myCallback(succeeded);
                [myCallback release];
            });
            [sqlName release];
            [params release];
        });
    }
}

- (void) asyncExecuteReader:(NSString*) sql
             withParameters:(NSArray *) parameters
                  withBlock:(void(^)(DataReader*)) callback {
    
    if (callback == nil)
        return;
    
    if (_database == nil) {
        callback(nil);
        return;
    }
    
    void(^myCallback)(DataReader*)  = [callback copy];
    __block NSString *sqlName       = [sql retain];
    __block NSArray *params         = [parameters retain];
    dispatch_queue_t current_thread = dispatch_get_current_queue();
    
    dispatch_async(_runningQueue, ^{
        @autoreleasepool {
            @try {
                sqlite3_stmt *stmt = nil;
                int ret = sqlite3_prepare_v2(_database, [sqlName UTF8String], -1, &stmt, nil);
                DatabaseAssert(ret == SQLITE_OK && stmt);
                DatabaseAssert([self setParameters:stmt withParameters:params]);
                dispatch_async(current_thread, ^{
                    myCallback([[[DataReader alloc] initWithStmt:stmt withDatabase:self] autorelease]);
                });
            } @catch (NSException *exception) {
                if (myCallback) {
                    dispatch_async(current_thread, ^{
                        //
                        // 线程切换，所有这里的代码都有可能发生问题。先这样。回头再改。
                        myCallback(nil);
                    });
                }
            } @finally {
                [myCallback release];
                [sqlName release];
                [params release];
            }
        }
    });
}

- (void) databaseCheckpoint {
    // Cause a checkpoint to occur, merge `sqlite-wal` file to `sqlite` file.
    sqlite3_wal_checkpoint(_database, NULL);
}

@end

#pragma mark - DatabaseOperator private

@interface DatabaseOperator (privateMethod)

- (Database *) database;

@end

@implementation DatabaseOperator (privateMethod)

- (Database *)database {
    return _database;
}

@end

#pragma mark - DatabaseOperator

@implementation DatabaseOperator

- (id)initWithDatabase:(Database *)database
{
    self = [super init];
    if (self) {
        _database = [database retain];
    }
    return self;
}

- (void)dealloc
{
    [_database release];
    _database = nil;
    [super dealloc];
}


- (void) usingTransaction:(DatabaseFunction) transaction {
    NSAssert(dispatch_get_current_queue() != [_database getCurrentQueue],@"");
    
    if (transaction) {
        DatabaseFunction privateCallback  = [transaction copy];
        dispatch_async([_database getCurrentQueue], ^{
            BOOL succeeded = NO;
            sqlite3_exec([_database dbInstance], "begin transaction", NULL, NULL, NULL);
            @try {
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                privateCallback(_database);
                [pool release];
                succeeded = YES;
            } @catch (NSException *exception) {
                NSLog(@"syncUsingTransaction cast a Error! %@ at %@", exception, [exception callStackSymbols]);
            } @finally {
                if (succeeded)
                    sqlite3_exec([_database dbInstance], "commit transaction", NULL, NULL, NULL);
                else
                    sqlite3_exec([_database dbInstance], "rollback transaction", NULL, NULL, NULL);
                [privateCallback release];
            }
        });
    }
}

- (void) syncUsingTransaction:(DatabaseFunction) transaction {
    NSAssert(dispatch_get_current_queue() != [_database getCurrentQueue],@"SyncUsingTransaction Queue Error");
    //    if (dispatch_get_current_queue() == dispatch_get_main_queue()) {
    //        NSLog(@"now in main_queue");
    //    }
    if (transaction) {
        DatabaseFunction privateCallback  = [transaction copy];
        dispatch_sync([_database getCurrentQueue], ^{
            sqlite3_exec([_database dbInstance], "begin transaction", NULL, NULL, NULL);
            @try {
                @autoreleasepool {
                    privateCallback(_database);
                }
            } @catch (NSException *exception) {
                NSLog(@"syncUsingTransaction cast a Error! %@ at %@", exception, [exception callStackSymbols]);
            } @finally {
                sqlite3_exec([_database dbInstance], "commit transaction", NULL, NULL, NULL);
                [privateCallback release];
            }
        });
    }
}

- (void) usingTransaction:(DatabaseFunction)transaction
             withComplate:(dispatch_block_t) end {
    NSAssert(dispatch_get_current_queue() != [_database getCurrentQueue],@"");
    
    if (transaction && end) {
        dispatch_queue_t currentQueue       = dispatch_get_main_queue();
        DatabaseFunction privateCallback    = [transaction copy];
        dispatch_block_t privateEnd         = [end copy];
        
        dispatch_async([_database getCurrentQueue], ^{
            sqlite3_exec([_database dbInstance], "begin transaction", NULL, NULL, NULL);
            @try {
                @autoreleasepool {
                    privateCallback(_database);
                }
            }
            @catch (NSException *exception) {
                NSLog(@"usingTransaction:withComplate: cast a Error! %@ at %@", exception, [exception callStackSymbols]);
            }
            @finally {
                sqlite3_exec([_database dbInstance], "commit transaction", NULL, NULL, NULL);
                [privateCallback release];
            }
            
            dispatch_async(currentQueue, ^{
                @try {
                    privateEnd();
                }
                @catch (NSException *exception) {
                    NSLog(exception, @"usingTransaction:withComplate catch a error!");
                }
                @finally {
                    [privateEnd release];
                }
            });
        });
    }
}

- (void) beginWithoutTransaction:(DatabaseFunction) func
                    withComplate:(dispatch_block_t) func2 {
    NSAssert(dispatch_get_current_queue() != [_database getCurrentQueue],@"beginWithoutTransaction Queue Error");
    if (func && func2) {
        dispatch_queue_t currentQueue       = dispatch_get_current_queue();
        DatabaseFunction privateCallback    = [func copy];
        dispatch_block_t privateEnd         = [func2 copy];
        
        dispatch_async([_database getCurrentQueue], ^{
            @try {
                @autoreleasepool {
                    privateCallback(_database);
                }
            }
            @catch (NSException *exception) {
                NSLog(@"usingTransaction:withComplate: cast a Error! %@ at %@", exception, [exception callStackSymbols]);
            }
            @finally {
                // mark by liudan(@"commit transaction");
                [privateCallback release];
            }
            
            dispatch_async(currentQueue, ^{
                @try {
                    privateEnd();
                }
                @catch (NSException *exception) {
                    NSLog(exception, @"usingTransaction:withComplate catch a error!");
                }
                @finally {
                    [privateEnd release];
                }
            });
        });
    }
}
- (void) syncWithoutTransaction:(DatabaseFunction) func {
    NSAssert(dispatch_get_current_queue() != [_database getCurrentQueue],@"syncWithoutTransaction");
    if (func) {
        DatabaseFunction privateCallback = [func copy];
        dispatch_sync([_database getCurrentQueue], ^{
            @try {
                privateCallback(_database);
            } @catch (NSException *exception) {
                NSLog(@"syncWithoutTransaction cast a Error! %@ at %@", exception, [exception callStackSymbols]);
            } @finally {
                [privateCallback release];
            }
        });
    }
}


@end

#pragma mark - DatabaseManager support multiInstance.

@interface DatabaseManager (PrivateMethod)

- (id)init;

- (void)dealloc;

-(DatabaseOperator *) GetInstanceByFilename:(NSString *) filePath;
-(BOOL) OpenByFullPath:(NSString *) dbFilePath;

@end

@implementation DatabaseManager (PrivateMethod)

- (id)init
{
    self = [super init];
    if (self) {
        _databaseMapping = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}

- (void)dealloc
{
    [_databaseMapping removeAllObjects];
    [_databaseMapping release];
    [super dealloc];
}

- (DatabaseOperator *)GetInstanceByFilename:(NSString *)filePath {
    return _databaseMapping ? [_databaseMapping objectForKey:filePath] : nil;
}

- (BOOL)OpenByFullPath:(NSString *)dbFilePath {
    if ([[_databaseMapping allKeys] containsObject:dbFilePath])
        return YES;
    
    BOOL opened = NO;
    Database *db = [[Database alloc] init];
    DatabaseOperator *database = [[DatabaseOperator alloc] initWithDatabase:db];
    if ([db open:dbFilePath usingCurrentThread:NO]) {
        [_databaseMapping setObject:database forKey:dbFilePath];
        opened = YES;
    } else {
        NSLog(@"Failed to open database: %s", sqlite3_errmsg(database));
    }
    
    NSLog(@"sqlite3_libversion : %s", sqlite3_libversion());
    NSLog(@"sqlite3_threadsafe : %d", sqlite3_threadsafe());
    
    [db release];
    [database release];
    return opened;
}

- (BOOL)CloseByFullPath:(NSString *)dbFilePath{
    if ([[_databaseMapping allKeys] containsObject:dbFilePath]) {
        DatabaseOperator *db = [_databaseMapping objectForKey:dbFilePath];
        BOOL ret = [[db database] close];
        [_databaseMapping removeObjectForKey:dbFilePath];
        return ret;
    }
    return YES;
}

@end

@implementation DatabaseManager

SINGLETON_INST(DatabaseManager);

+ (BOOL)OpenByFullPath:(NSString *)dbFilePath {
    return [[DatabaseManager sharedInstance] OpenByFullPath:dbFilePath];
}

+ (DatabaseOperator *)GetInstance:(NSString *)filePath {
    return [[DatabaseManager sharedInstance] GetInstanceByFilename:filePath];
}

+(BOOL)CloseByFullPath:(NSString *)dbFilePath{
    return [[DatabaseManager sharedInstance] CloseByFullPath:dbFilePath];
}

@end
