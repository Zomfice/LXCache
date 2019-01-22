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
}

@end
@implementation LXSqlite
- (instancetype)initWithPath:(NSString *)path{
    return [self init];
}

- (BOOL)open{
    return YES;
}
@end
