//
//  LXSeparateCacheProtocol.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/14.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import "LXCacheDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LXSeparateCacheProtocol <NSObject>

@property (nonatomic, copy, readonly) id <LXSeparateCacheProtocol> (^ cacheType)(LXCacheType cacheType);
@property (nonatomic, copy, readonly) id <LXSeparateCacheProtocol> (^ memoryTime)(NSTimeInterval memoryTime);
@property (nonatomic, copy, readonly) id <LXSeparateCacheProtocol> (^ diskTime)(NSTimeInterval diskTime);
@property (nonatomic, copy, readonly) id <LXSeparateCacheProtocol> (^ isClearWhenTimeOut)(BOOL isClearWhenTimeOut);

@property (nonatomic, strong, readonly) id <LXSeparateCacheProtocol> separateCache;

/**
 清除表
 */
- (BOOL)removeSeparaAllCache;

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
 设置分区存储数据默认时间

 @param memoryTime 内存缓存时间
 @param disTime 磁盘缓存时间
 @param isClearWhenTimeOut 是否过期清除
 */
- (void)setDefaultMemoryTime:(NSTimeInterval)memoryTime
             diskTime:(NSTimeInterval)disTime
   isClearWhenTimeOut:(BOOL)isClearWhenTimeOut;


/**
 设置缓存实例默认缓存时间属性

 @param memoryTime 内存缓存时间
 @param disTime 磁盘缓存时间
 @param isClearWhenTimeOut 是否过期清除
 */
- (void)setClearMemoryTime:(NSTimeInterval)memoryTime
                    diskTime:(NSTimeInterval)disTime
          isClearWhenTimeOut:(BOOL)isClearWhenTimeOut;
/**
 缓存大小
 */
- (CGFloat)cacheSize;


@end

NS_ASSUME_NONNULL_END
