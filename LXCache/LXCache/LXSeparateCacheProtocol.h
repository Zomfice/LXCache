//
//  LXSeparateCacheProtocol.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/14.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LXCacheType) {
    LXCacheDisk = 1,
    RHCacheMemory
};

typedef NS_OPTIONS(NSUInteger, LXCacheResultStatus) {
    LXCacheResultNever         = 0,
    LXCacheResultNormarl       = 1 << 0,
    LXCacheResultMemoryTimeOut = 1 << 1,
    LXCacheResultDiskTimeOut   = 1 << 2,
    LXCacheResultAll           = ~0UL
};

typedef NS_ENUM(NSUInteger, LXCachePosition) {
    LXDataNonContain = 0,
    LXDataMemoryContain,
    LXDataDiskContain
};

@protocol LXSeparateCacheProtocol <NSObject>


/**
 清除表
 */
- (void)removeSeparaAllCache;

/**
 异步清除缓存

 @param block 回调
 */
- (void)removeSeparaAllCacheWithBlock:(void (^) (BOOL success))block;
/**
 同步判断否包含存储对象
 
 @param key 键值
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 
 异步判断否包含存储对象

 @param key 键值
 @param block block回调
 */
- (void)containsObjectForKey:(NSString *)key
                   withBlock:(void (^) (NSString *key, BOOL contains))block;

/**
 同步获取存储对象

 @param key 键值
 @return 存储对象
 */
- (id <NSCoding>)objectForKey:(NSString *)key;

/**
 异步获取存储对象

 @param key 键值
 @param block 回调
 */
- (void)objectForKey:(NSString *)key
           withBlock:(void (^) (NSString *key, id <NSCoding>object))block;

/**
 
 
 @param object 存储对象
 @param key 键值
 */
- (BOOL)setObject:(id <NSCoding>)object forKey:(NSString *)key;

/**
 异步缓存

 @param object 存储对象
 @param key 键值
 @param block 回调
 */
- (void)setObject:(id <NSCoding>)object
           forKey:(NSString *)key
        withBlock:(void (^) (NSString *key, id <NSCoding>object, BOOL isSuccess))block;

/**
 设置缓存模式

 @param memoryTime 内存缓存时间
 @param disTime 磁盘缓存时间
 @param isClearWhenTimeOut 是否过期清除
 */
- (void)setMemoryTime:(NSTimeInterval)memoryTime
             diskTime:(NSTimeInterval)disTime
   isClearWhenTimeOut:(BOOL)isClearWhenTimeOut;



/**
 缓存大小
 */
- (CGFloat)totalSize;

@end

NS_ASSUME_NONNULL_END
