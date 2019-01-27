//
//  LXSqlite.m
//  LXCache
//
//  Created by 麻小亮 on 2018/12/11.
//  Copyright © 2018 xllpp. All rights reserved.
//

#import "LXSqlite.h"
#import <sqlite3.h>



@interface LXSqlite (){
    sqlite3 *_db;
    NSString *_path;
    dispatch_semaphore_t _lock;
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

- (void)lock{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unlock{
    dispatch_semaphore_signal(_lock);
}


@end
