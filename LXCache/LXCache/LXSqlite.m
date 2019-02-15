//
//  LXSqlite.m
//  LXCache
//
//  Created by 麻小亮 on 2018/12/11.
//  Copyright © 2018 xllpp. All rights reserved.
//

#import "LXSqlite.h"
#import <time.h>
#import <UIKit/UIKit.h>
#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif


static const NSUInteger kMaxErrorRetryCount = 8;
static const NSTimeInterval kMinRetryTimeInterval = 2.0;
static const int kPathLengthMax = PATH_MAX - 64;

static NSString *const kDBFileName = @"manifest.sqlite";
static NSString *const kDBShmFileName = @"manifest.sqlite-shm";
static NSString *const kDBWalFileName = @"manifest.sqlite-wal";
static NSString *const kDataDirectoryName = @"data";
static NSString *const kTrashDirectoryName = @"trash";


@interface LXSqlite (){
    sqlite3 *_db;
    NSString *_path;
    NSString *_dataPath;
    NSString *_trashPath;
    
    dispatch_semaphore_t _lock;
    CFMutableDictionaryRef _dbStmtCache;
    NSTimeInterval _dbLastOpenErrorTime;
    NSUInteger _dbOpenErrorCount;
    
    dispatch_queue_t _trashQueue;
}

@end

@implementation LXSqlite
- (instancetype)initWithPath:(NSString *)path{
    if (self = [super init]) {
        _path = path;
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

/**
 打开数据库
 */
- (BOOL)open{
    if (_db) return YES;
    if (sqlite3_open(_path.UTF8String, &_db)) {
        CFDictionaryKeyCallBacks keyCallBacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallBacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallBacks, &valueCallBacks);
        _dbLastOpenErrorTime = 0;
        _dbOpenErrorCount = 0;
        return YES;
    }else{
        _db = NULL;
        if (_dbStmtCache)CFRelease(_dbStmtCache);
        _dbStmtCache = NULL;
        _dbLastOpenErrorTime = CACurrentMediaTime();
        _dbOpenErrorCount ++;
        
        return NO;
    }
}

/**
 关闭数据库
 */
- (BOOL)dbClose{
    if (!_db) return YES;
    int result = 0;
    BOOL retry = NO;
    BOOL stmtFinalized = NO;
    
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
    
    do {
        retry = NO;
        result = sqlite3_close_v2(_db);
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                stmtFinalized = YES;
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, nil)) != 0) {
                    sqlite3_finalize(stmt);
                    retry = YES;
                }
            }
        }
    } while (retry);
    _db = NULL;
    return YES;
}


/**
 如果重启次数失败太多次或者尝试的时间过长，则返回nil

 */
- (BOOL)dbCheck{
    if (!_db) {
        if (_dbOpenErrorCount < kMaxErrorRetryCount &&
            CACurrentMediaTime() - _dbLastOpenErrorTime > kMinRetryTimeInterval) {
            return [self open] && [self initialized];
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)initialized{
    NSString *sql = @"";
    
    return NO;
}


- (BOOL)dbExecute:(NSString *)sql{
    return NO;
}

- (void)lock{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unlock{
    dispatch_semaphore_signal(_lock);
}


@end
