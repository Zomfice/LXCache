//
//  LXCacheProtocol.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/17.
//  Copyright © 2019 xllpp. All rights reserved.
//
#import "LXCacheDefine.h"
#import "EXTConcreteProtocol.h"
#import "LXConcreteProtocol.h"
//#import "EXTConcreteProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@protocol LXSeparateCacheDelegate <NSObject>


@end

@protocol LXKeyCacheProtocol <NSObject>

@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * identify;

@end
#pragma mark - LXSeparateCacheProtocol  -
@protocol LXSeparateCacheProtocol <NSObject>

@optional

@property (nonatomic, weak) id <LXSeparateCacheDelegate> delegate;

- (id <LXSeparateCacheProtocol>) separateCache;

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

- (BOOL)containsObjectForKey:(NSString *)key,...;

/**
 
 异步判断否包含存储对象  ... : 传入查询状态，LXCacheResultStatus
 
 @param key 键值
 @param block block回调
 */
- (void)containsObjectForKey:(NSString *)key
                   withBlock:(void (^) (NSString *key, BOOL contains))block,...;

/**
 同步判断否包含存储对象  ... : 传入查询状态，LXCacheResultStatus
 
 @param key 键值
 @param block block回调
 */
- (void)containsSynObjectForKey:(NSString *)key
                      withBlock:(void (^) (BOOL contains, id <LXKeyCacheProtocol> info))block,...;

/**
 异步判断否包含存储对象  ... : 传入查询状态，LXCacheResultStatus
 
 @param key 键值
 @param block block回调
 */
- (void)containsAsynObjectDetailForKey:(NSString *)key
                             withBlock:(void (^) (BOOL contains, id <LXKeyCacheProtocol> info))block,...;

/**
 同步获取存储对象  ... : 传入查询状态，LXCacheResultStatus
 
 @param key 键值
 @return 存储对象
 
 */
- (id <NSCoding>)objectForKey:(NSString *)key,...;

- (void)objectSynForKey:(NSString *)key
              withBlock:(void (^) (NSString *key, id <NSCoding>object, id <LXKeyCacheProtocol> info))block, ...;
/**
 异步获取存储对象 ... : 传入查询状态，LXCacheResultStatus
 
 @param key 键值
 @param block 回调
 */
- (void)objectForKey:(NSString *)key
           withBlock:(void (^) (NSString *key, id <NSCoding>object))block,...;


- (void)objectAsynForKey:(NSString *)key
               withBlock:(void (^) (NSString *key, id <NSCoding>object, id <LXKeyCacheProtocol> info))block,...;
/**
 缓存设置，设置完key后可设置：...:分别传入缓存类型、内存缓存时间、磁盘缓存时间、是否过期清空
 
 @param object 存储对象
 @param key 键值
 
 */
- (BOOL)setObject:(id <NSCoding>)object forKey:(NSString *)key, ...;

/**
 异步缓存  ... : 传入查询状态，LXCacheResultStatus
 
 @param object 存储对象
 @param key 键值
 @param block 回调
 */
- (void)setObject:(id <NSCoding>)object
           forKey:(NSString *)key
        withBlock:(void (^) (NSString *key, id <NSCoding>object, BOOL isSuccess))block,...;


/**
 移除key
 */
- (BOOL)removeObjectForKey:(NSString *)key;

/**
 异步移除key
 
 @param key 键值
 @param block 回调
 */
- (void)removeObjectForKey:(NSString *)key
                 withBlock:(void (^) (NSString *key, id <NSCoding> object))block;

/**
 设置分区存储数据默认时间
 
 @param memoryTime 内存缓存时间
 @param diskTime 磁盘缓存时间
 @param isClearWhenTimeOut 是否过期清除
 */
- (void)setDefaultMemoryTime:(NSTimeInterval)memoryTime
                    diskTime:(NSTimeInterval)diskTime
          isClearWhenTimeOut:(BOOL)isClearWhenTimeOut;


/**
 设置缓存实例默认缓存时间属性
 
 @param memoryTime 内存缓存时间
 @param diskTime 磁盘缓存时间
 @param isClearWhenTimeOut 是否过期清除
 */
- (void)setSaveMemoryTime:(NSTimeInterval)memoryTime
                 diskTime:(NSTimeInterval)diskTime
       isClearWhenTimeOut:(BOOL)isClearWhenTimeOut;
/**
 缓存大小
 */
- (CGFloat)cacheSize;


@end
@interface LXCacheProtocol : NSObject

@end

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


@protocol LXaaSeparateCacheProtocol <NSObject>

- (void)aa;

- (void)asdfasdfasdfasdfasdf;

- (void)asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf;
@end
NS_ASSUME_NONNULL_END
