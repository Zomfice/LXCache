//
//  LXSeparateCache.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/27.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class LXSqlite;
@protocol LXCacheSeparateDelegate;
@interface LXSeparateCache : NSObject
- (instancetype)initWithIdentity:(NSString *)identity sqlite:(LXSqlite *)sqlite;
@property (nonatomic, weak) id <LXCacheSeparateDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
