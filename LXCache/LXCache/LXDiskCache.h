//
//  LXDiskCache.h
//  LXCache
//
//  Created by 麻小亮 on 2019/2/14.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXSqlite.h"
NS_ASSUME_NONNULL_BEGIN

@interface LXDiskCache : NSObject

- (instancetype)initWithSqlite:(LXSqlite *)sqlite;

@property (nonatomic, copy) void (^lock) (void);

@property (nonatomic, copy) void (^unlock) (void);

@end

NS_ASSUME_NONNULL_END
