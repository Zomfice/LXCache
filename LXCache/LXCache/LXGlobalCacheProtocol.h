//
//  LXCacheMehodProtocol.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/16.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXKeyCacheProtocol.h"
NS_ASSUME_NONNULL_BEGIN

/**
 全局查询协议
 */
@protocol LXGlobalCacheProtocol <NSObject>

/**
 同步查询整个数据库缓存,传入查询匹配结果状态

 @param key 键值
 @param block 回调
 */
- (void)containSynObjectsForKey:(NSString *)key
                   withBlock:(void (^ ) (NSArray <id <LXKeyCacheProtocol>> *objects))block,...;
/**
 异步查询整个数据库缓存,传入查询匹配结果状态
 
 @param key 键值
 @param block 回调
 */
- (void)containAsynObjectsForKey:(NSString *)key
                       withBlock:(void (^ ) (NSArray <id <LXKeyCacheProtocol>> *objects))block,...;



@end

NS_ASSUME_NONNULL_END
