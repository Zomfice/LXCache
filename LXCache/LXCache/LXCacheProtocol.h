//
//  LXCacheProtocol.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/17.
//  Copyright © 2019 xllpp. All rights reserved.
//
#import "LXCacheDefine.h"

#pragma mark - LXCacheSeparateDelegate -


@protocol LXCacheSeparateDelegate <NSObject>


@end


#pragma mark - LXCacheObtainProtocol -
/**
 是否包含筛选条件
 */


@protocol LXCacheObtainProtocol <NSObject>

@property (nonatomic, assign) LXCacheResultStatus resultStatus;

@property (nonatomic, assign) NSTimeInterval memoryTime;

@property (nonatomic, assign) NSTimeInterval diskTime;

@end


#pragma mark - LXCacheKeyProtocol -


@protocol LXCacheKeyProtocol <NSObject>

@property (nonatomic, assign) LXCacheType cacheType;

@property (nonatomic, assign) NSTimeInterval memoryTime;

@property (nonatomic, assign) NSTimeInterval diskTime;

@property (nonatomic, assign) LXCacheResultStatus cacheStatus;

@property (nonatomic, assign) BOOL isClearWhenTimeOut;

@property (nonatomic, copy) NSString * key;

@property (nonatomic, copy) NSString * identify;

@property (nonatomic, assign) NSTimeInterval saveTime;

@end

#pragma mark - LXCacheProtocol -
@protocol LXCacheProtocol <NSObject>
/**
 清除表
 */
- (BOOL)removeSeparaAllCache;

/**
 异步清除缓存
 
 @param block 回调
 */
- (void)removeSeparaAllCacheWithBlock:(void (^) (BOOL success))block;

@end

#pragma mark - LXCacheSeparateProtocol  -


typedef void(^ moreSetInfo)(id <LXCacheKeyProtocol> info);
typedef void(^ moreObtainInfo)(id <LXCacheObtainProtocol> info);

@protocol LXCacheSeparateProtocol <LXCacheProtocol>

@optional

@property (nonatomic, weak) id <LXCacheSeparateDelegate> delegate;

- (id <LXCacheSeparateProtocol>) separateCache;




/**
 同步判断否包含存储对象
 
 @param key 键值
 */

- (BOOL)containsObjectForKey:(NSString *)key;

- (BOOL)containsObjectForKey:(NSString *)key moreInfo:(moreObtainInfo)info;

/**
 同步判断否包含存储对象  ... : 传入查询状态，LXCacheResultStatus
 
 @param key 键值
 @param block block回调
 */
- (void)containsSynObjectForKey:(NSString *)key
                      withBlock:(void (^) (BOOL contains, id <LXCacheKeyProtocol> info))block;

/**
 异步判断否包含存储对象  ... : 传入查询状态，LXCacheResultStatus
 
 @param key 键值
 @param block block回调
 */
- (void)containsAsynObjectDetailForKey:(NSString *)key
                             withBlock:(void (^) (BOOL contains, id <LXCacheKeyProtocol> info))block;

/**
 同步获取存储对象  ... : 传入查询状态，LXCacheResultStatus
 
 @param key 键值
 @return 存储对象
 
 */
- (id <NSCoding>)objectForKey:(NSString *)key;

- (id <NSCoding>)objectForKey:(NSString *)key moreInfo:(moreObtainInfo)moreInfo;

- (void)objectSynForKey:(NSString *)key
              withBlock:(void (^) (NSString *key, id <NSCoding>object, id <LXCacheKeyProtocol> info))block;


- (void)objectAsynForKey:(NSString *)key
               withBlock:(void (^) (NSString *key, id <NSCoding>object, id <LXCacheKeyProtocol> info))block;
/**
 缓存设置，设置完key后可设置：...:分别传入缓存类型、内存缓存时间、磁盘缓存时间、是否过期清空
 
 @param object 存储对象
 @param key 键值
 
 */
- (BOOL)setObject:(id <NSCoding>)object forKey:(NSString *)key;

- (BOOL)setObject:(id <NSCoding>)object forKey:(NSString *)key moreInfo:(moreSetInfo)info;

/**
 异步缓存  ... : 传入查询状态，LXCacheResultStatus
 
 @param object 存储对象
 @param key 键值
 @param block 回调
 */
- (void)setObject:(id <NSCoding>)object
           forKey:(NSString *)key
        withBlock:(void (^) (NSString *key, id <NSCoding>object, BOOL isSuccess))block;

- (void)setObject:(id <NSCoding>)object
         moreInfo:(moreSetInfo)info
           forKey:(NSString *)key
        withBlock:(void (^) (NSString *key, id <NSCoding>object, BOOL isSuccess))block;


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
 */
- (void)setDefaultMemoryTime:(NSTimeInterval)memoryTime
                    diskTime:(NSTimeInterval)diskTime
          isClearWhenTimeOut:(BOOL)isClearWhenTimeOut;

/**
 多长时间未使用后删除
 @param diskTime 磁盘缓存时间
 */
- (void)setUseDiskTime:(NSTimeInterval)diskTime
            memoryTime:(NSTimeInterval)memroyTime;

/**
 缓存大小
 */
- (CGFloat)cacheSize;


@end

#pragma mark - LXGlobalCacheProtocol -


/**
 全局查询协议
 */
@protocol LXGlobalCacheProtocol <NSObject>
@optional
/**
 同步查询整个数据库缓存,传入查询匹配结果状态
 
 @param key 键值
 @param block 回调
 */
- (void)containSynObjectsForKey:(NSString *)key
                      withBlock:(void (^ ) (NSArray <id <LXCacheKeyProtocol>> *objects))block;
/**
 异步查询整个数据库缓存,传入查询匹配结果状态
 
 @param key 键值
 @param block 回调
 */
- (void)containAsynObjectsForKey:(NSString *)key
                       withBlock:(void (^ ) (NSArray <id <LXCacheKeyProtocol>> *objects))block;

@end
